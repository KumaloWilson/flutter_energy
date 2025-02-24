import '../model/alert.dart';

class AlertsService {
  Future<List<Alert>> getAlerts() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return [
      Alert(
        id: 1,
        title: 'High Energy Usage Detected',
        message:
        'Your Air Conditioner is consuming more energy than usual. Consider checking the temperature settings.',
        type: AlertType.highUsage,
        priority: AlertPriority.high,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
        deviceName: 'Air Conditioner',
        actionText: 'View Device',
        actionRoute: '/appliance-detail',
      ),
      Alert(
        id: 2,
        title: 'Schedule Reminder',
        message:
        'Your Water Heater is scheduled to turn on in 30 minutes according to your morning schedule.',
        type: AlertType.scheduleReminder,
        priority: AlertPriority.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        deviceName: 'Water Heater',
        actionText: 'View Schedule',
        actionRoute: '/schedules',
      ),
      Alert(
        id: 3,
        title: 'Monthly Cost Alert',
        message:
        'You have reached 80% of your monthly energy budget. Consider implementing energy-saving measures.',
        type: AlertType.costAlert,
        priority: AlertPriority.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
        actionText: 'View Tips',
        actionRoute: '/tips',
      ),
    ];
  }

  Future<void> markAsRead(int alertId) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> deleteAlert(int alertId) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }
}

