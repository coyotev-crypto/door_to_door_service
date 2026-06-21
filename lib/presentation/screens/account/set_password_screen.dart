import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/account_security_controller.dart';

class SetPasswordScreen extends GetView<AccountSecurityController> {
  const SetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text(
          '设置登录密码',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.5,
      ),
      body: Form(
        key: c.setLoginPasswordFormKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          children: [
            _infoBanner(),
            SizedBox(height: 28.h),
            Obx(
              () => _passwordField(
                ctrl: c.setLoginPasswordController,
                label: '新密码',
                hint: '请输入新密码',
                obscure: c.obscureSetLoginPassword,
                onToggle: c.toggleSetLoginPasswordVisibility,
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入新密码';
                  if (value.length < 6) return '密码长度不能少于6位';
                  return null;
                },
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => _passwordField(
                ctrl: c.setLoginConfirmPasswordController,
                label: '确认密码',
                hint: '请再次输入新密码',
                obscure: c.obscureSetLoginConfirmPassword,
                onToggle: c.toggleSetLoginConfirmPasswordVisibility,
                validator: (value) {
                  if (value == null || value.isEmpty) return '请再次输入新密码';
                  if (value != c.setLoginPasswordController.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 32.h),
            Obx(
              () => _gradientButton(
                loading: c.isSettingLoginPassword,
                label: '确认设置',
                onTap: c.setPassword,
              ),
            ),
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
          colors: [
            AppTheme.gold.withValues(alpha: 0.08),
            AppTheme.gold.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_reset_rounded, size: 20.sp, color: AppTheme.gold),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '首次使用，请设置登录密码以保护账户安全',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
          decoration: _decoration(
            hint: hint,
            prefix: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20.sp,
                color: AppTheme.textMuted,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
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
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppTheme.gold),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
    );
  }

  Widget _gradientButton({
    required bool loading,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}
