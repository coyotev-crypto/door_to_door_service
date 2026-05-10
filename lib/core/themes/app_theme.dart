import 'package:flutter/material.dart';

class AppTheme {
  // Legacy colors (keep for backward compatibility)
  static const servicePrimaryColor = Color(0xFFFF6B35);
  static const serviceSecondaryColor = Color(0xFFF7931E);

  // Warm Spa Palette
  static const gold = Color(0xFFC4956A);
  static const amber = Color(0xFFB8860B);
  static const creamBg = Color(0xFFF7F5F2);
  static const creamFill = Color(0xFFF9F7F4);
  static const warmBorder = Color(0xFFE8E2D8);
  static const textPrimary = Color(0xFF2D2A26);
  static const textSecondary = Color(0xFF6B5E53);
  static const textMuted = Color(0xFFB8A99A);
  static const danger = Color(0xFFD4736A);
  static const sage = Color(0xFF6B8E7B);
  static const leather = Color(0xFF9B7653);
  static const rose = Color(0xFFD4A0A0);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.light,
      primary: gold,
      secondary: amber,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
      primary: gold,
      secondary: amber,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
