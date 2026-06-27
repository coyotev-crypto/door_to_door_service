import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/empty_placeholder_widget.dart';
import '../../widgets/transaction_card.dart';

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
                    itemCount: items.length,
                    separatorBuilder: (_, index) => SizedBox(height: 10.h),
                    itemBuilder: (_, index) {
                      return TransactionCard(item: items[index]);
                    },
                  ),
          );
        },
      ),
    );
  }
}
