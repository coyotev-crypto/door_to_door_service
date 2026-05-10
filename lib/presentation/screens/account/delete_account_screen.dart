import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/utils/toast_util.dart';
import '../../../routes/route_names.dart';
import '../../controllers/account_security_controller.dart';
import '../../widgets/primary_input_field.dart';
import '../../widgets/warning_info_widget.dart';

/// 账号注销页面
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _smsCodeController = TextEditingController();

  final _controller = Get.find<AccountSecurityController>();

  bool _isLoading = false;
  bool _canSendSms = true;
  int _countdown = 60;
  bool _agreed = false;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _smsCodeController.dispose();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendSmsCode() async {
    if (!_canSendSms) return;

    setState(() {
      _canSendSms = false;
      _countdown = 60;
    });

    // 开始倒计时
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canSendSms = true;
          timer.cancel();
        }
      });
    });

    try {
      // TODO: 调用发送验证码API
      ToastUtil.showSuccess('验证码已发送');
    } catch (e) {
      ToastUtil.showError('验证码发送失败: $e');
      setState(() {
        _canSendSms = true;
      });
    }
  }

  /// 提交注销
  Future<void> _submit() async {
    if (!_agreed) {
      ToastUtil.showError('请先阅读并同意注销协议');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final success = await _controller.deleteAccount(
      smsCode: _smsCodeController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // 退出登录并返回登录页
      Get.offAllNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '账号注销',
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
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          children: [
            SizedBox(height: 24.h),
            // 警告信息
            const WarningInfoWidget(
              title: '重要提示',
              description: '账号注销后，以下信息将被永久删除且无法恢复：',
              warningItems: [
                '• 账号信息和个人资料',
                '• 订单记录和交易信息',
                '• 收货地址和联系方式',
                '• 收藏和浏览记录',
                '• 其他所有与账号相关的数据',
              ],
            ),

            SizedBox(height: 24.h),

            // 验证码
            Row(
              children: [
                Expanded(
                  child: PrimaryInputField(
                    controller: _smsCodeController,
                    label: '验证码',
                    hintText: '请输入验证码',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入验证码';
                      }
                      if (value.length != 6) {
                        return '验证码长度应为6位';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 120.w,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _canSendSms ? _sendSmsCode : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSendSms
                          ? AppTheme.servicePrimaryColor
                          : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      _canSendSms ? '获取验证码' : '$_countdown秒后重试',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _canSendSms ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // 同意协议
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (value) {
                    setState(() {
                      _agreed = value ?? false;
                    });
                  },
                  activeColor: AppTheme.servicePrimaryColor,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreed = !_agreed;
                      });
                    },
                    child: Text(
                      '我已阅读并同意《账号注销协议》',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // 提交按钮
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
                shadowColor: Colors.red.withOpacity(0.3),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '确认注销',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

}
