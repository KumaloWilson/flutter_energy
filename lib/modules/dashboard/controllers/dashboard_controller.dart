import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/dashboard/services/energy_service.dart';

class DashboardController extends GetxController {
  final EnergyService _energyService = EnergyService();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
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
      hasError.value = false;
      errorMessage.value = '';

      final data = await _energyService.getLastReadings();

      if (data.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'No readings available';
      } else {
        readings.value = data;
        _calculateTotalEnergy();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to fetch readings',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
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

  // Retry fetching data when an error occurs
  void retryFetch() {
    fetchLastReadings();
  }
}