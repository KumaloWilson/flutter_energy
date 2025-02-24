import 'dart:math';

import 'package:flutter/material.dart';

class ApplianceService {
  Future<ApplianceDetails> getApplianceDetails(int id) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock timeline data
    final timeline = List.generate(
      10,
          (index) => TimelineEntry(
        timestamp: DateTime.now().subtract(Duration(hours: index)),
        event: _getRandomEvent(),
        value: (Random().nextDouble() * 100).toStringAsFixed(1),
      ),
    );

    // Generate mock power readings (24 hours)
    final powerReadings = List.generate(
      24,
          (index) => PowerReading(
        timestamp: DateTime.now().subtract(Duration(hours: 23 - index)),
        power: 100 + (Random().nextDouble() * 150),
      ),
    );

    return ApplianceDetails(
      timeline: timeline,
      powerReadings: powerReadings,
    );
  }

  String _getRandomEvent() {
    final events = [
      'Power on',
      'Power off',
      'Peak usage',
      'Low usage',
      'Standby mode',
      'Power saving activated',
      'Schedule started',
      'Schedule ended',
    ];
    return events[Random().nextInt(events.length)];
  }

  Future<void> updateSchedule(int id, Schedule schedule) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> togglePowerSaving(int id, bool enabled) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }
}

class ApplianceDetails {
  final List<TimelineEntry> timeline;
  final List<PowerReading> powerReadings;

  ApplianceDetails({
    required this.timeline,
    required this.powerReadings,
  });
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

class Schedule {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> activeDays;
  final bool enabled;

  Schedule({
    required this.startTime,
    required this.endTime,
    required this.activeDays,
    required this.enabled,
  });
}

