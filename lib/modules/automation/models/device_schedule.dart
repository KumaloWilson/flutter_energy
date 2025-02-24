import 'package:flutter/material.dart';

enum ScheduleType { daily, weekly, once }

class DeviceSchedule {
  final int id;
  final int applianceId;
  final String applianceName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ScheduleType type;
  final List<int> activeDays; // 1-7 for weekly schedule
  final bool isEnabled;

  DeviceSchedule({
    required this.id,
    required this.applianceId,
    required this.applianceName,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.activeDays,
    required this.isEnabled,
  });
}

