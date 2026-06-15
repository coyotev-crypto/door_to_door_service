import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../data/models/order_model.dart';
import 'primary_button.dart';
import 'order_status_badge.dart';

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
          OrderStatusBadge(status: order.status, isProvider: true),
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
          Expanded(
            child: PrimaryButton(
              text: '拒单',
              gradientColors: const [AppTheme.danger, AppTheme.danger],
              onPressed: onReject,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: PrimaryButton(
              text: '接单',
              gradientColors: const [AppTheme.gold, AppTheme.amber],
              onPressed: onAccept,
            ),
          ),
        ];
      case 2:
        return [
          Expanded(
            child: PrimaryButton(
              text: '出发',
              gradientColors: const [AppTheme.gold, AppTheme.amber],
              onPressed: onEnRoute,
            ),
          ),
        ];
      case 3:
        return [
          Expanded(
            child: PrimaryButton(
              text: '开始服务',
              gradientColors: const [AppTheme.gold, AppTheme.amber],
              onPressed: onStart,
            ),
          ),
        ];
      case 4:
        return [
          Expanded(
            child: PrimaryButton(
              text: '完成服务',
              gradientColors: const [AppTheme.sage, Color(0xFF5A7D6A)],
              onPressed: onComplete,
            ),
          ),
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
}
