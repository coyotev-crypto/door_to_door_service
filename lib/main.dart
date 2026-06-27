import 'package:dtd/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.setChatUIKitTheme();
  runApp(const MyApp());
}