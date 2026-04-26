/// API端点配置类
/// 统一管理所有API请求路径
class ApiEndpoints {
  // 私有构造函数，防止实例化
  ApiEndpoints._();

  // ========== 认证相关 ==========

  /// 发送短信验证码
  static const String sendSmsCode = '/sms/send-code';

  /// 手机号登录
  static const String loginByPhone = '/login/phone';

  /// 密码登录
  static const String loginByPassword = '/login/password';

  /// 微信登录
  static const String loginByWechat = '/login/wechat';

  /// 支付宝登录
  static const String loginByAlipay = '/login/alipay';

  /// 退出登录
  static const String logout = '/logout';

  // ========== 用户相关 ==========

  /// 获取用户信息
  static const String getUserInfo = '/user/info';

  /// 更新用户信息
  static const String updateUserInfo = '/user/update';

  // ========== 订单相关 ==========

  /// 创建订单
  static const String createOrder = '/order/create';

  /// 获取订单列表
  static const String getOrderList = '/order/list';

  /// 获取订单详情
  static const String getOrderDetail = '/order/detail';

  /// 取消订单
  static const String cancelOrder = '/order/cancel';

  // ========== 服务相关 ==========

  /// 获取服务列表
  static const String getServiceList = '/service/list';

  /// 获取服务详情
  static const String getServiceDetail = '/service/detail';

  /// 更新服务
  static const String updateService = '/service/{id}';

  // ========== 分类相关 ==========

  /// 获取分类列表
  static const String getCategories = '/service-category';

  /// 获取分类服务数量
  static const String getCategoryServiceCount = '/category-service-count';

  // ========== 协议相关 ==========

  /// 获取用户协议
  static const String getUserAgreement = '/agreement/user';

  /// 获取隐私政策
  static const String getPrivacyPolicy = '/agreement/privacy';

  /// 获取协议版本列表
  static const String getAgreementVersions = '/agreement/versions';

  // ========== 地址相关 ==========

  /// 获取地址列表
  static const String getAddressList = '/address/list';

  /// 创建地址
  static const String createAddress = '/address';

  /// 更新地址
  static const String updateAddress = '/address/{id}';

  /// 删除地址
  static const String deleteAddress = '/address/{id}';

  /// 设置默认地址
  static const String setDefaultAddress = '/address/{id}/default';
}
