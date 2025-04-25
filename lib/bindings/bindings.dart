import 'package:flutter_energy/modules/alerts/controller/alerts_controller.dart';
import 'package:flutter_energy/modules/appliance/controller/appliance_controller.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../core/utilities/logger.dart';
import '../modules/analytics/controllers/analytics_controller.dart';
import '../modules/analytics/controllers/comparison_controller.dart';
import '../modules/analytics/controllers/device_details_controller.dart';
import '../modules/analytics/controllers/peak_demand_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/main/controller/main_controller.dart';
import '../modules/settings/controller/settings_controller.dart';
import '../modules/tips/controller/tips_controller.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    try {
      Get.put(
          DashboardController(),
          permanent: true
      );

      Get.put(
          AlertsController(),
          permanent: true
      );

      Get.put(
          AnalyticsController(),
          permanent: true
      );

      Get.put(
          ComparisonController(),
          permanent: true
      );

      Get.put(
          PeakDemandController(),
          permanent: true
      );

      // Get.put(
      //     ApplianceController(),
      //     permanent: true
      // );

      Get.put(
          AuthController(),
          permanent: true
      );

      Get.put(
          DeviceDetailsController(1),
          permanent: true
      );



      Get.put(
          MainController(),
          permanent: true
      );

      Get.put(
          SettingsController(),
          permanent: true
      );

      Get.put(
          TipsController(),
          permanent: true
      );


    } catch (error) {
      DevLogs.logError('Binding initialization error: $error');
      rethrow;
    }
  }
}
