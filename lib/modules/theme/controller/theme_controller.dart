import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../appliance/models/appliance.dart';
import '../../auth/controllers/auth_controller.dart';


class ThemeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxString currentTheme = 'blue'.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to user profile changes to update theme
    ever(_authController.userProfile, (profile) {
      if (profile != null) {
        currentTheme.value = profile.themeColor;
        _applyTheme(profile.themeColor);
      }
    });
  }

  void changeTheme(String themeColor) {
    currentTheme.value = themeColor;
    _applyTheme(themeColor);

    // Update user preference in database
    _authController.updateTheme(themeColor);
  }

  void _applyTheme(String themeColor) {
    ThemeData theme = AppThemes.getThemeFromColor(themeColor);
    Get.changeTheme(theme);
  }

  List<ThemeOption> get availableThemes => [
    ThemeOption(name: 'Blue', color: 'blue', primaryColor: Colors.blue),
    ThemeOption(name: 'Green', color: 'green', primaryColor: Colors.green),
    ThemeOption(name: 'Purple', color: 'purple', primaryColor: Colors.purple),
    ThemeOption(name: 'Orange', color: 'orange', primaryColor: Colors.orange),
    ThemeOption(name: 'Red', color: 'red', primaryColor: Colors.red),
    ThemeOption(name: 'Teal', color: 'teal', primaryColor: Colors.teal),
  ];
}

class ThemeOption {
  final String name;
  final String color;
  final Color primaryColor;

  ThemeOption({
    required this.name,
    required this.color,
    required this.primaryColor,
  });
}
