import 'package:dio/dio.dart';
import 'package:dtd/core/config/app_config.dart';
import 'package:dtd/core/services/openim_chat_service.dart';
import 'package:dtd/core/utils/loading_util.dart';
import 'package:dtd/core/utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/route_names.dart';
import '../../data/repositories/account_security_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/toast_util.dart';
import '../../core/services/auth_service.dart';
import 'sms_code_controller.dart';

/// 登录控制器
class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final AccountSecurityRepository _accountSecurityRepository =
      AccountSecurityRepository();
  final AuthService _authService = AuthService.instance;
  final SmsCodeController smsCodeController = Get.find<SmsCodeController>();

  // 表单状态
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // UI状态
  final RxBool agreedToTerms = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordLogin = false.obs; // 登录方式：false=验证码登录, true=密码登录
  final RxBool isPasswordVisible = false.obs; // 密码可见性：false=隐藏, true=显示

  // 用户信息
  final Rx<UserModel?> userInfo = Rx<UserModel?>(null);

  // 忘记密码相关状态
  final TextEditingController forgotPhoneController = TextEditingController();
  final TextEditingController forgotCodeController = TextEditingController();
  final TextEditingController forgotNewPasswordController =
      TextEditingController();
  final TextEditingController forgotConfirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> forgotPwdFormKey = GlobalKey<FormState>();
  final RxBool forgotIsLoading = false.obs;
  final RxBool forgotObscureNewPassword = true.obs;
  final RxBool forgotObscureConfirmPassword = true.obs;

  /// 发送验证码
  /// [context] 上下文
  Future<void> sendVerificationCode(BuildContext context) async {
    // 检查是否同意用户协议
    if (!agreedToTerms.value) {
      ToastUtil.showError('请先同意用户协议和隐私政策');
      return;
    }

    await smsCodeController.sendVerificationCode(
      phoneNumber: phoneController.text,
      type: AppConfig.LOGIN_CODE,
    );
  }

  /// 登录/注册
  /// [context] 上下文
  Future<void> handleLogin(BuildContext context) async {
    // 验证手机号
    if (phoneController.text.isEmpty) {
      ToastUtil.showError('请输入手机号');
      return;
    }
    if (phoneController.text.length != 11) {
      ToastUtil.showError('请输入正确的手机号');
      return;
    }

    // 根据登录方式验证不同的输入
    if (isPasswordLogin.value) {
      // 密码登录
      if (passwordController.text.isEmpty) {
        ToastUtil.showError('请输入密码');
        return;
      }
      if (passwordController.text.length < 6) {
        ToastUtil.showError('密码长度不能少于6位');
        return;
      }
    } else {
      // 验证码登录
      if (codeController.text.isEmpty) {
        ToastUtil.showError('请输入验证码');
        return;
      }
      if (codeController.text.length != 6) {
        ToastUtil.showError('请输入6位验证码');
        return;
      }
    }

    if (!agreedToTerms.value) {
      ToastUtil.showError('请先同意用户协议');
      return;
    }

    isLoading.value = true;
    LoadingUtil.show();

    try {
      final result = isPasswordLogin.value
          ? await _authRepository.loginByPassword(
              phoneNumber: phoneController.text,
              password: passwordController.text,
            )
          : await _authRepository.loginByPhone(
              phoneNumber: phoneController.text,
              smsCode: codeController.text,
            );

      // 检查登录是否成功
      if (result.code != 200 || result.success != true) {
        throw Exception(result.message ?? '登录失败');
      }

      // 先保存Token，再获取用户信息（getUserInfo需要认证头）
      final loggedIn = await _authService.login(
        token: result.token!,
        expireSeconds: result.expire,
      );

      if (!loggedIn) {
        throw Exception('登录状态保存失败');
      }

      // Token已保存，现在获取用户信息并持久化
      try {
        final userRepository = UserRepository();
        final userInfo = await userRepository.getUserInfo();
        await _authService.updateUser(userInfo);
      } catch (e) {
        LogUtil.e('获取用户信息失败: $e', tag: 'LoginController');
      }

      await _loginOpenIMChat();

      if (context.mounted) {
        // 登录成功,跳转到首页
        final hasPassword = await _accountSecurityRepository.hasPassword();
        Get.offAllNamed(
          hasPassword ? RouteNames.home : RouteNames.setPassword,
        );
      }
    } on DioException catch (e) {
      ToastUtil.showError(e.message ?? '登录失败');
    } catch (e) {
      ToastUtil.showError('$e');
    } finally {
      isLoading.value = false;
      LoadingUtil.dismiss();
    }
  }

  /// 更新协议同意状态
  /// [value] 是否同意
  Future<void> _loginOpenIMChat() async {
    try {
      final chatService = Get.isRegistered<OpenIMChatService>()
          ? OpenIMChatService.to
          : Get.put(OpenIMChatService(), permanent: true);
      await chatService.loginWithBackendToken();
    } catch (e) {
      LogUtil.e('OpenIM Chat登录失败: $e', tag: 'LoginController');
    }
  }

  void updateAgreement(bool value) {
    agreedToTerms.value = value;
  }

  /// 切换登录方式
  void toggleLoginType() {
    isPasswordLogin.value = !isPasswordLogin.value;
    // 清空输入框
    codeController.clear();
    passwordController.clear();
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose() {
    phoneController.dispose();
    codeController.dispose();
    passwordController.dispose();
    forgotPhoneController.dispose();
    forgotCodeController.dispose();
    forgotNewPasswordController.dispose();
    forgotConfirmPasswordController.dispose();
    smsCodeController.resetCountdown();
    super.onClose();
  }

  /// 忘记密码-发送验证码
  Future<void> sendForgotPasswordCode() async {
    await smsCodeController.sendVerificationCode(
      phoneNumber: forgotPhoneController.text,
      type: AppConfig.FORGOT_PASSWORD_CODE,
    );
  }

  /// 忘记密码-切换新密码可见性
  void toggleForgotNewPasswordVisibility() {
    forgotObscureNewPassword.value = !forgotObscureNewPassword.value;
  }

  /// 忘记密码-切换确认密码可见性
  void toggleForgotConfirmPasswordVisibility() {
    forgotObscureConfirmPassword.value = !forgotObscureConfirmPassword.value;
  }

  /// 忘记密码-提交重置
  /// [context] 上下文，用于关闭当前界面
  Future<bool> submitForgotPassword(BuildContext context) async {
    // 验证手机号
    if (forgotPhoneController.text.isEmpty) {
      ToastUtil.showError('请输入手机号');
      return false;
    }

    if (forgotPhoneController.text.length != 11) {
      ToastUtil.showError('请输入正确的手机号');
      return false;
    }

    // 验证验证码
    if (forgotCodeController.text.isEmpty) {
      ToastUtil.showError('请输入验证码');
      return false;
    }

    if (forgotCodeController.text.length != 6) {
      ToastUtil.showError('验证码长度应为6位');
      return false;
    }

    // 验证新密码
    if (forgotNewPasswordController.text.isEmpty) {
      ToastUtil.showError('请输入新密码');
      return false;
    }

    if (forgotNewPasswordController.text.length < 6) {
      ToastUtil.showError('密码长度不能少于6位');
      return false;
    }

    // 验证确认密码
    if (forgotConfirmPasswordController.text.isEmpty) {
      ToastUtil.showError('请再次输入新密码');
      return false;
    }

    if (forgotConfirmPasswordController.text !=
        forgotNewPasswordController.text) {
      ToastUtil.showError('两次输入的密码不一致');
      return false;
    }

    forgotIsLoading.value = true;
    LoadingUtil.show();

    try {
      // 调用重置密码API
      final result = await _authRepository.resetPasswordWithCode(
        phone: forgotPhoneController.text,
        code: forgotCodeController.text,
        newPassword: forgotNewPasswordController.text,
      );
      LogUtil.d('Password reset result: ${result.isSuccess}');
      if (!result.isSuccess) {
        throw Exception(result.message);
      }
      return result.isSuccess;
    } catch (e) {
      ToastUtil.showError('密码重置失败: $e');
      return false;
    } finally {
      forgotIsLoading.value = false;
      LoadingUtil.dismiss();
    }
  }

  /// 忘记密码-清空表单
  void clearForgotPasswordForm() {
    forgotPhoneController.clear();
    forgotCodeController.clear();
    forgotNewPasswordController.clear();
    forgotConfirmPasswordController.clear();
    smsCodeController.resetCountdown();
  }
}
