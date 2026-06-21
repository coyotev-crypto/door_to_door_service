import '../../core/network/api_endpoints.dart';
import '../../core/network/base_response.dart';
import '../../core/network/dio_client.dart';
import '../models/agora_chat_token_model.dart';
import '../models/chat_user_profile_model.dart';

class AgoraChatRepository {
  final DioClient _dioClient;

  AgoraChatRepository() : _dioClient = DioClient.instance;

  Future<AgoraChatTokenModel> getToken() async {
    final response = await _dioClient.get(ApiEndpoints.agoraChatToken);
    final responseData = response.data as Map<String, dynamic>;
    final tokenData = responseData.containsKey('data')
        ? BaseResponse<AgoraChatTokenModel>.fromJson(
            responseData,
            dataParser: (data) => AgoraChatTokenModel.fromJson(
              data as Map<String, dynamic>,
            ),
          ).data
        : AgoraChatTokenModel.fromJson(responseData);

    if (tokenData == null ||
        tokenData.appKey.isEmpty ||
        tokenData.chatUserId.isEmpty ||
        tokenData.token.isEmpty) {
      throw Exception('Agora Chat token数据异常');
    }
    return tokenData;
  }

  Future<List<ChatUserProfileModel>> getUserProfiles(
    List<int> userIds,
  ) async {
    if (userIds.isEmpty) return [];

    final response = await _dioClient.post(
      ApiEndpoints.agoraChatUsersBatch,
      data: {
        'userIds': userIds,
      },
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
