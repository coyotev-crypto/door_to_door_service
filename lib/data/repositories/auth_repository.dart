import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/services/token_service.dart';
import '../models/login_response_model.dart';
import '../models/sms_response_model.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient.instance;
  final TokenService _tokenService = TokenService.instance;

  /// 发送短信验证码
  /// [phoneNumber] 手机号
  /// [type] 类型：1-注册, 2-登录, 3-找回密码
  Future<SmsResponseModel> sendSmsCode({
    required String phoneNumber,
    required String type,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.sendSmsCode,
      data: {
        'phoneNumber': phoneNumber,
        'type': type,
        'templateCode': ApiConfig.smsTemplateCode
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      return SmsResponseModel.fromJson(responseData);
    } else {
      throw Exception('发送验证码失败: 响应数据格式不正确');
    }
  }

  /// 手机号登录/注册
  /// [phoneNumber] 手机号
  /// [smsCode] 短信验证码
  Future<LoginResponseModel> loginByPhone({
    required String phoneNumber,
    required String smsCode,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.loginByPhone,
      data: {
        'phoneNumber': phoneNumber,
        'smsCode': smsCode,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final loginResponse = LoginResponseModel.fromJson(responseData);

      // 检查token是否存在
      if (loginResponse.token == null) {
        throw Exception('登录失败: 服务器未返回访问令牌');
      }
      return loginResponse;
    } else {
      throw Exception('登录失败: 响应数据格式不正确');
    }
  }

  /// 密码登录
  /// [phoneNumber] 手机号
  /// [password] 密码
  Future<LoginResponseModel> loginByPassword({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.loginByPassword,
      data: {
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final loginResponse = LoginResponseModel.fromJson(responseData);

      // 检查token是否存在
      if (loginResponse.token == null) {
        throw Exception('登录失败: 服务器未返回访问令牌');
      }
      return loginResponse;
    } else {
      throw Exception('登录失败: 响应数据格式不正确');
    }
  }

  /// 微信登录
  /// [openId] 微信openId
  /// [unionId] 微信unionId（可选）
  /// [nickName] 昵称（可选）
  /// [avatar] 头像URL（可选）
  Future<LoginResponseModel> loginByWechat({
    required String openId,
    String? unionId,
    String? nickName,
    String? avatar,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.loginByWechat,
      data: {
        'type': 'wechat',
        'openId': openId,
        'unionId': unionId,
        'nickName': nickName,
        'avatar': avatar,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final loginResponse = LoginResponseModel.fromJson(responseData);

      // 检查token是否存在
      if (loginResponse.token == null) {
        throw Exception('登录失败: 服务器未返回访问令牌');
      }
      return loginResponse;
    } else {
      throw Exception('登录失败: 响应数据格式不正确');
    }
  }

  /// 支付宝登录
  /// [openId] 支付宝openId
  /// [nickName] 昵称（可选）
  /// [avatar] 头像URL（可选）
  Future<LoginResponseModel> loginByAlipay({
    required String openId,
    String? nickName,
    String? avatar,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.loginByAlipay,
      data: {
        'type': 'alipay',
        'openId': openId,
        'nickName': nickName,
        'avatar': avatar,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final loginResponse = LoginResponseModel.fromJson(responseData);

      // 检查token是否存在
      if (loginResponse.token == null) {
        throw Exception('登录失败: 服务器未返回访问令牌');
      }
      return loginResponse;
    } else {
      throw Exception('登录失败: 响应数据格式不正确');
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } finally {
      // 无论接口调用成功与否，都清除本地Token
      await _tokenService.clearToken();
    }
  }
}
