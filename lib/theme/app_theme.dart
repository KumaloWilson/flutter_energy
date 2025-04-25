import 'package:flutter/material.dart';
import 'package:flutter_energy/core/theme/app_colors.dart';

class AppTheme {
  // Generate a light theme with custom colors
  static ThemeData getLightTheme(CustomColors customColors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: customColors.primary,
        onPrimary: Colors.white,
        secondary: customColors.secondary,
        onSecondary: Colors.white,
        tertiary: customColors.accent,
        onTertiary: Colors.black,
        error: const Color(0xFFB00020),
        onError: Colors.white,
        background: const Color(0xFFF5F7FA),
        onBackground: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
        surfaceContainerHighest: const Color(0xFFEEF1F8),
        onSurfaceVariant: Colors.black.withOpacity(0.6),
        outline: Colors.grey.shade300,
        outlineVariant: Colors.grey.shade200,
        shadow: Colors.black.withOpacity(0.1),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        backgroundColor: customColors.primary,
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
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: customColors.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: customColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: customColors.primary,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: customColors.primary,
          side: BorderSide(color: customColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: customColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return customColors.primary;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return customColors.primary.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: customColors.primary,
        thumbColor: customColors.primary,
        overlayColor: customColors.primary.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: customColors.primary,
        circularTrackColor: customColors.primary.withOpacity(0.2),
        linearTrackColor: customColors.primary.withOpacity(0.2),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return customColors.primary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F7FA),
        selectedColor: customColors.primary.withOpacity(0.2),
        labelStyle: const TextStyle(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  // Generate a dark theme with custom colors
  static ThemeData getDarkTheme(CustomColors customColors) {
    // Lighten colors for dark theme
    final lightPrimary = AppColors.lighten(customColors.primary, 0.1);
    final lightSecondary = AppColors.lighten(customColors.secondary, 0.1);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: lightPrimary,
        onPrimary: Colors.black,
        secondary: lightSecondary,
        onSecondary: Colors.black,
        tertiary: customColors.accent,
        onTertiary: Colors.black,
        error: const Color(0xFFEF5350),
        onError: Colors.black,
        background: const Color(0xFF121212),
        onBackground: Colors.white,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
        surfaceContainerHighest: const Color(0xFF303030),
        onSurfaceVariant: Colors.white.withOpacity(0.7),
        outline: const Color(0xFF333333),
        outlineVariant: const Color(0xFF444444),
        shadow: Colors.black.withOpacity(0.3),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF1E1E1E),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: lightPrimary,
        unselectedLabelColor: Colors.grey.shade400,
        indicatorColor: lightPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: lightPrimary,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: BorderSide(color: lightPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return lightPrimary;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return lightPrimary.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: lightPrimary,
        thumbColor: lightPrimary,
        overlayColor: lightPrimary.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: lightPrimary,
        circularTrackColor: lightPrimary.withOpacity(0.2),
        linearTrackColor: lightPrimary.withOpacity(0.2),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return lightPrimary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF333333),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: lightPrimary.withOpacity(0.2),
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
      ),
    );
  }

  // Get theme based on system brightness
  static ThemeData getThemeFromBrightness(Brightness brightness, CustomColors customColors) {
    return brightness == Brightness.dark
        ? getDarkTheme(customColors)
        : getLightTheme(customColors);
  }
}
