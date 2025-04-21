import 'package:dio/dio.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:intl/intl.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://sereneinv.co.zw/minimeter/',
    connectTimeout: const Duration(seconds: 40),
    receiveTimeout: const Duration(seconds: 40),
  ));

  // Fetch all registered devices
  Future<List<ApplianceInfo>> getRegisteredDevices() async {
    try {
      final response = await _dio.get('all-devices-registered/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ApplianceInfo.fromApiJson(json)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch registered devices');
    } catch (e) {
      throw Exception('Unexpected error while fetching devices: $e');
    }
  }

  // Fetch all readings for a specific device
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

  // Get the last reading for a specific device
  Future<ApplianceReading?> getLastReadingForDevice(int deviceId) async {
    https://sereneinv.co.zw/minimeter/last-reading/
    try {
      final readings = await getDeviceReadings(deviceId);
      if (readings.isEmpty) {
        return null;
      }

      // Sort readings by timestamp (most recent first)
      readings.sort((a, b) =>
          b.readingTimeStamp.compareTo(a.readingTimeStamp)
      );

      return readings.first;
    } catch (e) {
      throw Exception('Failed to get last reading for device $deviceId: $e');
    }
  }

  // Get total energy consumption for this month for the specified devices
  Future<Map<int, double>> getCurrentMonthConsumption(List<int> deviceIds) async {
    try {
      // Get the start and end date for the current month
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

      // Format dates for the API
      final startDate = dateFormat.format(firstDayOfMonth);
      final endDate = dateFormat.format(now);

      // Prepare the device IDs as a comma-separated string
      final deviceIdsString = deviceIds.join(',');

      // Make the API call
      final response = await _dio.get(
        'total-consumption-summary/',
        queryParameters: {
          'device_ids': deviceIdsString,
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Convert the response to a Map with device ID as key and energy consumption as value
        final Map<int, double> result = {};
        for (var item in data) {
          final deviceId = item['Appliance_Info_id'] as int;
          final energy = (item['total_energy'] as num).toDouble();
          result[deviceId] = energy;
        }

        return result;
      } else {
        throw Exception('Failed to load consumption data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch monthly consumption');
    } catch (e) {
      throw Exception('Unexpected error while fetching monthly consumption: $e');
    }
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