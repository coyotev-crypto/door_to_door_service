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
  static const String getUserInfo = '/user/profile';

  /// 更新用户信息
  static const String updateUserInfo = '/user/profile';

  /// 上传图片
  static const String uploadImage = '/public/uploadFile';

  /// 验证码重置密码
  static const String resetPasswordWithCode = '/user/pwd/reset-with-code';

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

  /// 根据ID获取服务详情
  static const String getServiceById = '/service/{id}';

  /// 更新服务
  static const String updateService = '/service/{id}';

  /// 创建服务
  static const String createService = '/service';

  /// 获取我的服务列表
  static const String getMyServices = '/service/my';

  static const String toggleFavoriteService = '/service/favorite';

  static const String deleteFavoriteService = '/service/favorite/{id}';

  /// 获取收藏列表
  static const String getFavorites = '/service/favorite/list';

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

  // ========== 实名认证相关 ==========

  /// 创建实名认证
  static const String createRealNameAuth = '/real-name-auth';

  /// 获取实名认证信息
  static const String getRealNameAuth = '/real-name-auth';

  /// 更新实名认证信息
  static const String updateRealNameAuth = '/real-name-auth';

  // ========== 账户安全相关 ==========

  /// 修改登录密码
  static const String changePassword = '/user/pwd/set';

  /// 设置支付密码
  static const String setPaymentPassword = '/user/pay-password/set';

  /// 修改支付密码
  static const String changePaymentPassword = '/user/payment-password/change';

  /// 验证支付密码
  static const String verifyPaymentPassword = '/user/payment-password/verify';

  /// 更换手机号
  static const String changePhoneNumber = '/user/phone/change';

  /// 获取登录设备列表
  static const String getLoginDevices = '/user/login-devices';

  /// 移除登录设备
  static const String removeLoginDevice = '/user/login-devices/{id}';

  /// 注销账号
  static const String deleteAccount = '/user/account';

  // ========== 社区帖子相关 ==========

  /// 帖子列表
  static const String getPostList = '/community-post/list';

  /// 帖子详情
  static const String getPostDetail = '/community-post/{id}';

  /// 发布帖子
  static const String createPost = '/community-post';

  /// 删除帖子
  static const String deletePost = '/community-post/{id}';

  /// 帖子点赞
  static const String togglePostLike = '/community-post/{id}/like';

  /// 帖子收藏
  static const String togglePostCollect = '/community-post/{id}/collect';

  /// 评论列表
  static const String getComments = '/community-post/{id}/comments';

  /// 发表评论
  static const String createComment = '/community-post/{id}/comments';

  /// 删除评论
  static const String deleteComment = '/comment/{id}';

  /// 评论点赞
  static const String toggleCommentLike = '/comment/{id}/like';

  // ========== 服务商资质相关 ==========

  /// 提交服务商资质材料
  static const String submitProviderQualification =
      '/service-provider-qualification';

  /// 获取当前用户资质认证数据
  static const String getMyQualification = '/service-provider-qualification/my';

  /// 更新服务商资质材料
  static const String updateProviderQualification =
      '/service-provider-qualification/{id}';
}
