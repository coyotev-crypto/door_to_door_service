import 'package:door_to_door_service/presentation/controllers/home_content_controller.dart';
import 'package:door_to_door_service/presentation/controllers/order_controller.dart';
import 'package:door_to_door_service/presentation/controllers/order_list_controller.dart';
import 'package:door_to_door_service/presentation/controllers/map_select_controller.dart';
import 'package:door_to_door_service/presentation/controllers/profile_controller.dart';
import 'package:door_to_door_service/presentation/controllers/provider_qualification_controller.dart';
import 'package:door_to_door_service/presentation/controllers/provider_service_controller.dart';
import 'package:door_to_door_service/presentation/controllers/provider_service_list_controller.dart';
import 'package:door_to_door_service/presentation/controllers/service_controller.dart';
import 'package:door_to_door_service/presentation/controllers/favorite_controller.dart';
import 'package:door_to_door_service/presentation/controllers/post_list_controller.dart';
import 'package:door_to_door_service/presentation/controllers/post_create_controller.dart';
import 'package:door_to_door_service/presentation/controllers/post_detail_controller.dart';
import 'package:get/get.dart';
import 'route_names.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/account/forgot_password_screen.dart';
import '../presentation/screens/community/post_list_page.dart';
import '../presentation/screens/community/post_create_page.dart';
import '../presentation/screens/community/post_detail_page.dart';
import '../presentation/screens/order/order_create_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/account/profile_edit_screen.dart';
import '../presentation/screens/provider/provider_join_page.dart';
import '../presentation/screens/provider/provider_qualification_page.dart';
import '../presentation/screens/provider/provider_service_page.dart';
import '../presentation/screens/provider/provider_service_list_page.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/agreement/privacy_policy_screen.dart';
import '../presentation/screens/agreement/user_agreement_screen.dart';
import '../presentation/screens/server/more_recommendations_screen.dart';
import '../presentation/screens/server/search_screen.dart';
import '../presentation/screens/server/favorite_list_screen.dart';
import '../presentation/screens/address/address_select_screen.dart';
import '../presentation/screens/address/address_manage_screen.dart';
import '../presentation/screens/address/address_edit_screen.dart';
import '../presentation/screens/address/map_select_screen.dart';
import '../presentation/screens/account/account_security_screen.dart';
import '../presentation/screens/account/change_password_screen.dart';
import '../presentation/screens/account/set_payment_password_screen.dart';
import '../presentation/screens/account/change_phone_screen.dart';
import '../presentation/screens/account/login_devices_screen.dart';
import '../presentation/screens/account/delete_account_screen.dart';
import '../presentation/controllers/login_controller.dart';
import '../presentation/controllers/privacy_policy_controller.dart';
import '../presentation/controllers/user_agreement_controller.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/message_controller.dart';
import '../presentation/controllers/more_recommendations_controller.dart';
import '../presentation/controllers/search_controller.dart';
import '../presentation/controllers/address_controller.dart';
import '../presentation/controllers/account_security_controller.dart';
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
      name: RouteNames.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    GetPage(
      name: RouteNames.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => HomeController()),
            Get.lazyPut(() => MessageController()),
            Get.lazyPut(() => ServiceController()),
            Get.lazyPut(() => ProfileController()),
            Get.lazyPut(() => HomeContentController()),
            Get.lazyPut(() => PostListController()),
            Get.lazyPut(() => OrderListController()),
            Get.put(() => AgoraChatService()),
          ]),
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
    GetPage(
      name: RouteNames.favorites,
      page: () => const FavoriteListScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => FavoriteController())),
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
      binding: BindingsBuilder(() => Get.lazyPut(() => MapSelectController())),
    ),
    GetPage(
      name: RouteNames.profileEdit,
      page: () => const ProfileEditScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ProfileController())),
    ),
    // 订单相关路由
    GetPage(
      name: RouteNames.orderCreate,
      page: () => const OrderCreateScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => OrderController())),
    ),
    // 社区相关路由
    GetPage(
      name: RouteNames.postList,
      page: () => const PostListPage(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => PostListController())),
    ),
    GetPage(
      name: RouteNames.postCreate,
      page: () => const PostCreatePage(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => PostCreateController())),
    ),
    GetPage(
      name: RouteNames.postDetail,
      page: () => const PostDetailPage(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => PostDetailController())),
    ),
    // 入驻相关路由
    GetPage(
      name: RouteNames.providerJoin,
      page: () => ProviderJoinPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ProfileController())),
    ),
    GetPage(
      name: RouteNames.providerQualification,
      page: () => const ProviderQualificationPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ProviderQualificationController())),
    ),
    GetPage(
      name: RouteNames.providerService,
      page: () => const ProviderServicePage(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => ProviderServiceController())),
    ),
    GetPage(
      name: RouteNames.providerServiceList,
      page: () => const ProviderServiceListPage(),
      binding: BindingsBuilder(
          () => Get.lazyPut(() => ProviderServiceListController())),
    ),

    // 账户安全相关路由
    GetPage(
      name: RouteNames.accountSecurity,
      page: () => const AccountSecurityScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => AccountSecurityController())),
    ),
    GetPage(
      name: RouteNames.changePassword,
      page: () => const ChangePasswordScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => AccountSecurityController())),
    ),
    GetPage(
      name: RouteNames.setPaymentPassword,
      page: () => const SetPaymentPasswordScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => AccountSecurityController())),
    ),
    GetPage(
      name: RouteNames.changePhone,
      page: () => const ChangePhoneScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => AccountSecurityController())),
    ),
    GetPage(
      name: RouteNames.loginDevices,
      page: () => const LoginDevicesScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => AccountSecurityController())),
    ),
    GetPage(
      name: RouteNames.deleteAccount,
      page: () => const DeleteAccountScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(() => AccountSecurityController())),
    ),
  ];
}
