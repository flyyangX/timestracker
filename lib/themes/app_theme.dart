import 'package:flutter/material.dart';

class AppTheme {
  // 主色调
  static const primaryColor = Color(0xFF5E35B1); // 深紫色
  static const secondaryColor = Color(0xFF7E57C2); // 中紫色
  static const accentColor = Color(0xFF7E57C2); // 强调色

  // 背景渐变色
  static const gradientStart = Color(0xFFEDE7F6); // 浅紫色
  static const gradientEnd = Color(0xFFD1C4E9); // 稍深紫色
  static const backgroundColor = Color(0xFFF5F5F5); // 添加背景色

  // 文本和图标颜色
  static const textPrimaryColor = Color(0xFF212121);
  static const textSecondaryColor = Color(0xFF757575);
  static const iconInactiveColor = Color(0xFFBDBDBD); // 未激活的图标颜色

  // 卡片样式
  static const cardBackgroundColor = Colors.white;
  static const cardElevation = 2.0;
  static const cardBorderRadius = 16.0;

  // 间距
  static const defaultPadding = 16.0;
  static const smallPadding = 8.0;

  // 文本主题
  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      color: textPrimaryColor,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      color: textPrimaryColor,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: textSecondaryColor,
      fontSize: 14,
    ),
  );

  // AppBar主题
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
  );

  // 获取主题数据
  static ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: backgroundColor,
      ),
      textTheme: textTheme,
      appBarTheme: appBarTheme,
    );
  }
}
