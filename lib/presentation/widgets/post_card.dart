import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';
import '../../data/models/post_model.dart';

/// 小红书风格笔记卡片
///
/// 布局从上到下：图片区 → 标题 → 用户信息
class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? Colors.black.withOpacity(0.04)
                  : Colors.white.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageArea(theme),
            _buildTitle(theme),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  /// 图片区域：3:4 竖图 + 点赞浮层
  Widget _buildImageArea(ThemeData theme) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: post.images.isNotEmpty
                ? Image.network(
                    post.images.first,
                    fit: BoxFit.cover,
                    cacheWidth: 512,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        // 点赞浮层
        Positioned(
          right: 8.w,
          bottom: 8.h,
          child: GestureDetector(
            onTap: onLike,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatCount(post.likeCount),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 标题：最多两行，超出省略
  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
      child: Text(
        post.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: theme.brightness == Brightness.light
              ? Colors.black87
              : Colors.white,
          height: 1.38,
        ),
      ),
    );
  }

  /// 底部：用户头像 + 昵称 + 时间
  Widget _buildFooter(ThemeData theme) {
    final textColor = theme.brightness == Brightness.light
        ? Colors.grey[600]!
        : Colors.grey[400]!;

    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundImage: post.authorAvatar != null
                ? ResizeImage(NetworkImage(post.authorAvatar!),
                    width: 48, height: 48)
                : null,
            backgroundColor: Colors.grey[200],
            child: post.authorAvatar == null
                ? Icon(Icons.person, size: 14.sp, color: Colors.grey[400])
                : null,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    post.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  ' · ${_formatTime(post.createTime)}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.image_rounded, size: 36.sp, color: Colors.grey[300]),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}w';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  static final Map<String, String> _timeCache = {};

  String _formatTime(String time) {
    final cached = _timeCache[time];
    if (cached != null) return cached;
    try {
      final dt = DateTime.parse(time);
      final diff = DateTime.now().difference(dt);
      final result = diff.inMinutes < 60
          ? '${diff.inMinutes}分钟前'
          : diff.inHours < 24
              ? '${diff.inHours}小时前'
              : diff.inDays < 7
                  ? '${diff.inDays}天前'
                  : '${dt.month}-${dt.day}';
      _timeCache[time] = result;
      return result;
    } catch (_) {
      _timeCache[time] = time;
      return time;
    }
  }
}
