import 'package:door_to_door_service/core/utils/loading_util.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:door_to_door_service/data/models/address_model.dart';
import 'package:door_to_door_service/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/service_item.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../routes/route_names.dart';

/// 服务商完善服务控制器
class ProviderServiceController extends GetxController {
  final String _tag = 'ProviderServiceController';
  final ServiceRepository _serviceRepository = ServiceRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  // 表单控制器
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController travelFeeController = TextEditingController();
  final TextEditingController deliveryRangeController = TextEditingController();
  final TextEditingController providerNameController = TextEditingController();

  // 响应式状态
  final RxBool _isLoading = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final Rx<CategoryModel?> _selectedCategory = Rx<CategoryModel?>(null);
  final RxInt _status = 1.obs; // 默认上架
  final Rxn<AddressModel> _selectedCity = Rxn<AddressModel>();
  final Rxn<ServiceItem> _serviceData = Rxn<ServiceItem>();

  // 星期时间段: [{weekday:1, startTime:"09:00:00", endTime:"12:00:00"}, ...]
  final RxList<Map<String, dynamic>> _weekdaySlots =
      <Map<String, dynamic>>[].obs;
  // 特殊日期时间段: [{specialDate:"2026-05-01", startTime:"08:00:00", endTime:"20:00:00"}, ...]
  final RxList<Map<String, dynamic>> _specialDateSlots =
      <Map<String, dynamic>>[].obs;

  // 多时长价格: [{durationMinutes:60, price:268}, ...]
  final RxList<Map<String, dynamic>> _prices = <Map<String, dynamic>>[].obs;

