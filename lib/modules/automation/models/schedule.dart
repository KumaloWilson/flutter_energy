import 'package:flutter/material.dart';

enum ScheduleType { daily, weekly, once }
enum ScheduleStatus { active, inactive, completed }

class Schedule {
  final int id;
  final String applianceName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ScheduleType type;
  final List<int> activeDays;
  final bool isEnabled;
  final ScheduleStatus status;
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.applianceName,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.activeDays,
    required this.isEnabled,
    required this.status,
    required this.createdAt,
  });
}

