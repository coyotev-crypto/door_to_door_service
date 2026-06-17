import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/screen_adapter.dart';
import '../../core/themes/app_theme.dart';
import '../controllers/profile_controller.dart';
import 'user_avatar_widget.dart';

/// 个人中心头部 — 温润质感
class ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileHeaderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF2D2A26).withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(
          children: [
            // 用户信息行
            Row(
              children: [
                // 头像
                GestureDetector(
                  onTap: () => controller.navigateToProfileEdit(),
                  child: UserAvatarWidget(
                    avatarUrl: user?.avatar,
                    username: user?.nickname,
                    size: 64.w,
                  ),
                ),
                SizedBox(width: 16.w),
                // 昵称 + 手机号 + 简介
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(user?.nickname ?? '未设置昵称',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                        ),
                        SizedBox(width: 6.w),
                        _genderBadge(user?.gender),
                      ]),
                      SizedBox(height: 4.h),
                      if (user?.phoneNumber != null &&
                          user!.phoneNumber.isNotEmpty)
                        Text(user.phoneNumber,
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppTheme.textSecondary)),
                      SizedBox(height: 4.h),
                      Text(
                        user?.remark?.trim().isNotEmpty == true
                            ? user!.remark!.trim()
                            : '这个人很神秘，什么都没留下',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.sp, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                // 编辑按钮
                GestureDetector(
                  onTap: () => controller.navigateToProfileEdit(),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.edit_rounded,
                        size: 16.sp, color: AppTheme.gold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // 快捷入口
            Row(children: [
              Expanded(
                  child: _quickEntry(Icons.business_center_rounded, '服务商入驻',
                      () => controller.navigateToProviderJoin())),
              SizedBox(width: 12.w),
              Expanded(
                  child: _quickEntry(Icons.security_rounded, '账户安全',
                      () => controller.navigateToAccountSecurity())),
            ]),
          ],
        ),
      );
    });
  }

  Widget _genderBadge(String? gender) {
    IconData icon;
    Color color;
    switch (gender) {
      case '1':
        icon = Icons.male_rounded;
        color = const Color(0xFF7B9CC2);
        break;
      case '2':
        icon = Icons.female_rounded;
        color = const Color(0xFFD4959F);
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, size: 14.sp, color: color),
    );
  }

  Widget _quickEntry(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.warmBorder),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 17.sp, color: AppTheme.gold),
          SizedBox(width: 6.w),
          Text(label,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }
}
