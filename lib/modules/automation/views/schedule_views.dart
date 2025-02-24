import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/automation/controllers/schedule_controller.dart';
import 'package:flutter_energy/modules/automation/models/schedule.dart';

class SchedulesView extends StatelessWidget {
  const SchedulesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScheduleController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.schedules.length,
          itemBuilder: (context, index) {
            final schedule = controller.schedules[index];
            return _ScheduleCard(
              schedule: schedule,
              controller: controller,
            ).animate().fadeIn(delay: (index * 100).ms).slideX();
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new schedule
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final ScheduleController controller;

  const _ScheduleCard({
    required this.schedule,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getApplianceIcon(schedule.applianceName),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.applianceName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        controller.getScheduleDays(schedule),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: schedule.isEnabled,
                  onChanged: (_) => controller.toggleSchedule(schedule),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TimeCard(
                  icon: Icons.wb_sunny,
                  label: 'Start',
                  time: schedule.startTime,
                ),
                const Icon(Icons.arrow_forward, size: 20),
                _TimeCard(
                  icon: Icons.nights_stay,
                  label: 'End',
                  time: schedule.endTime,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(schedule.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(schedule.status),
                        size: 16,
                        color: _getStatusColor(schedule.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.status.name.capitalize!,
                        style: TextStyle(
                          color: _getStatusColor(schedule.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, schedule),
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getApplianceIcon(String appliance) {
    switch (appliance.toLowerCase()) {
      case 'television':
        return Icons.tv;
      case 'air conditioner':
        return Icons.ac_unit;
      case 'water heater':
        return Icons.hot_tub;
      default:
        return Icons.electrical_services;
    }
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.active:
        return Colors.green;
      case ScheduleStatus.inactive:
        return Colors.orange;
      case ScheduleStatus.completed:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.active:
        return Icons.check_circle;
      case ScheduleStatus.inactive:
        return Icons.pause_circle;
      case ScheduleStatus.completed:
        return Icons.task_alt;
    }
  }

  Future<void> _confirmDelete(BuildContext context, Schedule schedule) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text(
          'Are you sure you want to delete the schedule for ${schedule.applianceName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      controller.deleteSchedule(schedule);
    }
  }
}

class _TimeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final TimeOfDay time;

  const _TimeCard({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time.format(context),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

