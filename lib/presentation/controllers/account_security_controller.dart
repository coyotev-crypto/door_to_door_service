import 'dart:async';

import 'package:dtd/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:dtd/core/config/app_config.dart';
import 'package:dtd/core/services/openim_chat_service.dart';
import 'package:dtd/core/services/auth_service.dart';
import 'package:dtd/core/utils/log_util.dart';
import 'package:dtd/core/utils/loading_util.dart';
import 'package:dtd/core/utils/toast_util.dart';
import 'package:get/get.dart';
import '../../data/models/login_device_model.dart';
import '../../data/repositories/account_security_repository.dart';
import 'sms_code_controller.dart';

/// 账户安全控制器
/// 管理账户安全相关的状态和业务逻辑
class AccountSecurityController extends GetxController {
  final AccountSecurityRepository _securityRepository =
      AccountSecurityRepository();
  final SmsCodeController smsCodeController = Get.find<SmsCodeController>();

  // 登录设备列表
  final RxList<LoginDeviceModel> _devices = <LoginDeviceModel>[].obs;
  final RxBool _isLoadingDevices = false.obs;

  // 是否已设置支付密码
  final RxBool _hasPaymentPassword = false.obs;

  // 修改密码加载状态
  final RxBool _isChangingPassword = false.obs;

  // 密码可见性状态
  final RxBool _obscureOldPassword = true.obs;
  final RxBool _obscureNewPassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  // 修改密码表单
  final GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // 首次设置登录密码表单
  final GlobalKey<FormState> setLoginPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController setLoginPasswordController =
      TextEditingController();
  final TextEditingController setLoginConfirmPasswordController =
      TextEditingController();
  final RxBool _isSettingLoginPassword = false.obs;
  final RxBool _obscureSetLoginPassword = true.obs;
  final RxBool _obscureSetLoginConfirmPassword = true.obs;

  // 修改支付密码表单
  final GlobalKey<FormState> changePaymentPasswordFormKey =
      GlobalKey<FormState>();
  final TextEditingController oldPaymentPasswordController =
      TextEditingController();
  final TextEditingController newPaymentPasswordController =
      TextEditingController();
  final TextEditingController confirmPaymentPasswordController =
      TextEditingController();
  final TextEditingController smsCodeInputController = TextEditingController();

  // 设置支付密码表单
  final GlobalKey<FormState> setPaymentPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController setPasswordController = TextEditingController();
  final TextEditingController setConfirmPasswordController =
      TextEditingController();
  final TextEditingController setSmsCodeController = TextEditingController();

  // 更换手机号表单
  final GlobalKey<FormState> changePhoneFormKey = GlobalKey<FormState>();
  final TextEditingController newPhoneController = TextEditingController();
  final TextEditingController changePhoneCodeController =
      TextEditingController();
  final RxBool _isChangingPhone = false.obs;

  // 修改支付密码状态
  final RxBool _isChangingPaymentPassword = false.obs;
  final RxBool _obscureOldPaymentPassword = true.obs;
  final RxBool _obscureNewPaymentPassword = true.obs;
  final RxBool _obscureConfirmPaymentPassword = true.obs;

  // 设置支付密码状态
  final RxBool _isSettingPaymentPassword = false.obs;
  final RxBool _obscureSetPassword = true.obs;
  final RxBool _obscureSetConfirmPassword = true.obs;

  // 获取登录设备列表
  List<LoginDeviceModel> get devices => _devices;

  // 是否正在加载设备列表
  bool get isLoadingDevices => _isLoadingDevices.value;

  // 是否已设置支付密码
  bool get hasPaymentPassword => _hasPaymentPassword.value;

  // 是否正在修改密码
  bool get isChangingPassword => _isChangingPassword.value;

  // 密码可见性
  bool get obscureOldPassword => _obscureOldPassword.value;
  bool get obscureNewPassword => _obscureNewPassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;
  bool get isSettingLoginPassword => _isSettingLoginPassword.value;
  bool get obscureSetLoginPassword => _obscureSetLoginPassword.value;
  bool get obscureSetLoginConfirmPassword =>
      _obscureSetLoginConfirmPassword.value;

  // 是否正在修改支付密码
  bool get isChangingPaymentPassword => _isChangingPaymentPassword.value;

  // 支付密码可见性
  bool get obscureOldPaymentPassword => _obscureOldPaymentPassword.value;
  bool get obscureNewPaymentPassword => _obscureNewPaymentPassword.value;
  bool get obscureConfirmPaymentPassword =>
      _obscureConfirmPaymentPassword.value;

