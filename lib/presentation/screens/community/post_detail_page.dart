import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/post_detail_controller.dart';

/// 帖子详情页面
class PostDetailPage extends GetView<PostDetailController> {
  const PostDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('帖子详情',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.share(),
            icon: Icon(Icons.share_rounded, size: 22.sp),
          ),
        ],
      ),
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
        return _buildContent(context, post);
      }),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 56.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('加载失败', style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
          SizedBox(height: 16.h),
          ElevatedButton(onPressed: () => controller.loadPost(controller.post.value?.id ?? 0), child: const Text('重试')),
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

  Widget _buildContent(BuildContext context, post) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(post.title,
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.4)),
          SizedBox(height: 16.h),
          // 作者信息
          Row(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  Text(_formatTime(post.createTime),
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 16.h),
          // 正文
          Text(post.content,
              style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                  height: 1.7)),
          // 图片
          if (post.images.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: post.images.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    url,
                    width: (MediaQuery.of(context).size.width - 56.w) / 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: (MediaQuery.of(context).size.width - 56.w) / 2,
                      height: 120.h,
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          // 标签
          if (post.tags.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Wrap(
              spacing: 8.w,
              children: post.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('#$tag',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).primaryColor)),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 24.h),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 16.h),
          // 操作栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: post.isLiked
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: '${post.likeCount}',
                color: post.isLiked ? Colors.red : Colors.grey[600]!,
                onTap: () => controller.toggleLike(),
              ),
              _buildActionButton(
                icon: post.isCollected
                    ? Icons.star
                    : Icons.star_border,
                label: '收藏',
                color: post.isCollected
                    ? Colors.amber
                    : Colors.grey[600]!,
                onTap: () => controller.toggleCollect(),
              ),
              _buildActionButton(
                icon: Icons.share_rounded,
                label: '分享',
                color: Colors.grey[600]!,
                onTap: () => controller.share(),
              ),
            ],
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22.sp, color: color),
          SizedBox(width: 6.w),
          Text(label,
              style: TextStyle(
                  fontSize: 14.sp, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final dt = DateTime.parse(time);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
      if (diff.inHours < 24) return '${diff.inHours}小时前';
      if (diff.inDays < 30) return '${diff.inDays}天前';
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return time;
    }
  }
}
