import 'package:door_to_door_service/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/payment_controller.dart';

/// 支付页面 — WebView 加载支付网页
class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('收银台',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 20.sp, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setNavigationDelegate(
                NavigationDelegate(
                  onPageFinished: (_) => controller.isLoading.value = false,
                  onNavigationRequest: (request) =>
                      controller.onPageChanged(request.url)
                          ? NavigationDecision.navigate
                          : NavigationDecision.prevent,
                ),
              )
              ..loadRequest(Uri.parse(controller.paymentUrl)),
          ),
          Obx(() => controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2.5))
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
