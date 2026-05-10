import 'package:door_to_door_service/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/payment_controller.dart';

/// 支付页面 — 温润质感·臻享结算
class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('确认支付',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        child: Column(
          children: [
            _buildAmountCard(),
            SizedBox(height: 24.h),
            _buildPaymentMethods(),
            SizedBox(height: 32.h),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final amount = controller.amount;
    final name = controller.serviceName;
    final duration = controller.durationMinutes;
    final orderNo = controller.orderNo;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: AppTheme.gold.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text('应付金额',
              style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text('¥',
                    style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gold)),
              ),
              Text(amount.toStringAsFixed(0),
                  style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.gold,
                      height: 1)),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.creamBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.spa_rounded, size: 14.sp, color: AppTheme.textMuted),
                SizedBox(width: 6.w),
                Text('$name · $duration 分钟',
                    style: TextStyle(
                        fontSize: 13.sp, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text('订单号: $orderNo',
              style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('支付方式',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          SizedBox(height: 12.h),
          _paymentTile(
              Icons.account_balance_wallet_rounded, '余额支付', '使用账户余额直接支付', 0),
          _divider(),
          _paymentTile(Icons.wechat_rounded, '微信支付', '推荐已安装微信的用户使用', 1),
          _divider(),
          _paymentTile(
              Icons.account_balance_rounded, '支付宝', '推荐已安装支付宝的用户使用', 2),
        ],
      ),
    );
  }

  Widget _paymentTile(IconData icon, String title, String subtitle, int index) {
    return Obx(() {
      final selected = controller.selectedMethod.value == index;
      return GestureDetector(
        onTap: () => controller.selectMethod(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color:
                selected ? AppTheme.gold.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.gold.withOpacity(0.1)
                      : AppTheme.creamBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon,
                    size: 20.sp,
                    color: selected ? AppTheme.gold : AppTheme.textMuted),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    SizedBox(height: 2.h),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12.sp, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded,
                    size: 22.sp, color: AppTheme.gold),
            ],
          ),
        ),
      );
    });
  }

  Widget _divider() {
    return Divider(height: 8.h, thickness: 0.5, color: AppTheme.warmBorder);
  }

  Widget _buildPayButton() {
    return GestureDetector(
      onTap: () => controller.handlePayment(),
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.gold, AppTheme.amber],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: AppTheme.gold.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 16.sp, color: Colors.white),
              SizedBox(width: 8.w),
              Text('立即支付 ¥${controller.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
