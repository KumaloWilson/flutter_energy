import 'package:get/get.dart';
import 'package:flutter_energy/modules/auth/views/login_view.dart';
import 'package:flutter_energy/modules/auth/views/signup_view.dart';
import 'package:flutter_energy/modules/appliance/views/appliance_detail_view.dart';
import 'package:flutter_energy/modules/analytics/views/analytics_view.dart';
import '../modules/alerts/view/alerts_view.dart';
import '../modules/automation/views/schedule_views.dart';
import '../modules/main/views/main_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/tips/view/tips_view.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignupView(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const MainView(),
      children: [
        GetPage(
          name: Routes.ANALYTICS,
          page: () => const AnalyticsView(),
        ),
        GetPage(
          name: Routes.SCHEDULES,
          page: () => const SchedulesView(),
        ),
        GetPage(
          name: Routes.SETTINGS,
          page: () => const SettingsView(),
        ),
      ],
    ),
    GetPage(
      name: Routes.APPLIANCE_DETAIL,
      page: () => const ApplianceDetailView(),
    ),
    GetPage(
      name: Routes.TIPS,
      page: () => const TipsView(),
    ),
    GetPage(
      name: Routes.ALERTS,
      page: () => const AlertsView(),
    ),
  ];
}

