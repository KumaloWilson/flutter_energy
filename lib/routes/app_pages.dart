import 'package:get/get.dart';
import 'package:flutter_energy/modules/auth/views/login_view.dart';
import 'package:flutter_energy/modules/auth/views/signup_view.dart';
import 'package:flutter_energy/modules/appliance/views/appliance_detail_view.dart';
import 'package:flutter_energy/modules/analytics/views/analytics_view.dart';
import '../modules/alerts/view/alerts_view.dart';
import '../modules/analytics/views/comparison_view.dart';
import '../modules/analytics/views/device_detail_view.dart';
import '../modules/analytics/views/peak_demand_view.dart';
import '../modules/auth/views/home_view.dart';
import '../modules/auth/views/profile_view.dart';
import '../modules/family_access/view/family_view.dart';
import '../modules/main/views/main_view.dart';
import '../modules/rooms/view/rooms_details.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/tips/view/tips_view.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

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

    GetPage(
      name: Routes.DEVICE_ANALYTICS,
      page: () {
        final params = Get.parameters;
        final id = int.parse(params['id'] ?? '0');
        final name = params['name'] ?? 'Device';
        return DeviceDetailsView(deviceId: id, deviceName: name);
      },
    ),
    GetPage(
      name: Routes.DEVICE_PEAK,
      page: () => const PeakDemandView(),
    ),
    GetPage(
      name: Routes.COMPARISON,
      page: () => const ComparisonView(),
    ),

    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupView(),
    ),

    GetPage(
      name: Routes.ROOM_DETAIL,
      page: () => RoomDetailView(),
    ),

    GetPage(
      name: Routes.APPLIANCE_DETAIL,
      page: () => ApplianceDetailView(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileView(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => SettingsView(),
    ),
    GetPage(
      name: Routes.FAMILY,
      page: () => FamilyView(),
    ),
    GetPage(
      name: Routes.ANALYTICS,
      page: () => AnalyticsView(),
    ),
  ];
}

