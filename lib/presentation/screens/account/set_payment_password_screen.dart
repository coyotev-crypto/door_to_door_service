import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/account_security_controller.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/primary_input_field.dart';
import '../../widgets/info_tip_widget.dart';

/// 设置支付密码页面
class SetPaymentPasswordScreen extends GetView<AccountSecurityController> {
  const SetPaymentPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '设置支付密码',
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
        key: controller.setPaymentPasswordFormKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          children: [
            SizedBox(height: 24.h),

            // 提示信息
            const InfoTipWidget(
              message: '支付密码用于支付时的安全验证，请妥善保管',
            ),

            SizedBox(height: 24.h),

            // 手机号显示
            Obx(() {
              final authService = Get.find<AuthService>();
              final phoneNumber = authService.user?.phoneNumber ?? '';
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 20.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '验证码将发送至: $phoneNumber',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 32.h),

            // 支付密码
            Obx(() => PrimaryInputField(
                  controller: controller.setPasswordController,
                  label: '支付密码',
                  hintText: '请输入6位数字支付密码',
                  obscureText: controller.obscureSetPassword,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.payment_outlined),
                  maxLength: 6,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureSetPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      controller.toggleSetPasswordVisibility();
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入支付密码';
                    }
                    if (value.length != 6) {
                      return '支付密码必须为6位数字';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return '支付密码必须为6位数字';
                    }
                    return null;
                  },
                )),

            const SizedBox(height: 16),

            // 确认密码
            Obx(() => PrimaryInputField(
                  controller: controller.setConfirmPasswordController,
                  label: '确认密码',
                  hintText: '请再次输入支付密码',
                  obscureText: controller.obscureSetConfirmPassword,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.payment_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureSetConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      controller.toggleSetConfirmPasswordVisibility();
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请再次输入支付密码';
                    }
                    if (value != controller.setPasswordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                )),

            const SizedBox(height: 16),

            // 验证码
            PrimaryInputField(
              controller: controller.setSmsCodeController,
              label: '验证码',
              hintText: '请输入验证码',
              maxLength: 6,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.verified_user_outlined),
              trailingButton: SizedBox(
                width: 120.w,
                height: 56.h,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.smsCodeController.countdown.value == 0
                        ? controller.sendSetPaymentPasswordSmsCode
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

            const SizedBox(height: 32),

            // 提交按钮
            Obx(() => PrimaryButton(
                  text: '确认设置',
                  onPressed: controller.isSettingPaymentPassword
                      ? null
                      : () => controller.setPaymentPassword(),
                  isLoading: controller.isSettingPaymentPassword,
                )),
          ],
        ),
      ),
    );
  }
}
