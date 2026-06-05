import 'package:door_to_door_service/core/config/app_config.dart';
import 'package:door_to_door_service/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/utils/toast_util.dart';
import '../../routes/route_names.dart';

/// 支付控制器
class PaymentController extends GetxController {
  final RxBool isLoading = true.obs;

  late final int orderId;
  late final String orderNo;
  late final String paymentUrl;
  late final WebViewController webViewController;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    orderId = args['orderId'] as int;
    orderNo = args['orderNo'] as String;
    paymentUrl = '${AppConfig.webUrl}${ApiEndpoints.payment}$orderNo';

    // WebViewController 只创建一次，避免 rebuild 时重建
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => isLoading.value = false,
          onNavigationRequest: (request) =>
              onPageChanged(request.url)
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent,
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));
  }

  /// WebView URL 变化回调，用于检测支付结果
  bool onPageChanged(String url) {
    if (url.contains('/payment/success')) {
      ToastUtil.showSuccess('支付成功');
      Get.until((route) => route.settings.name == RouteNames.home);
      return false;
    }
    if (url.contains('/payment/fail') || url.contains('/payment/cancel')) {
      ToastUtil.showError('支付失败，请重试');
      Get.back();
      return false;
    }
    return true;
  }
}
