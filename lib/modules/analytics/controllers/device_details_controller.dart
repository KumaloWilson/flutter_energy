import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../dashboard/models/appliance_reading.dart';
import '../../dashboard/services/api_service.dart';
import '../services/analytics_service.dart';
import '../../../core/utilities/logger.dart';

class DeviceDetailsController extends GetxController {
  final int deviceId;
  final ApiService _apiService = Get.find<ApiService>();
  final AnalyticsService _analyticsService = Get.find<AnalyticsService>();

  DeviceDetailsController(this.deviceId);

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingHourly = false.obs;
  final RxBool isLoadingDaily = false.obs;
  final RxBool isLoadingHistorical = false.obs;
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
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Chart data
  final RxList<HourlyData> hourlyData = <HourlyData>[].obs;
  final RxList<DailyData> dailyData = <DailyData>[].obs;
  final RxList<double> hourlyPatterns = <double>[].obs;

  // Historical readings
  final RxList<ApplianceReading> historicalReadings = <ApplianceReading>[].obs;

  // Real-time data
  final Rx<ApplianceReading?> latestReading = Rx<ApplianceReading?>(null);

  // Power usage trends
  final RxMap<String, double> powerUsageTrends = <String, double>{}.obs;

  // Cost calculation
  final RxDouble energyRate = 0.15.obs; // Default rate in $ per kWh

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
        fetchHistoricalReadings(),
        fetchLatestReading(),
        fetchPowerUsageTrends(),
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

  Future<void> fetchHistoricalReadings() async {
    try {
      isLoadingHistorical.value = true;

      // Fetch historical readings for this device
      final readings = await _apiService.getDeviceRecords(deviceId);

      // Sort by timestamp (newest first)
      readings.sort((a, b) => b.readingTimeStamp.compareTo(a.readingTimeStamp));

      historicalReadings.value = readings;

      // Calculate monthly energy from historical readings
      if (readings.isNotEmpty) {
        final now = DateTime.now();
        final firstDayOfMonth = DateTime(now.year, now.month, 1);

        double monthlyTotal = 0.0;

        for (final reading in readings) {
          if (reading.readingTimeStamp.isAfter(firstDayOfMonth)) {
            monthlyTotal += double.parse(reading.activeEnergy);
          }
        }

        // Update monthly energy if we have more accurate data
        if (monthlyTotal > 0) {
          monthlyEnergy.value = monthlyTotal;
        }
      }
    } catch (e) {
      DevLogs.logError('Failed to fetch historical readings: $e');
      // Don't throw, as this is supplementary data
    } finally {
      isLoadingHistorical.value = false;
    }
  }

  Future<void> fetchLatestReading() async {
    try {
      // Get the latest reading for this device
      final allReadings = await _apiService.getLastReadings();
      final ApplianceReading? deviceReading = allReadings
          .cast<ApplianceReading?>()
          .firstWhere(
            (reading) => reading?.applianceInfo.id == deviceId,
        orElse: () => null,
      );


      if (deviceReading != null) {
        latestReading.value = deviceReading;
      }
    } catch (e) {
      DevLogs.logError('Failed to fetch latest reading: $e');
      // Don't throw, as this is supplementary data
    }
  }

  Future<void> fetchPowerUsageTrends() async {
    try {
      // Calculate power usage trends from historical data
      if (historicalReadings.isNotEmpty) {
        // Group by day of week
        final dayOfWeekUsage = <int, List<double>>{};

        for (final reading in historicalReadings) {
          final dayOfWeek = reading.readingTimeStamp.weekday;
          final energy = double.parse(reading.activeEnergy);

          dayOfWeekUsage.putIfAbsent(dayOfWeek, () => []).add(energy);
        }

        // Calculate average for each day
        final trends = <String, double>{};

        dayOfWeekUsage.forEach((day, energies) {
          final avg = energies.reduce((a, b) => a + b) / energies.length;
          final dayName = _getDayName(day);
          trends[dayName] = avg;
        });

        powerUsageTrends.value = trends;
      }
    } catch (e) {
      DevLogs.logError('Failed to calculate power usage trends: $e');
      // Don't throw, as this is supplementary data
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  void setStartDate(DateTime date) {
    startDate.value = date;
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
  }

  void setEnergyRate(double rate) {
    energyRate.value = rate;
  }

  double calculateCost(double energy) {
    return energy * energyRate.value;
  }

  // Get the power factor from the latest reading
  double getPowerFactor() {
    if (latestReading.value != null) {
      final reading = latestReading.value!;
      final voltage = double.tryParse(reading.voltage) ?? 0.0;
      final current = double.tryParse(reading.current) ?? 0.0;
      final activeEnergy = double.tryParse(reading.activeEnergy) ?? 0.0;
      final timeOn = double.tryParse(reading.timeOn) ?? 0.0;

      if (voltage > 0 && current > 0 && timeOn > 0) {
        final activePower = activeEnergy / timeOn; // in watts
        final apparentPower = voltage * current;
        return activePower / apparentPower;
      }
    }
    return 0.0;
  }


  // Get the power from the latest reading
  double getPower() {
    if (latestReading.value != null) {
      return double.tryParse(latestReading.value!.activeEnergy) ?? 0.0;
    }
    return 0.0;
  }

  // Get the current from the latest reading
  double getCurrent() {
    if (latestReading.value != null) {
      return double.parse(latestReading.value!.current);
    }
    return 0.0;
  }

  // Get the voltage from the latest reading
  double getVoltage() {
    if (latestReading.value != null) {
      return double.parse(latestReading.value!.voltage);
    }
    return 0.0;
  }

  // Calculate efficiency score (0-100)
  double getEfficiencyScore() {
    final deviceRatedPower = deviceInfo.value?.ratedPower ?? '0 W';
    final ratedPower = int.tryParse(deviceRatedPower.replaceAll(RegExp(r'[^\d]'), '')) ?? 100;

    // Simple efficiency calculation based on rated power and usage
    final avgHourlyUsage = hourlyData.isNotEmpty
        ? hourlyData.map((e) => e.value).reduce((a, b) => a + b) / hourlyData.length
        : 0.0;

    final efficiencyScore = 100 - ((avgHourlyUsage * 1000) / ratedPower * 100);
    return efficiencyScore.clamp(0.0, 100.0);
  }

  // Get efficiency level based on score
  String getEfficiencyLevel() {
    final score = getEfficiencyScore();

    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Average';
    if (score >= 20) return 'Poor';
    return 'Very Poor';
  }

  // Get efficiency color based on score
  Color getEfficiencyColor() {
    final score = getEfficiencyScore();

    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.amber;
    if (score >= 20) return Colors.orange;
    return Colors.red;
  }

  // Get peak usage hours
  List<MapEntry<int, double>> getPeakUsageHours() {
    if (hourlyPatterns.isEmpty) return [];

    final entries = <MapEntry<int, double>>[];
    for (int i = 0; i < hourlyPatterns.length; i++) {
      entries.add(MapEntry(i, hourlyPatterns[i]));
    }

    // Sort by value (descending)
    entries.sort((a, b) => b.value.compareTo(a.value));

    // Get top 3 peak hours
    return entries.take(3).toList();
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
