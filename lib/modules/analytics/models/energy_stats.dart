class EnergyStats {
  final double dailyUsage;
  final double weeklyUsage;
  final double monthlyUsage;
  final double monthlyCost;
  final List<DailyUsage> dailyData;
  final double predictedUsage;
  final double costSavingTarget;

  EnergyStats({
    required this.dailyUsage,
    required this.weeklyUsage,
    required this.monthlyUsage,
    required this.monthlyCost,
    required this.dailyData,
    required this.predictedUsage,
    required this.costSavingTarget,
  });
}

class DailyUsage {
  final DateTime date;
  final double usage;
  final double cost;

  DailyUsage({
    required this.date,
    required this.usage,
    required this.cost,
  });
}

