import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:get/get.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';
import '../../routes/route_names.dart';

/// 帖子列表控制器
class PostListController extends GetxController {
  final String _tag = 'PostListController';
  final PostRepository _repository = PostRepository();

  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxString sortBy = 'latest'.obs;

  int get pageSize => 10;

  /// 下拉刷新
  Future<void> onRefresh() async {
    currentPage.value = 1;
    hasMore.value = true;
    isLoading.value = true;
    try {
      final response = await _repository.getPostList(
        pageIndex: 1,
        pageSize: pageSize,
        sortBy: sortBy.value,
      );
      posts.value = response.list ?? [];
      hasMore.value = (response.list ?? []).length >= pageSize;
    } catch (e) {
      LogUtil.e('刷新帖子列表失败: $e', tag: _tag);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      isLoading.value = false;
    }
  }

  /// 上拉加载更多
  Future<void> onLoadMore() async {
    if (isLoading.value || !hasMore.value) return;
    isLoading.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final response = await _repository.getPostList(
        pageIndex: nextPage,
        pageSize: pageSize,
        sortBy: sortBy.value,
      );
      final list = response.list ?? [];
      posts.addAll(list);
      hasMore.value = list.length >= pageSize;
      if (list.isNotEmpty) currentPage.value = nextPage;
    } catch (e) {
      LogUtil.e('加载更多失败: $e', tag: _tag);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLike(int postId) async {
    try {
      await _repository.toggleLike(postId);
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = posts[index];
        posts[index] = post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
        posts.refresh();
      }
    } catch (e) {
      ToastUtil.showError('$e');
    }
  }

  void navigateToDetail(PostModel post) {
    Get.toNamed(RouteNames.postDetail, arguments: post);
  }

  Future<void> navigateToCreate() async {
    final result = await Get.toNamed(RouteNames.postCreate);
    if (result == true) {
      onRefresh();
    }
  }
}
