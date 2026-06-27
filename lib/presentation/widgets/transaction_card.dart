import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/wallet_model.dart';

class TransactionCard extends StatelessWidget {
  final WalletTransactionModel item;

  const TransactionCard({super.key, required this.item});

  bool get _isIncome => item.isIncome;

  Color get _color {
    if (item.type == 'income') return AppTheme.sage;
    if (item.type == 'withdraw') return AppTheme.danger;
    if (item.type == 'freeze') return AppTheme.amber;
    return _isIncome ? AppTheme.sage : AppTheme.textMuted;
  }

  String get _title {
    if (item.type == 'income') return '已完成';
    if (item.type == 'withdraw') return '提现';
    if (item.type == 'freeze') return '冻结';
    if (item.type == 'unfreeze') return '解冻';
    if (item.type == 'refund') return '退款';
    return _isIncome ? '收入' : '支出';
  }

  String get _subtitle {
    if (item.type == 'income') return '订单收入已入账';
    if (item.type == 'withdraw') return '提现申请已提交';
    if (item.type == 'freeze') return '订单金额暂时冻结';
    return item.description;
  }

  IconData get _icon {
    if (item.type == 'income') return Icons.task_alt_rounded;
    if (item.type == 'withdraw') return Icons.account_balance_wallet_rounded;
    if (item.type == 'freeze') return Icons.lock_clock_rounded;
    return _isIncome ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded;
  }

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
                      '${_isIncome ? '+' : '-'}${_money(item.amount.abs())}',
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
