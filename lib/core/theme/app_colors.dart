import 'package:flutter/material.dart';

class CustomColors {
  final Color primary;
  final Color secondary;
  final Color accent;

  CustomColors({
    this.primary = const Color(0xFF1565C0),
    this.secondary = const Color(0xFF26A69A),
    this.accent = const Color(0xFFFFA000),
  });
}

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);
  
  // Secondary colors
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFF64D8CB);
  static const Color secondaryDark = Color(0xFF00766C);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  
  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  
  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3),
    Color(0xFFF44336),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF009688),
    Color(0xFFE91E63),
    Color(0xFFFFEB3B),
    Color(0xFF3F51B5),
    Color(0xFF8BC34A),
  ];
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Add tab-specific colors to the AppColors class
  static const Color tabBackground = Color(0xFFFFFFFF);
  static const Color tabSelected = Color(0xFF1565C0);
  static const Color tabUnselected = Color(0xFF757575);
  
  // Generate light variants of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  // Generate dark variants of a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
