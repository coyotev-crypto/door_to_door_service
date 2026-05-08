import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/post_list_controller.dart';
import '../../widgets/post_card.dart';
import '../../widgets/post_skeleton.dart';

/// 社区帖子列表页面
class PostListPage extends GetView<PostListController> {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.posts.isEmpty) {
        return _buildSkeletonGrid(context);
      }
      if (controller.posts.isEmpty) {
        return _buildEmptyView(context);
      }
      return _buildGridView(context);
    });
  }

  int _getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 768) return 3;
    if (width >= 480) return 2;
    return 1;
  }

  Widget _buildSkeletonGrid(BuildContext context) {
    final columns = _getColumnCount(context);
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.72,
      ),
      itemCount: columns * 2,
      itemBuilder: (_, __) => const PostSkeleton(),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_rounded, size: 72.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            '还没有帖子',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
          ),
          SizedBox(height: 8.h),
          Text(
            '快来发布第一条帖子吧',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: 180.w,
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: () => controller.navigateToCreate(),
              icon: Icon(Icons.edit_rounded, size: 18.sp),
              label: Text('发布帖子',
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final columns = _getColumnCount(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          if (controller.hasMore.value && !controller.isLoading.value) {
            controller.loadPosts();
          }
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.72,
        ),
        itemCount:
            controller.posts.length + (controller.hasMore.value ? columns : 0),
        itemBuilder: (context, index) {
          if (index >= controller.posts.length) {
            return const PostSkeleton();
          }
          final post = controller.posts[index];
          return PostCard(
            post: post,
            onTap: () => controller.navigateToDetail(post),
            onLike: () => controller.toggleLike(post.id),
          );
        },
      ),
    );
  }
}
