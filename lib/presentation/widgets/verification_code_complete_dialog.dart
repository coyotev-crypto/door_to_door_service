import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/themes/app_theme.dart';
import '../../core/utils/screen_adapter.dart';
import 'primary_button.dart';

class VerificationCodeCompleteDialog extends StatefulWidget {
  final Future<String?> Function() onScan;

  const VerificationCodeCompleteDialog({
    super.key,
    required this.onScan,
  });

  @override
  State<VerificationCodeCompleteDialog> createState() =>
      _VerificationCodeCompleteDialogState();
}

class _VerificationCodeCompleteDialogState
    extends State<VerificationCodeCompleteDialog> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final scannedCode = await widget.onScan();
    if (!mounted || scannedCode == null || scannedCode.isEmpty) return;
    Navigator.of(context).pop(scannedCode);
  }

  void _submit() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      Get.snackbar('提示', '核销码不能为空');
      return;
    }
    Navigator.of(context).pop(code);
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
                    Icons.verified_user_outlined,
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
                        '核销完成服务',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '扫描或输入用户出示的核销码',
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
            _ScanAction(onTap: _scan),
            SizedBox(height: 16.h),
            TextField(
              controller: _codeController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: '手动输入核销码',
                hintText: '请输入用户出示的核销码',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                filled: true,
                fillColor: AppTheme.creamFill,
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
                    text: '确认完成',
                    height: 48.h,
                    gradientColors: const [AppTheme.sage, Color(0xFF5A7D6A)],
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

class _ScanAction extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Ink(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppTheme.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.24)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: AppTheme.gold,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '扫码识别',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '打开相机扫描用户二维码',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
