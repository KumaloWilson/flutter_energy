import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/core/utilities/logger.dart';

import '../../home/models/appliance_model.dart';


class ApplianceService {
  static const String baseUrl = 'https://sereneinv.co.zw/minimeter';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://sereneinv.co.zw/minimeter/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<ApplianceReading>> getDeviceReadings(int deviceId) async {
    try {
      final response = await _dio.get('all-records-per-device/$deviceId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ApplianceReading.fromApiJson(json)).toList();
      } else {
        throw Exception('Failed to load readings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch device readings');
    } catch (e) {
      throw Exception('Unexpected error while fetching readings: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTotalConsumption(
      List<int> deviceIds,
      String startDate,
      String endDate
      ) async {
    try {
      final deviceIdsParam = deviceIds.join(',');
      final uri = 'total-consumption-summary/?device_ids=$deviceIdsParam&start_date=$startDate&end_date=$endDate';

      final response = await _dio.get(uri);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load consumption: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch consumption data');
    } catch (e) {
      throw Exception('Unexpected error while fetching consumption: $e');
    }
  }

  Future<void> updateSchedule(int id, Schedule schedule) async {
    // API implementation would go here
    // Since this endpoint isn't provided, we'll simulate it
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> togglePowerSaving(int id, bool enabled) async {
    // API implementation would go here
    // Since this endpoint isn't provided, we'll simulate it
    await Future.delayed(const Duration(seconds: 1));
  }

  // Add this new method to call the API endpoint for adding a device
  // Future<bool> addDevice({
  //   required String name,
  //   required String ratedPower,
  //   String? meterNumber,
  // }) async {
  //   try {
  //     final response = await _dio.post(
  //       'add-device',
  //       data: {
  //         'Device': name,
  //         'Rated_Power': ratedPower,
  //         'MeterNumber': meterNumber ?? 'DEFAULT',
  //         'Relay_Status': 'ON',
  //       },
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return true;
  //     } else {
  //       throw Exception('Failed to add device: ${response.statusCode}');
  //     }
  //   } on DioException catch (e) {
  //     throw _handleError(e, 'Failed to add device');
  //   } catch (e) {
  //     throw Exception('Unexpected error while adding device: $e');
  //   }
  // }

  // Handle Dio errors with more specific messages
  Exception _handleError(DioException e, String fallbackMessage) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Please check your internet connection.');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      default:
        return Exception('$fallbackMessage: ${e.message}');
    }
  }

  // Fetch all devices
  Future<List<ApplianceModel>> fetchDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-devices'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((device) => ApplianceModel.fromJson(device)).toList();
      } else {
        DevLogs.logError('Error fetching devices: ${response.statusCode}');
        throw Exception('Failed to fetch devices: ${response.statusCode}');
      }
    } catch (e) {
      DevLogs.logError('Exception fetching devices: $e');
      throw Exception('Network error: $e');
    }
  }

  // Add new device
  Future<ApplianceModel> addDevice({
    required String name,
    required String type,
    required double wattage,
    required String roomId,
    required String meterNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'type': type,
          'wattage': wattage,
          'room_id': roomId,
          'meter_number': meterNumber,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        return ApplianceModel.fromJson(data);
      } else {
        DevLogs.logError('Error adding device: ${response.statusCode}');
        throw Exception('Failed to add device: ${response.statusCode}');
      }
    } catch (e) {
      DevLogs.logError('Exception adding device: $e');
      throw Exception('Network error: $e');
    }
  }

  // Update device
  Future<ApplianceModel> updateDevice(ApplianceModel device) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-device/${device.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(device.toJson()),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        return ApplianceModel.fromJson(data);
      } else {
        DevLogs.logError('Error updating device: ${response.statusCode}');
        throw Exception('Failed to update device: ${response.statusCode}');
      }
    } catch (e) {
      DevLogs.logError('Exception updating device: $e');
      throw Exception('Network error: $e');
    }
  }

  // Delete device
  Future<bool> deleteDevice(String deviceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-device/$deviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        DevLogs.logError('Error deleting device: ${response.statusCode}');
        throw Exception('Failed to delete device: ${response.statusCode}');
      }
    } catch (e) {
      DevLogs.logError('Exception deleting device: $e');
      throw Exception('Network error: $e');
    }
  }

  // Turn device on
  Future<bool> turnDeviceOn(String meterNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/control/on/$meterNumber/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        DevLogs.logError('Error turning device on: ${response.statusCode}');
        throw Exception('Failed to turn device on: ${response.statusCode}');
      }
    } catch (e) {
      DevLogs.logError('Exception turning device on: $e');
      throw Exception('Network error: $e');
    }
  }

  // Turn device off
  Future<bool> turnDeviceOff(String meterNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/control/off/$meterNumber/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        DevLogs.logError('Error turning device off: ${response.statusCode}');
        throw Exception('Failed to turn device off: ${response.statusCode}');
      }
    } catch (e) {
      DevLogs.logError('Exception turning device off: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get device status
  Future<bool> getDeviceStatus(String meterNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/device-status/$meterNumber'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        return data['status'] == 'on';
      } else {
        DevLogs.logError('Error getting device status: ${response.statusCode}');
        throw Exception('Failed to get device status: ${response.statusCode}');
      }
    } catch (e) {
      DevLogs.logError('Exception getting device status: $e');
      return false; // Default to off if unable to determine
    }
  }
}

class Schedule {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> activeDays;
  final bool enabled;

  const Schedule({
    required this.startTime,
    required this.endTime,
    required this.activeDays,
    required this.enabled,
  });

  Schedule copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<int>? activeDays,
    bool? enabled,
  }) {
    return Schedule(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activeDays: activeDays ?? this.activeDays,
      enabled: enabled ?? this.enabled,
    );
  }
}

class TimelineEntry {
  final DateTime timestamp;
  final String event;
  final String value;

  TimelineEntry({
    required this.timestamp,
    required this.event,
    required this.value,
  });
}

class PowerReading {
  final DateTime timestamp;
  final double power;

  PowerReading({
    required this.timestamp,
    required this.power,
  });
}
