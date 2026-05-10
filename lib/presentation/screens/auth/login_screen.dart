import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
import '../../../routes/route_names.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/phone_input_field.dart';
import '../../widgets/login_input_field.dart';
import '../../widgets/agreement_checkbox.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends GetWidget<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),
                // Logo 图标
                Container(
                  width: 88.w, height: 88.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC4956A), Color(0xFFB8860B)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFC4956A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Icon(Icons.spa_rounded, size: 44.sp, color: Colors.white),
                ),
                SizedBox(height: 28.h),
                Text('解语',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.w800, color: const Color(0xFF2D2A26), letterSpacing: 2)),
                SizedBox(height: 8.h),
                Text('让生活更简单',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFFB8A99A), letterSpacing: 1)),
                SizedBox(height: 52.h),
                // 手机号
                PhoneInputField(controller: controller.phoneController),
                SizedBox(height: 8.h),
                // 验证码/密码
                Obx(() => LoginInputField(
                      passwordController: controller.passwordController,
                      codeController: controller.codeController,
                      isPasswordLogin: controller.isPasswordLogin.value,
                      isPasswordVisible: controller.isPasswordVisible.value,
                      onTogglePasswordVisibility: controller.togglePasswordVisibility,
                      countdown: controller.smsCodeController.countdown.value,
                      onSendCode: () => controller.sendVerificationCode(context),
                    )),
                SizedBox(height: 12.h),
                // 切换方式 + 忘记密码
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => TextButton(
                          onPressed: controller.toggleLoginType,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: Text(controller.isPasswordLogin.value ? '验证码登录' : '密码登录',
                              style: TextStyle(fontSize: 13.sp, color: const Color(0xFFB8860B))),
                        )),
                    Obx(() => controller.isPasswordLogin.value
                        ? TextButton(
                            onPressed: () => Get.toNamed(RouteNames.forgotPassword),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: Text('忘记密码?', style: TextStyle(fontSize: 13.sp, color: const Color(0xFFB8A99A))),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
                SizedBox(height: 8.h),
                Obx(() => AgreementCheckbox(
                      agreed: controller.agreedToTerms.value,
                      onChanged: (value) => controller.updateAgreement(value ?? false),
                      onUserAgreementTap: () => Get.toNamed(RouteNames.userAgreement),
                      onPrivacyPolicyTap: () => Get.toNamed(RouteNames.privacyPolicy),
                    )),
                SizedBox(height: 28.h),
                Obx(() => PrimaryButton(
                      text: controller.isPasswordLogin.value ? '登录' : '登录 / 注册',
                      isLoading: controller.isLoading.value,
                      onPressed: () => controller.handleLogin(context),
                    )),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
