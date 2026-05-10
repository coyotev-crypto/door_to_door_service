import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:get/get.dart';
import '../../core/network/base_response.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/category_list_response_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/service_item.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../routes/route_names.dart';

/// 服务管理列表控制器
class ProviderServiceListController extends GetxController {
  final String _tag = 'ProviderServiceListController';
  final ServiceRepository _serviceRepository = ServiceRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final RxList<ServiceItem> _services = <ServiceItem>[].obs;
  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<ServiceItem> get services => _services;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  /// 加载我的服务列表
  Future<void> loadServices() async {
    _isLoading.value = true;
    try {
      // 并行加载服务和分类
      final results = await Future.wait([
        _serviceRepository.getMyServices(),
        _categoryRepository.getCategories(pageSize: 200),
      ]);

      final serviceResponse = results[0] as BaseResponse<List<ServiceItem>>;

      // 缓存分类列表
      final categoryResponse = results[1] as CategoryListResponseModel;
      if (categoryResponse.list != null) {
        _categories.value = categoryResponse.list!;
      }

      if (serviceResponse.isSuccess && serviceResponse.data != null) {
        _services.value = serviceResponse.data!.map((service) {
          if (service.categoryId != null) {
            final category = _categories.firstWhereOrNull(
              (c) => c.id == service.categoryId,
            );
            if (category != null) {
              return service.copyWith(categoryName: category.name);
            }
          }
          return service;
        }).toList();
      }
    } catch (e) {
      LogUtil.e('加载服务列表失败: $e', tag: _tag);
      ToastUtil.showError('加载服务列表失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 跳转到新增服务页面
  Future<void> navigateToCreate() async {
    final result = await Get.toNamed(
      RouteNames.providerService,
      arguments: <String, dynamic>{'categories': _categories.toList()},
    );
    if (result == true) {
      loadServices(); // 创建成功后刷新列表
    }
  }

  /// 跳转到编辑服务页面
  Future<void> navigateToEdit(ServiceItem service) async {
    final result = await Get.toNamed(
      RouteNames.providerService,
      arguments: <String, dynamic>{
        'service': service,
        'categories': _categories.toList(),
      },
    );
    if (result == true) {
      loadServices(); // 编辑成功后刷新列表
    }
  }

  /// 切换服务上架/下架状态
  Future<void> toggleStatus(ServiceItem service) async {
    final newStatus = service.status == 1 ? 0 : 1;
    try {
      final response = await _serviceRepository.updateService(
        id: service.id,
        categoryId: service.categoryId ?? 0,
        name: service.name,
        price: service.price,
        providerName: service.providerName ?? '',
        address: service.address ?? '',
        deliveryRange: service.deliveryRange ?? 0,
        travelFee: service.travelFee,
        latitude: service.latitude,
        longitude: service.longitude,
        status: newStatus,
      );
      if (response.isSuccess) {
        ToastUtil.showSuccess(newStatus == 1 ? '已上架' : '已下架');
        // 本地更新列表状态，避免全量刷新
        if (newStatus == 1) {
          // 上架：当前服务上架，其余全部下架（互斥）
          for (var i = 0; i < _services.length; i++) {
            _services[i] = _services[i].copyWith(
              status: _services[i].id == service.id ? 1 : 0,
            );
          }
        } else {
          // 下架：仅更新当前服务
          final index = _services.indexWhere((s) => s.id == service.id);
          if (index != -1) {
            _services[index] = _services[index].copyWith(status: 0);
          }
        }
        _services.refresh();
      }
    } catch (e) {
      LogUtil.e('切换状态失败: $e', tag: _tag);
      ToastUtil.showError('$e');
    }
  }
}
