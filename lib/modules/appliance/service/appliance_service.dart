import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../dashboard/models/appliance_reading.dart';


class ApplianceService {
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
