import 'package:dtd/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/openim_chat_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/log_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    await AuthService.instance.initialize();
    // 检查登录状态
    final isLoggedIn = AuthService.instance.isLoggedIn;

    if (isLoggedIn) {
      // 已登录，跳转到首页
      await _loginOpenIMChat();
      Get.toNamed(RouteNames.home);
    } else {
      // 未登录，跳转到登录页
      Get.toNamed(RouteNames.login);
    }
  }

  Future<void> _loginOpenIMChat() async {
    try {
      final chatService = Get.isRegistered<OpenIMChatService>()
          ? OpenIMChatService.to
          : Get.put(OpenIMChatService(), permanent: true);
      await chatService.loginWithBackendToken();
    } catch (e) {
      LogUtil.e('OpenIM Chat登录失败: $e', tag: 'SplashScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
