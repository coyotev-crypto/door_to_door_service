import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/agreement_model.dart';

class AgreementRepository {
  final DioClient _dioClient = DioClient.instance;

  /// 获取用户协议
  /// [version] 版本号（可选）
  Future<AgreementModel> getUserAgreement({String? version}) async {
    final response = await _dioClient.get(
      ApiEndpoints.getUserAgreement,
      queryParameters: {
        'type': 'user',
        if (version != null) 'version': version,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      return AgreementModel.fromJson(responseData['data']);
    } else {
      throw Exception('获取用户协议失败: 响应数据格式不正确');
    }
  }

  /// 获取隐私政策
  /// [version] 版本号（可选）
  Future<AgreementModel> getPrivacyPolicy({String? version}) async {
    final response = await _dioClient.get(
      ApiEndpoints.getPrivacyPolicy,
      queryParameters: {
        'type': 'privacy',
        if (version != null) 'version': version,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      return AgreementModel.fromJson(responseData['data']);
    } else {
      throw Exception('获取隐私政策失败: 响应数据格式不正确');
    }
  }

  /// 获取协议版本列表
  /// [type] 协议类型：user-用户协议, privacy-隐私政策
  /// [pageIndex] 页码
  /// [pageSize] 每页数量
  Future<Map<String, dynamic>> getAgreementVersions({
    required String type,
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.getAgreementVersions,
      queryParameters: {
        'type': type,
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      return {
        'list': (responseData['data']['list'] as List)
            .map((e) => AgreementModel.fromJson(e))
            .toList(),
        'total': responseData['data']['total'] as int,
      };
    } else {
      throw Exception('获取协议版本列表失败: 响应数据格式不正确');
    }
  }
}
