import '../../core/network/api_endpoints.dart';
import '../../core/network/base_response.dart';
import '../../core/network/dio_client.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final DioClient _dioClient;

  WalletRepository() : _dioClient = DioClient.instance;

  Future<WalletModel> getWallet() async {
    final response = await _dioClient.get(ApiEndpoints.wallet);
    final result = BaseResponse<WalletModel>.fromJson(
      response.data,
      dataParser: (data) => WalletModel.fromJson(data as Map<String, dynamic>),
    );
    if (!result.isSuccess) throw Exception(result.message);
    return result.data ?? const WalletModel();
  }

  Future<CommissionRateModel> getCommissionRate() async {
    final response = await _dioClient.get(ApiEndpoints.commissionRate);
    final result = BaseResponse<CommissionRateModel>.fromJson(
      response.data,
      dataParser: (data) =>
          CommissionRateModel.fromJson(data as Map<String, dynamic>),
    );
    if (!result.isSuccess) throw Exception(result.message);
    return result.data ?? const CommissionRateModel();
  }

  Future<List<WalletTransactionModel>> getTransactions({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.walletTransactions,
      queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
    );
    return BaseResponse<List<WalletTransactionModel>>.fromJson(
          response.data,
          dataParser: (data) => _parseList(
            data,
            (item) => WalletTransactionModel.fromJson(item),
          ),
        ).data ??
        [];
  }

  Future<void> withdraw({
    required int accountId,
    required String accountName,
    required String accountNo,
    required double amount,
    required String method,
    required String payPassword,
    String remark = '',
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.walletWithdrawals,
      data: {
        'accountId': accountId,
        'accountName': accountName,
        'accountNo': accountNo,
        'amount': amount,
        'method': method,
        'payPassword': payPassword,
        'remark': remark,
      },
    );
    final result = BaseResponse<dynamic>.fromJson(response.data);
    if (!result.isSuccess) throw Exception(result.message);
  }

  Future<List<WithdrawalModel>> getWithdrawals({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.walletWithdrawals,
      queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
    );
    return BaseResponse<List<WithdrawalModel>>.fromJson(
          response.data,
          dataParser: (data) => _parseList(
            data,
            (item) => WithdrawalModel.fromJson(item),
          ),
        ).data ??
        [];
  }

  Future<WithdrawalModel> getWithdrawalDetail(int id) async {
    final path = ApiEndpoints.walletWithdrawalDetail.replaceAll(
      '{id}',
      id.toString(),
    );
    final response = await _dioClient.get(path);
    final result = BaseResponse<WithdrawalModel>.fromJson(
      response.data,
      dataParser: (data) =>
          WithdrawalModel.fromJson(data as Map<String, dynamic>),
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.message);
    }
    return result.data!;
  }

  /// 获取收款账户列表
  Future<List<PaymentAccountModel>> getPaymentAccounts() async {
    final response = await _dioClient.get(ApiEndpoints.paymentAccounts);
    return BaseResponse<List<PaymentAccountModel>>.fromJson(
          response.data,
          dataParser: (data) => _parseList(
            data,
            (item) => PaymentAccountModel.fromJson(item),
          ),
        ).data ??
        [];
  }

  /// 绑定收款账户
  Future<void> bindPaymentAccount({
    required String accountName,
    required String accountNo,
    required String method,
    int isDefault = 0,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.paymentAccounts,
      data: {
        'accountName': accountName,
        'accountNo': accountNo,
        'method': method,
        'isDefault': isDefault,
      },
    );
    final result = BaseResponse<dynamic>.fromJson(response.data);
    if (!result.isSuccess) throw Exception(result.message);
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) parser,
  ) {
    final source = data is List
        ? data
        : data is Map<String, dynamic> && data['list'] is List
            ? data['list'] as List
            : const [];
    return source.map((item) => parser(item as Map<String, dynamic>)).toList();
  }
}
