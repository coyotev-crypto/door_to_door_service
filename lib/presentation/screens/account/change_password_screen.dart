import 'package:door_to_door_service/presentation/widgets/info_tip_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/account_security_controller.dart';
import '../../widgets/primary_input_field.dart';
import '../../widgets/primary_button.dart';

/// 修改登录密码页面
class ChangePasswordScreen extends GetView<AccountSecurityController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '修改登录密码',
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
        key: controller.changePasswordFormKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          children: [
            SizedBox(height: 24.h),
            // 提示信息
            const InfoTipWidget(
              icon: Icons.info_outline_rounded,
              message: "请输入旧密码和新密码，密码长度不能少于6位",
            ),
            SizedBox(height: 32.h),
            // 旧密码
            Obx(
              () => PrimaryInputField(
                controller: controller.oldPasswordController,
                label: '旧密码',
                hintText: '请输入旧密码',
                obscureText: controller.obscureOldPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureOldPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: controller.toggleOldPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入旧密码';
                  }
                  if (value.length < 6) {
                    return '密码长度不能少于6位';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 16.h),

            // 新密码
            Obx(
              () => PrimaryInputField(
                controller: controller.newPasswordController,
                label: '新密码',
                hintText: '请输入新密码',
                obscureText: controller.obscureNewPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: controller.toggleNewPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入新密码';
                  }
                  if (value.length < 6) {
                    return '密码长度不能少于6位';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 16.h),

            // 确认密码
            Obx(
              () => PrimaryInputField(
                controller: controller.confirmPasswordController,
                label: '确认密码',
                hintText: '请再次输入新密码',
                obscureText: controller.obscureConfirmPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请再次输入新密码';
                  }
                  if (value != controller.newPasswordController.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 32.h),

            // 提交按钮
            Obx(
              () => PrimaryButton(
                text: '确认修改',
                isLoading: controller.isChangingPassword,
                onPressed: controller.changePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
