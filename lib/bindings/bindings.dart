import 'package:get/get.dart';
import '../core/utilities/logger.dart';
import '../modules/alerts/controller/alerts_controller.dart';
import '../modules/analytics/controllers/analytics_controller.dart';
import '../modules/analytics/controllers/comparison_controller.dart';
import '../modules/analytics/controllers/device_details_controller.dart';
import '../modules/analytics/controllers/peak_demand_controller.dart';
import '../modules/analytics/services/analytics_service.dart';
import '../modules/appliance/controller/appliance_controller.dart';
import '../modules/auth/controller/auth_controller.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/dashboard/services/api_service.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/home/service/firestore_service.dart';
import '../modules/main/controller/main_controller.dart';
import '../modules/scheduling/controllers/schedule_controller.dart';
import '../modules/scheduling/services/schedule_service.dart';
import '../modules/settings/controller/settings_controller.dart';
import '../modules/tips/controller/tips_controller.dart';

class InitialBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    try {
      // Register services first
      Get.put(ApiService(), permanent: true);
      Get.put(FirestoreService(), permanent: true);
      Get.put(AnalyticsService(), permanent: true);
      Get.put(ScheduleService(), permanent: true);

      // Core controllers
      Get.put(AuthController(), permanent: true);
      Get.put(MainController(), permanent: true);
      Get.put(SettingsController(), permanent: true);
      Get.put(HomeController(), permanent: true);
      Get.put(ScheduleController(), permanent: true);

      // Feature controllers
      Get.lazyPut(() => DashboardController());
      Get.lazyPut(() => ApplianceController());
      Get.lazyPut(() => AlertsController());
      Get.lazyPut(() => TipsController());

      // Analytics controllers
      Get.lazyPut(() => AnalyticsController());
      Get.lazyPut(() => DeviceDetailsController(1));
      Get.lazyPut(() => PeakDemandController());
      Get.lazyPut(() => ComparisonController());
    } catch (e) {
      DevLogs.logError('Binding initialization error: $e');
      rethrow;
    }
  }
}

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // This is used for page-specific bindings
    // The core dependencies are initialized in InitialBinding
  }
}
