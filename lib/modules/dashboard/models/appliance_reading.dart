class ApplianceReading {
  final int id;
  final ApplianceInfo applianceInfo;
  final String voltage;
  final String current;
  final String timeOn;
  final String activeEnergy;

  ApplianceReading({
    required this.id,
    required this.applianceInfo,
    required this.voltage,
    required this.current,
    required this.timeOn,
    required this.activeEnergy,
  });

  factory ApplianceReading.fromJson(Map<String, dynamic> json) {
    return ApplianceReading(
      id: json['id'],
      applianceInfo: ApplianceInfo.fromJson(json['Appliance_Info']),
      voltage: json['Voltage'],
      current: json['Current'],
      timeOn: json['TimeOn'],
      activeEnergy: json['ActiveEnergy'],
    );
  }
}

class ApplianceInfo {
  final int id;
  final String appliance;
  final String ratedPower;
  final DateTime dateAdded;

  ApplianceInfo({
    required this.id,
    required this.appliance,
    required this.ratedPower,
    required this.dateAdded,
  });

  factory ApplianceInfo.fromJson(Map<String, dynamic> json) {
    return ApplianceInfo(
      id: json['id'],
      appliance: json['Appliance'],
      ratedPower: json['Rated_Power'],
      dateAdded: DateTime.parse(json['DateAdded']),
    );
  }
}

