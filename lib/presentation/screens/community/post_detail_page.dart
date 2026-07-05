import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../data/models/comment_model.dart';
import '../../controllers/post_detail_controller.dart';
import '../../../core/themes/app_theme.dart';

/// 帖子详情页 — 小红书风格
class PostDetailPage extends GetView<PostDetailController> {
  const PostDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _backWithResult();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.creamBg,
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.loadError.value) {
            return _buildErrorView(context);
          }
          final post = controller.post.value;
          if (post == null) {
            return _buildNotFoundView(context);
          }
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(child: _buildBody(context, post)),
                  _buildCommentInputBar(context),
                ],
              ),
              _buildImmersiveAppBar(context),
            ],
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 沉浸式 AppBar
  // ═══════════════════════════════════════════
  Widget _buildImmersiveAppBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          children: [
            GestureDetector(
              onTap: _backWithResult,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_rounded,
                    size: 20.sp, color: Colors.white),
              ),
            ),
            const Spacer(),
            if (controller.post.value != null &&
                controller.canManagePost(controller.post.value!))
              GestureDetector(
                onTap: () => controller.deletePost(),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18.sp, color: Colors.white),
                ),
              ),
            GestureDetector(
              onTap: () => controller.share(),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.share_rounded, size: 18.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 主体滚动区
  // ═══════════════════════════════════════════
  Widget _buildBody(BuildContext context, post) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageGallery(context, post),
          _buildUserInfo(context, post),
          _buildContent(post),
          _buildInteractionStats(post),
          _buildDivider(),
          _buildCommentsSection(context),
        ],
      ),
    );
  }

  // ── 图片画廊 ──
  Widget _buildImageGallery(BuildContext context, post) {
    final hasImages = post.images.isNotEmpty;
    final width = MediaQuery.of(context).size.width;
    final height = width * 4 / 3;

    return SizedBox(
      width: width,
      height: height,
      child: hasImages
          ? _ImageGallery(
              images: post.images,
              width: width,
              height: height,
              onDoubleTapLike: () {
                if (!post.isLiked) controller.toggleLike();
                _showLikeAnimation(context);
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF9F7F4),
      child: Center(
        child: Icon(Icons.image_rounded, size: 48.sp, color: Colors.grey[300]),
      ),
    );
  }

  // ── 用户信息 ──
  Widget _buildUserInfo(BuildContext context, post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: post.authorAvatar != null
                ? NetworkImage(post.authorAvatar!)
                : null,
            backgroundColor: Colors.grey[200],
            child: post.authorAvatar == null
                ? Icon(Icons.person, size: 18.sp, color: Colors.grey)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.authorName,
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                Text(_formatTime(post.createTime),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 标题 + 正文 ──
  Widget _buildContent(post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3)),
          SizedBox(height: 10.h),
          Text(post.content,
              style: TextStyle(
                  fontSize: 15.sp, color: Colors.black87, height: 1.65)),
        ],
      ),
    );
  }

  // ── 互动统计 ──
  Widget _buildInteractionStats(post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.toggleLike(),
            child: _buildStatItem(
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              post.likeCount,
              post.isLiked ? Colors.red : Colors.grey[500]!,
            ),
          ),
          SizedBox(width: 20.w),
          _buildStatItem(Icons.chat_bubble_outline_rounded,
              _totalCommentCount(), Colors.grey[500]!),
          SizedBox(width: 20.w),
          // GestureDetector(
          //   onTap: () => controller.toggleCollect(),
          //   child: _buildStatItem(
          //     post.isCollected ? Icons.star_rounded : Icons.star_border_rounded,
          //     0,
          //     post.isCollected ? AppTheme.gold : Colors.grey[500]!,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 4.w),
        Text(_formatCount(count),
            style: TextStyle(fontSize: 13.sp, color: color)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 6.h,
      color: const Color(0xFFF9F7F4),
    );
  }

  // ═══════════════════════════════════════════
  // 评论区
  // ═══════════════════════════════════════════
  Widget _buildCommentsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('评论 (${_totalCommentCount()})',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          SizedBox(height: 12.h),
          Obx(() {
            if (controller.isLoadingComments.value) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator()));
            }
            if (controller.comments.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Text('暂无评论，来说两句吧',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                    textAlign: TextAlign.center),
              );
            }
            return Column(
              children: controller.comments
                  .map((c) => _buildCommentItem(context, c, 0))
                  .toList(),
            );
          }),
          SizedBox(height: 120.h), // 避开底部操作栏
        ],
      ),
    );
  }

  Widget _buildCommentItem(
      BuildContext context, CommentModel comment, int depth) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: depth > 0 ? EdgeInsets.only(left: 12.w) : EdgeInsets.zero,
      decoration: depth > 0
          ? const BoxDecoration(
              border:
                  Border(left: BorderSide(color: Color(0xFFE8E2D8), width: 2)),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.only(left: depth > 0 ? 12.w : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundImage: comment.userAvatar != null
                      ? NetworkImage(comment.userAvatar!)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 14.sp, color: Colors.grey),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(comment.userName,
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          SizedBox(width: 8.w),
                          Text(_formatTime(comment.createTime),
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.grey[400])),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(comment.content,
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              height: 1.45)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.only(left: 36.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.toggleCommentLike(comment.id),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          comment.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14.sp,
                          color:
                              comment.isLiked ? Colors.red : Colors.grey[400],
                        ),
                        if (comment.likeCount > 0) ...[
                          SizedBox(width: 3.w),
                          Text('${comment.likeCount}',
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.grey[400])),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                  GestureDetector(
                    onTap: () =>
                        controller.setReplyTarget(comment.id, comment.userName),
                    child: Text('回复',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey[500])),
                  ),
                  if (controller.canManageComment(comment)) ...[
                    SizedBox(width: 20.w),
                    GestureDetector(
                      onTap: () => controller.deleteComment(comment.id),
                      child: Text('删除',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey[400])),
                    ),
                  ],
                ],
              ),
            ),
            // 子回复
            if (comment.replies.isNotEmpty && depth < 1)
              ...comment.replies
                  .map((r) => _buildCommentItem(context, r, depth + 1)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 底部评论输入栏
  // ═══════════════════════════════════════════
  Widget _buildCommentInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: MediaQuery.of(context).padding.bottom + 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() {
            if (controller.replyToUser.value != null) {
              return GestureDetector(
                onTap: () => controller.clearReplyTarget(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  margin: EdgeInsets.only(right: 4.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('@${controller.replyToUser.value}',
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Theme.of(context).primaryColor)),
                      SizedBox(width: 2.w),
                      Icon(Icons.close,
                          size: 12.sp, color: Theme.of(context).primaryColor),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: SizedBox(
              height: 38.h,
              child: TextField(
                controller: controller.commentController,
                decoration: InputDecoration(
                  hintText: '说点什么...',
                  hintStyle:
                      TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: const BorderSide(color: Color(0xFFE8E2D8)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF9F7F4),
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => controller.submitComment(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, size: 16.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 错误 / 404 / 工具方法
  // ═══════════════════════════════════════════
  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 56.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('加载失败',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
          SizedBox(height: 16.h),
          ElevatedButton(
              onPressed: () =>
                  controller.loadPost(controller.post.value?.id ?? 0),
              child: const Text('重试')),
        ],
      ),
    );
  }

  Widget _buildNotFoundView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 72.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('帖子不存在或已被删除',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
          SizedBox(height: 16.h),
          TextButton(onPressed: () => Get.back(), child: const Text('返回')),
        ],
      ),
    );
  }

  void _showLikeAnimation(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 0.0),
          duration: const Duration(milliseconds: 800),
          onEnd: () => entry.remove(),
          builder: (_, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 2.0 - value,
                child: child,
              ),
            );
          },
          child: Center(
            child: Icon(Icons.favorite, size: 80.sp, color: Colors.red),
          ),
        );
      },
    );
    overlay.insert(entry);
  }

  void _backWithResult() {
    Get.back(result: controller.post.value);
  }

  int _totalCommentCount() {
    return controller.comments
        .fold<int>(0, (total, comment) => total + _countComment(comment));
  }

  int _countComment(CommentModel comment) {
    return 1 +
        comment.replies
            .fold<int>(0, (total, reply) => total + _countComment(reply));
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}w';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  String _formatTime(String time) {
    try {
      final dt = DateTime.parse(time);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
      if (diff.inHours < 24) return '${diff.inHours}小时前';
      if (diff.inDays < 30) return '${diff.inDays}天前';
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return time;
    }
  }
}

/// 图片画廊 + 轮播指示器
class _ImageGallery extends StatefulWidget {
  final List<String> images;
  final double width;
  final double height;
  final VoidCallback onDoubleTapLike;

  const _ImageGallery({
    required this.images,
    required this.width,
    required this.height,
    required this.onDoubleTapLike,
  });

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF9F7F4),
                      child: Center(
                        child: Icon(Icons.image_rounded,
                            size: 48.sp, color: Colors.grey[300]),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: widget.onDoubleTapLike,
                  ),
                ],
              );
            },
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 12.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: _currentIndex == i ? 16.w : 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: _currentIndex == i
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
