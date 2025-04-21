import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/core/utilities/logs.dart';
import '../services/analytics_service.dart';

class PeakDemandController extends GetxController {
  final AnalyticsService _analyticsService = AnalyticsService();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingHourly = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Date selection
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Peak demand data
  final RxDouble overallPeakDemand = 0.0.obs;
  final Rx<DateTime?> overallPeakDate = Rx<DateTime?>(null);
  final RxInt overallPeakHour = 0.obs;
  final RxInt dailyPeakHour = 0.obs;
  final RxDouble dailyPeakDemand = 0.0.obs;
  final RxList<HourlyDemandData> hourlyDemandData = <HourlyDemandData>[].obs;
  final RxMap<String, dynamic> hourlyPatterns = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPeakDemandSummary();
  }

  Future<void> fetchPeakDemandSummary() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final summary = await _analyticsService.getPeakDemandSummary();

      // Extract overall peak data
      if (summary.containsKey('overall_peak')) {
        final overallPeak = summary['overall_peak'];

        overallPeakDemand.value = (overallPeak['demand'] as num).toDouble();
        overallPeakHour.value = (overallPeak['hour'] as num).toInt();

        if (overallPeak.containsKey('date') && overallPeak['date'] is String) {
          try {
            overallPeakDate.value = DateTime.parse(overallPeak['date']);
          } catch (e) {
            DevLogs.logError('Failed to parse overall peak date: $e');
            overallPeakDate.value = null;
          }
        }
      }

      // Extract hourly patterns
      if (summary.containsKey('hourly_patterns')) {
        hourlyPatterns.value = summary['hourly_patterns'];
      }

      // Fetch data for the selected date
      await fetchPeakDemandForDate();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      DevLogs.logError('Failed to fetch peak demand summary: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPeakDemandForDate() async {
    try {
      isLoadingHourly.value = true;

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final summary = await _analyticsService.getPeakDemandSummary();

      if (summary.containsKey('daily_peaks') &&
          summary['daily_peaks'].containsKey(dateStr)) {

        final dailyPeak = summary['daily_peaks'][dateStr];

        // Extract daily peak data
        if (dailyPeak.containsKey('peak_demand')) {
          dailyPeakDemand.value = (dailyPeak['peak_demand'] as num).toDouble();
        }

        if (dailyPeak.containsKey('peak_hour')) {
          dailyPeakHour.value = (dailyPeak['peak_hour'] as num).toInt();
        }

        // Extract hourly data
        if (dailyPeak.containsKey('hourly')) {
          final hourlyData = dailyPeak['hourly'] as Map<String, dynamic>;
          final hourlyList = <HourlyDemandData>[];

          hourlyData.forEach((hour, demand) {
            final hourInt = int.parse(hour);
            final demandDouble = (demand as num).toDouble();

            hourlyList.add(HourlyDemandData(
              hour: hourInt,
              value: demandDouble,
            ));
          });

          // Sort by hour
          hourlyList.sort((a, b) => a.hour.compareTo(b.hour));
          hourlyDemandData.value = hourlyList;
        }
      } else {
        // No data for this date
        hourlyDemandData.clear();
        dailyPeakDemand.value = 0.0;
        dailyPeakHour.value = 0;
      }
    } catch (e) {
      DevLogs.logError('Failed to fetch peak demand for date: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch peak demand data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingHourly.value = false;
    }
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
    fetchPeakDemandForDate();
  }
}

class HourlyDemandData {
  final int hour;
  final double value;

  HourlyDemandData({
    required this.hour,
    required this.value,
  });
}
