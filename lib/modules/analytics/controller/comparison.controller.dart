import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/core/utilities/logs.dart';
import '../../dashboard/models/appliance_reading.dart';
import '../../dashboard/services/api_service.dart';
import '../services/analytics_service.dart';

class ComparisonController extends GetxController {
  final ApiService _apiService = ApiService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDeviceComparison = false.obs;
  final RxBool isLoadingPeriodComparison = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Devices
  final RxList<ApplianceInfo> devices = <ApplianceInfo>[].obs;
  final RxList<int> selectedDeviceIds = <int>[].obs;

  // Time periods
  final Rx<DateTime> period1Start = DateTime.now().subtract(const Duration(days: 7)).obs;
  final Rx<DateTime> period1End = DateTime.now().obs;
  final Rx<DateTime> period2Start = DateTime.now().subtract(const Duration(days: 14)).obs;
  final Rx<DateTime> period2End = DateTime.now().subtract(const Duration(days: 8)).obs;

  // Comparison data
  final RxList<ComparisonData> deviceComparisonData = <ComparisonData>[].obs;
  final RxList<ComparisonData> periodComparisonData = <ComparisonData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await fetchDevices();

      // If we have devices, select the first two by default
      if (devices.length >= 2 && selectedDeviceIds.isEmpty) {
        selectedDeviceIds.add(devices[0].id);
        selectedDeviceIds.add(devices[1].id);
      } else if (devices.isNotEmpty && selectedDeviceIds.isEmpty) {
        selectedDeviceIds.add(devices[0].id);
      }

      // Generate comparison data
      await generateComparisonData();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      DevLogs.logError('Failed to fetch comparison data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDevices() async {
    try {
      final deviceList = await _apiService.getRegisteredDevices();
      devices.value = deviceList;
    } catch (e) {
      DevLogs.logError('Failed to fetch devices: $e');
      throw Exception('Failed to fetch devices: $e');
    }
  }

  Future<void> generateComparisonData() async {
    await Future.wait([
      generateDeviceComparisonData(),
      generatePeriodComparisonData(),
    ]);
  }

  Future<void> generateDeviceComparisonData() async {
    try {
      isLoadingDeviceComparison.value = true;

      // Get total consumption for all devices
      final consumption = await _analyticsService.getTotalConsumption();

      final comparisonData = <ComparisonData>[];

      // For each selected device
      for (final deviceId in selectedDeviceIds) {
        final device = devices.firstWhere(
              (d) => d.id == deviceId,
          orElse: () => ApplianceInfo(
            id: deviceId,
            appliance: 'Unknown Device',
            ratedPower: '0 W',
            dateAdded: DateTime.now(),
          ),
        );

        // Find consumption data for this device
        final deviceConsumption = consumption.firstWhere(
              (item) => item['Appliance_Info_id'] == deviceId,
          orElse: () => {'total_energy': 0.0},
        );

        // Get energy value
        final energy = (deviceConsumption['total_energy'] as num?)?.toDouble() ?? 0.0;

        comparisonData.add(ComparisonData(
          name: device.appliance,
          value: energy,
        ));
      }

      deviceComparisonData.value = comparisonData;
    } catch (e) {
      DevLogs.logError('Failed to generate device comparison data: $e');
      throw Exception('Failed to generate device comparison data: $e');
    } finally {
      isLoadingDeviceComparison.value = false;
    }
  }

  Future<void> generatePeriodComparisonData() async {
    try {
      isLoadingPeriodComparison.value = true;

      // In a real app, you would fetch historical data for each period
      // Here we'll simulate it with some calculations based on the dashboard overview

      final overview = await _analyticsService.getDashboardOverview();
      final todayEnergy = overview.containsKey('today_predicted_energy')
          ? (overview['today_predicted_energy'] as num).toDouble()
          : 10.0; // Default value

      // Simulate period 1 energy (current week)
      final period1Days = period1End.value.difference(period1Start.value).inDays + 1;
      final period1Energy = todayEnergy * period1Days * 0.9; // Slight variation

      // Simulate period 2 energy (previous week)
      final period2Days = period2End.value.difference(period2Start.value).inDays + 1;
      final period2Energy = todayEnergy * period2Days * 1.1; // Slight variation

      periodComparisonData.value = [
        ComparisonData(
          name: '${DateFormat('MMM d').format(period1Start.value)} - ${DateFormat('MMM d').format(period1End.value)}',
          value: period1Energy,
        ),
        ComparisonData(
          name: '${DateFormat('MMM d').format(period2Start.value)} - ${DateFormat('MMM d').format(period2End.value)}',
          value: period2Energy,
        ),
      ];
    } catch (e) {
      DevLogs.logError('Failed to generate period comparison data: $e');
      throw Exception('Failed to generate period comparison data: $e');
    } finally {
      isLoadingPeriodComparison.value = false;
    }
  }

  void toggleDeviceSelection(int deviceId) {
    if (selectedDeviceIds.contains(deviceId)) {
      selectedDeviceIds.remove(deviceId);
    } else {
      selectedDeviceIds.add(deviceId);
    }
  }

  void setPeriod1(DateTime start, DateTime end) {
    period1Start.value = start;
    period1End.value = end;
  }

  void setPeriod2(DateTime start, DateTime end) {
    period2Start.value = start;
    period2End.value = end;
  }

  Future<void> applyComparison() async {
    await generateComparisonData();
  }
}

class ComparisonData {
  final String name;
  final double value;

  ComparisonData({
    required this.name,
    required this.value,
  });
}

class EfficiencyData {
  final String deviceName;
  final double score;
  final double actualEnergy;
  final double expectedEnergy;

  EfficiencyData({
    required this.deviceName,
    required this.score,
    required this.actualEnergy,
    required this.expectedEnergy,
  });
}
