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

  bool get isSubmitting => _isSubmitting.value;
  ServiceItem? get service => _service.value;
  AddressModel? get selectedAddress => _selectedAddress.value;
  String get selectedDate => _selectedDate.value;
  String get selectedTime => _selectedTime.value;
  String get serviceTimeText {
    if (_selectedDate.value.isEmpty) return '请选择服务时间';
    return '${_selectedDate.value} ${_selectedTime.value.isNotEmpty ? _selectedTime.value : ''}';
  }

  /// 总价 = 服务价格 + 交通费
  double get totalPrice {
    if (_service.value == null) return 0;
    return _service.value!.price + (_service.value!.travelFee ?? 0);
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
    } else if (args is Map<String, dynamic>) {
      if (args['service'] is ServiceItem) {
        _service.value = args['service'] as ServiceItem;
      }
      if (args['address'] is AddressModel) {
        _selectedAddress.value = args['address'] as AddressModel;
        _fillAddressInfo(args['address'] as AddressModel);
      }
    }
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
    try {
      final response = await _orderRepository.createOrder(
        serviceId: _service.value!.id,
        addressName: _selectedAddress.value!.name,
        latitude: _selectedAddress.value!.latitude,
        longitude: _selectedAddress.value!.longitude,
        contactName: contactNameController.text.trim(),
        contactPhone: contactPhoneController.text.trim(),
        remark: remarkController.text.trim().isNotEmpty
            ? remarkController.text.trim()
            : null,
        serviceTime: '${_selectedDate.value} ${_selectedTime.value}',
      );
      if (response.isSuccess) {
        Get.back(result: true);
        ToastUtil.showSuccess('下单成功');
      }
    } catch (e) {
      LogUtil.e('下单失败: $e', tag: _tag);
      ToastUtil.showError('$e');
    } finally {
      _isSubmitting.value = false;
    }
  }
}
