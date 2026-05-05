import '../models/login_device_model.dart';
import '../../core/network/base_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

/// 账户安全仓库
/// 处理账户安全相关的数据请求
class AccountSecurityRepository {
  final DioClient _dioClient;

  AccountSecurityRepository() : _dioClient = DioClient.instance;

  /// 修改登录密码
  /// [oldPassword] 旧密码
  /// [newPassword] 新密码
  /// 返回BaseResponse包含操作结果
  Future<BaseResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _dioClient.put(
      ApiEndpoints.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    final baseResponse = BaseResponse<void>.fromJson(response.data);
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }

  /// 设置支付密码
  /// [payPassword] 支付密码
  /// [phone] 手机号
  /// [code] 短信验证码
  /// 返回后端响应的消息
  Future<BaseResponse> setPaymentPassword({
    required String payPassword,
    required String phone,
    required String code,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.setPaymentPassword,
      data: {
        'payPassword': payPassword,
        'phone': phone,
        'code': code,
      },
    );
    
    // 解析后端返回的数据
    final baseResponse = BaseResponse<dynamic>.fromJson(
      response.data,
    );
    
    // 检查响应码，如果不是200则抛出异常
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    
    return baseResponse;
  }

  /// 修改支付密码
  /// [oldPassword] 旧支付密码
  /// [newPassword] 新支付密码
  /// [smsCode] 短信验证码
  /// 返回BaseResponse包含操作结果
  Future<BaseResponse<void>> changePaymentPassword({
    required String oldPassword,
    required String newPassword,
    required String smsCode,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.changePaymentPassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'smsCode': smsCode,
      },
    );

    final baseResponse = BaseResponse<void>.fromJson(response.data);
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }

  /// 验证支付密码
  /// [password] 支付密码
  /// 返回BaseResponse包含验证结果
  Future<BaseResponse<bool>> verifyPaymentPassword({
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.verifyPaymentPassword,
      data: {
        'password': password,
      },
    );

    final baseResponse = BaseResponse<bool>.fromJson(
      response.data,
      dataParser: (data) => data['success'] ?? false,
    );
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }

  /// 更换手机号
  /// [newPhone] 新手机号
  /// [code] 短信验证码
  /// 返回BaseResponse包含操作结果
  Future<BaseResponse<void>> changePhoneNumber({
    required String newPhone,
    required String code,
  }) async {
    final response = await _dioClient.put(
      ApiEndpoints.changePhoneNumber,
      data: {
        'newPhone': newPhone,
        'code': code,
      },
    );

    final baseResponse = BaseResponse<void>.fromJson(response.data);
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }

  /// 获取登录设备列表
  /// 返回BaseResponse包含设备列表数据
  Future<BaseResponse<List<LoginDeviceModel>>> getLoginDevices() async {
    final response = await _dioClient.get(
      ApiEndpoints.getLoginDevices,
    );

    final baseResponse = BaseResponse<List<LoginDeviceModel>>.fromJson(
      response.data,
      dataParser: (data) {
        final List<dynamic> list = data['list'] ?? [];
        return list.map((e) => LoginDeviceModel.fromJson(e)).toList();
      },
    );
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }

  /// 移除登录设备
  /// [deviceId] 设备ID
  /// 返回BaseResponse包含操作结果
  Future<BaseResponse<void>> removeLoginDevice({
    required String deviceId,
  }) async {
    final endpoint = ApiEndpoints.removeLoginDevice
        .replaceAll('{id}', deviceId);
    final response = await _dioClient.delete(endpoint);

    final baseResponse = BaseResponse<void>.fromJson(response.data);
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }

  /// 注销账号
  /// [smsCode] 短信验证码
  /// 返回BaseResponse包含操作结果
  Future<BaseResponse<void>> deleteAccount({
    required String smsCode,
  }) async {
    final response = await _dioClient.delete(
      ApiEndpoints.deleteAccount,
      data: {
        'smsCode': smsCode,
      },
    );

    final baseResponse = BaseResponse<void>.fromJson(response.data);
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }
}
