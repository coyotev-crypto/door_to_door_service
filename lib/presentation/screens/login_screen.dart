import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../routes/route_names.dart';
import '../../core/utils/screen_adapter.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/login_input_field.dart';
import '../widgets/agreement_checkbox.dart';

class LoginScreen extends GetWidget<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 80.h),
                  // Logo
                  Icon(
                    Icons.home_work_rounded,
                    size: 80.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    '解语',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '让生活更简单',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60.h),

                  // 手机号输入框
                  PhoneInputField(
                    controller: controller.phoneController,
                  ),
                  SizedBox(height: 8.h),

                  // 验证码输入框或密码输入框
                  Obx(
                    () => LoginInputField(
                      passwordController: controller.passwordController,
                      codeController: controller.codeController,
                      isPasswordLogin: controller.isPasswordLogin.value,
                      isPasswordVisible: controller.isPasswordVisible.value,
                      onTogglePasswordVisibility:
                          controller.togglePasswordVisibility,
                      countdown: controller.countdown.value,
                      onSendCode: () =>
                          controller.sendVerificationCode(context),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // 登录方式切换
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => TextButton(
                          onPressed: controller.toggleLoginType,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            controller.isPasswordLogin.value ? '验证码登录' : '密码登录',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      // 忘记密码按钮（仅在密码登录时显示）
                      Obx(
                        () => controller.isPasswordLogin.value
                            ? TextButton(
                                onPressed: () {
                                  // TODO: 跳转到忘记密码页面
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '忘记密码?',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // 用户协议勾选框
                  Obx(() => AgreementCheckbox(
                        agreed: controller.agreedToTerms.value,
                        onChanged: (value) {
                          controller.updateAgreement(value ?? false);
                        },
                        onUserAgreementTap: () {
                          Get.toNamed(RouteNames.userAgreement);
                        },
                        onPrivacyPolicyTap: () {
                          Get.toNamed(RouteNames.privacyPolicy);
                        },
                      )),

                  SizedBox(height: 24.h),

                  // 登录/注册按钮
                  Obx(
                    () => Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                controller.isPasswordLogin.value
                                    ? '登录'
                                    : '登录 / 注册',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
