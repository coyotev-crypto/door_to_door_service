import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/common_app_bar.dart';

class VerificationCodeScanPage extends StatefulWidget {
  const VerificationCodeScanPage({super.key});

  @override
  State<VerificationCodeScanPage> createState() =>
      _VerificationCodeScanPageState();
}

class _VerificationCodeScanPageState extends State<VerificationCodeScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (code.isEmpty) return;
    _handled = true;
    Get.back(result: code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CommonAppBar(title: '扫码核销'),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetect,
          ),
          Center(
            child: Container(
              width: 240.w,
              height: 240.w,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.gold, width: 2),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 44.h,
            child: Text(
              '请将用户出示的核销码二维码放入框内',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
