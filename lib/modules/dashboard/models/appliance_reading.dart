class ApplianceReading {
  final int id;
  late final ApplianceInfo applianceInfo;
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
      id: json['id'] ?? 0,
      applianceInfo: ApplianceInfo.fromJson(json['Appliance_Info']),
      voltage: json['Voltage'] ?? '0',
      current: json['Current'] ?? '0',
      timeOn: json['TimeOn'] ?? '0',
      activeEnergy: json['ActiveEnergy'] ?? '0',
      readingTimeStamp: DateTime.parse(json['Reading_Time_Stamp']),
    );
  }

  // Constructor specifically for API responses
  factory ApplianceReading.fromApiJson(Map<String, dynamic> json) {
    // For the last-reading endpoint or all-records endpoint
    final applianceInfoId = json['Appliance_Info'] is int
        ? json['Appliance_Info']
        : int.tryParse(json['Appliance_Info'].toString()) ?? 0;

    return ApplianceReading(
      id: applianceInfoId, // Using the Appliance_Info as the ID
      applianceInfo: ApplianceInfo(
        id: applianceInfoId,
        appliance: "Device #$applianceInfoId", // Will be updated later with device info
        ratedPower: "Unknown",
        dateAdded: DateTime.now(),
        meterNumber: "Unknown",
        relayStatus: "Unknown",
      ),
      voltage: json['Voltage'] ?? '0',
      current: json['Current'] ?? '0',
      timeOn: json['TimeOn'] ?? '0',
      activeEnergy: json['ActiveEnergy'] ?? '0',
      readingTimeStamp: DateTime.parse(json['Reading_Time_Stamp']),
    );
  }

  // Create a copy with updated appliance info
  ApplianceReading copyWithApplianceInfo(ApplianceInfo info) {
    return ApplianceReading(
      id: id,
      applianceInfo: info,
      voltage: voltage,
      current: current,
      timeOn: timeOn,
      activeEnergy: activeEnergy,
      readingTimeStamp: readingTimeStamp,
    );
  }
}

class ApplianceInfo {
  final int id;
  final String appliance;
  final String ratedPower;
  final DateTime dateAdded;
  final String meterNumber;
  final String relayStatus;

  ApplianceInfo({
    required this.id,
    required this.appliance,
    required this.ratedPower,
    required this.dateAdded,
    this.meterNumber = '',
    this.relayStatus = 'ON',
  });

  factory ApplianceInfo.fromJson(Map<String, dynamic> json) {
    return ApplianceInfo(
      id: json['id'] ?? 0,
      appliance: json['Device'] ?? json['Appliance'] ?? '',
      ratedPower: json['Rated_Power'] ?? '',
      dateAdded: json['DateAdded'] != null
          ? DateTime.parse(json['DateAdded'])
          : DateTime.now(),
      meterNumber: json['MeterNumber'] ?? '',
      relayStatus: json['Relay_Status'] ?? 'ON',
    );
  }

  // Constructor specifically for API responses from all-devices-registered
  factory ApplianceInfo.fromApiJson(Map<String, dynamic> json) {
    return ApplianceInfo(
      id: json['id'] ?? 0,
      appliance: json['Device'] ?? '',
      ratedPower: json['Rated_Power'] ?? '',
      dateAdded: json['DateAdded'] != null
          ? DateTime.parse(json['DateAdded'])
          : DateTime.now(),
      meterNumber: json['MeterNumber'] ?? '',
      relayStatus: json['Relay_Status'] ?? 'ON',
    );
  }
}
