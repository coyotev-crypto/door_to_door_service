import 'dart:io' show Platform;

/// API配置类
/// 统一管理API相关配置
class AppConfig {
  // 私有构造函数，防止实例化
  AppConfig._();

  /// 宿主机地址
  /// Android 模拟器需用 10.0.2.2 访问宿主机，真机/其他平台用实际 IP
  static String get _host => Platform.isAndroid ? '10.0.2.2' : '192.168.1.7';

  /// API基础URL
  /// 开发环境: http://localhost:8080
  /// 生产环境: 请修改为实际的生产环境地址
  static String get baseUrl => 'http://$_host:8000';
  // 前端地址，用于构建一些需要前端URL的接口，如支付回调等
  static String get webUrl => 'http://$_host:8080';
  static String get baseApiUrl => '$baseUrl/api/v1';

  /// 连接超时时间（秒）
  static const int connectTimeout = 30;

  /// 发送超时时间（秒）
  static const int sendTimeout = 30;

  /// 接收超时时间（秒）
  static const int receiveTimeout = 30;

  /// 请求头配置
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  /// 短信模板代码
  static const String smsTemplateCode = 'SMS_206546305';
  // 1-注册, 2-登录, 3-找回密码, 4-修改支付密码, 5-设置支付密码
  static const String REGISTER_CODE = '1'; // 注册验证码
  static const String LOGIN_CODE = '2'; // 登录验证码
  static const String FORGOT_PASSWORD_CODE = '3'; // 忘记密码验证码
  static const String SET_PAYMENT_PASSWORD_CODE = '5'; // 设置支付密码验证码
  static const String CHANGE_PHONE_CODE = '6'; // 修改手机号验证码

  static const int USER_TYPE = 2; //普通用户
  static const int MERCHANT_USER_TYPE = 3; //商家用户
}
