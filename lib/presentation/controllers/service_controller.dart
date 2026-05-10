import 'package:door_to_door_service/core/utils/log_util.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:get/get.dart';
import '../../data/models/service_item.dart';
import '../../data/models/sort_option.dart';
import '../../data/repositories/service_repository.dart';
import '../../core/services/location_service.dart';

/// 服务控制器
class ServiceController extends GetxController {
  final String _tag = 'ServiceController';
  final ServiceRepository _serviceRepository = ServiceRepository();

  // 通过 GetX 获取定位服务实例（确保已在 main 中注册）
  LocationService get _locationService => Get.find<LocationService>();

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

  // 选中的分类ID
  final Rx<int?> _selectedCategoryId = Rx<int?>(null);

  // 城市筛选相关状态
  final Rx<String?> _provinceId = Rx<String?>(null);
  final Rx<String?> _cityId = Rx<String?>(null);
  final Rx<String?> _areaId = Rx<String?>(null);

  // 搜索关键词
  final Rx<String?> _searchKeyword = Rx<String?>(null);

  // 用户位置
  final Rx<double?> _userLatitude = Rx<double?>(null);
  final Rx<double?> _userLongitude = Rx<double?>(null);
  bool _hasRefreshedWithGps = false; // GPS更新后仅刷新一次

  // 筛选后的服务列表
  final RxList<ServiceItem> _filteredServices = <ServiceItem>[].obs;

