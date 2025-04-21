import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/energy_stats.dart';
import '../../dashboard/models/appliance_reading.dart';
import '../../dashboard/services/api_service.dart';
import '../services/analytics_service.dart';
import '../../../core/utilities/logger.dart';

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
  final RxList<Map<String, dynamic>> totalConsumption = <Map<String, dynamic>>[].obs;

  // Selected date and device
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt selectedDeviceId = 0.obs;

  // Prediction data
  final RxList<ChartData> hourlyEnergyData = <ChartData>[].obs;
  final RxList<ChartData> peakDemandData = <ChartData>[].obs;
  final RxList<ChartData> weeklyData = <ChartData>[].obs;

  // Filter options
  final RxString timeRange = 'Day'.obs;
  final RxList<String> availableTimeRanges = ['Day', 'Week', 'Month'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchStats(),
      fetchDevices(),
      fetchDashboardOverview(),
      fetchPeakDemandSummary(),
      fetchTotalConsumption(),
    ]);
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await _analyticsService.getEnergyStats();
      stats.value = data;

      // Update weekly data for chart
      updateWeeklyData();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Logger.error('Failed to fetch statistics: $e');
      showErrorSnackbar('Failed to fetch statistics', e.toString());
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
      Logger.error('Failed to fetch devices: $e');
      showErrorSnackbar('Failed to fetch devices', e.toString());
    } finally {
      isLoadingDevices.value = false;
    }
  }

  Future<void> fetchDashboardOverview() async {
    try {
      final overview = await _analyticsService.getDashboardOverview();
      dashboardOverview.value = overview;

      // Update hourly data for charts if no device is selected yet
      if (selectedDeviceId.value == 0 && overview.containsKey('hourly_predictions')) {
        updateHourlyDataFromOverview(overview);
      }
    } catch (e) {
      Logger.error('Failed to fetch dashboard overview: $e');
      showErrorSnackbar('Failed to fetch dashboard overview', e.toString());
    }
  }

  Future<void> fetchPeakDemandSummary() async {
    try {
      isLoadingPeakDemand.value = true;

      final summary = await _analyticsService.getPeakDemandSummary();
      peakDemandSummary.value = summary;

      // Extract peak demand data for charts
      updatePeakDemandData(summary);
    } catch (e) {
      Logger.error('Failed to fetch peak demand summary: $e');
      showErrorSnackbar('Failed to fetch peak demand summary', e.toString());
    } finally {
      isLoadingPeakDemand.value = false;
    }
  }

  Future<void> fetchTotalConsumption() async {
    try {
      final consumption = await _analyticsService.getTotalConsumption();
      totalConsumption.value = consumption;
    } catch (e) {
      Logger.error('Failed to fetch total consumption: $e');
      showErrorSnackbar('Failed to fetch total consumption', e.toString());
    }
  }

  Future<void> fetchDevicePredictions(int deviceId) async {
    try {
      isLoadingPredictions.value = true;

      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final predictions = await _analyticsService.getEnergyPredictions(deviceId, date: formattedDate);

      updateHourlyDataFromPredictions(predictions);
    } catch (e) {
      Logger.error('Failed to fetch device predictions: $e');
      showErrorSnackbar('Failed to fetch device predictions', e.toString());
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

  void setTimeRange(String range) {
    timeRange.value = range;
    // Update data based on new time range
    if (range == 'Day') {
      // Already showing daily data
    } else if (range == 'Week') {
      updateWeeklyData();
    } else if (range == 'Month') {
      // Would fetch monthly data in a real app
    }
  }

  // Helper methods to update chart data
  void updateHourlyDataFromOverview(Map<String, dynamic> overview) {
    if (overview.containsKey('hourly_predictions')) {
      final hourlyData = <ChartData>[];
      final Map<String, dynamic> hourlyPredictions = overview['hourly_predictions'];

      hourlyPredictions.forEach((hour, devices) {
        final int hourInt = int.parse(hour);
        double totalEnergy = 0;

        devices.forEach((deviceId, energy) {
          totalEnergy += (energy as num).toDouble() * 1000; // Convert to Wh
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
  }

  void updateHourlyDataFromPredictions(List<Map<String, dynamic>> predictions) {
    final devicePredictions = <ChartData>[];

    for (final prediction in predictions) {
      final int hour = prediction['prediction_hour'];
      final double energy = (prediction['predicted_energy'] as num).toDouble() * 1000; // Convert to Wh

      devicePredictions.add(ChartData(
        hour: hour,
        usage: energy,
      ));
    }

    // Sort by hour
    devicePredictions.sort((a, b) => a.hour!.compareTo(b.hour!));
    hourlyEnergyData.value = devicePredictions;
  }

  void updatePeakDemandData(Map<String, dynamic> summary) {
    if (summary.containsKey('daily_peaks')) {
      final peakData = <ChartData>[];
      final Map<String, dynamic> dailyPeaks = summary['daily_peaks'];

      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (dailyPeaks.containsKey(today) && dailyPeaks[today].containsKey('hourly')) {
        final Map<String, dynamic> hourlyPeaks = dailyPeaks[today]['hourly'];

        // Get peak hours (hours with highest demand)
        final List<MapEntry<String, dynamic>> sortedHours = hourlyPeaks.entries.toList()
          ..sort((a, b) => (b.value as num).compareTo(a.value as num));

        // Take top 5 peak hours
        final topPeakHours = sortedHours.take(5).toList();

        for (final entry in topPeakHours) {
          final int hourInt = int.parse(entry.key);
          final double demand = (entry.value as num).toDouble() * 1000; // Convert to W

          peakData.add(ChartData(
            hour: hourInt,
            usage: demand,
          ));
        }

        // Sort by hour for display
        peakData.sort((a, b) => a.hour!.compareTo(b.hour!));
        peakDemandData.value = peakData;
      }
    }
  }

  void updateWeeklyData() {
    final dailyData = stats.value.dailyData;
    if (dailyData.isEmpty) return;

    final weekData = dailyData.map((daily) {
      return ChartData(
        day: daily.date,
        usage: daily.usage,
      );
    }).toList();

    weeklyData.value = weekData;
  }

  // Helper to get device name by ID
  String getDeviceNameById(int id) {
    final device = devices.firstWhere(
          (d) => d.id == id,
      orElse: () => ApplianceInfo(
        id: 0,
        appliance: 'Unknown',
        ratedPower: '0 W',
        dateAdded: DateTime.now(),
      ),
    );
    return device.appliance;
  }

  // Get total energy for a device
  double getDeviceTotalEnergy(int deviceId) {
    final deviceConsumption = totalConsumption.firstWhere(
          (item) => item['Appliance_Info_id'] == deviceId,
      orElse: () => {'total_energy': 0.0},
    );

    return (deviceConsumption['total_energy'] as num?)?.toDouble() ?? 0.0;
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

  // Show error snackbar
  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }
}
