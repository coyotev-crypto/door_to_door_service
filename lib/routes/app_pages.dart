import 'package:door_to_door_service/presentation/controllers/home_content_controller.dart';
import 'package:door_to_door_service/presentation/controllers/service_controller.dart';
import 'package:get/get.dart';
import 'route_names.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/privacy_policy_screen.dart';
import '../presentation/screens/user_agreement_screen.dart';
import '../presentation/screens/more_recommendations_screen.dart';
import '../presentation/screens/search_screen.dart';
import '../presentation/screens/address_select_screen.dart';
import '../presentation/screens/address_manage_screen.dart';
import '../presentation/screens/address_edit_screen.dart';
import '../presentation/screens/map_select_screen.dart';
import '../presentation/controllers/login_controller.dart';
import '../presentation/controllers/privacy_policy_controller.dart';
import '../presentation/controllers/user_agreement_controller.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/message_controller.dart';
import '../presentation/controllers/more_recommendations_controller.dart';
import '../presentation/controllers/search_controller.dart';
import '../presentation/controllers/address_controller.dart';
import '../core/services/agora_chat_service.dart';

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
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => HomeController()),
            Get.lazyPut(() => MessageController()),
            Get.lazyPut(() => ServiceController()),
            Get.lazyPut(() => HomeContentController()),
            Get.put(() => AgoraChatService()),
          ]),
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
      binding:
          BindingsBuilder(() => Get.lazyPut(() => PrivacyPolicyController())),
    ),
    GetPage(
      name: RouteNames.userAgreement,
      page: () => const UserAgreementScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => UserAgreementController())),
    ),
    GetPage(
      name: RouteNames.moreRecommendations,
      page: () => const MoreRecommendationsScreen(),
      binding: BindingsBuilder(
          () => Get.lazyPut(() => MoreRecommendationsController())),
    ),
    GetPage(
      name: RouteNames.search,
      page: () => const SearchScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SearchController())),
    ),
    // 地址相关路由
    GetPage(
      name: RouteNames.addressSelect,
      page: () => const AddressSelectScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AddressController())),
    ),
    GetPage(
      name: RouteNames.addressManage,
      page: () => const AddressManageScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AddressController())),
    ),
    GetPage(
      name: RouteNames.addressEdit,
      page: () => const AddressEditScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AddressController())),
    ),
    GetPage(
      name: RouteNames.mapSelect,
      page: () => const MapSelectScreen(),
    ),
  ];
}
