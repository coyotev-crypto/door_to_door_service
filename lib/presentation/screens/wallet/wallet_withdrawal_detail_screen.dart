import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../controllers/wallet_controller.dart';
import 'wallet_widgets.dart';

class WalletWithdrawalDetailScreen extends StatefulWidget {
  final int id;

  const WalletWithdrawalDetailScreen({super.key, required this.id});

  @override
  State<WalletWithdrawalDetailScreen> createState() =>
      _WalletWithdrawalDetailScreenState();
}

class _WalletWithdrawalDetailScreenState
    extends State<WalletWithdrawalDetailScreen> {
  final WalletController controller = Get.find<WalletController>();

  @override
  void initState() {
    super.initState();
    controller.loadWithdrawalDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: const Text('提现详情'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final item = controller.withdrawalDetail.value;
        if (item == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final color = statusColor(item.status);
        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 28.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded, size: 44.sp, color: color),
                  SizedBox(height: 10.h),
                  Text(
                    statusText(item.status),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.status == 'completed' ? '提现金额已到账' : '提现申请处理中',
                    style: TextStyle(
                        fontSize: 13.sp, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  _row('提现金额', money(item.amount)),
                  _row('手续费', money(item.fee)),
                  _row('到账金额', money(item.arrivalAmount)),
                  _row('到账银行', item.bankName),
                  _row('银行卡尾号', item.bankCardTail),
                  _row('申请时间', fullDate(item.createdAt)),
                  _row('到账时间', fullDate(item.completedAt), divider: false),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _row(String label, String value, {bool divider = true}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: AppTheme.warmBorder))
            : null,
      ),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
          SizedBox(width: 20.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
