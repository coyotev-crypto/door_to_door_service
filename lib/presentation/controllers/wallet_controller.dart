import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/toast_util.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletController extends GetxController {
  static const int pageSize = 10;

  final WalletRepository _repository = WalletRepository();
  final TextEditingController amountController = TextEditingController();

  final Rx<WalletModel> wallet = const WalletModel().obs;
  final Rx<CommissionRateModel> commissionRate =
      const CommissionRateModel().obs;
  final RxList<WalletTransactionModel> recentTransactions =
      <WalletTransactionModel>[].obs;
  final RxList<WalletTransactionModel> transactions =
      <WalletTransactionModel>[].obs;
  final RxList<WithdrawalModel> withdrawals = <WithdrawalModel>[].obs;
  final Rx<WithdrawalModel?> withdrawalDetail = Rx<WithdrawalModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool hasMoreTransactions = true.obs;
  final RxBool hasMoreWithdrawals = true.obs;
  final RxBool hasBindPaymentAccount = true.obs; // 是否已绑定收款账户
  final RxList<PaymentAccountModel> paymentAccounts = <PaymentAccountModel>[].obs; // 收款账户列表

  int _transactionPage = 1;
  int _withdrawalPage = 1;

  double get withdrawAmount =>
      double.tryParse(amountController.text.trim()) ?? 0;
  double get withdrawFee => withdrawAmount * commissionRate.value.rate;
  double get arrivalAmount =>
      (withdrawAmount - withdrawFee).clamp(0, double.infinity);
  String get commissionRateText {
    if (commissionRate.value.rateText.isNotEmpty) {
      return commissionRate.value.rateText;
    }
    return '${(commissionRate.value.rate * 100).toStringAsFixed(2)}%';
  }

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repository.getWallet(),
        _repository.getCommissionRate(),
        _repository.getTransactions(pageIndex: 1, pageSize: 3),
        _repository.getWithdrawals(pageIndex: 1, pageSize: 3),
        _repository.getPaymentAccounts(),
      ]);
      wallet.value = results[0] as WalletModel;
      commissionRate.value = results[1] as CommissionRateModel;
      recentTransactions.assignAll(
        results[2] as List<WalletTransactionModel>,
      );
      withdrawals.assignAll(results[3] as List<WithdrawalModel>);

      // 处理收款账户列表
      final accounts = results[4] as List<PaymentAccountModel>;
      paymentAccounts.assignAll(accounts);
      // 更新是否有绑定账户的状态
      hasBindPaymentAccount.value = accounts.isNotEmpty;
    } catch (e) {
      ToastUtil.showError('加载钱包失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTransactions() async {
    _transactionPage = 1;
    final list = await _repository.getTransactions(
      pageIndex: _transactionPage,
      pageSize: pageSize,
    );
    transactions.assignAll(list);
    hasMoreTransactions.value = list.length >= pageSize;
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMoreTransactions.value) return;
    final nextPage = _transactionPage + 1;
    final list = await _repository.getTransactions(
      pageIndex: nextPage,
      pageSize: pageSize,
    );
    transactions.addAll(list);
    _transactionPage = nextPage;
    hasMoreTransactions.value = list.length >= pageSize;
  }

  Future<void> refreshWithdrawals() async {
    _withdrawalPage = 1;
    final list = await _repository.getWithdrawals(
      pageIndex: _withdrawalPage,
      pageSize: pageSize,
    );
    withdrawals.assignAll(list);
    hasMoreWithdrawals.value = list.length >= pageSize;
  }

  Future<void> loadMoreWithdrawals() async {
    if (!hasMoreWithdrawals.value) return;
    final nextPage = _withdrawalPage + 1;
    final list = await _repository.getWithdrawals(
      pageIndex: nextPage,
      pageSize: pageSize,
    );
    withdrawals.addAll(list);
    _withdrawalPage = nextPage;
    hasMoreWithdrawals.value = list.length >= pageSize;
  }

  Future<void> submitWithdraw(
    PaymentAccountModel account,
    String paymentPassword,
  ) async {
    final amount = withdrawAmount;
    if (amount < 10) {
      ToastUtil.showError('最低提现金额为¥10.00');
      return;
    }
    if (amount > wallet.value.availableBalance) {
      ToastUtil.showError('提现金额不能超过可用余额');
      return;
    }

    isSubmitting.value = true;
    try {
      await _repository.withdraw(
        accountId: account.id,
        accountName: account.accountName,
        accountNo: account.accountNo,
        amount: amount,
        method: account.method,
        payPassword: paymentPassword,
      );
      ToastUtil.showSuccess('提现申请已提交');
      amountController.clear();
      await loadHome();
      await refreshWithdrawals();
      Get.back();
    } catch (e) {
      ToastUtil.showError('提现失败: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> loadWithdrawalDetail(int id) async {
    isLoading.value = true;
    try {
      withdrawalDetail.value = await _repository.getWithdrawalDetail(id);
    } catch (e) {
      ToastUtil.showError('加载提现详情失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bindPaymentAccount({
    required String accountName,
    required String accountNo,
    required String method,
    bool isDefault = false,
  }) async {
    isSubmitting.value = true;
    try {
      await _repository.bindPaymentAccount(
        accountName: accountName,
        accountNo: accountNo,
        method: method,
        isDefault: isDefault ? 1 : 0,
      );
      ToastUtil.showSuccess('绑定成功');
      await loadHome();
      Get.back();
    } catch (e) {
      ToastUtil.showError('绑定失败: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
