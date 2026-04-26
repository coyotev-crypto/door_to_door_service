import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../data/models/category_item.dart';
import '../../data/models/service_item.dart';
import '../../data/repositories/category_repository.dart';
import 'service_controller.dart';

/// 首页内容控制器
/// 管理首页内容的状态和业务逻辑
class HomeContentController extends GetxController {
  // 刷新控制器
  late final EasyRefreshController refreshController;

  // 分类相关状态
  final RxInt _selectedCategoryIndex = 0.obs;
  final RxList<CategoryItem> _categories = <CategoryItem>[].obs;
  final RxBool _isLoadingCategories = false.obs;
  final CategoryRepository _categoryRepository = CategoryRepository();

  // 城市筛选相关状态
  final Rx<String?> _provinceId = Rx<String?>(null);
  final Rx<String?> _cityId = Rx<String?>(null);
  final Rx<String?> _areaId = Rx<String?>(null);

  // 服务列表状态
  final RxList<ServiceItem> _services = <ServiceItem>[].obs;
  final RxList<ServiceItem> _newcomerServices = <ServiceItem>[].obs;
  final ServiceController _serviceController = Get.find<ServiceController>();

  // 搜索相关状态
  final Rx<String?> _searchKeyword = Rx<String?>(null);
  final RxBool _isSearching = false.obs;

  // 初始化状态
  final RxBool _isInitialized = false.obs;

  /// 获取选中的分类索引
  int get selectedCategoryIndex => _selectedCategoryIndex.value;

  /// 监听分类索引变化
  RxInt get selectedCategoryIndexObs => _selectedCategoryIndex;

  /// 获取分类列表
  List<CategoryItem> get categories => _categories;

  /// 是否正在加载分类
  bool get isLoadingCategories => _isLoadingCategories.value;

  /// 获取省份ID
  String? get provinceId => _provinceId.value;

  /// 获取城市ID
  String? get cityId => _cityId.value;

  /// 获取区域ID
  String? get areaId => _areaId.value;

  /// 获取服务列表
  List<ServiceItem> get services => _services;

  /// 获取新人推荐列表
  List<ServiceItem> get newcomerServices => _newcomerServices;

  /// 是否已初始化
  bool get isInitialized => _isInitialized.value;

  /// 搜索关键词
  String? get searchKeyword => _searchKeyword.value;

  /// 是否正在搜索
  bool get isSearching => _isSearching.value;

  /// 是否有更多数据
  bool get hasMore => _serviceController.hasMore;

  /// 是否正在加载
  bool get isLoading => _serviceController.isLoading;

  /// 获取错误信息
  String? get errorMessage => _serviceController.errorMessage;

  @override
  void onInit() {
    super.onInit();
    // 初始化刷新控制器
    refreshController = EasyRefreshController(
        controlFinishRefresh: true, controlFinishLoad: true);
    // 初始化数据
    initialize();
  }

  @override
  void onClose() {
    refreshController.dispose();
    _serviceController.dispose();
    super.onClose();
  }

  /// 初始化控制器
  Future<void> initialize() async {
    if (_isInitialized.value) return;

    await Future.wait([
      _loadCategories(),
    ]);

    _isInitialized.value = true;
  }

  /// 加载服务分类数据
  Future<void> _loadCategories() async {
    if (_isLoadingCategories.value) return;

    _isLoadingCategories.value = true;

    try {
      final response = await _categoryRepository.getPrimaryCategories();

      if (response.list != null && response.list!.isNotEmpty) {
        final categories = response.list!;

        // 保留"全部"分类，添加从后端获取的分类
        _categories.clear();
        _categories.add(CategoryItem(
          name: '全部',
          icon: Icons.apps_rounded,
          color: const Color(0xFF4CAF50),
        ));

        // 添加后端返回的分类
        for (var category in categories) {
          _categories.add(CategoryItem(
            name: category.name,
            icon: Icons.category_rounded,
            color: _getColorForIndex(_categories.length),
          ));
        }
      }
    } catch (e) {
      print('加载服务分类失败: $e');
    } finally {
      _isLoadingCategories.value = false;
    }
  }

  /// 根据索引获取颜色
  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFF8BC34A),
      const Color(0xFF3F51B5),
    ];
    return colors[index % colors.length];
  }

  /// 处理分类选择
  void handleCategorySelected(int index) {
    _selectedCategoryIndex.value = index;
    // 重新加载服务列表
    loadServices();
  }

  /// 加载服务列表
  Future<void> loadServices() async {
    try {
      // 调用ServiceController加载服务列表
      await _serviceController.loadServices(
        refresh: true,
        categoryId: _selectedCategoryIndex.value > 0
            ? _selectedCategoryIndex.value
            : null,
        provinceId: _provinceId.value,
        cityId: _cityId.value,
        areaId: _areaId.value,
        keyword: _searchKeyword.value,
      );

      // 更新服务列表
      _services.clear();
      _services.addAll(_serviceController.services);
      _newcomerServices.clear();
      _newcomerServices.addAll(_serviceController.newcomerServices);
    } catch (e) {
      // 错误处理
      _services.clear();
      rethrow;
    }
  }

  /// 下拉刷新
  Future<void> refreshServices() async {
    try {
      await _serviceController.refreshServices();

      _services.clear();
      _services.addAll(_serviceController.services);
      _newcomerServices.clear();
      _newcomerServices.addAll(_serviceController.newcomerServices);
      refreshController.finishRefresh();
    } catch (e) {
      refreshController.finishRefresh(IndicatorResult.fail);
      rethrow;
    }
  }

  /// 上拉加载
  Future<void> loadMoreServices() async {
    if (!_serviceController.hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    try {
      await _serviceController.loadMoreServices();

      _services.clear();
      _services.addAll(_serviceController.services);

      refreshController.finishLoad(_serviceController.hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore);
    } catch (e) {
      refreshController.finishLoad(IndicatorResult.fail);
      rethrow;
    }
  }

  /// 执行搜索
  /// [keyword] 搜索关键词
  Future<void> performSearch(String keyword) async {
    _searchKeyword.value = keyword;
    _isSearching.value = true;

    try {
      await _serviceController.searchServices(keyword);

      // 更新服务列表
      _services.clear();
      _services.addAll(_serviceController.services);
    } catch (e) {
      // 错误处理
      _services.clear();
      rethrow;
    } finally {
      _isSearching.value = false;
    }
  }

  /// 清空搜索
  void clearSearch() {
    _searchKeyword.value = null;
    _serviceController.clearSearch();
    loadServices();
  }
}
