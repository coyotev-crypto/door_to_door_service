import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dtd/core/config/app_config.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../../core/utils/log_util.dart';

/// 图片上传服务类
/// 处理图片上传相关功能
class ImageUploadService {
  final String _tag = 'ImageUploadService';
  static final ImageUploadService _instance = ImageUploadService._internal();

  factory ImageUploadService() => _instance;

  ImageUploadService._internal();

  final DioClient _dioClient = DioClient.instance;

  /// 上传图片
  ///
  /// [imageFile] 要上传的图片文件
  /// 返回图片的URL
  Future<String> uploadImage(File imageFile) async {
    try {
      LogUtil.d('开始上传图片: ${imageFile.path}', tag: _tag);

      // 准备上传的文件
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // 发送上传请求
      final response = await _dioClient.post(
        ApiEndpoints.uploadImage,
        data: formData,
      );

      // 解析响应
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        // 检查响应码
        if (responseData['code'] != 200) {
          throw Exception('上传图片失败: ${responseData['msg'] ?? '未知错误'}');
        }

        // 获取图片URL
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          // 优先使用full_path，如果没有则使用path
          final imageUrl =
              data['full_path']?.toString() ?? data['path']?.toString();
          if (imageUrl == null || imageUrl.isEmpty) {
            throw Exception('上传图片失败: 未获取到图片URL');
          }

          final fullUrl = imageUrl.startsWith('http://') ||
                  imageUrl.startsWith('https://')
              ? imageUrl
              : imageUrl.startsWith('/')
                  ? AppConfig.baseUrl + imageUrl
                  : '${AppConfig.baseUrl}/$imageUrl';
          LogUtil.d('图片上传成功: $fullUrl', tag: _tag);
          return fullUrl;
        } else {
          throw Exception('上传图片失败: 响应数据格式不正确');
        }
      } else {
        throw Exception('上传图片失败: 响应数据格式不正确');
      }
    } catch (e) {
      LogUtil.e('上传图片异常: $e', tag: _tag);
      rethrow;
    }
  }
}
