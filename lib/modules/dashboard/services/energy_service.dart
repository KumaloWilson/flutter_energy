import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/dashboard/services/api_service.dart';

class EnergyService {
  final ApiService _apiService = ApiService();

  Future<List<ApplianceReading>> getApplianceReadings() async {
    try {
      // Get all registered devices
      final devices = await _apiService.getRegisteredDevices();

      // Create a list to store all readings
      List<ApplianceReading> allReadings = [];

      // For each device, get its readings
      for (var device in devices) {
        final readings = await _apiService.getDeviceRecords(device.id);
        if (readings.isNotEmpty) {
          allReadings.addAll(readings);
        }
      }

      return allReadings;
    } catch (e) {
      throw Exception('Failed to get appliance readings: $e');
    }
  }

  Future<List<ApplianceReading>> getLastReadings() async {
    try {
      // Get all registered devices
      final devices = await _apiService.getRegisteredDevices();

      // Create a list to store the last reading of each device
      List<ApplianceReading> lastReadings = await _apiService.getLastReadings();


      return lastReadings;
    } catch (e) {
      throw Exception('Failed to get last readings: $e');
    }
  }

  Future<Map<int, double>> getCurrentMonthConsumption() async {
    try {
      // Get all registered devices
      final devices = await _apiService.getRegisteredDevices();

      if (devices.isEmpty) {
        return {};
      }

      // Extract device IDs
      final deviceIds = devices.map((device) => device.id).toList();

      // Get monthly consumption for all devices
      return await _apiService.getCurrentMonthConsumption(deviceIds);
    } catch (e) {
      throw Exception('Failed to get monthly consumption: $e');
    }
  }
}
