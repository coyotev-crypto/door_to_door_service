import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/themes/app_theme.dart';
import '../../core/utils/screen_adapter.dart';
import 'primary_button.dart';

class PaymentPasswordDialog extends StatefulWidget {
  final String title;
  final String message;

  const PaymentPasswordDialog({
    super.key,
    this.title = '输入支付密码',
    this.message = '请输入6位数字支付密码以确认操作',
  });

  @override
  State<PaymentPasswordDialog> createState() => _PaymentPasswordDialogState();

  static Future<String?> show({
    String title = '输入支付密码',
    String message = '请输入6位数字支付密码以确认操作',
  }) {
    return Get.dialog<String>(
      PaymentPasswordDialog(title: title, message: message),
      barrierDismissible: false,
    );
  }
}

class _PaymentPasswordDialogState extends State<PaymentPasswordDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _controller.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      Get.snackbar('提示', '请输入6位数字支付密码');
      return;
    }
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: AppTheme.gold,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: '请输入6位数字支付密码',
                prefixIcon: const Icon(Icons.password_rounded),
                filled: true,
                fillColor: AppTheme.creamFill,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppTheme.warmBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppTheme.warmBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                      const BorderSide(color: AppTheme.gold, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.warmBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        foregroundColor: AppTheme.textSecondary,
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryButton(
                    text: '确认',
                    height: 48.h,
                    gradientColors: const [AppTheme.gold, AppTheme.amber],
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
