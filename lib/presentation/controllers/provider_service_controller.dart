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
        return;
      }
    } else if (args is ServiceItem) {
      _serviceData.value = args;
      _populateForm(args);
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

    _isSubmitting.value = true;
    try {
      if (isEditMode) {
        await _updateService();
      } else {
        await _createService();
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 创建服务
  Future<void> _createService() async {
    try {
      final response = await _serviceRepository.createService(
        categoryId: _selectedCategory.value!.id,
        name: nameController.text.trim(),
        price: double.parse(priceController.text.trim()),
        providerName: providerNameController.text.trim(),
        address: _selectedCity.value!.name,
        deliveryRange: double.parse(deliveryRangeController.text.trim()),
        travelFee: travelFeeController.text.trim().isNotEmpty
            ? double.tryParse(travelFeeController.text.trim())
            : null,
        latitude: _selectedCity.value?.latitude,
        longitude: _selectedCity.value?.longitude,
        status: _status.value,
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
        price: double.parse(priceController.text.trim()),
        providerName: providerNameController.text.trim(),
        address: _selectedCity.value!.name,
        deliveryRange: double.parse(deliveryRangeController.text.trim()),
        travelFee: travelFeeController.text.trim().isNotEmpty
            ? double.tryParse(travelFeeController.text.trim())
            : null,
        latitude: _selectedCity.value?.latitude,
        longitude: _selectedCity.value?.longitude,
        status: _status.value,
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
