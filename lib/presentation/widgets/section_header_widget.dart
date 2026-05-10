import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';
import '../../core/themes/app_theme.dart';

/// 章节标题组件 — 渐变装饰线 + 标题 + 可选标签
class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final String? badge;
  final Color accentColor;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.badge,
    this.accentColor = AppTheme.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 2.w, height: 22.h,
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [accentColor, accentColor.withOpacity(0)],
              ),
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(title,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary, height: 1)),
          if (badge != null) ...[
            SizedBox(width: 8.w),
            Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                border: Border.all(color: accentColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(badge!, style: TextStyle(fontSize: 9.sp, color: accentColor,
                  fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ],
        ],
      ),
    );
  }
}
