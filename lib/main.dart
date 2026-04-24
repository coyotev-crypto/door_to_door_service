import 'package:door_to_door_service/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/app.dart';
import 'core/services/auth_service.dart';
import 'core/services/agora_chat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务
  Get.put(AuthService.instance);
  await AuthService.instance.initialize();
  Get.put(AgoraChatService());
  Get.lazyPut(() => LocationService());
  runApp(const MyApp());
}
