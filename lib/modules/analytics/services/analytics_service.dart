import 'package:dio/dio.dart';
import 'package:flutter_energy/modules/analytics/models/energy_stats.dart';
import 'package:flutter_energy/modules/dashboard/services/api_service.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  // Updated base URL from your provided endpoint
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://test.kingsmansoftwares.co.zw/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));


  // Get total consumption for all devices
  Future<List<Map<String, dynamic>>> getTotalConsumption({List<int>? deviceIds, DateTime? startDate, DateTime? endDate}) async {
    try {
      // Format dates for API request
      final now = DateTime.now();
      final start = startDate ?? now.subtract(const Duration(days: 7));
      final end = endDate ?? now;

      final formattedStart = DateFormat('yyyy-MM-ddTHH:mm:ss').format(start);
      final formattedEnd = DateFormat('yyyy-MM-ddTHH:mm:ss').format(end);

      String deviceIdsParam = '';
      if (deviceIds != null && deviceIds.isNotEmpty) {
        deviceIdsParam = deviceIds.join(',');
      }

      final response = await _dio.get(
        '/consumption/total',
        queryParameters: {
          'device_ids': deviceIdsParam,
          'start_date': formattedStart,
          'end_date': formattedEnd,
        },
      );

      if (response.statusCode == 200) {
        // Convert to List if it's not already
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else {
          return [response.data as Map<String, dynamic>];
        }
      } else {
        throw Exception('Failed to load total consumption: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch total consumption');
    } catch (e) {
      throw Exception('Unexpected error while fetching total consumption: $e');
    }
  }

  // Get energy predictions for a device
  Future<List<Map<String, dynamic>>> getEnergyPredictions(int deviceId, {String? date}) async {
    try {
      final formattedDate = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await _dio.get(
        '/predictions/energy',
        queryParameters: {
          'device_id': deviceId,
          'date': formattedDate,
        },
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else {
          return [response.data as Map<String, dynamic>];
        }
      } else {
        throw Exception('Failed to load energy predictions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch energy predictions');
    } catch (e) {
      throw Exception('Unexpected error while fetching predictions: $e');
    }
  }

  // Get peak predictions
  Future<Map<String, dynamic>> getPeakPredictions({String? date}) async {
    try {
      final formattedDate = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await _dio.get(
        '/predictions/peak',
        queryParameters: {
          'date': formattedDate,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load peak predictions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch peak predictions');
    } catch (e) {
      throw Exception('Unexpected error while fetching peak predictions: $e');
    }
  }

  // Get device predictions summary
  Future<Map<String, dynamic>> getDevicePredictionsSummary(int deviceId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Format dates for API request
      final now = DateTime.now();
      final start = startDate ?? now;
      final end = endDate ?? now.add(const Duration(days: 7));

      final formattedStart = DateFormat('yyyy-MM-dd').format(start);
      final formattedEnd = DateFormat('yyyy-MM-dd').format(end);

      final response = await _dio.get(
        '/predictions/device/$deviceId/summary',
        queryParameters: {
          'start_date': formattedStart,
          'end_date': formattedEnd,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load device prediction summary: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch device prediction summary');
    } catch (e) {
      throw Exception('Unexpected error while fetching device prediction summary: $e');
    }
  }

  // Get peak demand summary
  Future<Map<String, dynamic>> getPeakDemandSummary({DateTime? startDate, DateTime? endDate}) async {
    try {
      // Format dates for API request
      final now = DateTime.now();
      final start = startDate ?? now;
      final end = endDate ?? now.add(const Duration(days: 7));

      final formattedStart = DateFormat('yyyy-MM-dd').format(start);
      final formattedEnd = DateFormat('yyyy-MM-dd').format(end);

      final response = await _dio.get(
        '/predictions/peak/summary',
        queryParameters: {
          'start_date': formattedStart,
          'end_date': formattedEnd,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load peak demand summary: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch peak demand summary');
    } catch (e) {
      throw Exception('Unexpected error while fetching peak demand summary: $e');
    }
  }

  // Get dashboard overview
  Future<Map<String, dynamic>> getDashboardOverview() async {
    try {
      final response = await _dio.get('/dashboard/overview');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load dashboard overview: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch dashboard overview');
    } catch (e) {
      throw Exception('Unexpected error while fetching dashboard overview: $e');
    }
  }

  // Convert API data to EnergyStats model
  Future<EnergyStats> getEnergyStats() async {
    try {
      // Get dashboard overview for summary data
      final overview = await getDashboardOverview();

      // Get all devices
      final devices = await ApiService().getRegisteredDevices();

      // Get current date
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Create a list to hold daily usage data
      final List<DailyUsage> dailyData = [];

      // Get total consumption for past week
      double weeklyUsageTotal = 0;

      // For each day in the past week:
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        double dailyUsageValue = 0;

        // If we have the current day's prediction in the overview
        if (i == 0 && overview.containsKey('today_predicted_energy')) {
          dailyUsageValue = (overview['today_predicted_energy'] as num).toDouble();
        } else {
          // Need to fetch this data from predictions or historical data
          // This is simplified - in a real implementation you'd want to get actual historical data
          final formattedDate = DateFormat('yyyy-MM-dd').format(date);

          try {
            // Try to get predictions for each device for this date
            double dayTotal = 0;
            for (final device in devices) {
              try {
                final predictions = await getEnergyPredictions(device.id, date: formattedDate);
                // Sum all hourly predictions for this device on this day
                if (predictions.isNotEmpty) {
                  for (final prediction in predictions) {
                    dayTotal += (prediction['predicted_energy'] as num).toDouble();
                  }
                }
              } catch (e) {
                // Just continue if we can't get predictions for a device
                print('Could not get predictions for device ${device.id} on $formattedDate: $e');
              }
            }

            dailyUsageValue = dayTotal;
          } catch (e) {
            // If we can't get predictions, use a fallback value
            dailyUsageValue = 2000 + (i * 100);
            print('Using fallback value for $formattedDate: $e');
          }
        }

        // Calculate approximate cost (simplified)
        final cost = dailyUsageValue * 0.15; // Assuming $0.15 per kWh

        dailyData.add(DailyUsage(
          date: date,
          usage: dailyUsageValue,
          cost: cost,
        ));

        weeklyUsageTotal += dailyUsageValue;
      }

      // Calculate monthly projection (simplified)
      double monthlyUsage = weeklyUsageTotal * 4.3; // Approximate month as 4.3 weeks
      double monthlyCost = monthlyUsage * 0.15; // Assuming $0.15 per kWh

      // Get daily usage from today's prediction
      double dailyUsage = overview.containsKey('today_predicted_energy')
          ? (overview['today_predicted_energy'] as num).toDouble()
          : dailyData.isNotEmpty ? dailyData[0].usage : 0;

      // Predicted usage for next month
      double predictedUsage = monthlyUsage * 1.1; // Assuming 10% increase

      // Calculate cost saving target (simplified)
      double costSavingTarget = monthlyCost * 0.9; // Aim for 10% cost reduction

      return EnergyStats(
        dailyUsage: dailyUsage,
        weeklyUsage: weeklyUsageTotal,
        monthlyUsage: monthlyUsage,
        monthlyCost: monthlyCost,
        dailyData: dailyData,
        predictedUsage: predictedUsage,
        costSavingTarget: costSavingTarget,
      );
    } catch (e) {
      throw Exception('Failed to compile energy statistics: $e');
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