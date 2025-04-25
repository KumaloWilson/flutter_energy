import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/dashboard/services/energy_service.dart';
import 'package:flutter_energy/modules/dashboard/services/api_service.dart';

import '../../../core/utilities/logger.dart';

class DashboardController extends GetxController {
  final EnergyService _energyService = EnergyService();
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ApplianceReading> readings = <ApplianceReading>[].obs;
  final RxDouble totalEnergy = 0.0.obs;

  // For monthly consumption
  final RxBool isLoadingMonthly = false.obs;
  final RxBool hasMonthlyError = false.obs;
  final RxString monthlyErrorMessage = ''.obs;
  final RxMap<int, double> monthlyConsumption = <int, double>{}.obs;
  final RxDouble totalMonthlyEnergy = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLastReadings();
    fetchMonthlyConsumption();
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
      DevLogs.logError(e.toString());
      Get.snackbar(
        'Error',
        'Failed to fetch readings',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMonthlyConsumption() async {
    try {
      isLoadingMonthly.value = true;
      hasMonthlyError.value = false;
      monthlyErrorMessage.value = '';

      // Get all registered devices to get their IDs
      final devices = await _apiService.getRegisteredDevices();

      if (devices.isEmpty) {
        hasMonthlyError.value = true;
        monthlyErrorMessage.value = 'No devices available';
        return;
      }

      // Extract device IDs
      final deviceIds = devices.map((device) => device.id).toList();

      // Fetch monthly consumption for all devices
      final consumption = await _apiService.getCurrentMonthConsumption(deviceIds);

      if (consumption.isEmpty) {
        hasMonthlyError.value = true;
        monthlyErrorMessage.value = 'No monthly consumption data available';
      } else {
        monthlyConsumption.value = consumption;
        _calculateTotalMonthlyEnergy();
      }
    } catch (e) {
      hasMonthlyError.value = true;
      monthlyErrorMessage.value = e.toString();
      DevLogs.logError('Monthly consumption error: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to fetch monthly consumption',
        backgroundColor: Colors.red.withValues(alpha:0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMonthly.value = false;
    }
  }

  void _calculateTotalEnergy() {
    totalEnergy.value = readings.fold(
      0,
          (sum, reading) => sum + double.parse(reading.activeEnergy),
    );
  }

  void _calculateTotalMonthlyEnergy() {
    totalMonthlyEnergy.value = monthlyConsumption.values.fold(
      0.0,
          (sum, energy) => sum + energy,
    );
  }

  // Retry fetching data when an error occurs
  void retryFetch() {
    fetchLastReadings();
    fetchMonthlyConsumption();
  }

  // Get monthly consumption for a specific device
  double getDeviceMonthlyConsumption(int deviceId) {
    return monthlyConsumption[deviceId] ?? 0.0;
  }
}
