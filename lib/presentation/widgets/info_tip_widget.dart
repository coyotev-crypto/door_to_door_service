import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';

/// 信息提示组件
class InfoTipWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const InfoTipWidget({
    super.key,
    required this.message,
    this.icon,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? AppTheme.servicePrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.info_outline_rounded,
            color: iconColor ?? AppTheme.servicePrimaryColor,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
