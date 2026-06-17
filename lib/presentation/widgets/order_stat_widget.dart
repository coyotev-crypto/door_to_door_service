import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';

/// 订单状态快捷入口（图标 + 角标 + 标签）
class OrderStatWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;
  final bool showBadge;
  final Color? iconColor;

  const OrderStatWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
    this.showBadge = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.gold;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(children: [
        Stack(children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 22.sp, color: color),
          ),
          if (showBadge && count > 0)
            Positioned(
                right: -4,
                top: -4,
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                        color: AppTheme.danger,
                        borderRadius: BorderRadius.circular(10.r)),
                    constraints:
                        BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                    child: Text(count > 99 ? '99+' : '$count',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center))),
        ]),
        SizedBox(height: 8.h),
        Text(label,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
      ]),
    );
  }
}
