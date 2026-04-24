import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/toast_util.dart';
import '../../core/services/auth_service.dart';

/// 登录控制器
class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final AuthService _authService = AuthService.instance;

  // 表单状态
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // UI状态
  final RxBool agreedToTerms = false.obs;
  final RxBool isLoading = false.obs;
  final RxInt countdown = 0.obs;
  final RxBool isPasswordLogin = false.obs; // 登录方式：false=验证码登录, true=密码登录
  final RxBool isPasswordVisible = false.obs; // 密码可见性：false=隐藏, true=显示

  // 用户信息
  final Rx<UserModel?> userInfo = Rx<UserModel?>(null);

  /// 发送验证码
  /// [context] 上下文
  Future<void> sendVerificationCode(BuildContext context) async {
    if (phoneController.text.length != 11) {
      ToastUtil.showError('请输入正确的手机号');
      return;
    }

    // 检查是否同意用户协议
    if (!agreedToTerms.value) {
      ToastUtil.showError('请先同意用户协议和隐私政策');
      return;
    }

    try {
      await _authRepository.sendSmsCode(
        phoneNumber: phoneController.text,
        type: '2', // 2-登录
      );

      countdown.value = 60;
      _startCountdown();
      ToastUtil.showSuccess('验证码已发送');
    } on DioException catch (e) {
      ToastUtil.showError(e.message ?? '发送验证码失败');
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (countdown.value > 0) {
        countdown.value--;
      }
      return countdown.value > 0;
    });
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

      // Token已在auth_repository中保存，更新AuthService登录状态
      await _authService.login(
        token: result.token!,
        expireSeconds: result.expire,
      );

      if (context.mounted) {
        // 登录成功,跳转到首页
        Navigator.pushReplacementNamed(context, '/');
      }
    } on DioException catch (e) {
      ToastUtil.showError(e.message ?? '登录失败');
      isLoading.value = false;
    }
  }

  /// 更新协议同意状态
  /// [value] 是否同意
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
    super.onClose();
  }
}
