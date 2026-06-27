import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/models/wallet_model.dart';
import '../../../routes/route_names.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/empty_placeholder_widget.dart';
import '../../widgets/payment_password_dialog.dart';
import 'wallet_widgets.dart';

class WalletWithdrawScreen extends GetWidget<WalletController> {
  const WalletWithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _WalletWithdrawBody(controller: controller);
  }
}

class _WalletWithdrawBody extends StatefulWidget {
  final WalletController controller;

  const _WalletWithdrawBody({required this.controller});

  @override
  State<_WalletWithdrawBody> createState() => _WalletWithdrawBodyState();
}

class _WalletWithdrawBodyState extends State<_WalletWithdrawBody> {
  PaymentAccountModel? _selectedAccount;
  late final Worker _accountsWorker;

  @override
  void initState() {
    super.initState();
    // 进入页面时刷新数据，确保余额和账户列表是最新的
    widget.controller.loadHome();

    // 监听账户列表变化，自动选择默认账户
    _accountsWorker = ever(widget.controller.paymentAccounts, (accounts) {
      if (_selectedAccount == null && accounts.isNotEmpty) {
        setState(() {
          _initializeSelectedAccount();
        });
      }
    });
    
    // 初始化时选择默认账户或第一个账户
    _initializeSelectedAccount();
  }

  @override
  void dispose() {
    _accountsWorker.dispose();
    super.dispose();
  }

  void _initializeSelectedAccount() {
    final accounts = widget.controller.paymentAccounts;
    if (accounts.isNotEmpty) {
      _selectedAccount = accounts.firstWhere(
        (acc) => acc.isPrimary,
        orElse: () => accounts.first,
      );
    }
  }

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
              money(widget.controller.wallet.value.availableBalance),
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
            controller: widget.controller.amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) => widget.controller.commissionRate.refresh(),
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
           GestureDetector(
             onTap: widget.controller.paymentAccounts.isEmpty
                 ? () => Get.toNamed(RouteNames.paymentAccount)
                 : _showAccountSelector,
             child: Container(
               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
               decoration: BoxDecoration(
                 color: AppTheme.creamBg,
                 borderRadius: BorderRadius.circular(10.r),
                 border: widget.controller.paymentAccounts.isEmpty
                     ? Border.all(
                         color: AppTheme.textMuted.withValues(alpha: 0.3),
                         width: 1,
                       )
                     : null,
               ),
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   Icon(
                     widget.controller.paymentAccounts.isNotEmpty
                         ? Icons.account_balance_rounded
                         : Icons.warning_amber_rounded,
                     color: widget.controller.paymentAccounts.isNotEmpty
                         ? AppTheme.gold
                         : AppTheme.textMuted,
                     size: 20.sp,
                   ),
                   SizedBox(width: 8.w),
                   Expanded(
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         if(_selectedAccount == null) ...[
                           Text(
                             widget.controller.paymentAccounts.isEmpty
                                 ? '未绑定，点击绑定'
                                 : (_selectedAccount?.accountName ??
                                 _selectedAccount?.method ??
                                 '未选择'),
                             style: TextStyle(
                               fontSize: 14.sp,
                               fontWeight: FontWeight.w600,
                               color: widget.controller.paymentAccounts.isEmpty
                                   ? AppTheme.textMuted
                                   : AppTheme.textPrimary,
                             ),
                           ),
                         ],
                         if (_selectedAccount != null) ...[
                           Text(
                             _selectedAccount!.accountNoMask,
                             style: TextStyle(
                               fontSize: 14.sp,
                               fontWeight: FontWeight.w600,
                               color: AppTheme.textMuted,
                             ),
                           ),
                         ],
                       ],
                     ),
                   ),
                   if (widget.controller.paymentAccounts.isNotEmpty)
                     Icon(
                       Icons.keyboard_arrow_down_rounded,
                       color: AppTheme.textMuted,
                       size: 20.sp,
                     ),
                 ],
               ),
             ),
           ),
          SizedBox(height: 18.h),
          _label('到账金额'),
          SizedBox(height: 6.h),
          Text(
            money(widget.controller.arrivalAmount),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '手续费 ${money(widget.controller.withdrawFee)} · 费率 ${widget.controller.commissionRateText}',
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
          ),
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
                child: Obx(
                  () => TextButton(
                    onPressed: (widget.controller.isSubmitting.value ||
                            widget.controller.paymentAccounts.isEmpty ||
                            _selectedAccount == null)
                        ? null
                        : _confirmWithdraw,
                    child: Text(
                      widget.controller.paymentAccounts.isEmpty
                          ? '请先绑定收款账户'
                          : (widget.controller.isSubmitting.value
                              ? '提交中...'
                              : '确认提现'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmWithdraw() async {
    final account = _selectedAccount;
    if (account == null) return;
    final password = await PaymentPasswordDialog.show(
      title: '确认提现',
      message: '请输入支付密码完成提现申请',
    );
    if (password == null || password.isEmpty) return;
    await widget.controller.submitWithdraw(account, password);
  }

  Widget _withdrawalList() {
    if (widget.controller.withdrawals.isEmpty) {
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
        children: List.generate(widget.controller.withdrawals.length, (index) {
          final item = widget.controller.withdrawals[index];
          return WithdrawalTile(
            item: item,
            showDivider: index != widget.controller.withdrawals.length - 1,
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

  void _showAccountSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择收款账户',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            ...widget.controller.paymentAccounts.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final account = entry.value;
                final isSelected = _selectedAccount?.id == account.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAccount = account;
                    });
                    Get.back();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: index < widget.controller.paymentAccounts.length - 1 ? 12.h : 0),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.gold.withValues(alpha: 0.1) : AppTheme.creamBg,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected ? AppTheme.gold : AppTheme.warmBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    account.accountName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  if (account.isPrimary) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: AppTheme.gold,
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        '默认',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                account.accountNoMask,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.gold,
                            size: 20.sp,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
