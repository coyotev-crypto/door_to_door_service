import '../../core/network/api_endpoints.dart';
import '../../core/network/base_response.dart';
import '../../core/network/dio_client.dart';
import '../models/app_version_model.dart';

class AppVersionRepository {
  final DioClient _dioClient;

  AppVersionRepository() : _dioClient = DioClient.instance;

  Future<AppVersionCheckResult> checkVersion({
    required String currentVersion,
    required int currentVersionCode,
    required String platform,
    String? deviceId,
    String? userId,
    String? channel,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.appVersionCheck,
      queryParameters: {
        'current_version': currentVersion,
        'current_version_code': currentVersionCode,
        'platform': platform,
        if (deviceId?.isNotEmpty == true) 'device_id': deviceId,
        if (userId?.isNotEmpty == true) 'user_id': userId,
        if (channel?.isNotEmpty == true) 'channel': channel,
      },
    );
    final result = BaseResponse<AppVersionCheckResult>.fromJson(
      response.data,
      dataParser: (data) =>
          AppVersionCheckResult.fromJson(data as Map<String, dynamic>),
    );
    if (!result.isSuccess) {
      throw Exception(result.message);
    }
    return result.data ?? AppVersionCheckResult.none;
  }
}
