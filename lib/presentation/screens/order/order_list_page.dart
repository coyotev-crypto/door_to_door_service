import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../data/models/order_model.dart';
import '../../../routes/route_names.dart';
import '../../controllers/order_list_controller.dart';

/// 订单列表页面 — 温润质感
class OrderListPage extends GetView<OrderListController> {
  const OrderListPage({super.key});

  static const _tabs = ['全部', '待支付', '进行中', '已完成'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('我的订单',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Obx(() {
        final selected = controller.selectedTab.value;
        return Row(
          children: List.generate(_tabs.length, (i) {
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
                        ? AppTheme.gold.withOpacity(0.1)
                        : AppTheme.creamBg,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: active ? AppTheme.gold : AppTheme.warmBorder,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppTheme.gold : AppTheme.textSecondary,
                    ),
                  ),
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
      if (controller.isLoading.value && controller.orders.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(
                color: AppTheme.gold, strokeWidth: 2.5));
      }

      if (controller.orders.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_rounded,
                  size: 32.sp, color: AppTheme.textMuted),
            ),
            SizedBox(height: 16.h),
            Text('暂无订单',
                style: TextStyle(fontSize: 15.sp, color: AppTheme.textMuted)),
          ]),
        );
      }

      return EasyRefresh(
        controller: controller.refreshController,
        onRefresh: () => controller.onRefresh(),
        onLoad: () => controller.onLoadMore(),
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
          itemCount: controller.orders.length,
          itemBuilder: (_, i) => _OrderCard(order: controller.orders[i]),
        ),
      );
    });
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final price = order.totalPrice ?? order.servicePrice ?? 0;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
              color: AppTheme.textPrimary.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(order.serviceName ?? '服务订单',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
              ),
              SizedBox(width: 8.w),
              _statusBadge(order.status),
            ],
          ),
          if (order.serviceTime?.isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            _infoRow(Icons.access_time_rounded, order.serviceTime!),
          ],
          SizedBox(height: 6.h),
          _infoRow(Icons.location_on_outlined, order.addressName ?? ''),
          if (order.contactName?.isNotEmpty == true) ...[
            SizedBox(height: 4.h),
            _infoRow(Icons.person_outline_rounded,
                '${order.contactName ?? ''}  ${order.contactPhone ?? ''}'),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (order.createTime != null)
                Text(_formatDate(order.createTime!),
                    style:
                        TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('¥',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gold)),
                Text(price.toStringAsFixed(0),
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.gold,
                        height: 1)),
              ]),
            ],
          ),
          // 待支付订单显示支付按钮
          if (order.status == 0) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(RouteNames.orderPayment, arguments: {
                    'orderId': order.id,
                    'orderNo': order.orderNo ?? '${order.id}',
                    'amount': (order.totalPrice ?? 0).toDouble(),
                    'serviceName': order.serviceName ?? '',
                    'durationMinutes': order.durationMinutes ?? 60,
                  });
                },
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.gold, AppTheme.amber]),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text('去支付',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(int status) {
    final (color, label) = switch (status) {
      0 => (const Color(0xFFE8A838), '待支付'),
      1 => (const Color(0xFF7BA5C2), '待服务'),
      2 => (const Color(0xFF6B8E7B), '进行中'),
      3 => (AppTheme.textMuted, '已完成'),
      4 => (AppTheme.danger, '已取消'),
      _ => (AppTheme.textMuted, ''),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12.sp, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(children: [
        Icon(icon, size: 14.sp, color: AppTheme.textMuted),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
        ),
      ]),
    );
  }

  static final Map<String, String> _dateCache = {};
  static String _formatDate(String time) {
    if (_dateCache.containsKey(time)) return _dateCache[time]!;
    try {
      final dt = DateTime.parse(time);
      final r =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      _dateCache[time] = r;
      return r;
    } catch (_) {
      return time;
    }
  }
}
