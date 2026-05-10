import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';

/// 帖子详情控制器
class PostDetailController extends GetxController {
  final String _tag = 'PostDetailController';
  final PostRepository _repository = PostRepository();

  final Rxn<PostModel> post = Rxn<PostModel>();
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingComments = false.obs;
  final RxBool loadError = false.obs;

  final TextEditingController commentController = TextEditingController();
  final Rxn<int> replyToId = Rxn<int>();
  final Rxn<String> replyToUser = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PostModel) {
      post.value = args;
      loadComments();
    } else if (args is int) {
      loadPost(args);
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  Future<void> loadPost(int postId) async {
    isLoading.value = true;
    loadError.value = false;
    try {
      final response = await _repository.getPostDetail(postId);
      if (response.isSuccess && response.data != null) {
        post.value = response.data;
        loadComments();
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

  /// 加载评论列表
  Future<void> loadComments() async {
    if (post.value == null) return;
    isLoadingComments.value = true;
    try {
      final response = await _repository.getComments(postId: post.value!.id);
      if (response.isSuccess && response.data != null) {
        comments.value = response.data!;
      }
    } catch (e) {
      LogUtil.e('加载评论失败: $e', tag: _tag);
    } finally {
      isLoadingComments.value = false;
    }
  }

  /// 设置回复目标
  void setReplyTarget(int commentId, String userName) {
    replyToId.value = commentId;
    replyToUser.value = userName;
    commentController.text = '@$userName ';
  }

  void clearReplyTarget() {
    replyToId.value = null;
    replyToUser.value = null;
    commentController.clear();
  }

  /// 发表评论
  Future<void> submitComment() async {
    final content = commentController.text.trim();
    if (content.isEmpty) {
      ToastUtil.showError('请输入评论内容');
      return;
    }
    try {
      await _repository.createComment(
        postId: post.value!.id,
        content: content,
        parentId: replyToId.value,
      );
      ToastUtil.showSuccess('评论成功');
      clearReplyTarget();
      loadComments();
    } catch (e) {
      ToastUtil.showError('$e');
    }
  }

  /// 评论点赞
  Future<void> toggleCommentLike(int commentId) async {
    final index = _findCommentIndex(commentId);
    if (index == -1) return;
    final c = comments[index];
    comments[index] = CommentModel(
      id: c.id,
      postId: c.postId,
      parentId: c.parentId,
      userId: c.userId,
      userName: c.userName,
      userAvatar: c.userAvatar,
      content: c.content,
      likeCount: c.isLiked ? c.likeCount - 1 : c.likeCount + 1,
      isLiked: !c.isLiked,
      replies: c.replies,
      createTime: c.createTime,
    );
    comments.refresh();
    await _repository.toggleCommentLike(commentId);
  }

  /// 删除评论
  Future<void> deleteComment(int commentId) async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
      title: const Text('删除评论'),
      content: const Text('确定要删除这条评论吗？'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false), child: const Text('取消')),
        TextButton(
            onPressed: () => Get.back(result: true), child: const Text('删除')),
      ],
    ));
    if (confirmed != true) return;
    try {
      await _repository.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
      ToastUtil.showSuccess('已删除');
    } catch (e) {
      ToastUtil.showError('$e');
    }
  }

  int _findCommentIndex(int id) {
    return comments.indexWhere((c) => c.id == id);
  }

  Future<void> toggleLike() async {
    if (post.value == null) return;
    final p = post.value!;
    final newLiked = !p.isLiked;
    post.value = p.copyWith(
      isLiked: newLiked,
      likeCount: newLiked ? p.likeCount + 1 : p.likeCount - 1,
    );
    await _repository.toggleLike(p.id);
  }

  Future<void> toggleCollect() async {
    if (post.value == null) return;
    final p = post.value!;
    post.value = p.copyWith(isCollected: !p.isCollected);
    await _repository.toggleCollect(p.id);
  }

  void share() {
    if (post.value == null) return;
    final url = 'https://app.example.com/post/${post.value!.id}';
    Clipboard.setData(ClipboardData(text: url));
    ToastUtil.showSuccess('链接已复制');
  }
}
