import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/models/wallet_model.dart';

String money(num value) => '¥${value.toStringAsFixed(2)}';

String shortDate(DateTime? value) {
  if (value == null) return '';
  return '${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

String fullDate(DateTime? value) {
  if (value == null) return '-';
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

String statusText(String status) {
  switch (status) {
    case 'completed':
      return '已完成';
    case 'rejected':
      return '已拒绝';
    default:
      return '处理中';
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'completed':
      return const Color(0xFF4CAF50);
    case 'rejected':
      return AppTheme.danger;
    default:
      return AppTheme.amber;
  }
}

class WithdrawalTile extends StatelessWidget {
  final WithdrawalModel item;
  final VoidCallback? onTap;
  final bool showDivider;

  const WithdrawalTile({
    super.key,
    required this.item,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(item.status);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppTheme.warmBorder))
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '提现${money(item.amount)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    statusText(item.status),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.bankName} · ${item.bankCardTail} · ${shortDate(item.createdAt)}',
                    style:
                        TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.sp,
                    color: AppTheme.textMuted,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
