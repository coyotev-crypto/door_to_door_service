import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/real_name_auth_model.dart';

/// 用户仓库类
/// 处理用户相关的数据操作
class UserRepository {
  final DioClient _dioClient = DioClient.instance;

  /// 获取用户信息
  Future<UserModel> getUserInfo() async {
    final response = await _dioClient.get(
      ApiEndpoints.getUserInfo,
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        final user = data['user'];
        if (user is Map<String, dynamic>) {
          // 将API返回的数据映射到UserModel
          return UserModel(
            id: user['userId']?.toString() ?? '',
            phoneNumber: user['phone']?.toString() ?? '',
            nickname: user['nickName']?.toString(),
            avatar: user['avatar']?.toString(),
            email: user['email']?.toString(),
            gender: user['sex']?.toString(),
            remark: user['remark']?.toString(),
            roleId: user['roleId'] is int
                ? user['roleId']
                : int.tryParse(user['roleId']?.toString() ?? ''),
            createdAt: user['createdAt'] != null
                ? DateTime.tryParse(user['createdAt'])
                : null,
            updatedAt: user['updatedAt'] != null
                ? DateTime.tryParse(user['updatedAt'])
                : null,
          );
        } else {
          throw Exception('获取用户信息失败: 用户数据格式不正确');
        }
      } else {
        throw Exception('获取用户信息失败: 响应数据格式不正确');
      }
    } else {
      throw Exception('获取用户信息失败: 响应数据格式不正确');
    }
  }

  /// 更新用户信息
  Future<UserModel> updateUserInfo({
    String? nickname,
    String? avatar,
    String? email,
    String? gender,
    String? remark,
  }) async {
    final response = await _dioClient.put(
      ApiEndpoints.updateUserInfo,
      data: {
        if (nickname != null) 'nickname': nickname,
        if (avatar != null) 'avatar': avatar,
        if (email != null) 'email': email,
        if (gender != null) 'sex': gender,
        if (remark != null) 'remark': remark,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      // 检查响应码
      if (responseData['code'] != 200) {
        throw Exception('更新用户信息失败: ${responseData['msg'] ?? '未知错误'}');
      }

      // 获取当前用户信息
      final currentUser = await getUserInfo();

      // 返回更新后的用户信息
      return UserModel(
        id: currentUser.id,
        phoneNumber: currentUser.phoneNumber,
        nickname: nickname ?? currentUser.nickname,
        avatar: avatar ?? currentUser.avatar,
        email: email ?? currentUser.email,
        gender: gender ?? currentUser.gender,
        remark: remark ?? currentUser.remark,
        roleId: currentUser.roleId,
        hasPaymentPassword: currentUser.hasPaymentPassword,
        createdAt: currentUser.createdAt,
        updatedAt: currentUser.updatedAt,
      );
    } else {
      throw Exception('更新用户信息失败: 响应数据格式不正确');
    }
  }

  /// 创建实名认证
  Future<void> createRealNameAuth({
    required String realName,
    required String idCardNumber,
    required String idCardFrontImageUrl,
    required String idCardBackImageUrl,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.createRealNameAuth,
      data: {
        'realName': realName,
        'idCardNumber': idCardNumber,
        'idCardFrontImageUrl': idCardFrontImageUrl,
        'idCardBackImageUrl': idCardBackImageUrl,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      // 检查响应码
      if (responseData['code'] != 200) {
        throw Exception('创建实名认证失败: ${responseData['msg'] ?? '未知错误'}');
      }
      // 实名认证成功，无需返回数据
    } else {
      throw Exception('创建实名认证失败: 响应数据格式不正确');
    }
  }

  /// 获取实名认证信息
  Future<RealNameAuthModel> getRealNameAuth() async {
    final response = await _dioClient.get(
      ApiEndpoints.getRealNameAuth,
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      // 检查响应码
      if (responseData['code'] != 200) {
        throw Exception('获取实名认证信息失败: ${responseData['msg'] ?? '未知错误'}');
      }

      // 解析返回的实名认证数据
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return RealNameAuthModel.fromJson(data);
      } else {
        throw Exception('获取实名认证信息失败: 响应数据格式不正确');
      }
    } else {
      throw Exception('获取实名认证信息失败: 响应数据格式不正确');
    }
  }

  /// 更新实名认证信息
  Future<void> updateRealNameAuth({
    required String realName,
    required String idCardNumber,
    required String idCardFrontImageUrl,
    required String idCardBackImageUrl,
  }) async {
    final response = await _dioClient.put(
      ApiEndpoints.updateRealNameAuth,
      data: {
        'realName': realName,
        'idCardNumber': idCardNumber,
        'idCardFrontImageUrl': idCardFrontImageUrl,
        'idCardBackImageUrl': idCardBackImageUrl,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      // 检查响应码
      if (responseData['code'] != 200) {
        throw Exception('更新实名认证信息失败: ${responseData['msg'] ?? '未知错误'}');
      }
      // 实名认证更新成功，无需返回数据
    } else {
      throw Exception('更新实名认证信息失败: 响应数据格式不正确');
    }
  }
}
