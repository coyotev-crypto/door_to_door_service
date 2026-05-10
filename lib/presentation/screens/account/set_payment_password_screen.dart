import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../controllers/account_security_controller.dart';

/// 设置支付密码 — 温润质感
class SetPaymentPasswordScreen extends GetView<AccountSecurityController> {
  const SetPaymentPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('设置支付密码', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 0.5,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, size: 20.sp, color: AppTheme.textPrimary), onPressed: () => Get.back()),
      ),
      body: Form(
        key: c.setPaymentPasswordFormKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          children: [
            _infoBanner(),
            SizedBox(height: 24.h),
            _phoneDisplay(),
            SizedBox(height: 28.h),
            Obx(() => _pwField(ctrl: c.setPasswordController, label: '支付密码', hint: '请输入6位数字支付密码', obscure: c.obscureSetPassword, onToggle: c.toggleSetPasswordVisibility, validator: (v) => v == null || v.isEmpty ? '请输入支付密码' : v.length != 6 || !RegExp(r'^\d{6}$').hasMatch(v) ? '支付密码必须为6位数字' : null)),
            SizedBox(height: 16.h),
            Obx(() => _pwField(ctrl: c.setConfirmPasswordController, label: '确认密码', hint: '请再次输入支付密码', obscure: c.obscureSetConfirmPassword, onToggle: c.toggleSetConfirmPasswordVisibility, validator: (v) => v == null || v.isEmpty ? '请再次输入支付密码' : v != c.setPasswordController.text ? '两次输入的密码不一致' : null)),
            SizedBox(height: 16.h),
            _label('验证码'), SizedBox(height: 8.h),
            Row(children: [
              Expanded(child: TextFormField(
                controller: c.setSmsCodeController, keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
                decoration: _dec(hint: '请输入验证码', prefix: Icons.sms_outlined),
              )),
              SizedBox(width: 12.w),
              Obx(() {
                final cd = c.smsCodeController.countdown.value;
                final active = cd == 0;
                return GestureDetector(
                  onTap: active ? c.sendSetPaymentPasswordSmsCode : null,
                  child: Container(
                    height: 52.h, width: 110.w,
                    decoration: BoxDecoration(
                      gradient: active ? const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]) : LinearGradient(colors: [AppTheme.warmBorder, AppTheme.warmBorder]),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(child: Text(active ? '获取验证码' : '${cd}s', style: TextStyle(fontSize: 13.sp, color: active ? Colors.white : AppTheme.textMuted, fontWeight: FontWeight.w600))),
                  ),
                );
              }),
            ]),
            SizedBox(height: 32.h),
            Obx(() => _gradientBtn(loading: c.isSettingPaymentPassword, label: '确认设置', onTap: c.setPaymentPassword)),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.gold.withOpacity(0.08), AppTheme.gold.withOpacity(0.03)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10.r), border: Border.all(color: AppTheme.gold.withOpacity(0.12)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline_rounded, size: 18.sp, color: AppTheme.gold),
        SizedBox(width: 10.w),
        Expanded(child: Text('支付密码用于支付时的安全验证，请妥善保管', style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.4))),
      ]),
    );
  }

  Widget _phoneDisplay() {
    final phone = Get.find<AuthService>().user?.phoneNumber ?? '';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(color: AppTheme.creamBg, borderRadius: BorderRadius.circular(10.r)),
      child: Row(children: [
        Icon(Icons.phone_android_rounded, size: 18.sp, color: AppTheme.gold),
        SizedBox(width: 10.w),
        Text('验证码将发送至: $phone', style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
      ]),
    );
  }

  Widget _label(String t) => Text(t, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary));

  Widget _pwField({required TextEditingController ctrl, required String label, required String hint, required bool obscure, required VoidCallback onToggle, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      SizedBox(height: 8.h),
      TextFormField(
        controller: ctrl, obscureText: obscure, validator: validator, maxLength: 6,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
        decoration: _dec(hint: hint, prefix: Icons.payment_outlined, suffix: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20.sp, color: AppTheme.textMuted),
          onPressed: onToggle,
        )),
      ),
    ]);
  }

  InputDecoration _dec({required String hint, required IconData prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint, hintStyle: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
      filled: true, fillColor: AppTheme.creamBg,
      counterText: '',
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      prefixIcon: Icon(prefix, size: 18.sp, color: AppTheme.gold), suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppTheme.gold)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppTheme.danger)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppTheme.danger)),
    );
  }

  Widget _gradientBtn({required bool loading, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(child: loading
            ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5))),
      ),
    );
  }
}
