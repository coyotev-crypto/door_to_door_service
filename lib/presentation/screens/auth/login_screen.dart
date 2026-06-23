import 'package:door_to_door_service/core/config/app_config.dart';
import 'package:door_to_door_service/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
import '../../../routes/route_names.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/primary_input_field.dart';

/// 登录页面 — 温润质感·臻境迎宾
class LoginScreen extends GetWidget<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                _buildHero(),
                _buildFormCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 顶部品牌区 — 层叠辉光 + 浮游花 icon
  Widget _buildHero() {
    return SizedBox(
      height: 320.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 大辉光
          Positioned(
            top: -40.h,
            child: Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.gold.withValues(alpha: 0.12),
                    AppTheme.gold.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 小辉光
          Positioned(
            top: 20.h,
            left: 60.w,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.amber.withValues(alpha: 0.10),
                    AppTheme.amber.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 主内容
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon 容器
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.gold, AppTheme.amber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26.r),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child:
                    Icon(Icons.spa_rounded, size: 48.sp, color: Colors.white),
              ),
              SizedBox(height: 24.h),
              Text('解语',
                  style: TextStyle(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: 3,
                      height: 1)),
              SizedBox(height: 8.h),
              Text('让生活更简单',
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textMuted,
                      letterSpacing: 2)),
            ],
          ),
        ],
      ),
    );
  }

  /// 表单卡片
  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 手机号
          PrimaryInputField(
            controller: controller.phoneController,
            label: '手机号',
            hintText: '请输入手机号',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            prefixIcon: const Icon(Icons.phone_iphone_rounded),
          ),
          SizedBox(height: 14.h),
          // 验证码 / 密码
          Obx(() => controller.isPasswordLogin.value
              ? PrimaryInputField(
                  controller: controller.passwordController,
                  label: '密码',
                  hintText: '请输入密码',
                  obscureText: !controller.isPasswordVisible.value,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20.sp,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                )
              : PrimaryInputField(
                  controller: controller.codeController,
                  label: '验证码',
                  hintText: '请输入验证码',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  prefixIcon: const Icon(Icons.sms_outlined),
                  trailingButton: _buildSendCodeButton(),
                )),
          SizedBox(height: 16.h),
          // 切换方式 + 忘记密码
          _buildBottomLinks(),
          SizedBox(height: 14.h),
          // 协议
          _buildAgreement(),
          SizedBox(height: 28.h),
          // 登录按钮
          _buildLoginButton(),
        ],
      ),
    );
  }


  Widget _buildSendCodeButton() {
    final cd = controller.smsCodeController.countdown.value;
    final active = cd == 0;
    return GestureDetector(
      onTap:
          active ? () => controller.sendVerificationCode(Get.context!) : null,
      child: Container(
        height: 52.h,
        width: 110.w,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [AppTheme.gold, AppTheme.amber])
              : const LinearGradient(colors: [AppTheme.warmBorder, AppTheme.warmBorder]),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            active ? '获取验证码' : '${cd}s',
            style: TextStyle(
                fontSize: 13.sp,
                color: active ? Colors.white : AppTheme.textMuted,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// 切换登录方式 + 忘记密码
  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => GestureDetector(
              onTap: controller.toggleLoginType,
              child: Text(controller.isPasswordLogin.value ? '验证码登录' : '密码登录',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.amber,
                      fontWeight: FontWeight.w500)),
            )),
        Obx(() => controller.isPasswordLogin.value
            ? GestureDetector(
                onTap: () => _showForgotPasswordSheet(),
                child: Text('忘记密码?',
                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  /// 协议勾选
  Widget _buildAgreement() {
    return Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: controller.agreedToTerms.value,
                onChanged: (v) => controller.updateAgreement(v ?? false),
                activeColor: AppTheme.gold,
                side: const BorderSide(color: AppTheme.warmBorder, width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            Expanded(
              child: Wrap(
                  spacing: 2.w,
                  runSpacing: 2.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('我已阅读并同意',
                        style:
                            TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                    GestureDetector(
                      onTap: () => Get.toNamed(RouteNames.userAgreement),
                      child: Text('用户协议',
                          style:
                              TextStyle(fontSize: 12.sp, color: AppTheme.amber)),
                    ),
                    Text('和',
                        style:
                            TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                    GestureDetector(
                      onTap: () => Get.toNamed(RouteNames.privacyPolicy),
                      child: Text('隐私政策',
                          style:
                              TextStyle(fontSize: 12.sp, color: AppTheme.amber)),
                    ),
                  ],
                ),
            ),
          ],
        ));
  }

  /// 登录按钮
  Widget _buildLoginButton() {
    return Obx(() {
      final loading = controller.isLoading.value;
      final isPwd = controller.isPasswordLogin.value;
      return GestureDetector(
        onTap: loading ? null : () => controller.handleLogin(Get.context!),
        child: Container(
          height: 54.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.gold, AppTheme.amber],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.spa_rounded, size: 18.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(isPwd ? '登录' : '登录 / 注册',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5)),
                    ],
                  ),
          ),
        ),
      );
    });
  }

  // ==================== 忘记密码底部弹窗 ====================

  void _showForgotPasswordSheet() {
    final smsController = controller.smsCodeController;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Form(
          key: controller.forgotPwdFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 拖拽指示条
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                        color: AppTheme.warmBorder,
                        borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                Text('重置密码',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                SizedBox(height: 4.h),
                Text('请输入手机号获取验证码来重置密码',
                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
                SizedBox(height: 24.h),
                // 手机号
                PrimaryInputField(
                  controller: controller.forgotPhoneController,
                  label: '手机号',
                  hintText: '请输入手机号',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  prefixIcon: const Icon(Icons.phone_iphone_rounded),
                ),
                SizedBox(height: 16.h),
                // 验证码
                PrimaryInputField(
                  controller: controller.forgotCodeController,
                  label: '验证码',
                  hintText: '请输入验证码',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  prefixIcon: const Icon(Icons.sms_outlined),
                  trailingButton: Obx(() {
                    final cd = smsController.countdown.value;
                    final active = cd == 0;
                    return GestureDetector(
                      onTap: active
                          ? () => smsController.sendVerificationCode(
                              phoneNumber:
                                  controller.forgotPhoneController.text,
                              type: AppConfig.FORGOT_PASSWORD_CODE)
                          : null,
                      child: Container(
                        height: 40.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          gradient: active
                              ? const LinearGradient(
                                  colors: [AppTheme.gold, AppTheme.amber])
                              : const LinearGradient(
                                  colors: [AppTheme.warmBorder, AppTheme.warmBorder]),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            active ? '获取验证码' : '${cd}s',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color:
                                    active ? Colors.white : AppTheme.textMuted,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 16.h),
                // 新密码
                Obx(() => PrimaryInputField(
                  controller: controller.forgotNewPasswordController,
                  label: '新密码',
                  hintText: '请输入新密码（至少6位）',
                  obscureText: controller.forgotObscureNewPassword.value,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.forgotObscureNewPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.sp,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: controller.toggleForgotNewPasswordVisibility,
                  ),
                )),
                SizedBox(height: 16.h),
                // 确认密码
                Obx(() => PrimaryInputField(
                  controller: controller.forgotConfirmPasswordController,
                  label: '确认密码',
                  hintText: '请再次输入新密码',
                  obscureText: controller.forgotObscureConfirmPassword.value,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.forgotObscureConfirmPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.sp,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: controller.toggleForgotConfirmPasswordVisibility,
                  ),
                )),
                SizedBox(height: 28.h),
                // 提交按钮
                Obx(() {
                  final loading = controller.forgotIsLoading.value;
                  return GestureDetector(
                    onTap: loading
                        ? null
                        : () async {
                            final ok = await controller
                                .submitForgotPassword(Get.context!);
                            if (ok) {
                              Get.back(); // 关闭底部弹窗
                              controller.clearForgotPasswordForm();
                            }
                          },
                    child: Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.gold, AppTheme.amber],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Center(
                        child: loading
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text('重置密码',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.5)),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      barrierColor: Colors.black26,
    );
  }

}
