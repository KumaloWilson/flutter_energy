import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_energy/modules/analytics/models/energy_stats.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import '../../dashboard/services/api_service.dart';
import '../services/analytics_service.dart';

class AnalyticsController extends GetxController {
  final ApiService _apiService = ApiService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDevices = false.obs;
  final RxBool isLoadingPredictions = false.obs;
  final RxBool isLoadingPeakDemand = false.obs;

  // Error states
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Data states
  final Rx<EnergyStats> stats = EnergyStats(
    dailyUsage: 0,
    weeklyUsage: 0,
    monthlyUsage: 0,
    monthlyCost: 0,
    dailyData: [],
    predictedUsage: 0,
    costSavingTarget: 0,
  ).obs;

  final RxList<ApplianceInfo> devices = <ApplianceInfo>[].obs;
  final RxMap<String, dynamic> dashboardOverview = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> peakDemandSummary = <String, dynamic>{}.obs;

  // Selected date and device
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt selectedDeviceId = 0.obs;

  // Prediction data
  final RxList<ChartData> hourlyEnergyData = <ChartData>[].obs;
  final RxList<ChartData> dailyEnergyData = <ChartData>[].obs;
  final RxList<ChartData> peakDemandData = <ChartData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    fetchStats();
    fetchDevices();
    fetchDashboardOverview();
    fetchPeakDemandSummary();
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await _analyticsService.getEnergyStats();
      stats.value = data;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to fetch statistics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDevices() async {
    try {
      isLoadingDevices.value = true;
      hasError.value = false;

      final deviceList = await _apiService.getRegisteredDevices();
      devices.value = deviceList;

      // Set first device as selected if we don't have one yet
      if (selectedDeviceId.value == 0 && deviceList.isNotEmpty) {
        selectedDeviceId.value = deviceList[0].id;
        fetchDevicePredictions(deviceList[0].id);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to fetch devices: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingDevices.value = false;
    }
  }

  Future<void> fetchDashboardOverview() async {
    try {
      final overview = await _analyticsService.getDashboardOverview();
      dashboardOverview.value = overview;

      // Update hourly data for charts
      if (overview.containsKey('hourly_predictions')) {
        final hourlyData = <ChartData>[];
        final Map<String, dynamic> hourlyPredictions = overview['hourly_predictions'];

        hourlyPredictions.forEach((hour, devices) {
          final int hourInt = int.parse(hour);
          double totalEnergy = 0;

          devices.forEach((deviceId, energy) {
            totalEnergy += (energy as num).toDouble();
          });

          hourlyData.add(ChartData(
            hour: hourInt,
            usage: totalEnergy,
          ));
        });

        // Sort by hour
        hourlyData.sort((a, b) => a.hour!.compareTo(b.hour!));
        hourlyEnergyData.value = hourlyData;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch dashboard overview: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> fetchPeakDemandSummary() async {
    try {
      isLoadingPeakDemand.value = true;

      final summary = await _analyticsService.getPeakDemandSummary();
      peakDemandSummary.value = summary;

      // Extract peak demand data for charts
      if (summary.containsKey('daily_peaks')) {
        final peakData = <ChartData>[];
        final Map<String, dynamic> dailyPeaks = summary['daily_peaks'];

        final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

        if (dailyPeaks.containsKey(today) && dailyPeaks[today].containsKey('hourly')) {
          final Map<String, dynamic> hourlyPeaks = dailyPeaks[today]['hourly'];

          hourlyPeaks.forEach((hour, demand) {
            final int hourInt = int.parse(hour);
            peakData.add(ChartData(
              hour: hourInt,
              usage: (demand as num).toDouble(),
            ));
          });

          // Sort by hour
          peakData.sort((a, b) => a.hour!.compareTo(b.hour!));
          peakDemandData.value = peakData;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch peak demand summary: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingPeakDemand.value = false;
    }
  }

  Future<void> fetchDevicePredictions(int deviceId) async {
    try {
      isLoadingPredictions.value = true;

      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final predictions = await _analyticsService.getEnergyPredictions(deviceId, date: formattedDate);

      final devicePredictions = <ChartData>[];

      for (final prediction in predictions) {
        final int hour = prediction['prediction_hour'];
        final double energy = (prediction['predicted_energy'] as num).toDouble();

        devicePredictions.add(ChartData(
          hour: hour,
          usage: energy,
        ));
      }

      // Sort by hour
      devicePredictions.sort((a, b) => a.hour!.compareTo(b.hour!));
      hourlyEnergyData.value = devicePredictions;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch device predictions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingPredictions.value = false;
    }
  }

  void setSelectedDevice(int deviceId) {
    selectedDeviceId.value = deviceId;
    fetchDevicePredictions(deviceId);
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
    if (selectedDeviceId.value > 0) {
      fetchDevicePredictions(selectedDeviceId.value);
    }
  }

  List<ChartData> getDailyData() {
    // Return actual data from the stats object
    return stats.value.dailyData.map((daily) {
      return ChartData(
        day: daily.date,
        usage: daily.usage,
      );
    }).toList();
  }

  // Helper to get device name by ID
  String getDeviceNameById(int id) {
    final device = devices.firstWhere(
          (d) => d.id == id,
      orElse: () => ApplianceInfo(
        id: 0,
        ratedPower: '0 W',
        dateAdded: DateTime.now(), appliance: '',
      ),
    );
    return device.appliance;
  }

  // Format wattage from '100 W' to just the number
  int parseWattage(String ratedPower) {
    try {
      final numericPart = ratedPower.replaceAll(RegExp(r'[^\d]'), '');
      return int.parse(numericPart);
    } catch (e) {
      return 0;
    }
  }
}

class ChartData {
  final int? hour;
  final DateTime? day;
  final double usage;

  ChartData({
    this.hour,
    this.day,
    required this.usage,
  });
}