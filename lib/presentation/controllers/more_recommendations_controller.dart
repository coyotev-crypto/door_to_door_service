import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../data/models/service_item.dart';
import '../../data/repositories/service_repository.dart';
import '../../data/models/sort_option.dart';

/// 更多推荐页面控制器
/// 管理更多推荐页面的状态和业务逻辑
class MoreRecommendationsController extends GetxController {
  // 刷新控制器
  late final EasyRefreshController refreshController;

  // 服务列表
  final RxList<ServiceItem> _services = <ServiceItem>[].obs;

  // 总数量
  final RxInt _totalCount = 0.obs;

  // 当前页码
  final RxInt _currentPage = 1.obs;

  // 每页数量
  final RxInt _pageSize = 10.obs;

  // 是否正在加载
  final RxBool _isLoading = false.obs;

  // 错误信息
  final RxString _errorMessage = ''.obs;

  // 城市筛选相关状态
  final Rx<String?> _provinceId = Rx<String?>(null);
  final Rx<String?> _cityId = Rx<String?>(null);
  final Rx<String?> _areaId = Rx<String?>(null);

  // 排序方式
  final Rx<String?> _ratingOrder = Rx<String?>(null);
  final Rx<String?> _priceOrder = Rx<String?>(null);
  final Rx<String?> _salesOrder = Rx<String?>(null);
  final Rx<String?> _distanceOrder = Rx<String?>(null);

  // 排序选项
  final Rx<ServiceSortOption> _currentSortOption =
      ServiceSortOption.comprehensive.obs;
  final RxBool _isAscending = false.obs;

  final ServiceRepository _serviceRepository = ServiceRepository();

  /// 服务列表
  List<ServiceItem> get services => _services;

  /// 总数量
  int get totalCount => _totalCount.value;

  /// 当前页码
  int get currentPage => _currentPage.value;

  /// 每页数量
  int get pageSize => _pageSize.value;

  /// 是否正在加载
  bool get isLoading => _isLoading.value;

  /// 是否还有更多数据
  bool get hasMore => _services.length < _totalCount.value;

  /// 错误信息
  String get errorMessage => _errorMessage.value;

  /// 获取省份ID
  String? get provinceId => _provinceId.value;

  /// 获取城市ID
  String? get cityId => _cityId.value;

  /// 获取区域ID
  String? get areaId => _areaId.value;

  /// 获取当前排序选项
  ServiceSortOption get currentSortOption => _currentSortOption.value;

  /// 是否升序排序
  bool get isAscending => _isAscending.value;

  @override
  void onInit() {
    super.onInit();
    refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    // 从路由参数获取城市信息
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _provinceId.value = args['provinceId'] as String?;
      _cityId.value = args['cityId'] as String?;
      _areaId.value = args['areaId'] as String?;
    }
    loadServices();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  /// 加载服务列表
  Future<void> loadServices({bool isRefresh = false}) async {
    if (_isLoading.value) return;

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      if (isRefresh) {
        _currentPage.value = 1;
      }

      final response = await _serviceRepository.getServiceList(
        pageIndex: _currentPage.value,
        pageSize: _pageSize.value,
        ratingOrder: _ratingOrder.value,
        priceOrder: _priceOrder.value,
        orderCountOrder: _salesOrder.value,
        distanceOrder: _distanceOrder.value,
        provinceId: _provinceId.value,
        cityId: _cityId.value,
        areaId: _areaId.value,
      );

      if (isRefresh) {
        _services.clear();
      }

      if (response.list != null) {
        _services.addAll(response.list!);
      }
      _totalCount.value = response.count ?? 0;
      _currentPage.value++;
    } catch (e) {
      _errorMessage.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 刷新服务列表
  Future<void> refreshServices() async {
    try {
      await loadServices(isRefresh: true);
    } catch (e) {
      rethrow;
    }
  }

  /// 加载更多服务
  Future<void> loadMoreServices() async {
    if (!hasMore || _isLoading.value) return;

    try {
      await loadServices();
    } catch (e) {
      rethrow;
    }
  }

  /// 设置排序选项
  void setSortOption(ServiceSortOption option, bool ascending) {
    _currentSortOption.value = option;
    _isAscending.value = ascending;

    // 根据排序选项设置对应的排序字段
    _ratingOrder.value = null;
    _priceOrder.value = null;
    _salesOrder.value = null;
    _distanceOrder.value = null;

    switch (option) {
      case ServiceSortOption.rating:
        _ratingOrder.value = ascending ? 'asc' : 'desc';
        break;
      case ServiceSortOption.price:
        _priceOrder.value = ascending ? 'asc' : 'desc';
        break;
      case ServiceSortOption.sales:
        _salesOrder.value = ascending ? 'asc' : 'desc';
        break;
      case ServiceSortOption.distance:
        _distanceOrder.value = ascending ? 'asc' : 'desc';
        break;
      case ServiceSortOption.comprehensive:
        // 综合排序不设置特定字段
        break;
    }
  }

  /// 处理城市变化
  void handleCityChanged(Map<String, String?> cityInfo) {
    _provinceId.value = cityInfo['provinceId'];
    _cityId.value = cityInfo['cityId'];
    _areaId.value = cityInfo['areaId'];
    refreshServices();
  }
}
