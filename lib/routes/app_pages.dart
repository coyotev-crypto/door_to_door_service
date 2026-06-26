import 'package:door_to_door_service/core/services/agora_chat_service.dart';
import 'package:door_to_door_service/core/services/auth_service.dart';
import 'package:door_to_door_service/core/services/location_service.dart';
import 'package:door_to_door_service/presentation/controllers/home_content_controller.dart';
import 'package:door_to_door_service/presentation/controllers/order_controller.dart';
import 'package:door_to_door_service/presentation/controllers/order_list_controller.dart';
import 'package:door_to_door_service/presentation/controllers/order_detail_controller.dart';
import 'package:door_to_door_service/presentation/controllers/payment_controller.dart';
import 'package:door_to_door_service/presentation/controllers/map_select_controller.dart';
import 'package:door_to_door_service/presentation/controllers/profile_controller.dart';
import 'package:door_to_door_service/presentation/controllers/provider_qualification_controller.dart';
import 'package:door_to_door_service/presentation/controllers/provider_service_controller.dart';
import 'package:door_to_door_service/presentation/controllers/provider_service_list_controller.dart';
import 'package:door_to_door_service/presentation/controllers/service_controller.dart';
import 'package:door_to_door_service/presentation/controllers/favorite_controller.dart';
import 'package:door_to_door_service/presentation/controllers/wallet_controller.dart';
import 'package:door_to_door_service/presentation/controllers/post_list_controller.dart';
import 'package:door_to_door_service/presentation/controllers/post_create_controller.dart';
import 'package:door_to_door_service/presentation/controllers/post_detail_controller.dart';
import 'package:door_to_door_service/presentation/controllers/sms_code_controller.dart';
import 'package:get/get.dart';
import 'route_names.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/community/post_list_page.dart';
import '../presentation/screens/community/post_create_page.dart';
import '../presentation/screens/community/post_detail_page.dart';
import '../presentation/screens/order/order_create_screen.dart';
import '../presentation/screens/order/order_detail_screen.dart';
import '../presentation/screens/order/customer_order_list_page.dart';
import '../presentation/screens/order/provider_order_list_page.dart';
import '../presentation/screens/order/payment_screen.dart';
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
import '../presentation/screens/account/set_password_screen.dart';
import '../presentation/screens/account/change_password_screen.dart';
import '../presentation/screens/account/set_payment_password_screen.dart';
import '../presentation/screens/account/change_phone_screen.dart';
import '../presentation/screens/account/login_devices_screen.dart';
import '../presentation/screens/account/delete_account_screen.dart';
import '../presentation/screens/chat/chat_detail_screen.dart';
import '../presentation/screens/wallet/wallet_screen.dart';
import '../presentation/screens/wallet/wallet_transactions_screen.dart';
import '../presentation/screens/wallet/wallet_withdraw_screen.dart';
import '../presentation/screens/wallet/wallet_withdrawal_detail_screen.dart';
import '../presentation/screens/wallet/payment_account_screen.dart';
import '../presentation/screens/wallet/bind_alipay_screen.dart';
import '../presentation/controllers/login_controller.dart';
import '../presentation/controllers/privacy_policy_controller.dart';
import '../presentation/controllers/user_agreement_controller.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/more_recommendations_controller.dart';
import '../presentation/controllers/search_controller.dart';
import '../presentation/controllers/address_controller.dart';
import '../presentation/controllers/account_security_controller.dart';

class AppPages {
  static const String initial = RouteNames.splash;

