import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/routes/app_pages.dart';
import 'package:flutter_energy/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_energy/firebase_options.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/modules/settings/controller/settings_controller.dart';
import 'bindings/bindings.dart';
import 'core/utilities/logger.dart';
import 'package:flutter_energy/modules/scheduling/services/schedule_service.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize app dependencies
    await InitialBinding().dependencies();

    // Initialize ScheduleService for background tasks
    await Get.putAsync(() async {
      final scheduleService = ScheduleService();
      await scheduleService.initBackgroundTasks();
      return scheduleService;
    });


    runApp(const MyApp());
  } catch (e) {
    DevLogs.logError('Initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      // Get the selected theme from settings
      final selectedTheme = settingsController.selectedTheme.value;
      final customColors = settingsController.customColors.value;

      // Create theme based on user preferences
      final ThemeData theme = selectedTheme == 'system'
          ? AppTheme.getThemeFromBrightness(
          WidgetsBinding.instance.platformDispatcher.platformBrightness,
          customColors)
          : selectedTheme == 'dark'
          ? AppTheme.getDarkTheme(customColors)
          : AppTheme.getLightTheme(customColors);

      return GetMaterialApp(
        title: 'Energy Management',
        theme: theme,
        darkTheme: AppTheme.getDarkTheme(customColors),
        themeMode: selectedTheme == 'system'
            ? ThemeMode.system
            : selectedTheme == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: authController.isLoggedIn.value ? Routes.HOME : Routes.LOGIN,
        getPages: AppPages.routes,
        defaultTransition: Transition.fade,
      );
    });
  }
}
