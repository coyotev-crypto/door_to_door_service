class WalletModel {
  final double availableBalance;
  final double frozenBalance;
  final double totalIncome;

  const WalletModel({
    this.availableBalance = 0,
    this.frozenBalance = 0,
    this.totalIncome = 0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      availableBalance: _toDouble(
        json['availableBalance'] ?? json['balance'] ?? json['available'],
      ),
      frozenBalance: _toDouble(json['frozenBalance'] ?? json['frozen']),
      totalIncome: _toDouble(json['totalIncome'] ?? json['incomeTotal']),
    );
  }
}

class WalletTransactionModel {
  final int id;
  final String type;
  final String description;
  final double amount;
  final String? orderNo;
  final DateTime? createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    this.orderNo,
    this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ??
          json['remark']?.toString() ??
          _transactionTypeText(json['type']?.toString() ?? ''),
      amount: _toDouble(json['amount']),
      orderNo: json['orderNo']?.toString() ??
          json['referenceNo']?.toString() ??
          json['transactionNo']?.toString() ??
          json['orderId']?.toString(),
      createdAt: _toDateTime(json['createdAt'] ?? json['createTime']),
    );
  }

  bool get isIncome => amount >= 0 && type != 'withdraw';
}

class WithdrawalModel {
  final int id;
  final double amount;
  final double fee;
  final String status;
  final String bankName;
  final String bankCardTail;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const WithdrawalModel({
    required this.id,
    required this.amount,
    required this.fee,
    required this.status,
    required this.bankName,
    required this.bankCardTail,
    this.createdAt,
    this.completedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: _toInt(json['id']),
      amount: _toDouble(json['amount']),
      fee: _toDouble(json['fee']),
      status: json['status']?.toString() ?? 'pending',
      bankName: json['bankName']?.toString() ?? '',
      bankCardTail: json['bankCardTail']?.toString() ??
          json['cardTail']?.toString() ??
          '',
      createdAt: _toDateTime(json['createdAt'] ?? json['createTime']),
      completedAt: _toDateTime(json['completedAt'] ?? json['completeTime']),
    );
  }

  double get arrivalAmount => amount - fee;
}

class CommissionRateModel {
  final double rate;
  final String rateText;
  final DateTime? updatedAt;

  const CommissionRateModel({
    this.rate = 0,
    this.rateText = '',
    this.updatedAt,
  });

  factory CommissionRateModel.fromJson(Map<String, dynamic> json) {
    return CommissionRateModel(
      rate: _normalizeRate(_toDouble(json['rate'])),
      rateText: json['rateText']?.toString() ?? '',
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }
}

class PaymentAccountModel {
  final int id;
  final int userId;
  final String method; // 支付方式: alipay, wechat, bank_card
  final String accountNo;
  final String accountNoMask; // 掩码后的账号
  final String accountName; // 账户名称
  final int status; // 账户状态: 0=有效, 1=无效
  final int isDefault; // 是否为默认账户: 0=否, 1=是
  final DateTime? createTime;
  final DateTime? updateTime;

  const PaymentAccountModel({
    required this.id,
    required this.userId,
    required this.method,
    required this.accountNo,
    required this.accountNoMask,
    required this.accountName,
    required this.status,
    required this.isDefault,
    this.createTime,
    this.updateTime,
  });

  factory PaymentAccountModel.fromJson(Map<String, dynamic> json) {
    return PaymentAccountModel(
      id: _toInt(json['id']),
      userId: _toInt(json['userId']),
      method: json['method']?.toString() ?? '',
      accountNo: json['accountNo']?.toString() ?? '',
      accountNoMask: json['accountNoMask']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      status: _toInt(json['status']),
      isDefault: _toInt(json['isDefault']),
      createTime: _toDateTime(json['createTime']),
      updateTime: _toDateTime(json['updateTime']),
    );
  }

  bool get isValid => status == 0;
  bool get isPrimary => isDefault == 1;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

double _normalizeRate(double rate) {
  if (rate > 1) return rate / 100;
  return rate;
}

String _transactionTypeText(String type) {
  switch (type) {
    case 'income':
      return '订单收入';
    case 'withdraw':
      return '提现';
    case 'refund':
      return '退款';
    case 'freeze':
      return '冻结';
    case 'unfreeze':
      return '解冻';
    default:
      return type;
  }
}
