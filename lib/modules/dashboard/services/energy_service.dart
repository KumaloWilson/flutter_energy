import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';

class EnergyService {
  Future<List<ApplianceReading>> getApplianceReadings() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      ApplianceReading(
        id: 1,
        applianceInfo: ApplianceInfo(
          id: 1,
          appliance: "Television",
          ratedPower: "100 W",
          dateAdded: DateTime.parse("2025-02-23T19:38:27.999469Z"),
        ),
        voltage: "220",
        current: "8",
        timeOn: "15",
        activeEnergy: "440",
      ),
      ApplianceReading(
        id: 2,
        applianceInfo: ApplianceInfo(
          id: 2,
          appliance: "Refrigerator",
          ratedPower: "200 W",
          dateAdded: DateTime.parse("2025-02-23T19:38:48.041163Z"),
        ),
        voltage: "220",
        current: "12",
        timeOn: "15",
        activeEnergy: "660",
      ),
    ];
  }

  Future<List<ApplianceReading>> getLastReadings() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      ApplianceReading(
        id: 8,
        applianceInfo: ApplianceInfo(
          id: 1,
          appliance: "Television",
          ratedPower: "100 W",
          dateAdded: DateTime.parse("2025-02-23T19:38:27.999469Z"),
        ),
        voltage: "220",
        current: "8",
        timeOn: "60",
        activeEnergy: "1760",
      ),
      ApplianceReading(
        id: 9,
        applianceInfo: ApplianceInfo(
          id: 2,
          appliance: "Refrigerator",
          ratedPower: "200 W",
          dateAdded: DateTime.parse("2025-02-23T19:38:48.041163Z"),
        ),
        voltage: "220",
        current: "12",
        timeOn: "55",
        activeEnergy: "2428",
      ),
    ];
  }
}

