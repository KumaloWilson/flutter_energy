import 'package:dio/dio.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:intl/intl.dart';

import '../../../core/utilities/logger.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://sereneinv.co.zw/minimeter/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Get all registered devices
  Future<List<ApplianceInfo>> getRegisteredDevices() async {
    try {
      final response = await _dio.get('all-devices-registered');

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

  // Get all records for a specific device
  Future<List<ApplianceReading>> getDeviceRecords(int deviceId) async {
    try {
      final response = await _dio.get('all-records-per-device/$deviceId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ApplianceReading.fromApiJson(json)).toList();
      } else {
        throw Exception('Failed to load records: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch device records');
    } catch (e) {
      throw Exception('Unexpected error while fetching records: $e');
    }
  }

  // Get the last reading for all devices
  Future<List<ApplianceReading>> getLastReadings() async {
    try {
      final response = await _dio.get('all-records/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Group readings by device ID and get the latest for each
        final Map<int, ApplianceReading> latestReadings = {};

        for (final json in data) {
          final reading = ApplianceReading.fromApiJson(json);
          final deviceId = reading.applianceInfo.id;

          if (!latestReadings.containsKey(deviceId) ||
              reading.readingTimeStamp.isAfter(latestReadings[deviceId]!.readingTimeStamp)) {
            latestReadings[deviceId] = reading;
          }
        }

        return latestReadings.values.toList();
      } else {
        throw Exception('Failed to load readings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch last readings');
    } catch (e) {
      throw Exception('Unexpected error while fetching readings: $e');
    }
  }

  // Get the very latest reading (single reading)
  Future<ApplianceReading> getLatestReading() async {
    try {
      final response = await _dio.get('last-reading/');

      if (response.statusCode == 200) {
        return ApplianceReading.fromApiJson(response.data);
      } else {
        throw Exception('Failed to load latest reading: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch latest reading');
    } catch (e) {
      throw Exception('Unexpected error while fetching latest reading: $e');
    }
  }

  // Get consumption summary for devices in a date range
  Future<Map<int, double>> getCurrentMonthConsumption(List<int> deviceIds) async {
    try {
      // Calculate current month date range
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final startDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(startOfMonth);
      final endDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(endOfMonth);

      return getTotalConsumption(deviceIds, startDate, endDate);
    } catch (e) {
      DevLogs.logError('Failed to get current month consumption: $e');
      rethrow;
    }
  }

  // Get total consumption for devices in a date range
  Future<Map<int, double>> getTotalConsumption(
      List<int> deviceIds, String startDate, String endDate) async {
    try {
      final deviceIdsParam = deviceIds.join(',');
      final uri = 'total-consumption-summary/?device_ids=$deviceIdsParam&start_date=$startDate&end_date=$endDate';

      final response = await _dio.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final Map<int, double> result = {};

        for (final item in data) {
          final deviceId = item['Appliance_Info_id'] as int;
          final energy = (item['total_energy'] as num).toDouble();
          result[deviceId] = energy;
        }

        return result;
      } else {
        throw Exception('Failed to load consumption: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch consumption data');
    } catch (e) {
      throw Exception('Unexpected error while fetching consumption: $e');
    }
  }


  // Delete a device
  Future<bool> deleteDevice(String meterNumber) async {
    try {
      final response = await _dio.delete('delete-devices/$meterNumber/');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete device: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete device');
    } catch (e) {
      throw Exception('Unexpected error while deleting device: $e');
    }
  }

  // Update device attributes
  Future<bool> updateDevice({
    required String meterNumber,
    String? deviceName,
    String? ratedPower,
    String? relayStatus,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (deviceName != null) data['Device'] = deviceName;
      if (ratedPower != null) data['Rated_Power'] = ratedPower;
      if (relayStatus != null) data['Relay_Status'] = relayStatus;

      final response = await _dio.patch(
        'update-devices/$meterNumber/',
        data: data,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update device: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update device');
    } catch (e) {
      throw Exception('Unexpected error while updating device: $e');
    }
  }

  // Add a new device
  Future<bool> addDevice({
    required String name,
    required String ratedPower,
    String? meterNumber,
  }) async {
    try {
      final response = await _dio.post(
        'add-device/',
        data: {
          'Device': name,
          'Rated_Power': ratedPower,
          'MeterNumber': meterNumber ?? 'DEFAULT',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to add device');
    } catch (e) {
      throw Exception('Unexpected error while adding device: $e');
    }
  }

  // Turn device ON
  Future<bool> turnDeviceOn(String meterNumber) async {
    try {
      final response = await _dio.post('control/on/$meterNumber/');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to turn device on: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to turn device on');
    } catch (e) {
      throw Exception('Unexpected error while turning device on: $e');
    }
  }

  // Turn device OFF
  Future<bool> turnDeviceOff(String meterNumber) async {
    try {
      final response = await _dio.post('control/off/$meterNumber/');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to turn device off: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to turn device off');
    } catch (e) {
      throw Exception('Unexpected error while turning device off: $e');
    }
  }

  // Get complete appliance data with latest readings
  Future<List<ApplianceReading>> getCompleteApplianceData() async {
    try {
      // Get all devices first
      final devices = await getRegisteredDevices();

      // Then get all readings
      final readings = await getLastReadings();

      // Create a map of device IDs to device info
      final Map<int, ApplianceInfo> deviceMap = {
        for (var device in devices) device.id: device
      };

      // Update readings with complete device info
      final List<ApplianceReading> completeReadings = [];

      for (final reading in readings) {
        final deviceId = reading.applianceInfo.id;

        if (deviceMap.containsKey(deviceId)) {
          // We have device info for this reading
          completeReadings.add(reading.copyWithApplianceInfo(deviceMap[deviceId]!));
        } else {
          // No device info, use what we have
          completeReadings.add(reading);
        }
      }

      // Add devices that don't have readings yet
      for (final device in devices) {
        if (!readings.any((reading) => reading.applianceInfo.id == device.id)) {
          // Create a placeholder reading for this device
          completeReadings.add(ApplianceReading(
            id: device.id,
            applianceInfo: device,
            voltage: '220',
            current: '0',
            timeOn: '0',
            activeEnergy: '0',
            readingTimeStamp: DateTime.now(),
          ));
        }
      }

      return completeReadings;
    } catch (e) {
      DevLogs.logError('Failed to get complete appliance data: $e');
      rethrow;
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
