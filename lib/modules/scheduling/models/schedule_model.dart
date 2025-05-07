import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ScheduleAction {
  turnOn,
  turnOff,
  both // For schedules that turn on and later turn off
}

enum ScheduleRepeatType {
  once,
  daily,
  weekdays,
  weekends,
  custom
}

class Schedule {
  final String id;
  final String deviceId;
  final String deviceName;
  final TimeOfDay startTime;
  final TimeOfDay? endTime; // Optional for schedules that only turn on or off
  final ScheduleAction action;
  final ScheduleRepeatType repeatType;
  final List<int> activeDays; // 0 = Monday, 6 = Sunday
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastExecuted;

  Schedule({
    String? id,
    required this.deviceId,
    required this.deviceName,
    required this.startTime,
    this.endTime,
    required this.action,
    required this.repeatType,
    required this.activeDays,
    this.isEnabled = true,
    DateTime? createdAt,
    this.lastExecuted,
  }) :
        id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Copy with method for immutability
  Schedule copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool clearEndTime = false,
    ScheduleAction? action,
    ScheduleRepeatType? repeatType,
    List<int>? activeDays,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastExecuted,
    bool clearLastExecuted = false,
  }) {
    return Schedule(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      action: action ?? this.action,
      repeatType: repeatType ?? this.repeatType,
      activeDays: activeDays ?? List.from(this.activeDays),
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastExecuted: clearLastExecuted ? null : (lastExecuted ?? this.lastExecuted),
    );
  }

  // Convert TimeOfDay to a comparable double (hours.minutes)
  static double timeOfDayToDouble(TimeOfDay time) {
    return time.hour + time.minute / 60.0;
  }

  // Check if schedule should run today
  bool shouldRunToday() {
    final now = DateTime.now();
    final dayOfWeek = (now.weekday - 1) % 7; // Convert to 0-6 where 0 is Monday

    switch (repeatType) {
      case ScheduleRepeatType.once:
      // For one-time schedules, check if it's already executed
        return lastExecuted == null;
      case ScheduleRepeatType.daily:
        return true;
      case ScheduleRepeatType.weekdays:
        return dayOfWeek < 5; // Monday to Friday
      case ScheduleRepeatType.weekends:
        return dayOfWeek >= 5; // Saturday and Sunday
      case ScheduleRepeatType.custom:
        return activeDays.contains(dayOfWeek);
    }
  }

  // Check if schedule is due to run
  bool isDue() {
    if (!isEnabled || !shouldRunToday()) return false;

    final now = DateTime.now();
    final currentTimeDouble = timeOfDayToDouble(TimeOfDay.fromDateTime(now));
    final startTimeDouble = timeOfDayToDouble(startTime);

    // Check if current time is within 1 minute of start time
    final isStartTimeDue = (currentTimeDouble >= startTimeDouble) &&
        (currentTimeDouble < startTimeDouble + 1/60);

    // If this is a schedule with end time, also check if end time is due
    if (endTime != null && action == ScheduleAction.both) {
      final endTimeDouble = timeOfDayToDouble(endTime!);
      final isEndTimeDue = (currentTimeDouble >= endTimeDouble) &&
          (currentTimeDouble < endTimeDouble + 1/60);

      // Return true if either start or end time is due
      return isStartTimeDue || isEndTimeDue;
    }

    return isStartTimeDue;
  }

  // Determine if we should turn on or off based on current time
  bool shouldTurnOn() {
    if (action == ScheduleAction.turnOn) return true;
    if (action == ScheduleAction.turnOff) return false;

    // For "both" action, check if we're closer to start time or end time
    final now = DateTime.now();
    final currentTimeDouble = timeOfDayToDouble(TimeOfDay.fromDateTime(now));
    final startTimeDouble = timeOfDayToDouble(startTime);

    if (endTime == null) return true; // Default to on if no end time

    final endTimeDouble = timeOfDayToDouble(endTime!);

    // Handle case where end time is on the next day
    if (endTimeDouble < startTimeDouble) {
      // If current time is after start time or before end time, turn on
      return currentTimeDouble >= startTimeDouble || currentTimeDouble < endTimeDouble;
    } else {
      // If current time is between start and end time, turn on
      return currentTimeDouble >= startTimeDouble && currentTimeDouble < endTimeDouble;
    }
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime?.hour,
      'endTimeMinute': endTime?.minute,
      'action': action.index,
      'repeatType': repeatType.index,
      'activeDays': activeDays,
      'isEnabled': isEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastExecuted': lastExecuted != null ? Timestamp.fromDate(lastExecuted!) : null,
    };
  }

  // Create from Firestore map
  factory Schedule.fromMap(Map<String, dynamic> map, String documentId) {
    return Schedule(
      id: documentId,
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      startTime: TimeOfDay(
        hour: map['startTimeHour'] ?? 0,
        minute: map['startTimeMinute'] ?? 0,
      ),
      endTime: map['endTimeHour'] != null ? TimeOfDay(
        hour: map['endTimeHour'] ?? 0,
        minute: map['endTimeMinute'] ?? 0,
      ) : null,
      action: ScheduleAction.values[map['action'] ?? 0],
      repeatType: ScheduleRepeatType.values[map['repeatType'] ?? 0],
      activeDays: List<int>.from(map['activeDays'] ?? []),
      isEnabled: map['isEnabled'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastExecuted: (map['lastExecuted'] as Timestamp?)?.toDate(),
    );
  }

  // Get human-readable repeat text
  String getRepeatText() {
    switch (repeatType) {
      case ScheduleRepeatType.once:
        return 'Once';
      case ScheduleRepeatType.daily:
        return 'Every day';
      case ScheduleRepeatType.weekdays:
        return 'Weekdays';
      case ScheduleRepeatType.weekends:
        return 'Weekends';
      case ScheduleRepeatType.custom:
        if (activeDays.isEmpty) return 'Custom (No days selected)';
        if (activeDays.length == 7) return 'Every day';

        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final selectedDays = activeDays.map((day) => dayNames[day]).join(', ');
        return 'Custom ($selectedDays)';
    }
  }

  // Get human-readable action text
  String getActionText() {
    switch (action) {
      case ScheduleAction.turnOn:
        return 'Turn On';
      case ScheduleAction.turnOff:
        return 'Turn Off';
      case ScheduleAction.both:
        return 'Turn On/Off';
    }
  }

  // Format time for display
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Get schedule time text for display
  String getScheduleTimeText() {
    if (action == ScheduleAction.turnOn) {
      return 'Turn on at ${formatTime(startTime)}';
    } else if (action == ScheduleAction.turnOff) {
      return 'Turn off at ${formatTime(startTime)}';
    } else if (endTime != null) {
      return '${formatTime(startTime)} - ${formatTime(endTime!)}';
    } else {
      return formatTime(startTime);
    }
  }
}
