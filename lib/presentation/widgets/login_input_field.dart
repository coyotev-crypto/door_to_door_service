import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/screen_adapter.dart';

class LoginInputField extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController codeController;
  final bool isPasswordLogin;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final int countdown;
  final VoidCallback onSendCode;

  const LoginInputField({
    super.key,
    required this.passwordController,
    required this.codeController,
    required this.isPasswordLogin,
    required this.isPasswordVisible,
    required this.onTogglePasswordVisibility,
    required this.countdown,
    required this.onSendCode,
  });

  @override
  Widget build(BuildContext context) {
    if (isPasswordLogin) {
      // 密码登录 - 显示密码输入框
      return _PasswordField(
        controller: passwordController,
        isVisible: isPasswordVisible,
        onToggleVisibility: onTogglePasswordVisibility,
      );
    } else {
      // 验证码登录 - 显示验证码输入框和获取验证码按钮
      return _CodeInputField(
        codeController: codeController,
        countdown: countdown,
        onSendCode: onSendCode,
      );
    }
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const _PasswordField({
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: '请输入密码',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 16.h,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey[400],
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      style: TextStyle(fontSize: 16.sp, color: Colors.black87),
    );
  }
}

class _CodeInputField extends StatelessWidget {
  final TextEditingController codeController;
  final int countdown;
  final VoidCallback onSendCode;

  const _CodeInputField({
    required this.codeController,
    required this.countdown,
    required this.onSendCode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              hintText: '请输入验证码',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(fontSize: 16.sp, color: Colors.black87),
          ),
        ),
        SizedBox(width: 12.w),
        _SendCodeButton(
          countdown: countdown,
          onSendCode: onSendCode,
        ),
      ],
    );
  }
}

class _SendCodeButton extends StatelessWidget {
  final int countdown;
  final VoidCallback onSendCode;

  const _SendCodeButton({
    required this.countdown,
    required this.onSendCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        gradient: countdown > 0
            ? LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[300]!],
              )
            : LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ElevatedButton(
        onPressed: countdown > 0 ? null : onSendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          countdown > 0 ? '${countdown}s' : '获取验证码',
          style: TextStyle(
            fontSize: 14.sp,
            color: countdown > 0 ? Colors.grey[600] : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
