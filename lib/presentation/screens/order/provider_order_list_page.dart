import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/order_list_controller.dart';
import '../../widgets/provider_order_card.dart';

/// 服务商接单列表
class ProviderOrderListPage extends GetView<OrderListController> {
  const ProviderOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('接单列表',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(children: [
        _buildTabBar(),
        Expanded(child: _buildOrderList()),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Obx(() {
        final tabs = controller.tabs;
        final selected = controller.selectedTab.value;
        return Row(
          children: List.generate(tabs.length, (i) {
            final active = i == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.switchTab(i),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.gold.withValues(alpha: 0.1)
                        : AppTheme.creamBg,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: active ? AppTheme.gold : AppTheme.warmBorder,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Text(tabs[i],
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color:
                              active ? AppTheme.gold : AppTheme.textSecondary)),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildOrderList() {
    return Obx(() {
      if (controller.orders.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(
                color: AppTheme.gold, strokeWidth: 2.5));
      }
      return EasyRefresh(
        controller: controller.refreshController,
        onRefresh: () => controller.onRefresh(),
        onLoad: controller.orders.isNotEmpty ? () => controller.onLoadMore() : null,
        child: controller.orders.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_rounded,
                        size: 32.sp, color: AppTheme.textMuted),
                  ),
                  SizedBox(height: 16.h),
                  Text('暂无订单',
                      style: TextStyle(fontSize: 15.sp, color: AppTheme.textMuted)),
                ]),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
                itemCount: controller.orders.length,
                itemBuilder: (_, i) => ProviderOrderCard(
                  order: controller.orders[i],
                  onAccept: () =>
                      controller.acceptOrder(controller.orders[i].id),
                  onReject: () =>
                      controller.rejectOrder(controller.orders[i].id),
                  onEnRoute: () =>
                      controller.enRouteOrder(controller.orders[i].id),
                  onStart: () =>
                      controller.startService(controller.orders[i].id),
                  onComplete: () =>
                      controller.completeService(controller.orders[i].id),
                ),
              ),
      );
    });
  }
}
