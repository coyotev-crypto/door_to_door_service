import 'package:door_to_door_service/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import '../../core/utils/screen_adapter.dart';
import '../widgets/category_filter_bar_widget.dart';
import '../widgets/newcomer_recommendation_widget.dart';
import '../widgets/service_card_widget.dart';
import '../controllers/home_content_controller.dart';
import '../controllers/service_controller.dart';
import '../widgets/home_search_bar_widget.dart';
import '../widgets/empty_placeholder_widget.dart';

/// 首页内容组件
///
/// 展示首页的主要内容，包括搜索栏、分类导航、服务列表等
class HomeContentWidget extends GetWidget<HomeContentController> {
  final Future<void> Function() onRefresh;
  final bool isRefreshing;
  final serviceController = Get.find<ServiceController>();
  HomeContentWidget({
    super.key,
    required this.onRefresh,
    this.isRefreshing = false,
  });

  /// 下拉刷新
  Future<void> _onRefresh() async {
    try {
      await controller.refreshServices();
    } catch (e) {
      if (Get.context?.mounted == true) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('刷新失败: $e')),
        );
      }
    }
  }

  /// 上拉加载
  Future<void> _onLoad() async {
    try {
      await controller.loadMoreServices();
    } catch (e) {
      if (Get.context?.mounted == true) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('加载更多失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RepaintBoundary(
        child: Column(
          children: [
            // 固定在顶部的搜索栏和分类导航
            Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 搜索栏
                  RepaintBoundary(
                    child: HomeSearchBarWidget(
                      onSearchTap: () {
                        Get.toNamed(RouteNames.search);
                      },
                    ),
                  ),
                  // 分类筛选导航栏
                  GetBuilder<HomeContentController>(
                    id: 'category',
                    builder: (controller) => CategoryFilterBarWidget(
                      categories: controller.categories,
                      selectedIndex: controller.selectedCategoryIndex,
                      onCategorySelected: (index) {
                        controller.handleCategorySelected(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // 可滚动的内容区域
            Expanded(
              child: EasyRefresh(
                controller: controller.refreshController,
                onRefresh: _onRefresh,
                onLoad: _onLoad,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // 新人推荐
                      RepaintBoundary(
                        child: NewcomerRecommendationWidget(
                          services: controller.newcomerServices,
                          onMorePressed: () {
                            Get.toNamed(RouteNames.moreRecommendations,
                                arguments: {
                                  'provinceId': controller.provinceId,
                                  'cityId': controller.cityId,
                                  'areaId': controller.areaId,
                                });
                          },
                          onServiceTap: (service) {
                            // TODO: 跳转到服务详情
                          },
                        ),
                      ),
                      // 热门服务
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题
                            Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '推荐商户',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          'HOT',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 服务列表
                            controller.services.isEmpty
                                ? const EmptyPlaceholderWidget(
                                    message: '暂无推荐商户',
                                    constrainHeight: true,
                                  )
                                : RepaintBoundary(
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      cacheExtent: 5 * 140.h, // 缓存5个item的高度
                                      itemCount: controller.services.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        height: 1,
                                        color: Colors.grey[200],
                                      ),
                                      itemBuilder: (context, index) {
                                        final service =
                                            controller.services[index];
                                        return ServiceCardWidget(
                                          service: service,
                                          onTap: () {
                                            // TODO: 跳转到服务详情
                                          },
                                          onOrderTap: () {
                                            Get.toNamed(
                                                RouteNames.orderCreate,
                                                arguments: service);
                                          },
                                          onFavoriteTap: () async {
                                            final newFavoriteState =
                                                !(service.isFavorite ?? false);
                                            await serviceController
                                                .toggleFavorite(
                                              service.id,
                                              newFavoriteState,
                                            );
                                            // 更新本地服务列表中的收藏状态
                                            controller.updateServiceFavorite(
                                                service.id, newFavoriteState);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
