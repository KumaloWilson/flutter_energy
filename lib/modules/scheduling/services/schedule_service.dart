import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_energy/core/utilities/logger.dart';
import 'package:flutter_energy/modules/dashboard/services/api_service.dart';
import 'package:flutter_energy/modules/scheduling/models/schedule_model.dart';
import 'package:get/get.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:isolate';
import 'dart:ui';

import '../../../bindings/bindings.dart';

class ScheduleService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = Get.find<ApiService>();

  // Alarm IDs
  static const int periodicScheduleCheckId = 1;
  static const int initialScheduleCheckId = 2;

  // Collection reference for schedules
  CollectionReference<Map<String, dynamic>> get _schedulesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('schedules');
  }

  // Initialize alarm manager for background tasks
  Future<void> initBackgroundTasks() async {
    // Initialize the alarm manager plugin
    await AndroidAlarmManager.initialize();

    // Register periodic task to check schedules (15 minutes)
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 15),
      periodicScheduleCheckId,
      scheduleCheckCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    // Register one-time task to check schedules immediately
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 10),
      initialScheduleCheckId,
      scheduleCheckCallback,
      exact: true,
      wakeup: true,
    );
  }

  // Get all schedules
  Future<List<Schedule>> getSchedules() async {
    try {
      final snapshot = await _schedulesCollection.get();
      return snapshot.docs
          .map((doc) => Schedule.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      DevLogs.logError('Error fetching schedules: $e');
      return [];
    }
  }

  // Get schedules for a specific device
  Future<List<Schedule>> getDeviceSchedules(String deviceId) async {
    try {
      final snapshot = await _schedulesCollection
          .where('deviceId', isEqualTo: deviceId)
          .get();
      return snapshot.docs
          .map((doc) => Schedule.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      DevLogs.logError('Error fetching device schedules: $e');
      return [];
    }
  }

  // Add a new schedule
  Future<String> addSchedule(Schedule schedule) async {
    try {
      final docRef = await _schedulesCollection.add(schedule.toMap());
      return docRef.id;
    } catch (e) {
      DevLogs.logError('Error adding schedule: $e');
      throw Exception('Failed to add schedule: $e');
    }
  }

  // Update an existing schedule
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      await _schedulesCollection.doc(schedule.id).update(schedule.toMap());
    } catch (e) {
      DevLogs.logError('Error updating schedule: $e');
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Delete a schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _schedulesCollection.doc(scheduleId).delete();
    } catch (e) {
      DevLogs.logError('Error deleting schedule: $e');
      throw Exception('Failed to delete schedule: $e');
    }
  }

  // Toggle schedule enabled state
  Future<void> toggleSchedule(String scheduleId, bool isEnabled) async {
    try {
      await _schedulesCollection.doc(scheduleId).update({
        'isEnabled': isEnabled,
      });
    } catch (e) {
      DevLogs.logError('Error toggling schedule: $e');
      throw Exception('Failed to toggle schedule: $e');
    }
  }

  // Check and execute due schedules
  Future<void> checkSchedules() async {
    try {
      final schedules = await getSchedules();
      final dueSchedules = schedules.where((schedule) =>
      schedule.isEnabled && schedule.isDue()
      ).toList();

      for (final schedule in dueSchedules) {
        await _executeSchedule(schedule);
      }
    } catch (e) {
      DevLogs.logError('Error checking schedules: $e');
    }
  }

  // Execute a schedule
  Future<void> _executeSchedule(Schedule schedule) async {
    try {
      final shouldTurnOn = schedule.shouldTurnOn();
      final deviceId = schedule.deviceId;

      // Get device details to get meter number
      final deviceSnapshot = await _firestore
          .collection('devices')
          .doc(deviceId)
          .get();

      if (!deviceSnapshot.exists) {
        DevLogs.logError('Device not found: $deviceId');
        return;
      }

      final deviceData = deviceSnapshot.data();
      if (deviceData == null) return;

      final meterNumber = deviceData['meterNumber'] as String?;
      if (meterNumber == null || meterNumber.isEmpty) {
        DevLogs.logError('Device has no meter number: $deviceId');
        return;
      }

      // Execute the action
      bool success;
      if (shouldTurnOn) {
        success = await _apiService.turnDeviceOn(meterNumber);
      } else {
        success = await _apiService.turnDeviceOff(meterNumber);
      }

      if (success) {
        // Update last executed timestamp
        await _schedulesCollection.doc(schedule.id).update({
          'lastExecuted': Timestamp.now(),
        });

        DevLogs.logInfo('Schedule executed: ${schedule.id}, Action: ${shouldTurnOn ? 'ON' : 'OFF'}');
      } else {
        DevLogs.logError('Failed to execute schedule: ${schedule.id}');
      }
    } catch (e) {
      DevLogs.logError('Error executing schedule: $e');
    }
  }
}

// This is the callback function that will be called by AndroidAlarmManager
@pragma('vm:entry-point')
void scheduleCheckCallback() async {
  // This is needed for plugins that use platform channels
  WidgetsFlutterBinding.ensureInitialized();


  try {
    // Initialize Firebase

    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize app dependencies
    await InitialBinding().dependencies();

    final scheduleService = ScheduleService();
    await scheduleService.checkSchedules();

    // Save the last execution time in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastScheduleCheck', DateTime.now().toIso8601String());

    // For debugging purposes
    DevLogs.logInfo('Schedule check completed at ${DateTime.now()}');
  } catch (e) {
    DevLogs.logError('Error in schedule check callback: $e');
  }
}