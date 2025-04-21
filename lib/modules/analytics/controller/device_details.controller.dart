import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/core/utilities/logs.dart';
import '../../dashboard/models/appliance_reading.dart';
import '../../dashboard/services/api_service.dart';
import '../services/analytics_service.dart';

class DeviceDetailsController extends GetxController {
  final int deviceId;
  final ApiService _apiService = ApiService();
  final AnalyticsService _analyticsService = AnalyticsService();

  DeviceDetailsController(this.deviceId);

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingHourly = false.obs;
  final RxBool isLoadingDaily = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Device info
  final Rx<ApplianceInfo?> deviceInfo = Rx<ApplianceInfo?>(null);

  // Energy data
  final RxDouble todayEnergy = 0.0.obs;
  final RxDouble weeklyEnergy = 0.0.obs;
  final RxDouble monthlyEnergy = 0.0.obs;
  final RxDouble totalEnergy = 0.0.obs;

  // Date range
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 7)).obs;

  // Chart data
  final RxList<HourlyData> hourlyData = <HourlyData>[].obs;
  final RxList<DailyData> dailyData = <DailyData>[].obs;
  final RxList<double> hourlyPatterns = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      await Future.wait([
        fetchDeviceInfo(),
        fetchDeviceSummary(),
        fetchTotalConsumption(),
      ]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      DevLogs.logError('Failed to fetch device details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDeviceInfo() async {
    try {
      final devices = await _apiService.getRegisteredDevices();
      final device = devices.firstWhere(
            (d) => d.id == deviceId,
        orElse: () => ApplianceInfo(
          id: deviceId,
          appliance: 'Unknown Device',
          ratedPower: '0 W',
          dateAdded: DateTime.now(),
        ),
      );
      deviceInfo.value = device;
    } catch (e) {
      DevLogs.logError('Failed to fetch device info: $e');
      throw Exception('Failed to fetch device info: $e');
    }
  }

  Future<void> fetchDeviceSummary() async {
    try {
      isLoadingHourly.value = true;
      isLoadingDaily.value = true;

      final summary = await _analyticsService.getDevicePredictionsSummary(deviceId);

      // Extract hourly data
      if (summary.containsKey('daily_predictions')) {
        final dailyPredictions = summary['daily_predictions'] as Map<String, dynamic>;

        // Get today's date in the format used by the API
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

        if (dailyPredictions.containsKey(today) && dailyPredictions[today].containsKey('hourly')) {
          final hourlyPredictions = dailyPredictions[today]['hourly'] as Map<String, dynamic>;

          final hourlyDataList = <HourlyData>[];
          double dailyTotal = 0;

          hourlyPredictions.forEach((hour, energy) {
            final hourInt = int.parse(hour);
            final energyDouble = (energy as num).toDouble();

            hourlyDataList.add(HourlyData(
              hour: hourInt,
              value: energyDouble,
            ));

            dailyTotal += energyDouble;
          });

          // Sort by hour
          hourlyDataList.sort((a, b) => a.hour.compareTo(b.hour));
          hourlyData.value = hourlyDataList;

          // Update today's energy
          todayEnergy.value = dailyTotal;
        }

        // Extract daily data for the week
        final dailyDataList = <DailyData>[];
        double weekTotal = 0;

        // For each day in the date range
        final now = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final date = now.add(Duration(days: i));
          final dateStr = DateFormat('yyyy-MM-dd').format(date);

          if (dailyPredictions.containsKey(dateStr) && dailyPredictions[dateStr].containsKey('total')) {
            final total = (dailyPredictions[dateStr]['total'] as num).toDouble();

            dailyDataList.add(DailyData(
              date: date,
              value: total,
            ));

            if (i < 7) {
              weekTotal += total;
            }
          } else {
            // If no data for this date, use a placeholder value
            dailyDataList.add(DailyData(
              date: date,
              value: i == 0 ? todayEnergy.value : 0,
            ));
          }
        }

        dailyData.value = dailyDataList;
        weeklyEnergy.value = weekTotal;
        monthlyEnergy.value = weekTotal * 4.3; // Approximate month as 4.3 weeks
      }

      // Extract hourly patterns
      if (summary.containsKey('hourly_patterns')) {
        final patterns = summary['hourly_patterns'] as Map<String, dynamic>;
        final patternsList = List<double>.filled(24, 0.0);

        patterns.forEach((hour, pattern) {
          final hourInt = int.parse(hour);
          patternsList[hourInt] = (pattern as num).toDouble();
        });

        hourlyPatterns.value = patternsList;
      }
    } catch (e) {
      DevLogs.logError('Failed to fetch device summary: $e');
      throw Exception('Failed to fetch device summary: $e');
    } finally {
      isLoadingHourly.value = false;
      isLoadingDaily.value = false;
    }
  }

  Future<void> fetchTotalConsumption() async {
    try {
      final consumption = await _analyticsService.getTotalConsumption();
      final deviceConsumption = consumption.firstWhere(
            (item) => item['Appliance_Info_id'] == deviceId,
        orElse: () => {'total_energy': 0.0},
      );

      totalEnergy.value = (deviceConsumption['total_energy'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      DevLogs.logError('Failed to fetch total consumption: $e');
      throw Exception('Failed to fetch total consumption: $e');
    }
  }

  void setStartDate(DateTime date) {
    startDate.value = date;
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
  }
}

class HourlyData {
  final int hour;
  final double value;

  HourlyData({
    required this.hour,
    required this.value,
  });
}

class DailyData {
  final DateTime date;
  final double value;

  DailyData({
    required this.date,
    required this.value,
  });
}