  // 设置支付密码状态
  bool get isSettingPaymentPassword => _isSettingPaymentPassword.value;
  bool get obscureSetPassword => _obscureSetPassword.value;
  bool get obscureSetConfirmPassword => _obscureSetConfirmPassword.value;

  // 更换手机号状态
  bool get isChangingPhone => _isChangingPhone.value;

  @override
  void onClose() {
    // 修改登录密码
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    setLoginPasswordController.dispose();
    setLoginConfirmPasswordController.dispose();
    // 修改支付密码
    oldPaymentPasswordController.dispose();
    newPaymentPasswordController.dispose();
    confirmPaymentPasswordController.dispose();
    smsCodeInputController.dispose();
    // 设置支付密码
    setPasswordController.dispose();
    setConfirmPasswordController.dispose();
    setSmsCodeController.dispose();
    // 更换手机号
    newPhoneController.dispose();
    changePhoneCodeController.dispose();
    smsCodeController.resetCountdown();
    super.onClose();
  }

  /// 加载登录设备列表
  Future<void> loadLoginDevices() async {
    _isLoadingDevices.value = true;
    try {
      final devices = await _securityRepository.getLoginDevices();
      _devices.assignAll(devices.data ?? []);
    } catch (e) {
      ToastUtil.showError('加载登录设备失败: $e');
    } finally {
      _isLoadingDevices.value = false;
    }
  }

