import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/route_names.dart';

/// 支付控制器
class PaymentController extends GetxController {
  final RxInt selectedMethod = 0.obs; // 0=余额, 1=微信, 2=支付宝

  late final int orderId;
  late final String orderNo;
  late final double amount;
  late final String serviceName;
  late final int durationMinutes;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    orderId = args['orderId'] as int;
    orderNo = args['orderNo'] as String;
    amount = (args['amount'] as num).toDouble();
    serviceName = args['serviceName'] as String? ?? '';
    durationMinutes = args['durationMinutes'] as int? ?? 60;
  }

  void selectMethod(int index) {
    selectedMethod.value = index;
  }

  void handlePayment() {
    // TODO: 接入实际支付SDK后替换此模拟逻辑
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC4956A).withOpacity(0.1),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 36, color: Color(0xFFC4956A)),
              ),
              const SizedBox(height: 16),
              const Text('支付成功',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D2A26))),
              const SizedBox(height: 8),
              Text('订单 $orderNo 已支付',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B5E53))),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Get.until((route) => route.settings.name == RouteNames.home);
    });
  }
}
