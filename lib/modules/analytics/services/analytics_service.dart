import 'dart:math';

import 'package:flutter_energy/modules/analytics/models/energy_stats.dart';

class AnalyticsService {
  Future<EnergyStats> getEnergyStats() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock daily data for the past week
    final now = DateTime.now();
    final dailyData = List.generate(7, (index) {
      return DailyUsage(
        date: now.subtract(Duration(days: index)),
        usage: 2000 + (index * 100) + (Random().nextDouble() * 500),
        cost: 20 + (index * 1) + (Random().nextDouble() * 5),
      );
    });

    return EnergyStats(
      dailyUsage: 2500,
      weeklyUsage: 15000,
      monthlyUsage: 60000,
      monthlyCost: 150,
      dailyData: dailyData,
      predictedUsage: 65000,
      costSavingTarget: 130,
    );
  }
}

