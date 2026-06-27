import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/models/wallet_model.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/empty_placeholder_widget.dart';

class WalletTransactionsScreen extends StatefulWidget {
  const WalletTransactionsScreen({super.key});

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  final WalletController controller = Get.find<WalletController>();

  @override
  void initState() {
    super.initState();
    controller.refreshTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: const Text('交易流水'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () {
          final items = controller.transactions;
          return EasyRefresh(
            onRefresh: controller.refreshTransactions,
            onLoad: controller.hasMoreTransactions.value
                ? controller.loadMoreTransactions
                : null,
            child: items.isEmpty
                ? const EmptyPlaceholderWidget(message: '暂无交易流水')
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
                    itemCount: items.length + 1,
                    separatorBuilder: (_, index) => SizedBox(height: 10.h),
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return _TransactionSummary(transactions: items);
                      }
                      return _TransactionCard(item: items[index - 1]);
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _TransactionSummary extends StatelessWidget {
  final List<WalletTransactionModel> transactions;

  const _TransactionSummary({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final incomeTotal = transactions
        .where((item) => item.type == 'income')
        .fold<double>(0, (sum, item) => sum + item.amount.abs());
    final freezeTotal = transactions
        .where((item) => item.type == 'freeze')
        .fold<double>(0, (sum, item) => sum + item.amount.abs());

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.warmBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '流水概览',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '仅展示已完成收入与冻结金额',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: '已完成',
                  amount: incomeTotal,
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.sage,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SummaryMetric(
                  label: '冻结',
                  amount: freezeTotal,
                  icon: Icons.lock_rounded,
                  color: AppTheme.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _money(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final WalletTransactionModel item;

  const _TransactionCard({required this.item});

  bool get _isIncome => item.type == 'income';

  Color get _color => _isIncome ? AppTheme.sage : AppTheme.amber;

  String get _title => _isIncome ? '已完成' : '冻结';

  String get _subtitle => _isIncome ? '订单收入已入账' : '订单金额暂时冻结';

  IconData get _icon =>
      _isIncome ? Icons.task_alt_rounded : Icons.lock_clock_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(_icon, color: _color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.description.isNotEmpty
                                ? item.description
                                : _subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.35,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${_isIncome ? '+' : ''}${_money(item.amount.abs())}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _InfoChip(
                      icon: Icons.receipt_long_rounded,
                      text: item.orderNo?.isNotEmpty == true
                          ? '订单 ${item.orderNo}'
                          : '无订单号',
                    ),
                    _InfoChip(
                      icon: Icons.schedule_rounded,
                      text: _fullDate(item.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppTheme.creamFill,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: AppTheme.textMuted),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

String _money(num value) => '¥${value.toStringAsFixed(2)}';

String _fullDate(DateTime? value) {
  if (value == null) return '无时间';
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
