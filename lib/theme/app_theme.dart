import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Energy Blue
  static const Color primary = Color(0xFF0277BD);         // Deeper blue
  static const Color primaryLight = Color(0xFF58A5F0);    // Lighter blue
  static const Color primaryDark = Color(0xFF004C8C);     // Dark blue

  // Secondary colors - Energy Green
  static const Color secondary = Color(0xFF2E7D32);       // Eco green
  static const Color secondaryLight = Color(0xFF60AD5E);  // Light green
  static const Color secondaryDark = Color(0xFF005005);   // Dark green

  // Accent color - Energy Yellow
  static const Color accent = Color(0xFFFFC107);          // Energy/power yellow

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F7FA); // Soft light background
  static const Color lightSurface = Color(0xFFFFFFFF);    // White surface
  static const Color lightError = Color(0xFFD32F2F);      // Error red
  static const Color lightBorder = Color(0xFFE0E0E0);     // Light border

  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);  // Dark background
  static const Color darkSurface = Color(0xFF1E1E1E);     // Dark surface
  static const Color darkError = Color(0xFFEF5350);       // Lighter error red
  static const Color darkBorder = Color(0xFF333333);      // Dark border

  // Text colors
  static const Color lightTextPrimary = Color(0xFF212121);    // Near black
  static const Color lightTextSecondary = Color(0xFF757575);  // Medium gray
  static const Color darkTextPrimary = Color(0xFFF5F5F5);     // Near white
  static const Color darkTextSecondary = Color(0xFFBDBDBD);   // Light gray

  // Status colors
  static const Color success = Color(0xFF43A047);             // Success green
  static const Color warning = Color(0xFFFFA000);             // Warning amber
  static const Color info = Color(0xFF1E88E5);                // Info blue
  static const Color lowPower = Color(0xFF43A047);            // Low power usage
  static const Color mediumPower = Color(0xFFFBC02D);         // Medium power usage
  static const Color highPower = Color(0xFFE53935);           // High power usage

  // Chart/Graph colors - Energy conscious palette
  static const List<Color> chartColors = [
    Color(0xFF2196F3),  // Blue
    Color(0xFF4CAF50),  // Green
    Color(0xFFFFC107),  // Amber
    Color(0xFFFF5722),  // Deep Orange
    Color(0xFF9C27B0),  // Purple
    Color(0xFF00ACC1),  // Cyan
    Color(0xFF8BC34A),  // Light Green
    Color(0xFFFFB74D),  // Orange
    Color(0xFF5C6BC0),  // Indigo
    Color(0xFF26A69A),  // Teal
  ];

  // Tab-specific colors
  static const Color tabSelectedLight = primary;
  static const Color tabUnselectedLight = Color(0xFF78909C);
  static const Color tabSelectedDark = primaryLight;
  static const Color tabUnselectedDark = Color(0xFF607D8B);
}

class AppTheme {
  // LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.accent,
      onTertiary: Colors.black,
      error: AppColors.lightError,
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: Color(0xFFEEF1F8),
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder.withValues(alpha:0.5),
      shadow: Colors.black.withValues(alpha:0.1),
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      color: AppColors.lightSurface,
      shadowColor: Colors.black.withValues(alpha:0.1),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.tabSelectedLight,
      unselectedLabelColor: AppColors.tabUnselectedLight,
      indicatorColor: AppColors.tabSelectedLight,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha:0.5);
        }
        return Colors.grey.withValues(alpha:0.3);
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha:0.2),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      circularTrackColor: AppColors.primary.withValues(alpha:0.2),
      linearTrackColor: AppColors.primary.withValues(alpha:0.2),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightBackground,
      selectedColor: AppColors.primary.withValues(alpha:0.2),
      labelStyle: TextStyle(color: AppColors.lightTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.lightBorder),
      ),
    ),
  );

  // DARK THEME
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,  // Slightly lighter for dark mode
      onPrimary: Colors.black,
      secondary: AppColors.secondaryLight,
      onSecondary: Colors.black,
      tertiary: AppColors.accent,
      onTertiary: Colors.black,
      error: AppColors.darkError,
      onError: Colors.black,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: Color(0xFF303030),
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder.withValues(alpha:0.5),
      shadow: Colors.black.withValues(alpha:0.3),
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      color: AppColors.darkSurface,
      shadowColor: Colors.black.withValues(alpha:0.3),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.tabSelectedDark,
      unselectedLabelColor: AppColors.tabUnselectedDark,
      indicatorColor: AppColors.tabSelectedDark,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight.withValues(alpha:0.5);
        }
        return Colors.grey.withValues(alpha:0.3);
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryLight,
      thumbColor: AppColors.primaryLight,
      overlayColor: AppColors.primaryLight.withValues(alpha:0.2),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      circularTrackColor: AppColors.primaryLight.withValues(alpha:0.2),
      linearTrackColor: AppColors.primaryLight.withValues(alpha:0.2),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return null;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.primaryLight.withValues(alpha:0.2),
      labelStyle: TextStyle(color: AppColors.darkTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.darkBorder),
      ),
    ),
  );
}