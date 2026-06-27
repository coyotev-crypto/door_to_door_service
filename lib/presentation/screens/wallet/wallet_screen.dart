import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../../routes/route_names.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/empty_placeholder_widget.dart';
import '../../widgets/transaction_card.dart';
import 'wallet_widgets.dart';

class WalletScreen extends GetWidget<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: const Text('我的钱包'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () => EasyRefresh(
          onRefresh: controller.loadHome,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
            children: [
              _balanceCard(),
              SizedBox(height: 20.h),
              _sectionHeader(),
              SizedBox(height: 10.h),
              _transactionCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceCard() {
    final wallet = controller.wallet.value;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('可用余额',
              style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
          SizedBox(height: 8.h),
          Text(
            money(wallet.availableBalance),
            style: TextStyle(
              fontSize: 36.sp,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              _balanceMetric('冻结', wallet.frozenBalance),
              Container(width: 1, height: 30.h, color: Colors.white24),
              _balanceMetric('累计', wallet.totalIncome),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () => Get.toNamed(RouteNames.walletWithdraw),
              child: Text(
                '提现',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceMetric(String label, double value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
          SizedBox(height: 4.h),
          Text(
            money(value),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '交易流水',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(RouteNames.walletTransactions),
          child: Row(
            children: [
              Text('查看全部',
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
              Icon(Icons.chevron_right_rounded,
                  size: 18.sp, color: AppTheme.textMuted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _transactionCard() {
    if (controller.recentTransactions.isEmpty) {
      return _whiteCard(
        const EmptyPlaceholderWidget(
          message: '暂无交易流水',
          constrainHeight: true,
        ),
      );
    }

    return Column(
      children: List.generate(controller.recentTransactions.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == controller.recentTransactions.length - 1 ? 0 : 10.h,
          ),
          child: TransactionCard(item: controller.recentTransactions[index]),
        );
      }),
    );
  }

  Widget _whiteCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: child,
    );
  }
}
