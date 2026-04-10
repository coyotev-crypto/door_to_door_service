import 'package:flutter/material.dart';

class AppTheme {
  // 上门服务行业主题色 - 温暖的橙色，代表服务和热情
  static const servicePrimaryColor = Color(0xFFFF6B35); // 橙红色
  static const serviceSecondaryColor = Color(0xFFF7931E); // 橙色

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: servicePrimaryColor, 
      brightness: Brightness.light,
      primary: servicePrimaryColor,
      secondary: serviceSecondaryColor,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: servicePrimaryColor, 
      brightness: Brightness.dark,
      primary: servicePrimaryColor,
      secondary: serviceSecondaryColor,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
