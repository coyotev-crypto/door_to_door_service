import 'package:door_to_door_service/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/utils/log_util.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/payment_controller.dart';
import '../../widgets/common_app_bar.dart';

/// 支付页面 — WebView 加载支付网页
class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LogUtil.d('PaymentScreen.build() called, isLoading=${controller.isLoading.value}', tag: 'PAYMENT');
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '收银台'),
      body: Stack(
        children: [
          WebViewWidget(controller: controller.webViewController),
          Obx(() => controller.isLoading.value
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.gold, strokeWidth: 2.5)),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
