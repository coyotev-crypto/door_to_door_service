/// 路由名称常量类
/// 统一管理所有路由地址
class RouteNames {
  // 私有构造函数，防止实例化
  RouteNames._();

  // 初始路由
  static const String initial = '/splash';

  // 认证相关
  static const String splash = '/splash';
  static const String login = '/login';

  // 主页面
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // 服务相关
  static const String category = '/category';
  static const String moreRecommendations = '/more-recommendations';
  static const String search = '/search';

  // 协议相关
  static const String privacyPolicy = '/privacy-policy';
  static const String userAgreement = '/user-agreement';

  // 地址相关
  static const String addressSelect = '/address/select';
  static const String addressManage = '/address/manage';
  static const String addressEdit = '/address/edit';
  static const String mapSelect = '/map/select';
}
