import 'package:door_to_door_service/core/network/base_response.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/provider_qualification_model.dart';

/// 服务商仓库类
/// 处理服务商相关的数据操作
class ProviderRepository {
  final DioClient _dioClient = DioClient.instance;

  /// 提交服务商资质材料
  ///
  /// [name] 服务商姓名
  /// [phone] 联系电话
  /// [age] 年龄
  /// [gender] 性别
  /// [emergencyContact] 紧急联系人
  /// [emergencyPhone] 紧急联系人电话
  /// [recentPhoto] 本人近期照URL
  /// [healthCert] 健康证URL
  /// [qualificationCert] 从业证明URL
  /// [otherCert] 证书URL
  /// [idCardFront] 身份证正面URL
  /// [idCardBack] 身份证反面URL
  /// [noCriminalRecord] 无犯罪记录证明URL
  /// [certificateLevel] 证书等级
  /// [createBy] 创建人ID
  /// [updateBy] 更新人ID
  Future<BaseResponse<void>> submitQualification({
    required String name,
    required String phone,
    required int age,
    required String gender,
    required String emergencyContact,
    required String emergencyPhone,
    required String recentPhoto,
    required String healthCert,
    required String qualificationCert,
    required String otherCert,
    required String idCardFront,
    required String idCardBack,
    required String noCriminalRecord,
    required String certificateLevel,
    int createBy = 0,
    int updateBy = 0,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.submitProviderQualification,
      data: {
        'age': age,
        'certificateLevel': certificateLevel,
        'createBy': createBy,
        'emergencyContact': emergencyContact,
        'emergencyPhone': emergencyPhone,
        'gender': gender,
        'healthCert': healthCert,
        'idCardBack': idCardBack,
        'idCardFront': idCardFront,
        'name': name,
        'noCriminalRecord': noCriminalRecord,
        'otherCert': otherCert,
        'phone': phone,
        'qualificationCert': qualificationCert,
        'recentPhoto': recentPhoto,
        'updateBy': updateBy,
      },
    );
    final baseResponse = BaseResponse<void>.fromJson(response.data);
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }

  /// 更新服务商资质材料
  ///
  /// [id] 资质记录ID
  /// [name] 服务商姓名
  /// [phone] 联系电话
  /// [age] 年龄
  /// [gender] 性别
  /// [emergencyContact] 紧急联系人
  /// [emergencyPhone] 紧急联系人电话
  /// [recentPhoto] 本人近期照URL
  /// [healthCert] 健康证URL
  /// [qualificationCert] 从业证明URL
  /// [otherCert] 证书URL
  /// [idCardFront] 身份证正面URL
  /// [idCardBack] 身份证反面URL
  /// [noCriminalRecord] 无犯罪记录证明URL
  /// [certificateLevel] 证书等级
  Future<BaseResponse<void>> updateQualification({
    required int id,
    required String name,
    required String phone,
    required int age,
    required String gender,
    required String emergencyContact,
    required String emergencyPhone,
    required String recentPhoto,
    required String healthCert,
    required String qualificationCert,
    required String otherCert,
    required String idCardFront,
    required String idCardBack,
    required String noCriminalRecord,
    required String certificateLevel,
  }) async {
    final path = ApiEndpoints.updateProviderQualification
        .replaceAll('{id}', id.toString());
    final response = await _dioClient.put(
      path,
      data: {
        'id': id,
        'age': age,
        'certificateLevel': certificateLevel,
        'emergencyContact': emergencyContact,
        'emergencyPhone': emergencyPhone,
        'gender': gender,
        'healthCert': healthCert,
        'idCardBack': idCardBack,
        'idCardFront': idCardFront,
        'name': name,
        'noCriminalRecord': noCriminalRecord,
        'otherCert': otherCert,
        'phone': phone,
        'qualificationCert': qualificationCert,
        'recentPhoto': recentPhoto,
      },
    );
    final baseResponse = BaseResponse<void>.fromJson(response.data);
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }

  /// 获取当前用户资质认证数据
  ///
  /// 返回当前用户的资质认证信息
  Future<BaseResponse<ProviderQualificationModel>> getMyQualification() async {
    final response = await _dioClient.get(
      ApiEndpoints.getMyQualification,
    );
    final baseResponse = BaseResponse<ProviderQualificationModel>.fromJson(
      response.data,
      dataParser: (data) => ProviderQualificationModel.fromJson(data),
    );
    if (!baseResponse.isSuccess) {
      throw Exception(baseResponse.message);
    }
    return baseResponse;
  }
}
