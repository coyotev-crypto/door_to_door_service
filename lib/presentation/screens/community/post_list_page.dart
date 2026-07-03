import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../data/models/post_model.dart';
import '../../controllers/post_list_controller.dart';
import '../../widgets/post_card.dart';
import '../../widgets/post_skeleton.dart';

/// 社区帖子列表页面
class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late final PostListController controller;
  final EasyRefreshController _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    controller = Get.find<PostListController>();
    controller.onRefresh();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await controller.onRefresh();
    _refreshController.finishRefresh();
  }

  Future<void> _onLoad() async {
    if (!controller.hasMore.value) {
      _refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    await controller.onLoadMore();
    _refreshController.finishLoad(
      controller.hasMore.value
          ? IndicatorResult.success
          : IndicatorResult.noMore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          final posts = controller.posts.toList();
          final isLoading = controller.isLoading.value;
          if (isLoading && posts.isEmpty) {
            return _buildSkeletonGrid(context);
          }
          if (posts.isEmpty) {
            return EasyRefresh(
              onRefresh: controller.onRefresh,
              child: _buildEmptyView(context),
            );
          }
          return _buildGridView(context, posts);
        }),
        Positioned(
          right: 16.w,
          bottom: 76.h,
          child: FloatingActionButton(
            onPressed: () => controller.navigateToCreate(),
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add_rounded, size: 28.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.56,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const PostSkeleton(),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 120.h),
        Center(
          child: Column(
            children: [
              Icon(Icons.forum_rounded, size: 72.sp, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text('还没有帖子',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
              SizedBox(height: 8.h),
              Text('快来发布第一条帖子吧',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[400])),
              SizedBox(height: 24.h),
              SizedBox(
                width: 180.w,
                height: 44.h,
                child: ElevatedButton.icon(
                  onPressed: () => controller.navigateToCreate(),
                  icon: Icon(Icons.edit_rounded, size: 18.sp),
                  label: Text('发布帖子',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w600)),
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
        ),
      ],
    );
  }

  Widget _buildGridView(BuildContext context, List<PostModel> posts) {
    return EasyRefresh(
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoad: _onLoad,
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.56,
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return RepaintBoundary(
            child: PostCard(
              post: post,
              onTap: () => controller.navigateToDetail(post),
              onLike: () => controller.toggleLike(post.id),
            ),
          );
        },
      ),
    );
  }
}
