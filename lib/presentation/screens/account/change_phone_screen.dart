import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../controllers/account_security_controller.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/primary_input_field.dart';

/// 更换手机号 — 温润质感
class ChangePhoneScreen extends GetView<AccountSecurityController> {
  const ChangePhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '更换手机号'),
      body: Form(
        key: controller.changePhoneFormKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          children: [
            _infoBanner(),
            SizedBox(height: 28.h),
            PrimaryInputField(
              controller: controller.newPhoneController,
              label: '新手机号',
              hintText: '请输入新手机号',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              prefixIcon: const Icon(Icons.phone_android_rounded),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入手机号';
                if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(v)) return '请输入正确的手机号';
                return null;
              },
            ),
            SizedBox(height: 16.h),
            PrimaryInputField(
              controller: controller.changePhoneCodeController,
              label: '验证码',
              hintText: '请输入验证码',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.sms_outlined),
              trailingButton: Obx(() {
                final cd = controller.smsCodeController.countdown.value;
                final active = cd == 0;
                return GestureDetector(
                  onTap: active ? controller.sendChangePhoneSmsCode : null,
                  child: Container(
                    height: 40.h, width: 100.w,
                    decoration: BoxDecoration(
                      gradient: active ? const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]) : const LinearGradient(colors: [AppTheme.warmBorder, AppTheme.warmBorder]),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(child: Text(active ? '获取验证码' : '${cd}s',
                        style: TextStyle(fontSize: 13.sp, color: active ? Colors.white : AppTheme.textMuted, fontWeight: FontWeight.w600))),
                  ),
                );
              }),
            ),
            SizedBox(height: 32.h),
            Obx(() => _gradientBtn(
                  loading: controller.isChangingPhone,
                  label: '确认更换',
                  onTap: controller.changePhoneNumber,
                )),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.gold.withValues(alpha: 0.08), AppTheme.gold.withValues(alpha: 0.03)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline_rounded, size: 18.sp, color: AppTheme.gold),
        SizedBox(width: 10.w),
        Expanded(child: Text('更换手机号后，原手机号将无法用于登录', style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.4))),
      ]),
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
          boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(child: loading
            ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5))),
      ),
    );
  }
}
