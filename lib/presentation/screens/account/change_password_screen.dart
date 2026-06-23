import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../controllers/account_security_controller.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/primary_input_field.dart';

/// 修改登录密码 — 温润质感
class ChangePasswordScreen extends GetView<AccountSecurityController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '修改登录密码'),
      body: Form(
        key: c.changePasswordFormKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          children: [
            _infoBanner(),
            SizedBox(height: 28.h),
            Obx(() => PrimaryInputField(
                controller: c.oldPasswordController,
                label: '旧密码',
                hintText: '请输入旧密码',
                obscureText: c.obscureOldPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(c.obscureOldPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20.sp, color: AppTheme.textMuted),
                  onPressed: c.toggleOldPasswordVisibility,
                ),
                validator: (v) => v == null || v.isEmpty
                    ? '请输入旧密码'
                    : v.length < 6
                        ? '密码长度不能少于6位'
                        : null)),
            SizedBox(height: 16.h),
            Obx(() => PrimaryInputField(
                controller: c.newPasswordController,
                label: '新密码',
                hintText: '请输入新密码',
                obscureText: c.obscureNewPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(c.obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20.sp, color: AppTheme.textMuted),
                  onPressed: c.toggleNewPasswordVisibility,
                ),
                validator: (v) => v == null || v.isEmpty
                    ? '请输入新密码'
                    : v.length < 6
                        ? '密码长度不能少于6位'
                        : null)),
            SizedBox(height: 16.h),
            Obx(() => PrimaryInputField(
                controller: c.confirmPasswordController,
                label: '确认密码',
                hintText: '请再次输入新密码',
                obscureText: c.obscureConfirmPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(c.obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20.sp, color: AppTheme.textMuted),
                  onPressed: c.toggleConfirmPasswordVisibility,
                ),
                validator: (v) => v == null || v.isEmpty
                    ? '请再次输入新密码'
                    : v != c.newPasswordController.text
                        ? '两次输入的密码不一致'
                        : null)),
            SizedBox(height: 32.h),
            Obx(() => _gradientBtn(
                loading: c.isChangingPassword,
                label: '确认修改',
                onTap: c.changePassword)),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppTheme.gold.withValues(alpha: 0.08), AppTheme.gold.withValues(alpha: 0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline_rounded, size: 18.sp, color: AppTheme.gold),
        SizedBox(width: 10.w),
        Expanded(
            child: Text('请输入旧密码和新密码，密码长度不能少于6位',
                style:
                    TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.4))),
      ]),
    );
  }


  Widget _gradientBtn(
      {required bool loading,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
            child: loading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Text(label,
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5))),
      ),
    );
  }
}
