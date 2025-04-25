import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/routes/app_pages.dart';
import 'package:flutter_energy/theme/app_theme.dart';

import 'bindings/binding.dart';
import 'core/core/utilities/logs.dart';
import 'modules/theme/controller/theme_controller.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await InitialBinding().dependencies();

    runApp(MyApp());
  } catch (e) {
    DevLogs.logError('Initialization error: $e');
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: 'Smart Energy',
      theme: AppThemes.getThemeFromColor(themeController.currentTheme.value),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.light, // Default to light theme
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      getPages: AppPages.routes,
      initialRoute: AppPages.INITIAL,
      transitionDuration: 300.milliseconds,
    ));
  }
}

