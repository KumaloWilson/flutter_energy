import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/core/utilities/logger.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/dashboard/services/api_service.dart';
import 'package:intl/intl.dart';
import '../../home/service/firestore_service.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // General loading and error states
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ApplianceReading> readings = <ApplianceReading>[].obs;
  final RxDouble totalEnergy = 0.0.obs;
  final RxList<ApplianceInfo> devices = <ApplianceInfo>[].obs;

  // For monthly consumption
  final RxBool isLoadingMonthly = false.obs;
  final RxBool hasMonthlyError = false.obs;
  final RxString monthlyErrorMessage = ''.obs;
  final RxMap<int, double> monthlyConsumption = <int, double>{}.obs;
  final RxDouble totalMonthlyEnergy = 0.0.obs;

  // For device control
  final RxMap<int, bool> deviceControlLoading = <int, bool>{}.obs;

  // For usage chart
  final RxBool isLoadingUsageData = false.obs;
  final RxList<double> usageData = <double>[].obs;
  final RxList<String> usageLabels = <String>[].obs;
  final RxDouble maxUsageValue = 0.0.obs;
  final RxDouble averageUsage = 0.0.obs;
  final RxBool showAverage = true.obs;
  final RxString selectedTimeRange = 'Today'.obs;
  final RxBool usageDataUpdated = false.obs;
  final Rx<DateTime?> lastUsageDataUpdate = Rx<DateTime?>(null);

  // Historical readings for chart
  final RxMap<int, List<ApplianceReading>> deviceHistoricalReadings = <int, List<ApplianceReading>>{}.obs;

  // Track the currently viewed device ID for charts
  final Rx<int?> currentViewedDeviceId = Rx<int?>(null);

  // Timer for auto-refresh
  Timer? _refreshTimer;
  Timer? _usageDataTimer;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();

    // Set up periodic refresh for usage data
    _startUsageDataTimer();

    // Set up periodic refresh for all data
    _startRefreshTimer();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    _usageDataTimer?.cancel();
    super.onClose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
          (_) => refreshDashboard(),
    );
  }

  void _startUsageDataTimer() {
    _usageDataTimer?.cancel();
    _usageDataTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => fetchUsageData(),
    );
  }

  Future<void> refreshDashboard() async {
    await fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Get complete appliance data (devices + readings)
      final completeData = await _apiService.getCompleteApplianceData();
      readings.value = completeData;

      // Extract device info
      devices.value = completeData.map((reading) => reading.applianceInfo).toList();

      // Calculate total energy
      _calculateTotalEnergy();

      // Get monthly consumption
      await fetchMonthlyConsumption();

      // Get usage data for chart
      await fetchUsageData();

      // Update Firestore with latest device data
      await _updateFirestoreDeviceData();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      DevLogs.logError('Failed to fetch data: $e');
      showErrorSnackbar('Failed to fetch data', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsageData({int? deviceId}) async {
    try {
      isLoadingUsageData.value = true;

      // Store the current device ID being viewed
      currentViewedDeviceId.value = deviceId;

      // Get usage data based on selected time range and device ID
      final data = await _fetchUsageDataForTimeRange(
          selectedTimeRange.value,
          deviceId
      );

      // Update the chart data
      usageData.value = data.values;
      usageLabels.value = data.labels;

      // Calculate max and average
      if (usageData.isNotEmpty) {
        maxUsageValue.value = usageData.reduce((a, b) => a > b ? a : b);
        averageUsage.value = usageData.reduce((a, b) => a + b) / usageData.length;
      } else {
        maxUsageValue.value = 0.0;
        averageUsage.value = 0.0;
      }

      // Signal that data has been updated
      usageDataUpdated.value = true;
      lastUsageDataUpdate.value = DateTime.now();
    } catch (e) {
      DevLogs.logError('Failed to fetch usage data: $e');
      // Don't show error snackbar for background updates
      if (isLoadingUsageData.value) {
        showErrorSnackbar('Failed to fetch usage data', e.toString());
      }
    } finally {
      isLoadingUsageData.value = false;
    }
  }



  Future<UsageChartData> _fetchUsageDataForTimeRange(String timeRange, int? deviceId) async {
    final now = DateTime.now();
    late DateTime startDate;
    late List<String> labels;

    switch (timeRange) {
      case 'Today':
      // Hourly data for today
        startDate = DateTime(now.year, now.month, now.day);
        labels = List.generate(24, (i) => '${i.toString().padLeft(2, '0')}:00');
        break;
      case 'Week':
      // Daily data for the last 7 days
        startDate = now.subtract(const Duration(days: 6));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        labels = List.generate(7, (i) {
          final date = startDate.add(Duration(days: i));
          return DateFormat('E').format(date);
        });
        break;
      case 'Month':
      // Daily data for the current month
        startDate = DateTime(now.year, now.month, 1);
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        labels = List.generate(daysInMonth, (i) => (i + 1).toString());
        break;
      case 'Year':
      // Monthly data for the current year
        startDate = DateTime(now.year, 1, 1);
        labels = List.generate(12, (i) => DateFormat('MMM').format(DateTime(now.year, i + 1)));
        break;
      default:
      // Default to today
        startDate = DateTime(now.year, now.month, now.day);
        labels = List.generate(24, (i) => '${i.toString().padLeft(2, '0')}:00');
    }

    // Format dates for API
    final formattedStartDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    // Get device IDs - if deviceId is provided, use only that one
    final deviceIds = deviceId != null
        ? [deviceId]
        : devices.map((device) => device.id).toList();

    try {
      // Fetch historical data for each device if needed
      await _fetchHistoricalDataIfNeeded(deviceIds);

      // Fetch consumption data for the time range
      final consumptionData = await _apiService.getTotalConsumption(
        deviceIds,
        formattedStartDate,
        formattedEndDate,
      );

      // Process the data based on time range
      final values = _processUsageData(timeRange, labels.length, consumptionData, deviceId);

      return UsageChartData(values: values, labels: labels);
    } catch (e) {
      DevLogs.logError('Error fetching usage data: $e');
      // Return empty data on error
      return UsageChartData(
        values: List.filled(labels.length, 0.0),
        labels: labels,
      );
    }
  }

  Future<void> _fetchHistoricalDataIfNeeded(List<int> deviceIds) async {
    // Only fetch historical data if we don't have it yet or if it's been more than 10 minutes
    final shouldFetch = deviceHistoricalReadings.isEmpty ||
        lastUsageDataUpdate.value == null ||
        DateTime.now().difference(lastUsageDataUpdate.value!).inMinutes > 10;

    if (shouldFetch) {
      for (final deviceId in deviceIds) {
        try {
          final records = await _apiService.getDeviceRecords(deviceId);
          deviceHistoricalReadings[deviceId] = records;
        } catch (e) {
          DevLogs.logError('Failed to fetch historical data for device $deviceId: $e');
        }
      }
    }
  }

  List<double> _processUsageData(
      String timeRange,
      int expectedLength,
      Map<int, double> consumptionData,
      int? deviceId
      ) {
    // Initialize with zeros
    final result = List<double>.filled(expectedLength, 0.0);

    // If filtering for a specific device
    if (deviceId != null) {
      // Use only the consumption for this specific device
      final deviceConsumption = consumptionData[deviceId] ?? 0.0;

      if (deviceConsumption > 0) {
        // Create a distribution pattern for this specific device
        _distributeConsumption(result, timeRange, deviceConsumption);
      } else {
        // Try to use historical readings for this device if available
        if (deviceHistoricalReadings.containsKey(deviceId)) {
          _processHistoricalReadingsForDevice(result, timeRange, deviceId);
        }
      }
    }
    // For all devices
    else if (consumptionData.isNotEmpty) {
      // Sum up consumption for all devices
      double totalConsumption = consumptionData.values.fold(0.0, (sum, value) => sum + value);

      if (totalConsumption > 0) {
        // Distribute the consumption based on time range
        _distributeConsumption(result, timeRange, totalConsumption);
      } else if (deviceHistoricalReadings.isNotEmpty) {
        // Use historical readings for all devices
        _processHistoricalReadings(result, timeRange);
      }
    } else if (deviceHistoricalReadings.isNotEmpty) {
      // If we didn't get consumption data, try historical readings
      _processHistoricalReadings(result, timeRange);
    }

    return result;
  }

  // Helper method to distribute consumption values based on time patterns
  void _distributeConsumption(List<double> result, String timeRange, double totalConsumption) {
    switch (timeRange) {
      case 'Today':
      // Hourly pattern for today
        for (int i = 0; i < result.length; i++) {
          // Higher usage during day hours (8am-8pm)
          if (i >= 8 && i <= 20) {
            result[i] = totalConsumption * 0.06 * (1 + 0.5 * _getRandomVariation());
          } else {
            result[i] = totalConsumption * 0.02 * (1 + 0.3 * _getRandomVariation());
          }
        }
        break;
      case 'Week':
      // Daily pattern for week (weekdays higher than weekend)
        for (int i = 0; i < result.length; i++) {
          // Weekdays (0-4) have higher usage than weekend (5-6)
          if (i < 5) {
            result[i] = totalConsumption * 0.17 * (1 + 0.2 * _getRandomVariation());
          } else {
            result[i] = totalConsumption * 0.13 * (1 + 0.2 * _getRandomVariation());
          }
        }
        break;
      case 'Month':
      // Distribute across days of month
        final daysInMonth = result.length;
        for (int i = 0; i < daysInMonth; i++) {
          result[i] = totalConsumption / daysInMonth * (1 + 0.3 * _getRandomVariation());
        }
        break;
      case 'Year':
      // Monthly pattern (higher in summer/winter months)
        for (int i = 0; i < 12; i++) {
          // Higher in summer (5-7) and winter (0-1, 11)
          if (i >= 5 && i <= 7 || i <= 1 || i == 11) {
            result[i] = totalConsumption * 0.1 * (1 + 0.2 * _getRandomVariation());
          } else {
            result[i] = totalConsumption * 0.07 * (1 + 0.2 * _getRandomVariation());
          }
        }
        break;
    }

    // Ensure the sum matches the total consumption (adjust for rounding errors)
    final currentSum = result.fold(0.0, (sum, value) => sum + value);
    if (currentSum > 0) {
      final adjustmentFactor = totalConsumption / currentSum;
      for (int i = 0; i < result.length; i++) {
        result[i] *= adjustmentFactor;
      }
    }
  }

  // Helper method to process historical readings for a specific device
  void _processHistoricalReadingsForDevice(List<double> result, String timeRange, int deviceId) {
    final deviceReadings = deviceHistoricalReadings[deviceId];
    if (deviceReadings == null || deviceReadings.isEmpty) return;

    // Sort by timestamp
    deviceReadings.sort((a, b) => a.readingTimeStamp.compareTo(b.readingTimeStamp));

    final now = DateTime.now();

    switch (timeRange) {
      case 'Today':
        final todayStart = DateTime(now.year, now.month, now.day);

        // Group readings by hour
        final hourlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in deviceReadings) {
          if (reading.readingTimeStamp.isAfter(todayStart)) {
            final hour = reading.readingTimeStamp.hour;
            hourlyReadings.putIfAbsent(hour, () => []).add(reading);
          }
        }

        // Calculate energy for each hour
        for (int hour = 0; hour < 24; hour++) {
          if (hourlyReadings.containsKey(hour)) {
            final readings = hourlyReadings[hour]!;
            double hourlyEnergy = 0;

            for (final reading in readings) {
              hourlyEnergy += double.parse(reading.activeEnergy);
            }

            result[hour] = hourlyEnergy;
          }
        }
        break;

      case 'Week':
        final weekStart = now.subtract(Duration(days: 6));
        final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

        // Group readings by day
        final dailyReadings = <int, List<ApplianceReading>>{};
        for (final reading in deviceReadings) {
          if (reading.readingTimeStamp.isAfter(startOfWeek)) {
            final dayDiff = reading.readingTimeStamp.difference(startOfWeek).inDays;
            if (dayDiff >= 0 && dayDiff < 7) {
              dailyReadings.putIfAbsent(dayDiff, () => []).add(reading);
            }
          }
        }

        // Calculate energy for each day
        for (int day = 0; day < 7; day++) {
          if (dailyReadings.containsKey(day)) {
            final readings = dailyReadings[day]!;
            double dailyEnergy = 0;

            for (final reading in readings) {
              dailyEnergy += double.parse(reading.activeEnergy);
            }

            result[day] = dailyEnergy;
          }
        }
        break;

      case 'Month':
        final monthStart = DateTime(now.year, now.month, 1);
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

        // Group readings by day of month
        final monthlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in deviceReadings) {
          if (reading.readingTimeStamp.isAfter(monthStart)) {
            final day = reading.readingTimeStamp.day - 1; // 0-based index
            if (day >= 0 && day < daysInMonth) {
              monthlyReadings.putIfAbsent(day, () => []).add(reading);
            }
          }
        }

        // Calculate energy for each day
        for (int day = 0; day < daysInMonth; day++) {
          if (monthlyReadings.containsKey(day)) {
            final readings = monthlyReadings[day]!;
            double dailyEnergy = 0;

            for (final reading in readings) {
              dailyEnergy += double.parse(reading.activeEnergy);
            }

            result[day] = dailyEnergy;
          }
        }
        break;

      case 'Year':
        final yearStart = DateTime(now.year, 1, 1);

        // Group readings by month
        final yearlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in deviceReadings) {
          if (reading.readingTimeStamp.isAfter(yearStart)) {
            final month = reading.readingTimeStamp.month - 1; // 0-based index
            yearlyReadings.putIfAbsent(month, () => []).add(reading);
          }
        }

        // Calculate energy for each month
        for (int month = 0; month < 12; month++) {
          if (yearlyReadings.containsKey(month)) {
            final readings = yearlyReadings[month]!;
            double monthlyEnergy = 0;

            for (final reading in readings) {
              monthlyEnergy += double.parse(reading.activeEnergy);
            }

            result[month] = monthlyEnergy;
          }
        }
        break;
    }
  }

  void _processHistoricalReadings(List<double> result, String timeRange) {
    // Combine all device readings
    final allReadings = <ApplianceReading>[];
    for (final readings in deviceHistoricalReadings.values) {
      allReadings.addAll(readings);
    }

    // Sort by timestamp
    allReadings.sort((a, b) => a.readingTimeStamp.compareTo(b.readingTimeStamp));

    if (allReadings.isEmpty) return;

    final now = DateTime.now();

    switch (timeRange) {
      case 'Today':
        final todayStart = DateTime(now.year, now.month, now.day);

        // Group readings by hour
        final hourlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in allReadings) {
          if (reading.readingTimeStamp.isAfter(todayStart)) {
            final hour = reading.readingTimeStamp.hour;
            hourlyReadings.putIfAbsent(hour, () => []).add(reading);
          }
        }

        // Calculate energy for each hour
        for (int hour = 0; hour < 24; hour++) {
          if (hourlyReadings.containsKey(hour)) {
            final readings = hourlyReadings[hour]!;
            double hourlyEnergy = 0;

            for (final reading in readings) {
              hourlyEnergy += double.parse(reading.activeEnergy);
            }

            result[hour] = hourlyEnergy;
          }
        }
        break;

      case 'Week':
        final weekStart = now.subtract(Duration(days: 6));
        final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

        // Group readings by day
        final dailyReadings = <int, List<ApplianceReading>>{};
        for (final reading in allReadings) {
          if (reading.readingTimeStamp.isAfter(startOfWeek)) {
            final dayDiff = reading.readingTimeStamp.difference(startOfWeek).inDays;
            if (dayDiff >= 0 && dayDiff < 7) {
              dailyReadings.putIfAbsent(dayDiff, () => []).add(reading);
            }
          }
        }

        // Calculate energy for each day
        for (int day = 0; day < 7; day++) {
          if (dailyReadings.containsKey(day)) {
            final readings = dailyReadings[day]!;
            double dailyEnergy = 0;

            for (final reading in readings) {
              dailyEnergy += double.parse(reading.activeEnergy);
            }

            result[day] = dailyEnergy;
          }
        }
        break;

      case 'Month':
        final monthStart = DateTime(now.year, now.month, 1);
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

        // Group readings by day of month
        final monthlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in allReadings) {
          if (reading.readingTimeStamp.isAfter(monthStart)) {
            final day = reading.readingTimeStamp.day - 1; // 0-based index
            if (day >= 0 && day < daysInMonth) {
              monthlyReadings.putIfAbsent(day, () => []).add(reading);
            }
          }
        }

        // Calculate energy for each day
        for (int day = 0; day < daysInMonth; day++) {
          if (monthlyReadings.containsKey(day)) {
            final readings = monthlyReadings[day]!;
            double dailyEnergy = 0;

            for (final reading in readings) {
              dailyEnergy += double.parse(reading.activeEnergy);
            }

            result[day] = dailyEnergy;
          }
        }
        break;

      case 'Year':
        final yearStart = DateTime(now.year, 1, 1);

        // Group readings by month
        final yearlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in allReadings) {
          if (reading.readingTimeStamp.isAfter(yearStart)) {
            final month = reading.readingTimeStamp.month - 1; // 0-based index
            yearlyReadings.putIfAbsent(month, () => []).add(reading);
          }
        }

        // Calculate energy for each month
        for (int month = 0; month < 12; month++) {
          if (yearlyReadings.containsKey(month)) {
            final readings = yearlyReadings[month]!;
            double monthlyEnergy = 0;

            for (final reading in readings) {
              monthlyEnergy += double.parse(reading.activeEnergy);
            }

            result[month] = monthlyEnergy;
          }
        }
        break;
    }
  }

  // Helper method to add some randomness to the data distribution
  double _getRandomVariation() {
    // Simple pseudo-random variation between -1 and 1
    return (DateTime.now().microsecondsSinceEpoch % 100) / 50 - 1;
  }

  // Update time range and refetch data with the current device ID
  void updateTimeRange(String newRange, {int? deviceId}) {
    if (selectedTimeRange.value != newRange) {
      selectedTimeRange.value = newRange;
      // Use the passed deviceId or the currently stored one
      fetchUsageData(deviceId: deviceId ?? currentViewedDeviceId.value);
    }
  }


  void _processHistoricalReadingssy(List<double> result, String timeRange) {
    // Combine all device readings
    final allReadings = <ApplianceReading>[];
    for (final readings in deviceHistoricalReadings.values) {
      allReadings.addAll(readings);
    }

    // Sort by timestamp
    allReadings.sort((a, b) => a.readingTimeStamp.compareTo(b.readingTimeStamp));

    if (allReadings.isEmpty) return;

    final now = DateTime.now();

    switch (timeRange) {
      case 'Today':
        final todayStart = DateTime(now.year, now.month, now.day);

        // Group readings by hour
        final hourlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in allReadings) {
          if (reading.readingTimeStamp.isAfter(todayStart)) {
            final hour = reading.readingTimeStamp.hour;
            hourlyReadings.putIfAbsent(hour, () => []).add(reading);
          }
        }

        // Calculate energy for each hour
        for (int hour = 0; hour < 24; hour++) {
          if (hourlyReadings.containsKey(hour)) {
            final readings = hourlyReadings[hour]!;
            double hourlyEnergy = 0;

            for (final reading in readings) {
              hourlyEnergy += double.parse(reading.activeEnergy);
            }

            result[hour] = hourlyEnergy;
          }
        }
        break;

      case 'Week':
        final weekStart = now.subtract(Duration(days: 6));
        final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

        // Group readings by day
        final dailyReadings = <int, List<ApplianceReading>>{};
        for (final reading in allReadings) {
          if (reading.readingTimeStamp.isAfter(startOfWeek)) {
            final dayDiff = reading.readingTimeStamp.difference(startOfWeek).inDays;
            if (dayDiff >= 0 && dayDiff < 7) {
              dailyReadings.putIfAbsent(dayDiff, () => []).add(reading);
            }
          }
        }

        // Calculate energy for each day
        for (int day = 0; day < 7; day++) {
          if (dailyReadings.containsKey(day)) {
            final readings = dailyReadings[day]!;
            double dailyEnergy = 0;

            for (final reading in readings) {
              dailyEnergy += double.parse(reading.activeEnergy);
            }

            result[day] = dailyEnergy;
          }
        }
        break;

      case 'Month':
        final monthStart = DateTime(now.year, now.month, 1);
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

        // Group readings by day of month
        final monthlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in allReadings) {
          if (reading.readingTimeStamp.isAfter(monthStart)) {
            final day = reading.readingTimeStamp.day - 1; // 0-based index
            if (day >= 0 && day < daysInMonth) {
              monthlyReadings.putIfAbsent(day, () => []).add(reading);
            }
          }
        }

        // Calculate energy for each day
        for (int day = 0; day < daysInMonth; day++) {
          if (monthlyReadings.containsKey(day)) {
            final readings = monthlyReadings[day]!;
            double dailyEnergy = 0;

            for (final reading in readings) {
              dailyEnergy += double.parse(reading.activeEnergy);
            }

            result[day] = dailyEnergy;
          }
        }
        break;

      case 'Year':
        final yearStart = DateTime(now.year, 1, 1);

        // Group readings by month
        final yearlyReadings = <int, List<ApplianceReading>>{};
        for (final reading in allReadings) {
          if (reading.readingTimeStamp.isAfter(yearStart)) {
            final month = reading.readingTimeStamp.month - 1; // 0-based index
            yearlyReadings.putIfAbsent(month, () => []).add(reading);
          }
        }

        // Calculate energy for each month
        for (int month = 0; month < 12; month++) {
          if (yearlyReadings.containsKey(month)) {
            final readings = yearlyReadings[month]!;
            double monthlyEnergy = 0;

            for (final reading in readings) {
              monthlyEnergy += double.parse(reading.activeEnergy);
            }

            result[month] = monthlyEnergy;
          }
        }
        break;
    }
  }

  // Helper method to add some randomness to the data distribution
  // double _getRandomVariation() {
  //   // Simple pseudo-random variation between -1 and 1
  //   return (DateTime.now().microsecondsSinceEpoch % 100) / 50 - 1;
  // }
  //
  // void updateTimeRange(String newRange) {
  //   if (selectedTimeRange.value != newRange) {
  //     selectedTimeRange.value = newRange;
  //     fetchUsageData();
  //   }
  // }

  Future<void> _updateFirestoreDeviceData() async {
    try {
      // Get current user's home ID
      final homeId = await _firestoreService.getCurrentHomeId();
      if (homeId == null) return;

      // Get room mappings from Firestore
      final roomMappings = await _firestoreService.getDeviceRoomMappings(homeId);

      // Update device-room mappings in Firestore
      for (final device in devices) {
        final deviceId = device.id.toString();

        // Check if device exists in mappings
        if (!roomMappings.containsKey(deviceId)) {
          // Device not yet mapped to a room, assign to default room
          await _firestoreService.assignDeviceToRoom(
            homeId: homeId,
            deviceId: deviceId,
            roomId: await _firestoreService.getDefaultRoomId(homeId),
            deviceName: device.appliance,
            deviceType: _determineDeviceType(device.appliance),
            meterNumber: device.meterNumber,
          );
        }

        // Update device status in Firestore
        await _firestoreService.updateDeviceStatus(
          homeId: homeId,
          deviceId: deviceId,
          isActive: device.relayStatus == 'ON',
        );
      }
    } catch (e) {
      DevLogs.logError('Error updating Firestore device data: $e');
      // Don't throw, as this is a background operation
    }
  }

  String _determineDeviceType(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('light') || name.contains('lamp')) return 'lighting';
    if (name.contains('tv') || name.contains('television')) return 'entertainment';
    if (name.contains('fridge') || name.contains('refrigerator')) return 'refrigeration';
    if (name.contains('ac') || name.contains('air')) return 'cooling';
    if (name.contains('heater')) return 'heating';
    if (name.contains('oven') || name.contains('stove')) return 'cooking';
    return 'other';
  }

  Future<void> fetchMonthlyConsumption() async {
    try {
      isLoadingMonthly.value = true;
      hasMonthlyError.value = false;
      monthlyErrorMessage.value = '';

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
      DevLogs.logError('Monthly consumption error: $e');
      showErrorSnackbar('Failed to fetch monthly consumption', e.toString());
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
    fetchAllData();
  }

  // Get monthly consumption for a specific device
  double getDeviceMonthlyConsumption(int deviceId) {
    return monthlyConsumption[deviceId] ?? 0.0;
  }

  // Get count of active devices
  int getActiveDevicesCount() {
    return devices.where((device) => device.relayStatus == 'ON').length;
  }

  // Add a new device
  Future<bool> addDevice(String name, String ratedPower, String meterNumber) async {
    try {
      isLoading.value = true;

      final success = await _apiService.addDevice(
        name: name,
        ratedPower: ratedPower,
        meterNumber: meterNumber,
      );

      if (success) {
        // Refresh devices and readings
        await fetchAllData();

        Get.snackbar(
          'Success',
          'Device added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        return true;
      } else {
        errorMessage.value = 'Failed to add device';
        showErrorSnackbar('Error', 'Failed to add device');
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      DevLogs.logError('Failed to add device: $e');
      showErrorSnackbar('Error', 'Failed to add device: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle device on/off
  Future<bool> toggleDevice(ApplianceInfo device) async {
    try {
      // Set loading state for this device
      deviceControlLoading[device.id] = true;

      final isCurrentlyOn = device.relayStatus == 'ON';
      final meterNumber = device.meterNumber;

      if (meterNumber.isEmpty) {
        throw Exception('Device has no meter number');
      }

      bool success;
      if (isCurrentlyOn) {
        // Turn off
        success = await _apiService.turnDeviceOff(meterNumber);
      } else {
        // Turn on
        success = await _apiService.turnDeviceOn(meterNumber);
      }

      if (success) {
        // Update the device status locally
        final index = devices.indexWhere((d) => d.id == device.id);
        if (index >= 0) {
          final updatedDevice = ApplianceInfo(
            id: device.id,
            appliance: device.appliance,
            ratedPower: device.ratedPower,
            dateAdded: device.dateAdded,
            meterNumber: device.meterNumber,
            relayStatus: isCurrentlyOn ? 'OFF' : 'ON',
          );

          devices[index] = updatedDevice;

          // Also update in readings
          final readingIndex = readings.indexWhere((r) => r.applianceInfo.id == device.id);
          if (readingIndex >= 0) {
            readings[readingIndex] = readings[readingIndex].copyWithApplianceInfo(updatedDevice);
          }

          // Update device status in Firestore
          _updateDeviceStatusInFirestore(device.id.toString(), !isCurrentlyOn);

          // Refresh usage data to reflect the change
          fetchUsageData();
        }

        // Show success message
        Get.snackbar(
          'Success',
          'Device ${isCurrentlyOn ? 'turned off' : 'turned on'} successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        return true;
      } else {
        showErrorSnackbar('Error', 'Failed to toggle device');
        return false;
      }
    } catch (e) {
      DevLogs.logError('Failed to toggle device: $e');
      showErrorSnackbar('Error', 'Failed to toggle device: $e');
      return false;
    } finally {
      deviceControlLoading[device.id] = false;
    }
  }

  Future<void> _updateDeviceStatusInFirestore(String deviceId, bool isActive) async {
    try {
      final homeId = await _firestoreService.getCurrentHomeId();
      if (homeId != null) {
        await _firestoreService.updateDeviceStatus(
          homeId: homeId,
          deviceId: deviceId,
          isActive: isActive,
        );
      }
    } catch (e) {
      DevLogs.logError('Error updating device status in Firestore: $e');
      // Don't throw, as this is a background operation
    }
  }

  // Check if a device is currently being controlled
  bool isDeviceControlLoading(int deviceId) {
    return deviceControlLoading[deviceId] ?? false;
  }

  // Show error snackbar
  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}

// Helper class for usage chart data
class UsageChartData {
  final List<double> values;
  final List<String> labels;

  UsageChartData({required this.values, required this.labels});
}
