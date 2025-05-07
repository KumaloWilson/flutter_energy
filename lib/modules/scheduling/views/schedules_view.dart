import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/scheduling/controllers/schedule_controller.dart';
import 'package:flutter_energy/modules/scheduling/models/schedule_model.dart';
import 'package:flutter_energy/modules/scheduling/views/schedule_editor_view.dart';
import 'package:flutter_energy/modules/scheduling/widgets/schedule_list.dart';
import 'package:get/get.dart';

import '../../dashboard/models/appliance_reading.dart';
import '../../home/controllers/home_controller.dart';

class SchedulesView extends StatelessWidget {
  const SchedulesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScheduleController());

    // Fetch all schedules when the view is loaded
    controller.fetchAllSchedules();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllSchedules(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick info card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Scheduling',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create schedules to automatically turn your devices on and off at specific times. This helps save energy and automate your home.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Schedule list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ScheduleList(
                schedules: controller.schedules,
                onEdit: (schedule) {
                  // Set the current device before editing
                  controller.currentDevice.value = ApplianceInfo(
                    id: int.tryParse(schedule.deviceId) ?? 0,
                    appliance: schedule.deviceName,
                    ratedPower: '',
                    dateAdded: schedule.createdAt,
                  );

                  controller.initEditSchedule(schedule);
                  Get.to(() => const ScheduleEditorView());
                },
                onDelete: (scheduleId) {
                  _showDeleteConfirmation(context, scheduleId, controller);
                },
                onToggle: (scheduleId, isEnabled) {
                  controller.toggleScheduleEnabled(scheduleId, isEnabled);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show device selection dialog before creating a new schedule
          _showDeviceSelectionDialog(context, controller);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Schedule'),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      String scheduleId,
      ScheduleController controller,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteSchedule(scheduleId);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceSelectionDialog(
      BuildContext context,
      ScheduleController controller,
      ) async {
    // In a real app, you would fetch this from your device service
    // For now, we'll use a simplified approach
    final homeController = Get.find<HomeController>();

    // Wait for devices to load if needed
    if (homeController.isLoading.value) {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (homeController.allDevices.isEmpty) {
      Get.snackbar(
        'No Devices',
        'Please add devices before creating schedules',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Device'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: homeController.allDevices.length,
            itemBuilder: (context, index) {
              final device = homeController.allDevices[index];
              return ListTile(
                leading: Icon(
                  _getDeviceIcon(device.appliance),
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(device.appliance),
                subtitle: Text(device.meterNumber),
                onTap: () {
                  Navigator.of(context).pop();

                  // Convert to ApplianceInfo
                  final applianceInfo = ApplianceInfo(
                    id: device.id ?? 0,
                    appliance: device.appliance,
                    ratedPower: device.ratedPower,
                    dateAdded: device.dateAdded,
                    meterNumber: device.meterNumber,
                  );

                  // Set the device and initialize a new schedule
                  controller.setDevice(applianceInfo);
                  controller.initNewSchedule();
                  Get.to(() => const ScheduleEditorView());
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('light') || name.contains('lamp')) return Icons.lightbulb;
    if (name.contains('tv') || name.contains('television')) return Icons.tv;
    if (name.contains('fridge') || name.contains('refrigerator')) return Icons.kitchen;
    if (name.contains('ac') || name.contains('air')) return Icons.ac_unit;
    if (name.contains('heater')) return Icons.hot_tub;
    if (name.contains('fan')) return Icons.air;
    if (name.contains('oven') || name.contains('stove')) return Icons.microwave;
    if (name.contains('washer') || name.contains('washing')) return Icons.local_laundry_service;
    return Icons.electrical_services;
  }
}
