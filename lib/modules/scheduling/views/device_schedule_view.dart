import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/scheduling/controllers/schedule_controller.dart';
import 'package:flutter_energy/modules/scheduling/views/schedule_editor_view.dart';
import 'package:flutter_energy/modules/scheduling/widgets/schedule_list.dart';
import 'package:get/get.dart';

class DeviceSchedulesView extends StatelessWidget {
  final ApplianceInfo device;

  const DeviceSchedulesView({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with device
    final controller = Get.put(ScheduleController());
    controller.setDevice(device);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Schedules'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ScheduleList(
          schedules: controller.deviceSchedules,
          onEdit: (schedule) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.initNewSchedule();
          Get.to(() => const ScheduleEditorView());
        },
        child: const Icon(Icons.add),
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
}
