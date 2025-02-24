import 'package:flutter/material.dart';

import '../models/device_schedule.dart';

class AutomationService {
  Future<List<DeviceSchedule>> getDeviceSchedules() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      DeviceSchedule(
        id: 1,
        applianceId: 1,
        applianceName: "Television",
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 22, minute: 0),
        type: ScheduleType.daily,
        activeDays: [1, 2, 3, 4, 5],
        isEnabled: true,
      ),
      DeviceSchedule(
        id: 2,
        applianceId: 2,
        applianceName: "Air Conditioner",
        startTime: const TimeOfDay(hour: 20, minute: 0),
        endTime: const TimeOfDay(hour: 6, minute: 0),
        type: ScheduleType.daily,
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
      ),
    ];
  }

  Future<void> toggleSchedule(int scheduleId, bool isEnabled) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> addSchedule(DeviceSchedule schedule) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }
}

