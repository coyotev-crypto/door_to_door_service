import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';

/// 帖子详情控制器
class PostDetailController extends GetxController {
  final String _tag = 'PostDetailController';
  final PostRepository _repository = PostRepository();

  final Rxn<PostModel> post = Rxn<PostModel>();
  final RxBool isLoading = false.obs;
  final RxBool loadError = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PostModel) {
      post.value = args;
    } else if (args is int) {
      loadPost(args);
    }
  }

  Future<void> loadPost(int postId) async {
    isLoading.value = true;
    loadError.value = false;
    try {
      final response = await _repository.getPostDetail(postId);
      if (response.isSuccess && response.data != null) {
        post.value = response.data;
      } else {
        loadError.value = true;
      }
    } catch (e) {
      LogUtil.e('加载帖子详情失败: $e', tag: _tag);
      loadError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLike() {
    if (post.value == null) return;
    final p = post.value!;
    final newLiked = !p.isLiked;
    post.value = p.copyWith(
      isLiked: newLiked,
      likeCount: newLiked ? p.likeCount + 1 : p.likeCount - 1,
    );
    _repository.toggleLike(p.id);
  }

  void toggleCollect() {
    if (post.value == null) return;
    final p = post.value!;
    post.value = p.copyWith(isCollected: !p.isCollected);
    _repository.toggleCollect(p.id);
  }

  void share() {
    if (post.value == null) return;
    final url = 'https://app.example.com/post/${post.value!.id}';
    Clipboard.setData(ClipboardData(text: url));
    ToastUtil.showSuccess('链接已复制');
  }
}
