import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/routes/app_pages.dart';
import 'package:flutter_energy/theme/app_theme.dart';

import 'bindings/binding.dart';
import 'core/core/utilities/logs.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await InitialBinding().dependencies();

    runApp(const MyApp());
  } catch (e) {
    DevLogs.logError('Initialization error: $e');
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Energy Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}

