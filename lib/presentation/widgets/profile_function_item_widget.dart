import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';
import '../../core/themes/app_theme.dart';

/// 个人中心功能项 — 温润质感
class ProfileFunctionItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showDivider;

  const ProfileFunctionItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.gold;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, size: 20.sp, color: color),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary)),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 18.sp, color: AppTheme.warmBorder),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 66.w, endIndent: 16.w, color: AppTheme.warmBorder),
      ],
    );
  }
}
