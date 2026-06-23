import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/empty_placeholder_widget.dart';
import 'wallet_widgets.dart';

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
        () => EasyRefresh(
          onRefresh: controller.refreshTransactions,
          onLoad: controller.hasMoreTransactions.value
              ? controller.loadMoreTransactions
              : null,
          child: controller.transactions.isEmpty
              ? const EmptyPlaceholderWidget(message: '暂无交易流水')
              : ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        children:
                            List.generate(controller.transactions.length, (i) {
                          return WalletTransactionTile(
                            item: controller.transactions[i],
                            showDivider:
                                i != controller.transactions.length - 1,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
