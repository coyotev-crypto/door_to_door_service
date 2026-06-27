import 'package:dtd/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/agora_chat_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/log_util.dart';
import '../../data/repositories/agora_chat_repository.dart';

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
      await _loginAgoraChat();
      Get.toNamed(RouteNames.home);
    } else {
      // 未登录，跳转到登录页
      Get.toNamed(RouteNames.login);
    }
  }

  Future<void> _loginAgoraChat() async {
    try {
      final chatToken = await AgoraChatRepository().getToken();
      final chatService = Get.isRegistered<AgoraChatService>()
          ? AgoraChatService.to
          : Get.put(AgoraChatService(), permanent: true);
      await chatService.initialize(appKey: chatToken.appKey);
      final user = AuthService.instance.user;
      await chatService.login(
        chatToken.chatUserId,
        chatToken.token,
        nickname: user?.nickname,
        avatarUrl: user?.avatar,
      );
    } catch (e) {
      LogUtil.e('Agora Chat登录失败: $e', tag: 'SplashScreen');
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