  // 新人推荐列表
  final RxList<ServiceItem> _newcomerServices = <ServiceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initLocationCallback();
  }

  @override
  void onClose() {
    _locationService.onLocationUpdated = null;
    _hasRefreshedWithGps = false;
    super.onClose();
  }

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
  String? get errorMessage =>
      _errorMessage.value.isEmpty ? null : _errorMessage.value;

  /// 选中的分类ID
  int? get selectedCategoryId => _selectedCategoryId.value;

  /// 省份ID
  String? get provinceId => _provinceId.value;

  /// 城市ID
  String? get cityId => _cityId.value;

  /// 区域ID
  String? get areaId => _areaId.value;

  /// 筛选后的服务列表
  List<ServiceItem> get filteredServices => _filteredServices;

  /// 新人推荐列表
  List<ServiceItem> get newcomerServices => _newcomerServices;

  /// 搜索关键词
  String? get searchKeyword => _searchKeyword.value;

  /// 用户纬度
  double? get userLatitude => _userLatitude.value;

  /// 用户经度
  double? get userLongitude => _userLongitude.value;

  /// 加载服务列表
  /// [refresh] 是否刷新
  /// [categoryId] 分类ID
  /// [sortOption] 排序选项
  /// [ascending] 是否升序
  /// [provinceId] 省份ID
  /// [cityId] 城市ID
  /// [areaId] 区域ID
  /// [keyword] 搜索关键词
  /// [latitude] 用户纬度（可选，不传则使用当前用户位置）
  /// [longitude] 用户经度（可选，不传则使用当前用户位置）
  /// [radius] 搜索半径，默认为20.0
  Future<void> loadServices({
    bool refresh = false,
    int? categoryId,
    ServiceSortOption? sortOption,
    bool? ascending,
    String? provinceId,
    String? cityId,
    String? areaId,
    String? keyword,
    double? latitude,
    double? longitude,
    double radius = 20.0,
  }) async {
    // 如果是刷新，重置页码
    LogUtil.d(
        'loadServices called with refresh=$refresh, categoryId=$categoryId, sortOption=$sortOption',
        tag: _tag);
    if (refresh) {
      _currentPage.value = 1;
      _services.clear();
    }

    // 更新筛选条件
    _selectedCategoryId.value = categoryId;
    _provinceId.value = provinceId;
    _cityId.value = cityId;
    _areaId.value = areaId;
    _searchKeyword.value = keyword;

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      // 使用传入的经纬度，如果没有传入则使用当前用户位置
      final useLatitude = latitude ?? _userLatitude.value;
      final useLongitude = longitude ?? _userLongitude.value;

      final response = await _serviceRepository.getServiceList(
        categoryId: _selectedCategoryId.value,
        pageIndex: _currentPage.value,
        pageSize: _pageSize.value,
        provinceId: _provinceId.value,
        cityId: _cityId.value,
        areaId: _areaId.value,
        keyword: _searchKeyword.value,
        latitude: useLatitude,
        longitude: useLongitude,
        radius: radius,
      );

      if (refresh) {
        _services.value = response.list ?? [];
        // 更新新人推荐列表
        _newcomerServices.value = response.newcomerList ?? [];
      } else {
        _services.addAll(response.list ?? []);
      }

      _totalCount.value = response.count ?? 0;
      _errorMessage.value = '';
    } catch (e) {
      _errorMessage.value = e.toString();
      if (refresh) {
        _services.clear();
        _filteredServices.clear();
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载更多服务
  Future<void> loadMoreServices() async {
    if (_isLoading.value || !hasMore) return;

    _currentPage.value++;
    await loadServices(refresh: false);
  }

  /// 刷新服务列表
  Future<void> refreshServices() async {
    await loadServices(
      refresh: true,
      categoryId: _selectedCategoryId.value,
      provinceId: _provinceId.value,
      cityId: _cityId.value,
      areaId: _areaId.value,
      keyword: _searchKeyword.value,
      // 使用当前用户位置
      latitude: _userLatitude.value,
      longitude: _userLongitude.value,
    );
  }

  /// 清空服务列表
  void clearServices() {
    _services.value = [];
    _currentPage.value = 1;
    _totalCount.value = 0;
    _filteredServices.value = [];
  }

  /// 搜索服务
  /// [keyword] 搜索关键词
  /// [refresh] 是否刷新
  Future<void> searchServices(String keyword, {bool refresh = true}) async {
    _searchKeyword.value = keyword;
    await loadServices(refresh: refresh);
  }

  /// 清空搜索
  void clearSearch() {
    _searchKeyword.value = null;
  }

  /// 设置用户位置
  /// [latitude] 用户纬度
  /// [longitude] 用户经度
  /// [refresh] 是否刷新服务列表
  Future<void> setUserLocation({
    required double latitude,
    required double longitude,
    bool refresh = true,
  }) async {
    _userLatitude.value = latitude;
    _userLongitude.value = longitude;
    if (refresh) {
      await refreshServices();
    }
  }

  /// 清除用户位置
  /// [refresh] 是否刷新服务列表
  Future<void> clearUserLocation({bool refresh = true}) async {
    _userLatitude.value = null;
    _userLongitude.value = null;
    LogUtil.d('清除用户位置', tag: _tag);
    if (refresh) {
      await refreshServices();
    }
  }

  /// 初始化位置更新回调
  void _initLocationCallback() {
    // 设置位置更新回调：GPS定位成功后触发一次刷新
    _locationService.onLocationUpdated = (latitude, longitude) {
      final shouldRefresh = !_hasRefreshedWithGps;
      _hasRefreshedWithGps = true;
      setUserLocation(
        latitude: latitude,
        longitude: longitude,
        refresh: shouldRefresh,
      );
    };

    // 如果 LocationService 已经有位置信息（缓存），立即设置但不刷新
    final currentLocation = _locationService.currentLocation;
    if (currentLocation != null &&
        currentLocation.latitude != null &&
        currentLocation.longitude != null) {
      LogUtil.d(
          '从LocationService获取到已有位置: 纬度=${currentLocation.latitude}, 经度=${currentLocation.longitude}',
          tag: _tag);
      setUserLocation(
        latitude: currentLocation.latitude!,
        longitude: currentLocation.longitude!,
        refresh: false,
      );
    }
  }

  /// 切换收藏状态
  /// [serviceId] 服务ID
  /// [isFavorite] 是否收藏
  Future<void> toggleFavorite(
    int serviceId,
    bool isFavorite,
  ) async {
    try {
      await _serviceRepository.toggleFavorite(
        serviceId: serviceId,
        isFavorite: isFavorite,
      );

      // 更新本地服务列表中的收藏状态
      final index = _services.indexWhere((service) => service.id == serviceId);
      if (index != -1) {
        _services[index] = _services[index].copyWith(isFavorite: isFavorite);
      }

      // 更新筛选后服务列表中的收藏状态
      final filteredIndex =
          _filteredServices.indexWhere((service) => service.id == serviceId);
      if (filteredIndex != -1) {
        _filteredServices[filteredIndex] =
            _filteredServices[filteredIndex].copyWith(isFavorite: isFavorite);
      }

      // 更新新人推荐列表中的收藏状态
      final newcomerIndex =
          _newcomerServices.indexWhere((service) => service.id == serviceId);
      if (newcomerIndex != -1) {
        _newcomerServices[newcomerIndex] =
            _newcomerServices[newcomerIndex].copyWith(isFavorite: isFavorite);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      ToastUtil.showError('操作失败: $e');
    }
  }
}
