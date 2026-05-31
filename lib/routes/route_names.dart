/// 路由名称常量类
/// 统一管理所有路由地址
class RouteNames {
  // 私有构造函数，防止实例化
  RouteNames._();

  // 认证相关
  static const String splash = '/splash';
  static const String login = '/login';
  // 主页面
  static const String home = '/';
  static const String profile = '/profile';
  static const String profileEdit = '/profile-edit';
  static const String settings = '/settings';
  
  // 入驻相关
  static const String providerJoin = '/provider-join';
  static const String providerQualification = '/provider-join/qualification';
  static const String providerService = '/provider-join/service';
  static const String providerServiceList = '/provider-join/service/list';

  // 订单相关
  static const String orderCreate = '/order/create';
  static const String orderPayment = '/order/payment';
  static const String customerOrderList = '/order/list';
  static const String providerOrderList = '/order/provider-list';

  // 社区相关
  static const String postList = '/community';
  static const String postCreate = '/community/create';
  static const String postDetail = '/community/post';

  // 服务相关
  static const String category = '/category';
  static const String moreRecommendations = '/more-recommendations';
  static const String search = '/search';
  static const String favorites = '/favorites';

  // 协议相关
  static const String privacyPolicy = '/privacy-policy';
  static const String userAgreement = '/user-agreement';

  // 地址相关
  static const String addressSelect = '/address/select';
  static const String addressManage = '/address/manage';
  static const String addressEdit = '/address/edit';
  static const String mapSelect = '/map/select';

  // 账户安全相关
  static const String accountSecurity = '/account/security';
  static const String changePassword = '/account/change-password';
  static const String setPaymentPassword = '/account/set-payment-password';
  static const String changePhone = '/account/change-phone';
  static const String loginDevices = '/account/login-devices';
  static const String deleteAccount = '/account/delete-account';
}
