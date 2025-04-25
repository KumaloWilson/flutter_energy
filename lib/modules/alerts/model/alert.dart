import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType {
  highUsage,
  deviceMalfunction,
  scheduleReminder,
  systemUpdate,
  costAlert,
}

enum AlertPriority {
  low,
  medium,
  high,
}

class Alert {
  final int id;
  final String title;
  final String message;
  final AlertType type;
  final AlertPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? deviceName;
  final String? actionText;
  final String? actionRoute;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.deviceName,
    this.actionText,
    this.actionRoute,
  });

  Alert copyWith({
    int? id,
    String? title,
    String? message,
    AlertType? type,
    AlertPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? deviceName,
    String? actionText,
    String? actionRoute,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deviceName: deviceName ?? this.deviceName,
      actionText: actionText ?? this.actionText,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.index,
      'priority': priority.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'deviceName': deviceName,
      'actionText': actionText,
      'actionRoute': actionRoute,
    };
  }

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: AlertType.values[map['type'] ?? 0],
      priority: AlertPriority.values[map['priority'] ?? 0],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      deviceName: map['deviceName'],
      actionText: map['actionText'],
      actionRoute: map['actionRoute'],
    );
  }

  factory Alert.fromFirestore(Map<String, dynamic> map, String id) {
    return Alert(
      id: int.tryParse(id) ?? 0,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: AlertType.values[map['type'] ?? 0],
      priority: AlertPriority.values[map['priority'] ?? 0],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      deviceName: map['deviceName'],
      actionText: map['actionText'],
      actionRoute: map['actionRoute'],
    );
  }
}
