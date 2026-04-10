import 'package:get/get.dart';
import 'route_names.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/privacy_policy_screen.dart';
import '../presentation/screens/user_agreement_screen.dart';
import '../presentation/controllers/login_controller.dart';
import '../presentation/controllers/privacy_policy_controller.dart';
import '../presentation/controllers/user_agreement_controller.dart';

class AppPages {
  static const String initial = RouteNames.initial;

  static final routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: RouteNames.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    GetPage(
      name: RouteNames.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: RouteNames.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: RouteNames.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: RouteNames.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PrivacyPolicyController())),
    ),
    GetPage(
      name: RouteNames.userAgreement,
      page: () => const UserAgreementScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => UserAgreementController())),
    ),
  ];
}
