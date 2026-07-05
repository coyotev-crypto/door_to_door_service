import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_theme.dart';
import '../../../routes/route_names.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/empty_placeholder_widget.dart';
import 'wallet_widgets.dart';

class WalletWithdrawalsScreen extends StatefulWidget {
  const WalletWithdrawalsScreen({super.key});

  @override
  State<WalletWithdrawalsScreen> createState() =>
      _WalletWithdrawalsScreenState();
}

class _WalletWithdrawalsScreenState extends State<WalletWithdrawalsScreen> {
  final WalletController controller = Get.find<WalletController>();

  @override
  void initState() {
    super.initState();
    controller.refreshWithdrawals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: const Text('提现记录'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () {
          final items = controller.withdrawals;
          return EasyRefresh(
            onRefresh: controller.refreshWithdrawals,
            onLoad: controller.hasMoreWithdrawals.value
                ? controller.loadMoreWithdrawals
                : null,
            child: items.isEmpty
                ? const EmptyPlaceholderWidget(message: '暂无提现记录')
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
                    itemCount: items.length,
                    separatorBuilder: (_, index) => SizedBox(height: 10.h),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: WithdrawalTile(
                          item: item,
                          showDivider: false,
                          onTap: () => Get.toNamed(
                            RouteNames.walletWithdrawalDetail.replaceAll(
                              ':id',
                              item.id.toString(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
