import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dtd/core/utils/toast_util.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';

/// 短信验证码控制器
/// 管理发送验证码和倒计时功能
class SmsCodeController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // 倒计时状态
  final RxInt countdown = 0.obs;
  final RxBool canSendSms = true.obs;
  Timer? _countdownTimer;

  /// 是否可以发送验证码
  bool get isCanSendSms => canSendSms.value && countdown.value == 0;

  /// 发送验证码
  /// [phoneNumber] 手机号
  /// [type] 验证码类型
  Future<bool> sendVerificationCode({
    required String phoneNumber,
    required String type,
  }) async {
    // 验证手机号
    if (phoneNumber.isEmpty) {
      ToastUtil.showError('请输入手机号');
      return false;
    }

    if (phoneNumber.length != 11) {
      ToastUtil.showError('请输入正确的手机号');
      return false;
    }

    // 检查是否可以发送
    if (!isCanSendSms) {
      return false;
    }

    try {
      final response = await _authRepository.sendSmsCode(
        phoneNumber: phoneNumber,
        type: type,
      );
      if (!response.isSuccess) {
        throw Exception(response.message);
      }
      // 开始倒计时
      _startCountdown();
      ToastUtil.showSuccess('验证码已发送');
      return true;
    } on DioException catch (e) {
      ToastUtil.showError(e.message ?? '发送验证码失败');
      return false;
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    countdown.value = 60;
    canSendSms.value = false;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canSendSms.value = true;
        timer.cancel();
      }
    });
  }

  /// 重置倒计时状态
  void resetCountdown() {
    _countdownTimer?.cancel();
    countdown.value = 0;
    canSendSms.value = true;
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
