import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../../routes/route_names.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/empty_placeholder_widget.dart';
import 'wallet_widgets.dart';

class WalletWithdrawScreen extends GetWidget<WalletController> {
  const WalletWithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: const Text('申请提现'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () => ListView(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
          children: [
            _tipBanner(),
            SizedBox(height: 18.h),
            Text('可提现余额',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
            SizedBox(height: 4.h),
            Text(
              money(controller.wallet.value.availableBalance),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.gold,
              ),
            ),
            SizedBox(height: 18.h),
            _formCard(),
            SizedBox(height: 20.h),
            Text(
              '提现记录',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            _withdrawalList(),
          ],
        ),
      ),
    );
  }

  Widget _tipBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.gold, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '提现将在1-3个工作日内到账',
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('提现金额'),
          SizedBox(height: 8.h),
          TextField(
            controller: controller.amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) => controller.wallet.refresh(),
            decoration: InputDecoration(
              prefixText: '¥ ',
              hintText: '请输入提现金额',
              filled: true,
              fillColor: AppTheme.creamBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text('最低提现金额 ¥10.00',
              style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
          SizedBox(height: 18.h),
          _label('到账账户'),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.creamBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_rounded,
                    color: AppTheme.gold, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${WalletController.bankName} 尾号${WalletController.bankCardTail}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textMuted, size: 20.sp),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          _label('到账金额'),
          SizedBox(height: 6.h),
          Text(
            money(controller.arrivalAmount),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text('手续费 ${money(controller.withdrawFee)}',
              style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.gold, AppTheme.amber]),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.submitWithdraw,
                child: Text(
                  controller.isSubmitting.value ? '提交中...' : '确认提现',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _withdrawalList() {
    if (controller.withdrawals.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: const EmptyPlaceholderWidget(
          message: '暂无提现记录',
          constrainHeight: true,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: List.generate(controller.withdrawals.length, (index) {
          final item = controller.withdrawals[index];
          return WithdrawalTile(
            item: item,
            showDivider: index != controller.withdrawals.length - 1,
            onTap: () => Get.toNamed(
              RouteNames.walletWithdrawalDetail.replaceAll(
                ':id',
                item.id.toString(),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
