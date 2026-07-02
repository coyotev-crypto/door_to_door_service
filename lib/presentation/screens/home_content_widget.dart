import 'package:dtd/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../core/utils/screen_adapter.dart';
import '../widgets/category_filter_bar_widget.dart';
import '../widgets/service_card_widget.dart';
import '../controllers/home_content_controller.dart';
import '../controllers/service_controller.dart';
import '../widgets/home_search_bar_widget.dart';
import '../widgets/empty_placeholder_widget.dart';
import '../widgets/section_header_widget.dart';
import '../../core/themes/app_theme.dart';

/// 首页内容组件 — CustomScrollView + Slivers
class HomeContentWidget extends GetWidget<HomeContentController> {
  final Future<void> Function() onRefresh;
  final serviceController = Get.find<ServiceController>();

  HomeContentWidget({super.key, required this.onRefresh});

  Future<void> _onRefresh() async {
    try {
      await onRefresh();
      await controller.refreshServices();
    } catch (e) {
      if (Get.context?.mounted == true) {
        ScaffoldMessenger.of(Get.context!)
            .showSnackBar(SnackBar(content: Text('刷新失败: $e')));
      }
    }
  }

  Future<void> _onLoad() async {
    try {
      await controller.loadMoreServices();
    } catch (e) {
      if (Get.context?.mounted == true) {
        ScaffoldMessenger.of(Get.context!)
            .showSnackBar(SnackBar(content: Text('加载更多失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 固定顶部：搜索栏 + 分类导航
        RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: AppTheme.textPrimary.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                    child: HomeSearchBarWidget(
                  onSearchTap: () => Get.toNamed(RouteNames.search),
                )),
                GetBuilder<HomeContentController>(
                  id: 'category',
                  builder: (ctrl) => CategoryFilterBarWidget(
                    categories: ctrl.categories,
                    selectedIndex: ctrl.selectedCategoryIndex,
                    onCategorySelected: (index) =>
                        ctrl.handleCategorySelected(index),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 可滚动内容区 — Slivers 避免 shrinkWrap
        Expanded(
          child: Obx(
            () => EasyRefresh(
              controller: controller.refreshController,
              onRefresh: _onRefresh,
              onLoad: _onLoad,
              child: CustomScrollView(
                scrollCacheExtent: const ScrollCacheExtent.pixels(800),
                slivers: [
                  const SliverToBoxAdapter(
                      child: SectionHeaderWidget(
                          title: '推荐商户', badge: '精选')),
                  // 服务列表
                  if (controller.services.isEmpty)
                    const SliverFillRemaining(
                      child: EmptyPlaceholderWidget(
                          message: '暂无推荐商户', constrainHeight: true),
                    )
                  else
                    SliverList.builder(
                      itemCount: controller.services.length,
                      itemBuilder: (context, index) {
                        final service = controller.services[index];
                        return RepaintBoundary(
                          child: Column(
                            children: [
                              ServiceCardWidget(
                                service: service,
                                onTap: () => Get.toNamed(
                                    RouteNames.orderCreate,
                                    arguments: service),
                                onOrderTap: () => Get.toNamed(
                                    RouteNames.orderCreate,
                                    arguments: service),
                                onFavoriteTap: () async {
                                  final s =
                                      !(service.isFavorite ?? false);
                                  final success =
                                      await serviceController.toggleFavorite(
                                    service.id,
                                    s,
                                  );
                                  if (!success) return;
                                },
                              ),
                              if (index <
                                  controller.services.length - 1)
                                Divider(
                                    height: 1,
                                    indent: 16.w,
                                    endIndent: 16.w,
                                    color: AppTheme.warmBorder),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
