import 'package:flutter/material.dart';
import '../../../core/utils/screen_adapter.dart';

/// 警告信息组件
class WarningInfoWidget extends StatelessWidget {
  final String title;
  final String description;
  final List<String> warningItems;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? textColor;

  const WarningInfoWidget({
    super.key,
    required this.title,
    required this.description,
    required this.warningItems,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? Colors.red[700];
    final defaultBackgroundColor = backgroundColor ?? Colors.red[50];
    final defaultTextColor = textColor ?? Colors.red[700];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon ?? Icons.warning_amber_rounded,
                color: defaultIconColor,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  color: defaultIconColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: TextStyle(
              color: defaultTextColor,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          ...warningItems.map((item) => _buildWarningItem(item, defaultTextColor)),
        ],
      ),
    );
  }

  /// 构建警告项
  Widget _buildWarningItem(String text, Color? textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14.sp,
          height: 1.5,
        ),
      ),
    );
  }
}
