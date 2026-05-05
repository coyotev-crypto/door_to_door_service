
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

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
  /// [cityId] 城市ID
  /// [cityName] 城市名称
  /// [serviceRange] 上门服务范围
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
  /// [latitude] 纬度
  /// [longitude] 经度
  Future<void> submitQualification({
    required String name,
    required String phone,
    required int age,
    required String gender,
    required int cityId,
    required String cityName,
    required double serviceRange,
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
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.submitProviderQualification,
      data: {
        'name': name,
        'phone': phone,
        'age': age,
        'gender': gender,
        'cityId': cityId,
        'cityName': cityName,
        'serviceRange': serviceRange,
        'emergencyContact': emergencyContact,
        'emergencyPhone': emergencyPhone,
        'recentPhoto': recentPhoto,
        'healthCert': healthCert,
        'qualificationCert': qualificationCert,
        'otherCert': otherCert,
        'idCardFront': idCardFront,
        'idCardBack': idCardBack,
        'noCriminalRecord': noCriminalRecord,
        'certificateLevel': certificateLevel,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      // 检查响应码
      if (responseData['code'] != 200) {
        throw Exception('提交资质材料失败: ${responseData['msg'] ?? '未知错误'}');
      }
      // 资质材料提交成功，无需返回数据
    } else {
      throw Exception('提交资质材料失败: 响应数据格式不正确');
    }
  }
}
