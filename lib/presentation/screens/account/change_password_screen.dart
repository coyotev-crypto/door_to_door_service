import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../controllers/account_security_controller.dart';

/// 修改登录密码 — 温润质感
class ChangePasswordScreen extends GetView<AccountSecurityController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('修改登录密码',
            style: TextStyle(
                fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios_rounded, size: 20.sp, color: AppTheme.textPrimary),
            onPressed: () => Get.back()),
      ),
      body: Form(
        key: c.changePasswordFormKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          children: [
            _infoBanner(),
            SizedBox(height: 28.h),
            Obx(() => _pwField(
                ctrl: c.oldPasswordController,
                label: '旧密码',
                hint: '请输入旧密码',
                obscure: c.obscureOldPassword,
                onToggle: c.toggleOldPasswordVisibility,
                validator: (v) => v == null || v.isEmpty
                    ? '请输入旧密码'
                    : v.length < 6
                        ? '密码长度不能少于6位'
                        : null)),
            SizedBox(height: 16.h),
            Obx(() => _pwField(
                ctrl: c.newPasswordController,
                label: '新密码',
                hint: '请输入新密码',
                obscure: c.obscureNewPassword,
                onToggle: c.toggleNewPasswordVisibility,
                validator: (v) => v == null || v.isEmpty
                    ? '请输入新密码'
                    : v.length < 6
                        ? '密码长度不能少于6位'
                        : null)),
            SizedBox(height: 16.h),
            Obx(() => _pwField(
                ctrl: c.confirmPasswordController,
                label: '确认密码',
                hint: '请再次输入新密码',
                obscure: c.obscureConfirmPassword,
                onToggle: c.toggleConfirmPasswordVisibility,
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
            colors: [AppTheme.gold.withOpacity(0.08), AppTheme.gold.withOpacity(0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.gold.withOpacity(0.12)),
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

  Widget _pwField(
      {required TextEditingController ctrl,
      required String label,
      required String hint,
      required bool obscure,
      required VoidCallback onToggle,
      String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      SizedBox(height: 8.h),
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        validator: validator,
        style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
        decoration: _dec(
            hint: hint,
            prefix: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20.sp,
                  color: AppTheme.textMuted),
              onPressed: onToggle,
            )),
      ),
    ]);
  }

  InputDecoration _dec(
      {required String hint, required IconData prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
      filled: true,
      fillColor: AppTheme.creamBg,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      prefixIcon: Icon(prefix, size: 18.sp, color: AppTheme.gold),
      suffixIcon: suffix,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.gold)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.danger)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.danger)),
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
                color: AppTheme.gold.withOpacity(0.3),
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
