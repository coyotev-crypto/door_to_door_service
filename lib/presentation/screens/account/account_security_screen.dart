import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../controllers/account_security_controller.dart';
import '../../../routes/route_names.dart';

/// 账户安全页面 — 温润质感·安全中心
class AccountSecurityScreen extends GetView<AccountSecurityController> {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('账户安全',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 20.sp, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        children: [
          _buildInfoBanner(),
          SizedBox(height: 28.h),
          _buildSectionHeader('账户保护'),
          SizedBox(height: 12.h),
          _buildCardGroup([
            _menuItem(
              icon: Icons.lock_outline_rounded,
              title: '登录密码',
              subtitle: '定期修改密码，保护账户安全',
              onTap: () => Get.toNamed(RouteNames.changePassword),
            ),
            _menuItem(
              icon: Icons.payment_outlined,
              title: '支付密码',
              subtitle: '用于支付时的安全验证',
              onTap: () => Get.toNamed(RouteNames.setPaymentPassword),
            ),
            _menuItem(
              icon: Icons.phone_android_rounded,
              title: '手机号更换',
              subtitle: '更换绑定的手机号码',
              onTap: () => Get.toNamed(RouteNames.changePhone),
              showDivider: false,
            ),
          ]),
          SizedBox(height: 28.h),
          _buildSectionHeader('设备与账号'),
          SizedBox(height: 12.h),
          _buildCardGroup([
            _menuItem(
              icon: Icons.devices_rounded,
              title: '登录设备管理',
              subtitle: '查看和管理已登录的设备',
              onTap: () => Get.toNamed(RouteNames.loginDevices),
            ),
            _menuItem(
              icon: Icons.delete_outline_rounded,
              title: '账号注销',
              subtitle: '永久删除账号及所有数据',
              iconColor: AppTheme.danger,
              onTap: () => _showDeleteAccountDialog(context),
              showDivider: false,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gold.withOpacity(0.08), AppTheme.gold.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.gold.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.security_rounded, size: 18.sp, color: AppTheme.gold),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '保护您的账户安全，建议定期检查并更新安全设置',
              style: TextStyle(
                  fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
      child: Row(
        children: [
          Container(
            width: 2.w,
            height: 16.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.gold, Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(title,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2D2A26).withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool showDivider = true,
  }) {
    final color = iconColor ?? AppTheme.gold;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, size: 20.sp, color: color),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        SizedBox(height: 2.h),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 12.sp, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 20.sp, color: AppTheme.warmBorder),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
              height: 1, indent: 72.w, endIndent: 16.w, color: AppTheme.warmBorder),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded,
                    size: 28.sp, color: AppTheme.danger),
              ),
              SizedBox(height: 16.h),
              Text('注销账号',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              SizedBox(height: 8.h),
              Text(
                '注销账号后，您的所有数据将被永久删除，无法恢复。确定要继续吗？',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.5),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 46.h,
                        decoration: BoxDecoration(
                          color: AppTheme.creamBg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text('取消',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteNames.deleteAccount);
                      },
                      child: Container(
                        height: 46.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.danger,
                              AppTheme.danger.withOpacity(0.85)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.danger.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Center(
                          child: Text('确定注销',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
