enum AlertType {
  highUsage,
  deviceMalfunction,
  scheduleReminder,
  systemUpdate,
  costAlert,
}

enum AlertPriority { low, medium, high }

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
    required this.isRead,
    this.deviceName,
    this.actionText,
    this.actionRoute,
  });
}

