import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/service_item.dart';
import 'service_controller.dart';

/// 搜索控制器
/// 管理搜索页面的状态和业务逻辑
class SearchController extends GetxController {
  /// 搜索历史存储键
  static const String _searchHistoryKey = 'search_history';

  /// 最大搜索历史数量
  static const int _maxSearchHistoryCount = 10;
  final ServiceController _serviceController = Get.find<ServiceController>();

  // 刷新控制器
  late final EasyRefreshController refreshController;

  // 搜索相关状态
  final RxString _searchKeyword = ''.obs;
  final RxBool _isSearching = false.obs;
  final RxBool _hasSearched = false.obs;

  // 搜索历史
  final RxList<String> _searchHistory = <String>[].obs;

  // 服务列表状态
  final RxList<ServiceItem> _services = <ServiceItem>[].obs;

  // 初始化状态
  final RxBool _isInitialized = false.obs;

  // 搜索输入控制器
  final TextEditingController searchController = TextEditingController();

  /// 获取搜索关键词
  String get searchKeyword => _searchKeyword.value;

  /// 是否正在搜索
  bool get isSearching => _isSearching.value;

  /// 是否已执行过搜索
  bool get hasSearched => _hasSearched.value;

  /// 获取搜索历史
  List<String> get searchHistory => _searchHistory;

  /// 获取服务列表
  List<ServiceItem> get services => _services;

  /// 是否已初始化
  bool get isInitialized => _isInitialized.value;

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
    searchController.dispose();
    super.onClose();
  }

  /// 初始化控制器
  Future<void> initialize() async {
    if (_isInitialized.value) return;

    await _loadSearchHistory();

    _isInitialized.value = true;
  }

  /// 加载搜索历史
  /// 从本地存储加载搜索历史记录
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList(_searchHistoryKey);
      if (historyList != null && historyList.isNotEmpty) {
        _searchHistory.addAll(historyList);
      }
    } catch (e) {
      // 加载失败时使用默认搜索历史
    }
  }

  /// 保存搜索历史
  /// 将搜索历史记录保存到本地存储
  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_searchHistoryKey, _searchHistory);
    } catch (e) {
      // 保存失败，忽略错误
      debugPrint('保存搜索历史失败: $e');
    }
  }

  /// 执行搜索
  /// [keyword] 搜索关键词
  /// [provinceId] 省份ID
  /// [cityId] 城市ID
  /// [areaId] 区域ID
  Future<void> performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    _searchKeyword.value = keyword.trim();
    _isSearching.value = true;
    _hasSearched.value = true;

    // 更新搜索历史
    if (_searchHistory.contains(keyword)) {
      _searchHistory.remove(keyword);
    }
    _searchHistory.insert(0, keyword);
    // 限制搜索历史数量
    if (_searchHistory.length > _maxSearchHistoryCount) {
      _searchHistory.removeRange(_maxSearchHistoryCount, _searchHistory.length);
    }
    await _saveSearchHistory();

    try {
      await _serviceController.loadServices(
        refresh: true,
        keyword: keyword,
        provinceId: _serviceController.provinceId,
        cityId: _serviceController.cityId,
        areaId: _serviceController.areaId,
      );

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

  /// 清空搜索历史
  void clearSearchHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
  }

  /// 删除指定的搜索历史
  void removeSearchHistory(String keyword) {
    _searchHistory.remove(keyword);
    _saveSearchHistory();
  }

  /// 下拉刷新
  Future<void> refreshServices() async {
    try {
      await _serviceController.refreshServices();

      _services.clear();
      _services.addAll(_serviceController.services);

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
}
