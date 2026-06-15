import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';

/// 订单状态徽章组件
class OrderStatusBadge extends StatelessWidget {
  final int status;
  final bool isProvider;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isProvider = false,
  });

  @override
  Widget build(BuildContext context) {
    final (c, l) = switch (status) {
      0 => (const Color(0xFFE8A838), isProvider ? '待接单' : '待支付'),
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
}
