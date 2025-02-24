import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controller/alerts_controller.dart';
import '../model/alert.dart';

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AlertsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (controller.unreadCount > 0) {
              return TextButton.icon(
                onPressed: () {
                  // Mark all as read
                },
                icon: const Icon(Icons.done_all),
                label: const Text('Mark all as read'),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ).animate().fadeIn().scale(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.alerts.length,
          itemBuilder: (context, index) {
            final alert = controller.alerts[index];
            return _AlertCard(
              alert: alert,
              controller: controller,
            ).animate().fadeIn(delay: (index * 100).ms).slideX();
          },
        );
      }),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final AlertsController controller;

  const _AlertCard({
    required this.alert,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('alert_${alert.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteAlert(alert),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () {
            if (!alert.isRead) {
              controller.markAsRead(alert);
            }
            if (alert.actionRoute != null) {
              Get.toNamed(alert.actionRoute!);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: controller
                            .getAlertColor(alert.type)
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.getAlertIcon(alert.type),
                        color: controller.getAlertColor(alert.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            timeago.format(alert.timestamp),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!alert.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.getAlertColor(alert.type),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(alert.message),
                if (alert.actionText != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      if (!alert.isRead) {
                        controller.markAsRead(alert);
                      }
                      if (alert.actionRoute != null) {
                        Get.toNamed(alert.actionRoute!);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: controller.getAlertColor(alert.type),
                    ),
                    child: Text(alert.actionText!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

