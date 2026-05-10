import 'package:door_to_door_service/core/utils/loading_util.dart';
import 'package:door_to_door_service/core/utils/log_util.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:door_to_door_service/data/models/favorite_list_response_model.dart';
import 'package:get/get.dart';
import '../../data/repositories/service_repository.dart';

/// 收藏列表控制器
class FavoriteController extends GetxController {
  final String _tag = 'FavoriteController';
  final ServiceRepository _serviceRepository = ServiceRepository();

  // 收藏列表
  final RxList<FavoriteItem> _favorites = <FavoriteItem>[].obs;

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

  /// 收藏列表
  List<FavoriteItem> get favorites => _favorites;

  /// 总数量
  int get totalCount => _totalCount.value;

  /// 当前页码
  int get currentPage => _currentPage.value;

  /// 每页数量
  int get pageSize => _pageSize.value;

  /// 是否正在加载
  bool get isLoading => _isLoading.value;

  /// 是否还有更多数据
  bool get hasMore => _favorites.length < _totalCount.value;

  /// 错误信息
  String? get errorMessage =>
      _errorMessage.value.isEmpty ? null : _errorMessage.value;

  /// 加载收藏列表
  /// [userId] 用户ID
  /// [refresh] 是否刷新
  Future<void> loadFavorites({
    required int userId,
    bool refresh = false,
  }) async {
    // 如果是刷新，重置页码
    LogUtil.d('loadFavorites called with refresh=$refresh, userId=$userId',
        tag: _tag);
    if (refresh) {
      _currentPage.value = 1;
      _favorites.clear();
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await _serviceRepository.getFavorites(
        userId: userId,
        pageIndex: _currentPage.value,
        pageSize: _pageSize.value,
      );

      if (refresh) {
        _favorites.value = response.list ?? [];
      } else {
        _favorites.addAll(response.list ?? []);
      }

      _totalCount.value = response.count ?? 0;
      _errorMessage.value = '';
    } catch (e) {
      _errorMessage.value = e.toString();
      if (refresh) {
        _favorites.clear();
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载更多收藏
  Future<void> loadMoreFavorites(int userId) async {
    if (_isLoading.value || !hasMore) return;

    _currentPage.value++;
    await loadFavorites(
      userId: userId,
      refresh: false,
    );
  }

  /// 刷新收藏列表
  Future<void> refreshFavorites(int userId) async {
    await loadFavorites(
      userId: userId,
      refresh: true,
    );
  }

  /// 清空收藏列表
  void clearFavorites() {
    _favorites.value = [];
    _currentPage.value = 1;
    _totalCount.value = 0;
  }

  /// 切换收藏状态
  /// [serviceId] 服务ID
  /// [isFavorite] 是否收藏
  Future<void> toggleFavorite(int serviceId, bool isFavorite) async {
    LoadingUtil.show();
    try {
      await _serviceRepository.toggleFavorite(
        serviceId: serviceId,
        isFavorite: isFavorite,
      );

      // 更新本地收藏列表中的收藏状态
      final index = _favorites.indexWhere((item) => item.serviceId == serviceId);
      if (index != -1) {
        final fav = _favorites[index];
        final updatedService = fav.service.copyWith(
          isFavorite: isFavorite,
          favoriteCount: _nextFavoriteCount(fav.service.favoriteCount, isFavorite),
        );
        _favorites[index] = FavoriteItem(
          id: fav.id,
          userId: fav.userId,
          serviceId: fav.serviceId,
          createTime: fav.createTime,
          service: updatedService,
        );
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      ToastUtil.showError('操作失败: $e');
      rethrow;
    } finally {
      LoadingUtil.dismiss();
    }
  }

  int _nextFavoriteCount(int? current, bool isFavorite) {
    final c = current ?? 0;
    return isFavorite ? c + 1 : (c > 0 ? c - 1 : 0);
  }

  /// 从收藏列表中移除服务
  /// [serviceId] 服务ID
  void removeFavorite(int serviceId) {
    _favorites.removeWhere((item) => item.serviceId == serviceId);
    _totalCount.value = _totalCount.value > 0 ? _totalCount.value - 1 : 0;
  }
}
