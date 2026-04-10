import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 等待一小段时间显示启动页
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    // 检查登录状态
    final isLoggedIn = await AuthService.instance.isLoggedIn;
    
    if (isLoggedIn) {
      // 已登录，跳转到首页
      Navigator.pushReplacementNamed(context, '/');
    } else {
      // 未登录，跳转到登录页
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FlutterLogo(size: 100),
      ),
    );
  }
}
