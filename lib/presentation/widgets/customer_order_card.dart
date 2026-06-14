import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/utils/toast_util.dart';
import '../../../data/models/order_model.dart';
import '../controllers/order_list_controller.dart';
import '../../../routes/route_names.dart';

/// 用户订单卡片（我的订单）
class CustomerOrderCard extends StatelessWidget {
  final OrderModel order;
  const CustomerOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final price = order.totalPrice ?? order.servicePrice ?? '0';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
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
        ]),
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
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (order.createTime != null)
            Text(_formatDate(order.createTime!),
                style: TextStyle(
                    fontSize: 11.sp, color: AppTheme.textMuted)),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('¥',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold)),
            Text(price,
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.gold,
                    height: 1)),
          ]),
        ]),
        // 待支付 → 去支付
        if (order.status == 0) ...[
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              Get.toNamed(RouteNames.orderPayment, arguments: {
                'orderId': order.id,
                'orderNo': order.orderNo ?? '${order.id}',
                'amount': order.totalPrice ?? '0',
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
        ],
        // 已支付但未完成 → 申请退款
        if (order.status >= 1 && order.status <= 4 && order.refundStatus == 0) ...[
          SizedBox(height: 12.h),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(
              onTap: () => _showRefundDialog(context),
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.gold, width: 1.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text('申请退款',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold)),
                ),
              ),
            ),
          ]),
        ],
        if (order.refundStatus > 0) ...[
          SizedBox(height: 12.h),
          _buildRefundStatusBanner(),
        ],
      ]),
    );
  }

  static Widget _statusBadge(int s) {
    final (c, l) = switch (s) {
      0 => (const Color(0xFFE8A838), '待支付'),
      1 => (const Color(0xFF7BA5C2), '待接单'),
      2 => (const Color(0xFF5A8DB5), '已接单'),
      3 => (const Color(0xFF6B9EBF), '待上门'),
      4 => (AppTheme.sage, '服务中'),
      5 => (AppTheme.textMuted, '已完成'),
      6 => (AppTheme.danger, '已取消'),
      _ => (AppTheme.textMuted, ''),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.r)),
      child: Text(l,
          style: TextStyle(
              fontSize: 12.sp, color: c, fontWeight: FontWeight.w600)),
    );
  }

  void _showRefundDialog(BuildContext context) {
    final reasonCtl = TextEditingController();
    final selectedReason = ''.obs;

    Get.defaultDialog(
      title: '申请退款',
      titleStyle: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('请选择退款原因',
              style:
                  TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
          SizedBox(height: 12.h),
          ...['不需要此服务', '误操作 / 重复下单', '价格不合理', '其他原因'].map((reason) {
            return Obx(() {
              final active = selectedReason.value == reason;
              return GestureDetector(
                onTap: () {
                  selectedReason.value = reason;
                  reasonCtl.text = reason;
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.gold.withValues(alpha: 0.08)
                        : Colors.white,
                    border: Border.all(
                      color:
                          active ? AppTheme.gold : AppTheme.warmBorder,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(reason,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: active
                              ? AppTheme.gold
                              : AppTheme.textSecondary)),
                ),
              );
            });
          }),
          SizedBox(height: 8.h),
          TextField(
            controller: reasonCtl,
            maxLines: 2,
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: '补充说明（选填）',
              hintStyle: TextStyle(
                  fontSize: 12.sp, color: AppTheme.textMuted),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppTheme.warmBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppTheme.warmBorder),
              ),
            ),
          ),
        ],
      ),
      textConfirm: '提交申请',
      textCancel: '取消',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.gold,
      onConfirm: () {
        if (reasonCtl.text.isEmpty) {
          ToastUtil.showError('请选择或填写退款原因');
          return;
        }
        Get.find<OrderListController>()
            .requestRefund(order.id, reasonCtl.text);
        Get.back();
      },
    );
  }

  Widget _buildRefundStatusBanner() {
    final (c, l, icon) = switch (order.refundStatus) {
      1 => (const Color(0xFFFFA500), '退款申请中，请等待审核', Icons.hourglass_empty_rounded),
      2 => (AppTheme.sage, '退款已批准', Icons.check_circle_outline_rounded),
      3 => (AppTheme.danger, '退款已拒绝', Icons.cancel_outlined),
      4 => (AppTheme.sage, '已退款', Icons.monetization_on_outlined),
      _ => (AppTheme.textMuted, '', Icons.info_outline),
    };
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        border: Border.all(color: c.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(children: [
        Icon(icon, size: 18.sp, color: c),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l,
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: c,
                      fontWeight: FontWeight.w600)),
              if (order.refundReason?.isNotEmpty == true) ...[
                SizedBox(height: 4.h),
                Text('原因：${order.refundReason}',
                    style: TextStyle(
                        fontSize: 11.sp, color: AppTheme.textMuted)),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  static Widget _infoRow(IconData icon, String text) {
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
              style: TextStyle(
                  fontSize: 12.sp, color: AppTheme.textSecondary)),
        ),
      ]),
    );
  }

  static final Map<String, String> _dc = {};
  static String _formatDate(String t) {
    if (_dc.containsKey(t)) return _dc[t]!;
    try {
      final d = DateTime.parse(t);
      final r =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      _dc[t] = r;
      return r;
    } catch (_) {
      return t;
    }
  }
}
