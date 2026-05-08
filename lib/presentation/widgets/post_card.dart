import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';
import '../../data/models/post_model.dart';

/// 帖子网格卡片
class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const PostCard({super.key, required this.post, this.onTap, this.onLike});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 封面图
            if (post.images.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  post.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 10,
                child: _buildPlaceholderImage(),
              ),
            // 内容区
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // 作者信息
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10.r,
                        backgroundImage: post.authorAvatar != null
                            ? NetworkImage(post.authorAvatar!)
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: post.authorAvatar == null
                            ? Icon(Icons.person, size: 12.sp, color: Colors.grey)
                            : null,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          post.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                        ),
                      ),
                      Text(
                        _formatTime(post.createTime),
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // 互动数据
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 14.sp,
                              color:
                                  post.isLiked ? Colors.red : Colors.grey[400],
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${post.likeCount}',
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 14.sp, color: Colors.grey[400]),
                          SizedBox(width: 2.w),
                          Text(
                            '${post.commentCount}',
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.image_rounded, size: 32.sp, color: Colors.grey[300]),
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
      return '${dt.month}-${dt.day}';
    } catch (_) {
      return time;
    }
  }
}
