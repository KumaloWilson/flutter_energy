import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/alert.dart';

class AlertsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get collection reference for the current user's alerts
  CollectionReference<Map<String, dynamic>> get _alertsCollection {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('alerts');
  }

  // Get all alerts for the current user
  Future<List<Alert>> getAlerts() async {
    try {
      final snapshot = await _alertsCollection
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Alert.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching alerts: $e');
      // Return some mock data if there's an error or during development
      return _getMockAlerts();
    }
  }

  // Mark an alert as read
  Future<void> markAsRead(int alertId) async {
    try {
      await _alertsCollection.doc(alertId.toString()).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking alert as read: $e');
      // Handle error appropriately
    }
  }

  // Delete an alert
  Future<void> deleteAlert(int alertId) async {
    try {
      await _alertsCollection.doc(alertId.toString()).delete();
    } catch (e) {
      print('Error deleting alert: $e');
      // Handle error appropriately
    }
  }

  // Mark all alerts as read
  Future<void> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _alertsCollection
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all alerts as read: $e');
      // Handle error appropriately
    }
  }

  // Create a new alert
  Future<void> createAlert({
    required String title,
    required String message,
    required AlertType type,
    required AlertPriority priority,
    String? deviceName,
    String? actionText,
    String? actionRoute,
  }) async {
    try {
      // Get the next ID
      final snapshot = await _alertsCollection
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      int nextId = 1;
      if (snapshot.docs.isNotEmpty) {
        nextId = (snapshot.docs.first.data()['id'] as int) + 1;
      }

      await _alertsCollection.doc(nextId.toString()).set({
        'id': nextId,
        'title': title,
        'message': message,
        'type': type.index,
        'priority': priority.index,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'deviceName': deviceName,
        'actionText': actionText,
        'actionRoute': actionRoute,
      });
    } catch (e) {
      print('Error creating alert: $e');
      // Handle error appropriately
    }
  }

  // Mock data for testing or when Firebase is not available
  List<Alert> _getMockAlerts() {
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
}