  static final routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthService.instance)),
    ),
    GetPage(
      name: RouteNames.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => SmsCodeController()),
            Get.lazyPut(() => LoginController())
          ]),
    ),
    GetPage(
      name: RouteNames.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() => [
            if (!Get.isRegistered<AgoraChatService>())
              Get.lazyPut(() => AgoraChatService()),
            Get.lazyPut(() => LocationService()),
            Get.lazyPut(() => HomeController()),
            Get.lazyPut(() => ServiceController()),
            Get.lazyPut(() => ProfileController()),
            Get.lazyPut(() => HomeContentController()),
            Get.lazyPut(() => PostListController()),
            Get.lazyPut(() => OrderListController()),
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
      name: RouteNames.category,
      page: () => const PostListPage(),
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
      binding: BindingsBuilder(() => Get.lazyPut(() => OrderController())),
    ),
    GetPage(
      name: RouteNames.orderPayment,
      page: () => const PaymentScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PaymentController())),
    ),
    GetPage(
      name: RouteNames.orderDetail,
      page: () => const OrderDetailScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => OrderDetailController())),
    ),
    GetPage(
      name: RouteNames.customerOrderList,
      page: () => const CustomerOrderListPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => OrderListController())),
    ),
    GetPage(
      name: RouteNames.providerOrderList,
      page: () => const ProviderOrderListPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => OrderListController())),
    ),
    // 社区相关路由
    GetPage(
      name: RouteNames.postList,
      page: () => const PostListPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PostListController())),
    ),
    GetPage(
      name: RouteNames.postCreate,
      page: () => const PostCreatePage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PostCreateController())),
    ),
    GetPage(
      name: RouteNames.postDetail,
      page: () => const PostDetailPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PostDetailController())),
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
      binding: BindingsBuilder(
          () => Get.lazyPut(() => ProviderQualificationController())),
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
      name: RouteNames.wallet,
      page: () => const WalletScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => WalletController())),
    ),
    GetPage(
      name: RouteNames.walletWithdraw,
      page: () => const WalletWithdrawScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<WalletController>()) {
          Get.lazyPut(() => WalletController());
        }
      }),
    ),
    GetPage(
      name: RouteNames.walletTransactions,
      page: () => const WalletTransactionsScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<WalletController>()) {
          Get.lazyPut(() => WalletController());
        }
      }),
    ),
     GetPage(
       name: RouteNames.walletWithdrawalDetail,
       page: () => WalletWithdrawalDetailScreen(
         id: int.tryParse(Get.parameters['id'] ?? '') ?? 0,
       ),
       binding: BindingsBuilder(() {
         if (!Get.isRegistered<WalletController>()) {
           Get.lazyPut(() => WalletController());
         }
       }),
     ),
     GetPage(
       name: RouteNames.paymentAccount,
       page: () => const PaymentAccountScreen(),
     ),
     GetPage(
       name: RouteNames.bindAlipay,
       page: () => const BindAlipayScreen(),
     ),
    GetPage(
      name: RouteNames.accountSecurity,
      page: () => const AccountSecurityScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => SmsCodeController()),
            Get.lazyPut(() => AccountSecurityController())
          ]),
    ),
    GetPage(
      name: RouteNames.setPassword,
      page: () => const SetPasswordScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => SmsCodeController()),
            Get.lazyPut(() => AccountSecurityController())
          ]),
    ),
    GetPage(
      name: RouteNames.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => SmsCodeController()),
            Get.lazyPut(() => AccountSecurityController())
          ]),
    ),
    GetPage(
      name: RouteNames.setPaymentPassword,
      page: () => const SetPaymentPasswordScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => SmsCodeController()),
            Get.lazyPut(() => AccountSecurityController())
          ]),
    ),
    GetPage(
      name: RouteNames.changePhone,
      page: () => const ChangePhoneScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => SmsCodeController()),
            Get.lazyPut(() => AccountSecurityController())
          ]),
    ),
    GetPage(
      name: RouteNames.loginDevices,
      page: () => const LoginDevicesScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => SmsCodeController()),
            Get.lazyPut(() => AccountSecurityController())
          ]),
    ),
    GetPage(
      name: RouteNames.deleteAccount,
      page: () => const DeleteAccountScreen(),
      binding: BindingsBuilder(() => [
            Get.lazyPut(() => SmsCodeController()),
            Get.lazyPut(() => AccountSecurityController())
          ]),
    ),
    // 聊天相关路由
    GetPage(
      name: RouteNames.chatDetail,
      page: () => ChatDetailScreen(
        userId: Get.parameters['userId'] ?? '',
      ),
    ),
  ];
}
