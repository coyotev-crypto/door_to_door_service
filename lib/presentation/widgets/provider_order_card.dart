import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../data/models/order_model.dart';

/// 服务商订单卡片（接单列表）
class ProviderOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onEnRoute;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const ProviderOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onEnRoute,
    required this.onStart,
    required this.onComplete,
  });

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
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.person_rounded,
                size: 20.sp, color: AppTheme.gold),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.contactName ?? '客户',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  if (order.contactPhone?.isNotEmpty == true)
                    Text(order.contactPhone!,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondary)),
                ]),
          ),
          _statusBadge(order.status),
        ]),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppTheme.creamBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(children: [
            _infoRow(Icons.spa_rounded,
                order.serviceName ?? '服务', AppTheme.textPrimary),
            if (order.durationMinutes != null) ...[
              SizedBox(height: 6.h),
              _infoRow(Icons.timer_outlined,
                  '${order.durationMinutes} 分钟', AppTheme.textSecondary),
            ],
            SizedBox(height: 6.h),
            _infoRow(Icons.access_time_rounded,
                order.serviceTime ?? '', AppTheme.textSecondary),
            SizedBox(height: 6.h),
            _infoRow(Icons.location_on_outlined,
                order.addressName ?? '', AppTheme.textSecondary),
          ]),
        ),
        SizedBox(height: 12.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('¥',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold)),
            Text(price,
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.gold,
                    height: 1)),
          ]),
          ..._buildActions(order.status),
        ]),
      ]),
    );
  }

  List<Widget> _buildActions(int status) {
    switch (status) {
      case 0:
      case 1:
        return [
          _actionBtn('拒单', AppTheme.danger, AppTheme.danger.withValues(alpha: 0.85),
              onReject),
          SizedBox(width: 10.w),
          _actionBtn('接单', AppTheme.gold, AppTheme.amber, onAccept),
        ];
      case 2:
        return [
          _actionBtn('出发', AppTheme.gold, AppTheme.amber, onEnRoute),
        ];
      case 3:
        return [
          _actionBtn('开始服务', AppTheme.gold, AppTheme.amber, onStart),
        ];
      case 4:
        return [
          _actionBtn('完成服务', AppTheme.sage, const Color(0xFF5A7D6A),
              onComplete),
        ];
      default:
        return const [];
    }
  }

  static Widget _infoRow(IconData icon, String text, Color color) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(children: [
      Icon(icon, size: 14.sp, color: AppTheme.textMuted),
      SizedBox(width: 8.w),
      Expanded(
        child: Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.sp, color: color)),
      ),
    ]);
  }

  static Widget _statusBadge(int s) {
    final (c, l) = switch (s) {
      0 => (const Color(0xFFE8A838), '待接单'),
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

  static Widget _actionBtn(
      String label, Color c1, Color c2, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c1, c2]),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
                color: c1.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }
}
