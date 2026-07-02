import '../../core/network/api_endpoints.dart';
import '../../core/network/base_response.dart';
import '../../core/network/dio_client.dart';
import '../models/chat_user_profile_model.dart';
import '../models/openim_token_model.dart';

class OpenIMChatRepository {
  final DioClient _dioClient;

  OpenIMChatRepository() : _dioClient = DioClient.instance;

  Future<OpenIMTokenModel> getToken() async {
    final response = await _dioClient.get(ApiEndpoints.openIMToken);
    final responseData = response.data as Map<String, dynamic>;
    final tokenData = responseData.containsKey('data')
        ? BaseResponse<OpenIMTokenModel>.fromJson(
            responseData,
            dataParser: (data) => OpenIMTokenModel.fromJson(
              data as Map<String, dynamic>,
            ),
          ).data
        : OpenIMTokenModel.fromJson(responseData);

    if (tokenData == null ||
        tokenData.openIMUserID.isEmpty ||
        tokenData.token.isEmpty ||
        tokenData.apiAddr.isEmpty ||
        tokenData.wsAddr.isEmpty) {
      throw Exception('OpenIM token数据异常');
    }
    return tokenData;
  }

  Future<List<ChatUserProfileModel>> getUserProfiles(
    List<int> userIds,
  ) async {
    if (userIds.isEmpty) return [];

    final response = await _dioClient.post(
      ApiEndpoints.chatUsersBatch,
      data: {
        'userIds': userIds,
      },
      cancelPrevious: false,
    );
    final baseResponse = BaseResponse<List<ChatUserProfileModel>>.fromJson(
      response.data as Map<String, dynamic>,
      dataParser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list
            .map((item) =>
                ChatUserProfileModel.fromJson(item as Map<String, dynamic>))
            .where((item) => item.userId > 0)
            .toList();
      },
    );
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse.data ?? [];
  }
}
