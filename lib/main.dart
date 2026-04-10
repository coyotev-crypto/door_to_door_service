import 'package:flutter/material.dart';
import 'presentation/app.dart';
import 'core/services/auth_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化认证服务
  await AuthService.instance.initialize();

  runApp(const MyApp());
}
