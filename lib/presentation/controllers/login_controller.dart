import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/toast_util.dart';

class LoginController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // 表单状态
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // UI状态
  bool agreedToTerms = false;
  bool isLoading = false;
  int countdown = 0;
  bool isPasswordLogin = false; // 登录方式：false=验证码登录, true=密码登录
  bool isPasswordVisible = false; // 密码可见性：false=隐藏, true=显示

  // 用户信息
  UserModel? userInfo;

  // 发送验证码
  Future<void> sendVerificationCode(BuildContext context) async {
    if (phoneController.text.length != 11) {
      ToastUtil.showError(context, '请输入正确的手机号');
      return;
    }

    // 检查是否同意用户协议
    if (!agreedToTerms) {
      ToastUtil.showError(context, '请先同意用户协议和隐私政策');
      return;
    }

    try {
      await _authRepository.sendSmsCode(
        phoneNumber: phoneController.text,
        type: '2', // 2-登录
      );

      countdown = 60;
      notifyListeners();
      _startCountdown();
      ToastUtil.showSuccess(context, '验证码已发送');
    } on DioException catch (e) {
      ToastUtil.showError(context, e.message ?? '发送验证码失败');
    }
  }

  // 开始倒计时
  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (countdown > 0) {
        countdown--;
        notifyListeners();
      }
      return countdown > 0;
    });
  }

  // 登录/注册
  Future<void> handleLogin(BuildContext context) async {
    // 验证手机号
    if (phoneController.text.isEmpty) {
      ToastUtil.showError(context, '请输入手机号');
      return;
    }
    if (phoneController.text.length != 11) {
      ToastUtil.showError(context, '请输入正确的手机号');
      return;
    }

    // 根据登录方式验证不同的输入
    if (isPasswordLogin) {
      // 密码登录
      if (passwordController.text.isEmpty) {
        ToastUtil.showError(context, '请输入密码');
        return;
      }
      if (passwordController.text.length < 6) {
        ToastUtil.showError(context, '密码长度不能少于6位');
        return;
      }
    } else {
      // 验证码登录
      if (codeController.text.isEmpty) {
        ToastUtil.showError(context, '请输入验证码');
        return;
      }
      if (codeController.text.length != 6) {
        ToastUtil.showError(context, '请输入6位验证码');
        return;
      }
    }

    if (!agreedToTerms) {
      ToastUtil.showError(context, '请先同意用户协议');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final result = isPasswordLogin
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

      // 保存Token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result.token ?? '');

      // 保存Token过期时间
      if (result.expire != null) {
        await prefs.setString('tokenExpire', result.expire!);
      }

      if (context.mounted) {
        // 登录成功,跳转到首页
        Navigator.pushReplacementNamed(context, '/');
      }
    } on DioException catch (e) {
      ToastUtil.showError(context, e.message ?? '登录失败');
      isLoading = false;
      notifyListeners();
    }
  }

  // 更新协议同意状态
  void updateAgreement(bool value) {
    agreedToTerms = value;
    notifyListeners();
  }

  // 切换登录方式
  void toggleLoginType() {
    isPasswordLogin = !isPasswordLogin;
    // 清空输入框
    codeController.clear();
    passwordController.clear();
    notifyListeners();
  }

  // 切换密码可见性
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
