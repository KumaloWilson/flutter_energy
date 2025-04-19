class ApplianceReading {
  final int id;
  final ApplianceInfo applianceInfo;
  final String voltage;
  final String current;
  final String timeOn;
  final String activeEnergy;
  final DateTime readingTimeStamp;

  ApplianceReading({
    required this.id,
    required this.applianceInfo,
    required this.voltage,
    required this.current,
    required this.timeOn,
    required this.activeEnergy,
    required this.readingTimeStamp,
  });

  factory ApplianceReading.fromJson(Map<String, dynamic> json) {
    return ApplianceReading(
      id: json['id'],
      applianceInfo: ApplianceInfo.fromJson(json['Appliance_Info']),
      voltage: json['Voltage'],
      current: json['Current'],
      timeOn: json['TimeOn'],
      activeEnergy: json['ActiveEnergy'],
      readingTimeStamp: DateTime.now(), // Default for backwards compatibility
    );
  }

  // Constructor specifically for API responses
  factory ApplianceReading.fromApiJson(Map<String, dynamic> json) {
    return ApplianceReading(
      id: json['id'],
      applianceInfo: ApplianceInfo.fromApiJson(json['Appliance_Info']),
      voltage: json['Voltage'],
      current: json['Current'],
      timeOn: json['TimeOn'],
      activeEnergy: json['ActiveEnergy'],
      readingTimeStamp: DateTime.parse(json['Reading_Time_Stamp']),
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

  // Constructor specifically for API responses
  factory ApplianceInfo.fromApiJson(Map<String, dynamic> json) {
    return ApplianceInfo(
      id: json['id'],
      appliance: json['Device'],
      ratedPower: json['Rated_Power'],
      dateAdded: DateTime.parse(json['DateAdded']),
    );
  }
}