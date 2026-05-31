import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/login_controller.dart';
import '../../widgets/primary_input_field.dart';
import '../../widgets/info_tip_widget.dart';

/// 忘记密码页面
class ForgotPasswordScreen extends GetWidget<LoginController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '忘记密码',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: controller.forgotPwdFormKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          children: [
            SizedBox(height: 24.h),

            // 提示信息
            const InfoTipWidget(
              message: '请输入手机号、验证码和新密码来重置您的密码',
            ),

            SizedBox(height: 32.h),

            // 手机号
            PrimaryInputField(
              controller: controller.forgotPhoneController,
              label: '手机号',
              hintText: '请输入手机号',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),

            SizedBox(height: 16.h),

            PrimaryInputField(
              controller: controller.forgotCodeController,
              label: '验证码',
              hintText: '请输入验证码',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.verified_user_outlined),
              trailingButton: SizedBox(
                width: 120.w,
                height: 56.h,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.smsCodeController.countdown.value == 0
                        ? controller.sendForgotPasswordCode
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          controller.smsCodeController.countdown.value == 0
                              ? AppTheme.servicePrimaryColor
                              : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      controller.smsCodeController.countdown.value == 0
                          ? '获取验证码'
                          : '${controller.smsCodeController.countdown.value}秒后重试',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: controller.smsCodeController.countdown.value == 0
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // 新密码
            Obx(
              () => PrimaryInputField(
                controller: controller.forgotNewPasswordController,
                label: '新密码',
                hintText: '请输入新密码',
                obscureText: controller.forgotObscureNewPassword.value,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.forgotObscureNewPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: controller.toggleForgotNewPasswordVisibility,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // 确认密码
            Obx(
              () => PrimaryInputField(
                controller: controller.forgotConfirmPasswordController,
                label: '确认密码',
                hintText: '请再次输入新密码',
                obscureText: controller.forgotObscureConfirmPassword.value,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.forgotObscureConfirmPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: controller.toggleForgotConfirmPasswordVisibility,
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // 提交按钮
            Obx(
              () => ElevatedButton(
                onPressed: controller.forgotIsLoading.value
                    ? null
                    : () async {
                        if (controller.forgotPwdFormKey.currentState!
                            .validate()) {
                          final bool isSuccess =
                              await controller.submitForgotPassword(context);
                          if (isSuccess) {
                            controller.clearForgotPasswordForm();
                            // 关闭当前界面
                            Get.back();
                            ToastUtil.showSuccess('密码重置成功，请使用新密码登录');
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.servicePrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                  shadowColor: AppTheme.servicePrimaryColor.withValues(alpha: 0.3),
                ),
                child: controller.forgotIsLoading.value
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        '确认重置',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
