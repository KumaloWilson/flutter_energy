import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../modules/appliance/controller/appliance_controller.dart';

class UsageTimeline extends StatelessWidget {
  const UsageTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplianceController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.timelineData.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(child: Text('No timeline data available')),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.timelineData.length,
        itemBuilder: (context, index) {
          final entry = controller.timelineData[index];
          final isLast = index == controller.timelineData.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getEventColor(entry.event, colorScheme),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.event,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entry.value} • ${DateFormat('MMM d, h:mm a').format(entry.timestamp)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Color _getEventColor(String event, ColorScheme colorScheme) {
    switch (event.toLowerCase()) {
      case 'power on':
      case 'schedule started':
        return Colors.green;
      case 'power off':
      case 'schedule ended':
      case 'appliance off':
        return Colors.red;
      case 'peak usage':
      case 'power usage increased':
        return Colors.orange;
      case 'low usage':
      case 'power usage decreased':
        return Colors.blue;
      case 'standby mode':
      case 'power saving activated':
        return Colors.purple;
      case 'latest reading':
        return colorScheme.primary;
      default:
        return colorScheme.primary;
    }
  }
}