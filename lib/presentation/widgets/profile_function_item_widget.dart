
import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/screen_adapter.dart';

/// 个人中心功能项组件
class ProfileFunctionItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileFunctionItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.servicePrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 22.sp,
              color: AppTheme.servicePrimaryColor,
            ),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: Colors.grey[400],
          ),
          onTap: onTap,
        ),
        Divider(
          height: 1.h,
          indent: 72.w,
          endIndent: 16.w,
          color: Colors.grey[200],
        ),
      ],
    );
  }
}
