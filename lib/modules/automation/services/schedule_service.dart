import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/automation/models/schedule.dart';

class ScheduleService {
  Future<List<Schedule>> getSchedules() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return [
      Schedule(
        id: 1,
        applianceName: "Television",
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 22, minute: 0),
        type: ScheduleType.daily,
        activeDays: [1, 2, 3, 4, 5],
        isEnabled: true,
        status: ScheduleStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Schedule(
        id: 2,
        applianceName: "Air Conditioner",
        startTime: const TimeOfDay(hour: 20, minute: 0),
        endTime: const TimeOfDay(hour: 6, minute: 0),
        type: ScheduleType.daily,
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        status: ScheduleStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Schedule(
        id: 3,
        applianceName: "Water Heater",
        startTime: const TimeOfDay(hour: 6, minute: 0),
        endTime: const TimeOfDay(hour: 7, minute: 30),
        type: ScheduleType.weekly,
        activeDays: [1, 3, 5],
        isEnabled: false,
        status: ScheduleStatus.inactive,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  Future<void> toggleSchedule(int id, bool isEnabled) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> deleteSchedule(int id) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }
}

