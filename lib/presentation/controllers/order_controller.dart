import 'package:door_to_door_service/core/utils/loading_util.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/address_model.dart';
import '../../data/models/service_item.dart';
import '../../data/repositories/order_repository.dart';
import '../../routes/route_names.dart';

/// 下单控制器
class OrderController extends GetxController {
  final String _tag = 'OrderController';
  final OrderRepository _orderRepository = OrderRepository();

  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  final RxBool _isSubmitting = false.obs;
  final Rxn<ServiceItem> _service = Rxn<ServiceItem>();
  final Rxn<AddressModel> _selectedAddress = Rxn<AddressModel>();
  final RxString _selectedDate = ''.obs;
  final RxString _selectedTime = ''.obs;
  final RxInt _selectedDurationMinutes = 60.obs;

  bool get isSubmitting => _isSubmitting.value;
  ServiceItem? get service => _service.value;
  AddressModel? get selectedAddress => _selectedAddress.value;
  String get selectedDate => _selectedDate.value;
  String get selectedTime => _selectedTime.value;
  int get selectedDurationMinutes => _selectedDurationMinutes.value;

  /// 当前所选时长的价格
  double get selectedPrice {
    final s = _service.value;
    if (s == null) return 0;
    if (s.prices != null && s.prices!.isNotEmpty) {
      for (final p in s.prices!) {
        if ((p['durationMinutes'] as int?) == _selectedDurationMinutes.value) {
          return (p['price'] as num?)?.toDouble() ?? s.price;
        }
      }
    }
    return s.price;
  }

  String get serviceTimeText {
    if (_selectedDate.value.isEmpty) return '请选择服务时间';
    return '${_selectedDate.value} ${_selectedTime.value.isNotEmpty ? _selectedTime.value : ''}';
  }

  /// 总价 = 所选时长的价格 + 交通费
  double get totalPrice {
    if (_service.value == null) return 0;
    return selectedPrice + (_service.value!.travelFee ?? 0);
  }

  /// 可选的时长列表
  List<Map<String, dynamic>> get availableDurations {
    final s = _service.value;
    if (s?.prices != null && s!.prices!.isNotEmpty) {
      return s.prices!;
    }
    return [{'durationMinutes': 60, 'price': s?.price ?? 0}];
  }

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
  }

  @override
  void onClose() {
    contactNameController.dispose();
    contactPhoneController.dispose();
    remarkController.dispose();
    super.onClose();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args is ServiceItem) {
      _service.value = args;
      _initDefaultDuration();
    } else if (args is Map<String, dynamic>) {
      if (args['service'] is ServiceItem) {
        _service.value = args['service'] as ServiceItem;
        _initDefaultDuration();
      }
      if (args['address'] is AddressModel) {
        _selectedAddress.value = args['address'] as AddressModel;
        _fillAddressInfo(args['address'] as AddressModel);
      }
    }
  }

  void _initDefaultDuration() {
    final s = _service.value;
    if (s?.prices != null && s!.prices!.isNotEmpty) {
      _selectedDurationMinutes.value =
          (s.prices!.first['durationMinutes'] as int?) ?? 60;
    }
  }

  /// 选择服务时长
  void selectDuration(int minutes) {
    _selectedDurationMinutes.value = minutes;
  }

  /// 选择日期
  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      _selectedDate.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  /// 选择时间
  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      _selectedTime.value =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 跳转选择地址
  Future<void> selectAddress() async {
    final result = await Get.toNamed(RouteNames.addressSelect);
    if (result is AddressModel) {
      _selectedAddress.value = result;
      _fillAddressInfo(result);
    }
  }

  /// 从地址模型填充联系人信息
  void _fillAddressInfo(AddressModel address) {
    if (address.contactName != null && address.contactName!.isNotEmpty) {
      contactNameController.text = address.contactName!;
    }
    if (address.contactPhone != null && address.contactPhone!.isNotEmpty) {
      contactPhoneController.text = address.contactPhone!;
    }
  }

  /// 构建 ISO8601 格式开始时间（北京时间 UTC+8）
  String _buildStartTime() {
    final date = _selectedDate.value; // "2026-05-11"
    final time = _selectedTime.value; // "09:00"
    return '${date}T${time}:00+08:00';
  }

  /// 验证并提交订单
  Future<void> submit() async {
    if (_selectedAddress.value == null) {
      ToastUtil.showError('请选择服务地址');
      return;
    }
    if (contactNameController.text.trim().isEmpty) {
      ToastUtil.showError('请输入联系人姓名');
      return;
    }
    if (contactPhoneController.text.trim().isEmpty) {
      ToastUtil.showError('请输入联系电话');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(contactPhoneController.text.trim())) {
      ToastUtil.showError('请输入正确的手机号码');
      return;
    }
    if (_selectedDate.value.isEmpty) {
      ToastUtil.showError('请选择服务日期');
      return;
    }
    if (_selectedTime.value.isEmpty) {
      ToastUtil.showError('请选择服务时间');
      return;
    }

    _isSubmitting.value = true;
    LoadingUtil.show();
    try {
      final response = await _orderRepository.createOrder(
        serviceId: _service.value!.id,
        durationMinutes: _selectedDurationMinutes.value,
        startTime: _buildStartTime(),
        addressName: _selectedAddress.value!.name,
        latitude: _selectedAddress.value!.latitude,
        longitude: _selectedAddress.value!.longitude,
        contactName: contactNameController.text.trim(),
        contactPhone: contactPhoneController.text.trim(),
        remark: remarkController.text.trim().isNotEmpty
            ? remarkController.text.trim()
            : null,
      );
      if (response.isSuccess) {
        final data = response.data;
        final orderId = data is Map ? (data['orderId'] as int?) : null;
        final orderNo =
            data is Map ? (data['orderNo'] as String?) : null;
        Get.back();
        if (orderId != null && orderNo != null) {
          Get.toNamed(
            RouteNames.orderPayment,
            arguments: {
              'orderId': orderId,
              'orderNo': orderNo,
              'amount': totalPrice,
              'serviceName': _service.value?.name ?? '',
              'durationMinutes': _selectedDurationMinutes.value,
            },
          );
        }
        ToastUtil.showSuccess('下单成功');
      }
    } catch (e) {
      LogUtil.e('下单失败: $e', tag: _tag);
      ToastUtil.showError('$e');
    } finally {
      _isSubmitting.value = false;
      LoadingUtil.dismiss();
    }
  }
}
