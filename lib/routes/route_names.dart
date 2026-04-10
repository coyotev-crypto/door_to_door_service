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

  // 协议相关
  static const String privacyPolicy = '/privacy-policy';
  static const String userAgreement = '/user-agreement';
}
