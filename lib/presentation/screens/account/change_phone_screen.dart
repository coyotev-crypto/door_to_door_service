import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/account_security_controller.dart';
import '../../widgets/info_tip_widget.dart';
import '../../widgets/phone_input_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/primary_input_field.dart';

/// 更换手机号页面
///
/// 用户可以通过此页面更换绑定的手机号码
class ChangePhoneScreen extends GetView<AccountSecurityController> {
  const ChangePhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '更换手机号',
          style: TextStyle(
            fontSize: 18.sp,
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
        key: controller.changePhoneFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60.h),

                    /// 提示信息
                    InfoTipWidget(
                      message: '更换手机号后，原手机号将无法用于登录',
                      iconColor: primaryColor,
                      backgroundColor: primaryColor.withOpacity(0.08),
                    ),

                    SizedBox(height: 60.h),

                    /// 新手机号输入框
                    PhoneInputField(
                      controller: controller.newPhoneController,
                      hintText: '请输入新手机号',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入手机号';
                        }
                        if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                          return '请输入正确的手机号';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 8.h),

                    /// 验证码输入框和发送按钮
                    PrimaryInputField(
                      controller: controller.changePhoneCodeController,
                      label: '验证码',
                      hintText: '请输入验证码',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.verified_user_outlined,
                          color: primaryColor),
                      trailingButton: SizedBox(
                        width: 120.w,
                        height: 56.h,
                        child: Obx(() => ElevatedButton(
                              onPressed:
                                  controller.smsCodeController.isCanSendSms
                                      ? controller.sendChangePhoneSmsCode
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    controller.smsCodeController.isCanSendSms
                                        ? primaryColor
                                        : Colors.grey[300],
                                foregroundColor:
                                    controller.smsCodeController.isCanSendSms
                                        ? Colors.white
                                        : Colors.grey[600],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                controller.smsCodeController.isCanSendSms
                                    ? '获取验证码'
                                    : '${controller.smsCodeController.countdown.value}秒后重试',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    /// 提交按钮
                    Obx(() => PrimaryButton(
                          text: '确认更换',
                          isLoading: controller.isChangingPhone,
                          onPressed: controller.changePhoneNumber,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
