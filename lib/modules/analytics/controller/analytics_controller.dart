import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter_energy/modules/analytics/models/energy_stats.dart';
import 'package:flutter_energy/modules/analytics/services/analytics_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _analyticsService = AnalyticsService();
  final RxBool isLoading = false.obs;
  final Rx<EnergyStats> stats = EnergyStats(
    dailyUsage: 0,
    weeklyUsage: 0,
    monthlyUsage: 0,
    monthlyCost: 0,
    dailyData: [],
    predictedUsage: 0,
    costSavingTarget: 0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final data = await _analyticsService.getEnergyStats();
      stats.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch statistics');
    } finally {
      isLoading.value = false;
    }
  }

  List<ChartData> getHourlyData() {
    return List.generate(24, (index) {
      return ChartData(
        hour: index,
        usage: 100 + (Random().nextDouble() * 150),
      );
    });
  }

  List<ChartData> getDailyData() {
    return List.generate(7, (index) {
      return ChartData(
        day: DateTime.now().subtract(Duration(days: 6 - index)),
        usage: 500 + (Random().nextDouble() * 1000),
      );
    });
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

