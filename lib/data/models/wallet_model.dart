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
      description:
          json['description']?.toString() ?? json['remark']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      orderNo: json['orderNo']?.toString(),
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
