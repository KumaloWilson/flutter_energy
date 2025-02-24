import 'package:get/get.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/dashboard/services/energy_service.dart';

class DashboardController extends GetxController {
  final EnergyService _energyService = EnergyService();
  final RxBool isLoading = false.obs;
  final RxList<ApplianceReading> readings = <ApplianceReading>[].obs;
  final RxDouble totalEnergy = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLastReadings();
  }

  Future<void> fetchLastReadings() async {
    try {
      isLoading.value = true;
      final data = await _energyService.getLastReadings();
      readings.value = data;
      _calculateTotalEnergy();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch readings');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateTotalEnergy() {
    totalEnergy.value = readings.fold(
      0,
      (sum, reading) => sum + double.parse(reading.activeEnergy),
    );
  }
}

