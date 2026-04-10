/// API配置类
/// 统一管理API相关配置
class ApiConfig {
  // 私有构造函数，防止实例化
  ApiConfig._();

  /// API基础URL
  /// 开发环境: http://localhost:8080
  /// 生产环境: 请修改为实际的生产环境地址
  static const String baseUrl = 'http://172.18.0.1:8000/api/v1';

  /// 连接超时时间（秒）
  static const int connectTimeout = 30;

  /// 接收超时时间（秒）
  static const int receiveTimeout = 30;

  /// 请求头配置
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  /// 短信模板代码
  static const String smsTemplateCode = 'SMS_206546305';
}
