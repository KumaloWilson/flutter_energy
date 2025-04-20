class EnergyPrediction {
  final int deviceId;
  final String deviceName;
  final double predictedEnergy;
  final int predictionHour;
  final DateTime predictionDate;
  final DateTime createdAt;

  EnergyPrediction({
    required this.deviceId,
    required this.deviceName,
    required this.predictedEnergy,
    required this.predictionHour,
    required this.predictionDate,
    required this.createdAt,
  });

  factory EnergyPrediction.fromJson(Map<String, dynamic> json) {
    return EnergyPrediction(
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      predictedEnergy: (json['predicted_energy'] as num).toDouble(),
      predictionHour: json['prediction_hour'],
      predictionDate: DateTime.parse(json['prediction_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Model for peak demand predictions
class PeakDemandPrediction {
  final double predictedPeakDemand;
  final int hour;
  final DateTime predictionDate;
  final DateTime createdAt;

  PeakDemandPrediction({
    required this.predictedPeakDemand,
    required this.hour,
    required this.predictionDate,
    required this.createdAt,
  });

  factory PeakDemandPrediction.fromJson(Map<String, dynamic> json, String date, int hour) {
    return PeakDemandPrediction(
      predictedPeakDemand: (json['predicted_peak_demand'] as num).toDouble(),
      hour: hour,
      predictionDate: DateTime.parse(date),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

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

