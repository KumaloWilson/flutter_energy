import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/alert.dart';
import '../service/alerts_service.dart';

class AlertsController extends GetxController {
  final AlertsService _alertsService = AlertsService();
  final RxBool isLoading = false.obs;
  final RxList<Alert> alerts = <Alert>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    try {
      isLoading.value = true;
      final data = await _alertsService.getAlerts();
      alerts.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch alerts');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(Alert alert) async {
    try {
      await _alertsService.markAsRead(alert.id);
      final index = alerts.indexWhere((a) => a.id == alert.id);
      if (index != -1) {
        alerts[index] = Alert(
          id: alert.id,
          title: alert.title,
          message: alert.message,
          type: alert.type,
          priority: alert.priority,
          timestamp: alert.timestamp,
          isRead: true,
          deviceName: alert.deviceName,
          actionText: alert.actionText,
          actionRoute: alert.actionRoute,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update alert');
    }
  }

  Future<void> deleteAlert(Alert alert) async {
    try {
      await _alertsService.deleteAlert(alert.id);
      alerts.removeWhere((a) => a.id == alert.id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete alert');
    }
  }

  Color getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.highUsage:
        return Colors.red;
      case AlertType.deviceMalfunction:
        return Colors.orange;
      case AlertType.scheduleReminder:
        return Colors.blue;
      case AlertType.systemUpdate:
        return Colors.purple;
      case AlertType.costAlert:
        return Colors.amber;
    }
  }

  IconData getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.highUsage:
        return Icons.warning;
      case AlertType.deviceMalfunction:
        return Icons.error;
      case AlertType.scheduleReminder:
        return Icons.schedule;
      case AlertType.systemUpdate:
        return Icons.system_update;
      case AlertType.costAlert:
        return Icons.attach_money;
    }
  }

  int get unreadCount => alerts.where((alert) => !alert.isRead).length;
}