  static const List<String> weekdayLabels = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日'
  ];

  // 表单校验Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 是否正在加载
  bool get isLoading => _isLoading.value;

  /// 是否正在提交
  bool get isSubmitting => _isSubmitting.value;

  /// 分类列表
  List<CategoryModel> get categories => _categories;

  /// 选中的分类
  CategoryModel? get selectedCategory => _selectedCategory.value;

  /// 状态：1上架 0下架
  int get status => _status.value;

  /// 选中的意向城市
  AddressModel? get selectedCity => _selectedCity.value;

  /// 是否为编辑模式
  bool get isEditMode => _serviceData.value != null;

  /// 星期时间段列表
  List<Map<String, dynamic>> get weekdaySlots => _weekdaySlots;

  /// 特殊日期时间段列表
  List<Map<String, dynamic>> get specialDateSlots => _specialDateSlots;

  /// 获取某星期几的时间段
  List<Map<String, dynamic>> slotsForWeekday(int w) =>
      _weekdaySlots.where((s) => s['weekday'] == w).toList();

  void addWeekdaySlot(int weekday) {
    _weekdaySlots.add({
      'weekday': weekday,
      'startTime': '09:00:00',
      'endTime': '18:00:00',
    });
    _weekdaySlots.refresh();
  }

  void removeWeekdaySlot(int index) {
    _weekdaySlots.removeAt(index);
    _weekdaySlots.refresh();
  }

  void updateWeekdaySlot(int index, String key, String value) {
    _weekdaySlots[index] = {..._weekdaySlots[index], key: value};
    _weekdaySlots.refresh();
  }

  void addSpecialDateSlot(String date) {
    _specialDateSlots.add({
      'specialDate': date,
      'startTime': '09:00:00',
      'endTime': '18:00:00',
    });
    _specialDateSlots.refresh();
  }

  void removeSpecialDateSlot(int index) {
    _specialDateSlots.removeAt(index);
    _specialDateSlots.refresh();
  }

  void updateSpecialDateSlot(int index, String key, String value) {
    _specialDateSlots[index] = {..._specialDateSlots[index], key: value};
    _specialDateSlots.refresh();
  }

  /// 多时长价格列表
  List<Map<String, dynamic>> get prices => _prices;

  void addPrice() => _prices.add({'durationMinutes': 60, 'price': 100.0});
  void removePrice(int i) => _prices.removeAt(i);
  void updatePrice(int i, String key, dynamic value) {
    _prices[i] = {..._prices[i], key: value};
    _prices.refresh();
  }

  /// 构建 timeSlots JSON（数组格式）
  List<Map<String, dynamic>> _buildTimeSlotsJson() => _weekdaySlots.toList();

  /// 构建 specialDateSlots JSON
  List<Map<String, dynamic>> _buildSpecialDateSlotsJson() =>
      _specialDateSlots.toList();

  /// 校验时间段：开始<结束，同一天不重叠
  bool _validateTimeSlots() {
    // 校验星期时间段
    for (var i = 0; i < _weekdaySlots.length; i++) {
      final s = _weekdaySlots[i];
      final start = s['startTime'] as String;
      final end = s['endTime'] as String;
      final w = (s['weekday'] as int) - 1;
      if (start.compareTo(end) >= 0) {
        ToastUtil.showError('${weekdayLabels[w]} 开始时间必须早于结束时间');
        return false;
      }
      // 检查同一天重叠
      for (var j = i + 1; j < _weekdaySlots.length; j++) {
        final s2 = _weekdaySlots[j];
        if (s['weekday'] != s2['weekday']) continue;
        if (_overlaps(
            start, end, s2['startTime'] as String, s2['endTime'] as String)) {
          ToastUtil.showError('${weekdayLabels[w]} 时间段存在重叠');
          return false;
        }
      }
    }
    // 校验特殊日期时间段
    for (var i = 0; i < _specialDateSlots.length; i++) {
      final s = _specialDateSlots[i];
      final start = s['startTime'] as String;
      final end = s['endTime'] as String;
      if (start.compareTo(end) >= 0) {
        ToastUtil.showError('${s['specialDate']} 开始时间必须早于结束时间');
        return false;
      }
      for (var j = i + 1; j < _specialDateSlots.length; j++) {
        final s2 = _specialDateSlots[j];
        if (s['specialDate'] != s2['specialDate']) continue;
        if (_overlaps(
            start, end, s2['startTime'] as String, s2['endTime'] as String)) {
          ToastUtil.showError('${s['specialDate']} 时间段存在重叠');
          return false;
        }
      }
    }
    return true;
  }

  bool _overlaps(String s1, String e1, String s2, String e2) =>
      s1.compareTo(e2) < 0 && s2.compareTo(e1) < 0;

  /// 服务数据
  ServiceItem? get serviceData => _serviceData.value;

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
  }

  /// 从路由参数中解析分类和服务数据
  void _parseArguments() {
    // 重置状态，避免 Get.lazyPut 缓存导致旧数据残留
    _resetFormState();

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['categories'] is List<CategoryModel>) {
        _categories.value = args['categories'] as List<CategoryModel>;
      }

      if (args['service'] is ServiceItem) {
        final service = args['service'] as ServiceItem;
        _serviceData.value = service;
        _populateForm(service);
        loadServiceDetail(service.id); // 从详情接口获取时间段等完整数据
        return;
      }
    } else if (args is ServiceItem) {
      _serviceData.value = args;
      _populateForm(args);
      loadServiceDetail(args.id);
      return;
    }

    if (_categories.isEmpty) {
      loadCategories();
    }
  }

  /// 重置表单到初始状态
  void _resetFormState() {
    _serviceData.value = null;
    _selectedCategory.value = null;
    _selectedCity.value = null;
    _status.value = 1;
    nameController.clear();
    priceController.clear();
    travelFeeController.clear();
    deliveryRangeController.clear();
    providerNameController.clear();
    _weekdaySlots.clear();
    _specialDateSlots.clear();
    _prices.clear();
    _prices.add({'durationMinutes': 60, 'price': 100.0});
  }

  /// 从 prices 取第一个价格作为 base price（API 兼容）
  double get _basePrice {
    if (_prices.isEmpty) return 0;
    return (_prices.first['price'] as num?)?.toDouble() ?? 0;
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    travelFeeController.dispose();
    deliveryRangeController.dispose();
    providerNameController.dispose();
    super.onClose();
  }

  /// 加载分类列表
  Future<void> loadCategories() async {
    try {
      final response = await _categoryRepository.getCategories(pageSize: 200);
      if (response.list != null) {
        _categories.value = response.list!;
      }
    } catch (e) {
      LogUtil.e('加载分类列表失败: $e', tag: _tag);
    }
  }

  /// 更新选中的分类
  void updateCategory(CategoryModel? category) {
    _selectedCategory.value = category;
  }

  /// 更新状态
  void updateStatus(int status) {
    _status.value = status;
  }

  /// 打开地图选择意向城市
  Future<void> selectCity() async {
    final result = await Get.toNamed(RouteNames.mapSelect);
    if (result is AddressModel) {
      _selectedCity.value = result;
    }
  }

  /// 加载服务详情（编辑模式）
  Future<void> loadServiceDetail(int serviceId) async {
    _isLoading.value = true;
    try {
      final response = await _serviceRepository.getServiceById(serviceId);
      if (response.isSuccess && response.data != null) {
        _serviceData.value = response.data;
        _populateForm(response.data!);
      }
    } catch (e) {
      LogUtil.e('加载服务详情失败: $e', tag: _tag);
      ToastUtil.showError('加载服务详情失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 填充表单数据
  void _populateForm(ServiceItem service) {
    nameController.text = service.name;
    priceController.text = service.price.toString();
    travelFeeController.text = service.travelFee?.toString() ?? '';
    providerNameController.text = service.providerName ?? '';
    _status.value = service.status ?? 1;
    deliveryRangeController.text = service.deliveryRange?.toString() ?? '';

    // 设置城市和经纬度
    if (service.address != null && service.address!.isNotEmpty) {
      _selectedCity.value = AddressModel(
        name: service.address!,
        shortName: service.address!,
        province: '',
        city: '',
        district: '',
        street: '',
        latitude: service.latitude ?? 0.0,
        longitude: service.longitude ?? 0.0,
      );
    }

    // 预填时间段数据
    _weekdaySlots.clear();
    if (service.timeSlots != null) {
      _weekdaySlots.addAll(service.timeSlots!);
    }
    _specialDateSlots.clear();
    if (service.specialDateSlots != null) {
      _specialDateSlots.addAll(service.specialDateSlots!);
    }
    _prices.clear();
    if (service.prices != null) {
      _prices.addAll(service.prices!);
    }

    // 设置分类
    if (service.categoryId != null) {
      final category = _categories.firstWhereOrNull(
        (c) => c.id == service.categoryId,
      );
      if (category != null) {
        _selectedCategory.value = category;
      }
    }
  }

  /// 验证表单
  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedCategory.value == null) {
      ToastUtil.showError('请选择服务分类');
      return false;
    }

    if (_selectedCity.value == null || _selectedCity.value!.name.isEmpty) {
      ToastUtil.showError('请选择意向合作城市');
      return false;
    }

    final deliveryRange = double.tryParse(deliveryRangeController.text.trim());
    if (deliveryRange == null || deliveryRange <= 0) {
      ToastUtil.showError('请输入有效的配送范围');
      return false;
    }

    return true;
  }

  /// 提交服务
  Future<void> submit() async {
    if (!_validateForm()) return;
    if (!_validateTimeSlots()) return;

    _isSubmitting.value = true;
    LoadingUtil.show();
    try {
      if (isEditMode) {
        await _updateService();
      } else {
        await _createService();
      }
    } finally {
      _isSubmitting.value = false;
      LoadingUtil.dismiss();
    }
  }

  /// 创建服务
  Future<void> _createService() async {
    try {
      final response = await _serviceRepository.createService(
        categoryId: _selectedCategory.value!.id,
        name: nameController.text.trim(),
        price: _basePrice,
        providerName: providerNameController.text.trim(),
        address: _selectedCity.value!.name,
        deliveryRange: double.parse(deliveryRangeController.text.trim()),
        travelFee: travelFeeController.text.trim().isNotEmpty
            ? double.tryParse(travelFeeController.text.trim())
            : null,
        latitude: _selectedCity.value?.latitude,
        longitude: _selectedCity.value?.longitude,
        status: _status.value,
        timeSlots: _buildTimeSlotsJson(),
        specialDateSlots: _buildSpecialDateSlotsJson(),
        prices: _prices.toList(),
      );
      if (response.isSuccess) {
        Get.back(result: true);
        ToastUtil.showSuccess('服务创建成功');
      }
    } catch (e) {
      LogUtil.e('创建服务失败: $e', tag: _tag);
      ToastUtil.showError('$e');
    }
  }

  /// 更新服务
  Future<void> _updateService() async {
    try {
      final response = await _serviceRepository.updateService(
        id: _serviceData.value!.id,
        categoryId: _selectedCategory.value!.id,
        name: nameController.text.trim(),
        price: _basePrice,
        providerName: providerNameController.text.trim(),
        address: _selectedCity.value!.name,
        deliveryRange: double.parse(deliveryRangeController.text.trim()),
        travelFee: travelFeeController.text.trim().isNotEmpty
            ? double.tryParse(travelFeeController.text.trim())
            : null,
        latitude: _selectedCity.value?.latitude,
        longitude: _selectedCity.value?.longitude,
        status: _status.value,
        timeSlots: _buildTimeSlotsJson(),
        specialDateSlots: _buildSpecialDateSlotsJson(),
        prices: _prices.toList(),
      );
      if (response.isSuccess) {
        Get.back(result: true);
        ToastUtil.showSuccess('服务更新成功');
      }
    } catch (e) {
      LogUtil.e('更新服务失败: $e', tag: _tag);
      ToastUtil.showError('$e');
    }
  }
}
