import 'package:dio/dio.dart';
import 'package:flutter_energy/modules/analytics/models/energy_stats.dart';
import 'package:intl/intl.dart';

import '../../../core/utilities/logger.dart';

class AnalyticsService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.43.229:5000/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Get energy predictions for a device
  Future<List<Map<String, dynamic>>> getEnergyPredictions(int deviceId, {String? date}) async {
    try {
      final formattedDate = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final response = await _dio.get('/predictions/energy');
      
      if (response.statusCode == 200) {
        final List<dynamic> allPredictions = response.data;
        
        // Filter predictions for the specific device and date
        final devicePredictions = allPredictions.where((prediction) {
          return prediction['device_id'] == deviceId && 
                 prediction['prediction_date'].toString().contains(formattedDate);
        }).toList();
        
        return List<Map<String, dynamic>>.from(devicePredictions);
      } else {
        throw Exception('Failed to load energy predictions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch energy predictions');
    } catch (e) {
      throw Exception('Unexpected error while fetching predictions: $e');
    }
  }

  // Get device summary for a specific device
  Future<Map<String, dynamic>> getDevicePredictionsSummary(int deviceId) async {
    try {
      final response = await _dio.get('/predictions/device/$deviceId/summary');
      
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
  Future<Map<String, dynamic>> getPeakDemandSummary() async {
    try {
      final response = await _dio.get('/predictions/peak/summary');
      
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

  // Get total consumption per device
  Future<List<Map<String, dynamic>>> getTotalConsumption() async {
    try {
      final response = await _dio.get('/consumption/total');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load total consumption: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch total consumption');
    } catch (e) {
      throw Exception('Unexpected error while fetching total consumption: $e');
    }
  }

  // Convert API data to EnergyStats model
  Future<EnergyStats> getEnergyStats() async {
    try {
      // Get dashboard overview for summary data
      final overview = await getDashboardOverview();
      
      // Get total consumption for devices
      final consumption = await getTotalConsumption();
      
      // Get current date
      final now = DateTime.now();
      
      // Create a list to hold daily usage data
      final List<DailyUsage> dailyData = [];
      
      // Get today's predicted energy from overview
      double todayEnergy = overview.containsKey('today_predicted_energy') 
          ? (overview['today_predicted_energy'] as num).toDouble() 
          : 0.0;
      
      // For each day in the past week:
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        double dailyUsageValue;
        
        if (i == 0) {
          // Use today's prediction
          dailyUsageValue = todayEnergy;
        } else {
          // Generate simulated historical data (in a real app, you'd fetch this from an API)
          // This is just for demonstration purposes
          dailyUsageValue = todayEnergy * (0.9 + (0.2 * (i % 3)));
        }
        
        // Calculate approximate cost (simplified)
        final cost = dailyUsageValue * 0.15; // Assuming $0.15 per kWh
        
        dailyData.add(DailyUsage(
          date: date,
          usage: dailyUsageValue,
          cost: cost,
        ));
      }
      
      // Calculate weekly usage
      double weeklyUsage = dailyData.fold(0, (sum, item) => sum + item.usage);
      
      // Calculate monthly projection
      double monthlyUsage = weeklyUsage * 4.3; // Approximate month as 4.3 weeks
      double monthlyCost = monthlyUsage * 0.15; // Assuming $0.15 per kWh
      
      // Predicted usage for next month (10% increase)
      double predictedUsage = monthlyUsage * 1.1;
      
      // Calculate cost saving target (10% reduction)
      double costSavingTarget = monthlyCost * 0.9;
      
      return EnergyStats(
        dailyUsage: todayEnergy,
        weeklyUsage: weeklyUsage,
        monthlyUsage: monthlyUsage,
        monthlyCost: monthlyCost,
        dailyData: dailyData,
        predictedUsage: predictedUsage,
        costSavingTarget: costSavingTarget,
      );
    } catch (e) {
      DevLogs.logError('Failed to compile energy statistics: $e');
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