  /// 修改登录密码
  Future<bool> changePassword() async {
    if (!changePasswordFormKey.currentState!.validate()) {
      return false;
    }

    // 检查新密码和旧密码是否一致
    if (oldPasswordController.text == newPasswordController.text) {
      ToastUtil.showError('新密码不能与旧密码相同');
      return false;
    }

    _isChangingPassword.value = true;
    LoadingUtil.show();
    try {
      await _securityRepository.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );
      ToastUtil.showSuccess('密码修改成功，请重新登录');
      // 导航到登录页面
      Get.offAllNamed(RouteNames.login);
      return true;
    } catch (e) {
      ToastUtil.showError('密码修改失败: $e');
      return false;
    } finally {
      _isChangingPassword.value = false;
      LoadingUtil.dismiss();
    }
  }

  Future<bool> setPassword() async {
    if (!setLoginPasswordFormKey.currentState!.validate()) {
      return false;
    }

    _isSettingLoginPassword.value = true;
    LoadingUtil.show();
    try {
      await _securityRepository.setPassword(
        newPassword: setLoginPasswordController.text,
      );
      ToastUtil.showSuccess('密码设置成功');
      Get.offAllNamed(RouteNames.home);
      unawaited(_loginOpenIMChat());
      return true;
    } catch (e) {
      ToastUtil.showError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isSettingLoginPassword.value = false;
      LoadingUtil.dismiss();
    }
  }

  /// 设置支付密码
  Future<void> _loginOpenIMChat() async {
    try {
      final chatService = Get.isRegistered<OpenIMChatService>()
          ? OpenIMChatService.to
          : Get.put(OpenIMChatService(), permanent: true);
      await chatService.loginWithBackendToken().timeout(
            const Duration(seconds: 8),
          );
    } catch (e) {
      LogUtil.e('OpenIM Chat登录失败: $e', tag: 'AccountSecurityController');
    }
  }

  Future<bool> setPaymentPassword() async {
    if (!setPaymentPasswordFormKey.currentState!.validate()) {
      return false;
    }

    // 获取当前用户手机号
    final authService = AuthService.instance;
    final phoneNumber = authService.user?.phoneNumber ?? '';

    if (phoneNumber.isEmpty) {
      ToastUtil.showError('无法获取用户手机号，请重新登录');
      return false;
    }

    _isSettingPaymentPassword.value = true;
    LoadingUtil.show();
    try {
      final response = await _securityRepository.setPaymentPassword(
        payPassword: setPasswordController.text,
        phone: phoneNumber,
        code: setSmsCodeController.text,
      );
      _hasPaymentPassword.value = true;
      Get.back();
      // 延迟显示Toast，确保在页面返回后再显示
      Future.delayed(const Duration(milliseconds: 300), () {
        ToastUtil.showSuccess(response.message);
      });
      return true;
    } catch (e) {
      ToastUtil.showError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isSettingPaymentPassword.value = false;
      LoadingUtil.dismiss();
    }
  }

  /// 验证支付密码
  /// [password] 支付密码
  Future<bool> verifyPaymentPassword({
    required String password,
  }) async {
    try {
      final response = await _securityRepository.verifyPaymentPassword(
        password: password,
      );
      return response.isSuccess;
    } catch (e) {
      ToastUtil.showError('支付密码验证失败: $e');
      return false;
    }
  }

  /// 更换手机号
  /// 验证表单后调用更换手机号API
  Future<bool> changePhoneNumber() async {
    if (!changePhoneFormKey.currentState!.validate()) {
      return false;
    }

    _isChangingPhone.value = true;
    LoadingUtil.show();
    try {
      final response = await _securityRepository.changePhoneNumber(
        newPhone: newPhoneController.text,
        code: changePhoneCodeController.text,
      );
      if (!response.isSuccess) {
        throw Exception(response.message);
      }
      ToastUtil.showSuccess('手机号更换成功，请重新登录');
      // 导航到登录页面
      Get.offAllNamed(RouteNames.login);
      return response.isSuccess;
    } catch (e) {
      ToastUtil.showError('手机号更换失败: $e');
      return false;
    } finally {
      _isChangingPhone.value = false;
      LoadingUtil.dismiss();
    }
  }

  /// 发送更换手机号验证码
  Future<void> sendChangePhoneSmsCode() async {
    // 只验证手机号，不验证验证码
    final phoneNumber = newPhoneController.text;
    if (phoneNumber.isEmpty) {
      ToastUtil.showError('请输入手机号');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneNumber)) {
      ToastUtil.showError('请输入正确的手机号');
      return;
    }

    await smsCodeController.sendVerificationCode(
      phoneNumber: phoneNumber,
      type: AppConfig.CHANGE_PHONE_CODE,
    );
  }

  /// 移除登录设备
  /// [deviceId] 设备ID
  Future<bool> removeLoginDevice({
    required String deviceId,
  }) async {
    LoadingUtil.show();
    try {
      await _securityRepository.removeLoginDevice(
        deviceId: deviceId,
      );
      await loadLoginDevices();
      ToastUtil.showSuccess('设备移除成功');
      return true;
    } catch (e) {
      ToastUtil.showError('设备移除失败: $e');
      return false;
    } finally {
      LoadingUtil.dismiss();
    }
  }

  /// 注销账号
  /// [smsCode] 短信验证码
  Future<bool> deleteAccount({
    required String smsCode,
  }) async {
    LoadingUtil.show();
    try {
      await _securityRepository.deleteAccount(
        smsCode: smsCode,
      );
      ToastUtil.showSuccess('账号注销成功');
      return true;
    } catch (e) {
      ToastUtil.showError('账号注销失败: $e');
      return false;
    } finally {
      LoadingUtil.dismiss();
    }
  }

  /// 切换旧密码可见性
  void toggleOldPasswordVisibility() {
    _obscureOldPassword.value = !_obscureOldPassword.value;
  }

  /// 切换新密码可见性
  void toggleNewPasswordVisibility() {
    _obscureNewPassword.value = !_obscureNewPassword.value;
  }

  /// 切换确认密码可见性
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }

  void toggleSetLoginPasswordVisibility() {
    _obscureSetLoginPassword.value = !_obscureSetLoginPassword.value;
  }

  void toggleSetLoginConfirmPasswordVisibility() {
    _obscureSetLoginConfirmPassword.value =
        !_obscureSetLoginConfirmPassword.value;
  }

  /// 切换旧支付密码可见性
  void toggleOldPaymentPasswordVisibility() {
    _obscureOldPaymentPassword.value = !_obscureOldPaymentPassword.value;
  }

  /// 切换新支付密码可见性
  void toggleNewPaymentPasswordVisibility() {
    _obscureNewPaymentPassword.value = !_obscureNewPaymentPassword.value;
  }

  /// 切换确认支付密码可见性
  void toggleConfirmPaymentPasswordVisibility() {
    _obscureConfirmPaymentPassword.value =
        !_obscureConfirmPaymentPassword.value;
  }

  /// 切换设置支付密码可见性
  void toggleSetPasswordVisibility() {
    _obscureSetPassword.value = !_obscureSetPassword.value;
  }

  /// 切换设置确认支付密码可见性
  void toggleSetConfirmPasswordVisibility() {
    _obscureSetConfirmPassword.value = !_obscureSetConfirmPassword.value;
  }

  /// 发送设置支付密码验证码
  Future<void> sendSetPaymentPasswordSmsCode() async {
    // 获取当前用户手机号
    final authService = AuthService.instance;
    final phoneNumber = authService.user?.phoneNumber ?? '';

    if (phoneNumber.isEmpty) {
      ToastUtil.showError('无法获取用户手机号，请重新登录');
      return;
    }

    await smsCodeController.sendVerificationCode(
      phoneNumber: phoneNumber,
      type: AppConfig.SET_PAYMENT_PASSWORD_CODE,
    );
  }
}
