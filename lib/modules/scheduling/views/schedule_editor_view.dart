import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/scheduling/controllers/schedule_controller.dart';
import 'package:flutter_energy/modules/scheduling/models/schedule_model.dart';
import 'package:get/get.dart';

class ScheduleEditorView extends StatelessWidget {
  const ScheduleEditorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();
    final isEditing = controller.currentSchedule.value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Schedule' : 'Create Schedule'),
        actions: [
          TextButton(
            onPressed: () async {
              final success = await controller.saveSchedule();
              if (success) {
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device info
              if (controller.currentDevice.value != null)
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          _getDeviceIcon(controller.currentDevice.value!.appliance),
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Device',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                controller.currentDevice.value!.appliance,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Schedule type
              _buildSectionTitle(context, 'Schedule Type'),
              _buildActionSelector(context, controller),
              const SizedBox(height: 24),

              // Time selection
              _buildSectionTitle(context, 'Time'),
              _buildTimeSelector(context, controller),
              const SizedBox(height: 24),

              // Repeat options
              _buildSectionTitle(context, 'Repeat'),
              _buildRepeatSelector(context, controller),
              const SizedBox(height: 16),

              // Custom days selector (if custom repeat is selected)
              if (controller.selectedRepeatType.value == ScheduleRepeatType.custom)
                _buildDaysSelector(context, controller),
              const SizedBox(height: 24),

              // Enabled toggle
              _buildEnabledToggle(context, controller),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionSelector(BuildContext context, ScheduleController controller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to do?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildActionChip(
                  context,
                  'Turn On',
                  Icons.power,
                  controller.selectedAction.value == ScheduleAction.turnOn,
                      () => controller.setAction(ScheduleAction.turnOn),
                ),
                _buildActionChip(
                  context,
                  'Turn Off',
                  Icons.power_off,
                  controller.selectedAction.value == ScheduleAction.turnOff,
                      () => controller.setAction(ScheduleAction.turnOff),
                ),
                _buildActionChip(
                  context,
                  'Turn On & Off',
                  Icons.schedule,
                  controller.selectedAction.value == ScheduleAction.both,
                      () => controller.setAction(ScheduleAction.both),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
      BuildContext context,
      String label,
      IconData icon,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context, ScheduleController controller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start time
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                controller.selectedAction.value == ScheduleAction.turnOff
                    ? 'Turn off at'
                    : 'Start time',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: OutlinedButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: controller.selectedStartTime.value,
                  );
                  if (time != null) {
                    controller.selectedStartTime.value = time;
                  }
                },
                child: Text(
                  _formatTimeOfDay(controller.selectedStartTime.value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            // End time (only for "both" action)
            if (controller.selectedAction.value == ScheduleAction.both)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End time'),
                trailing: OutlinedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: controller.selectedEndTime.value ??
                          TimeOfDay(
                            hour: (controller.selectedStartTime.value.hour + 1) % 24,
                            minute: controller.selectedStartTime.value.minute,
                          ),
                    );
                    if (time != null) {
                      controller.selectedEndTime.value = time;
                    }
                  },
                  child: Text(
                    controller.selectedEndTime.value != null
                        ? _formatTimeOfDay(controller.selectedEndTime.value!)
                        : 'Select',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatSelector(BuildContext context, ScheduleController controller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<ScheduleRepeatType>(
            title: const Text('Once'),
            value: ScheduleRepeatType.once,
            groupValue: controller.selectedRepeatType.value,
            onChanged: (value) {
              if (value != null) controller.setRepeatType(value);
            },
          ),
          RadioListTile<ScheduleRepeatType>(
            title: const Text('Every day'),
            value: ScheduleRepeatType.daily,
            groupValue: controller.selectedRepeatType.value,
            onChanged: (value) {
              if (value != null) controller.setRepeatType(value);
            },
          ),
          RadioListTile<ScheduleRepeatType>(
            title: const Text('Weekdays (Mon-Fri)'),
            value: ScheduleRepeatType.weekdays,
            groupValue: controller.selectedRepeatType.value,
            onChanged: (value) {
              if (value != null) controller.setRepeatType(value);
            },
          ),
          RadioListTile<ScheduleRepeatType>(
            title: const Text('Weekends (Sat-Sun)'),
            value: ScheduleRepeatType.weekends,
            groupValue: controller.selectedRepeatType.value,
            onChanged: (value) {
              if (value != null) controller.setRepeatType(value);
            },
          ),
          RadioListTile<ScheduleRepeatType>(
            title: const Text('Custom'),
            value: ScheduleRepeatType.custom,
            groupValue: controller.selectedRepeatType.value,
            onChanged: (value) {
              if (value != null) controller.setRepeatType(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelector(BuildContext context, ScheduleController controller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select days',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayButton(context, 'M', 0, controller),
                _buildDayButton(context, 'T', 1, controller),
                _buildDayButton(context, 'W', 2, controller),
                _buildDayButton(context, 'T', 3, controller),
                _buildDayButton(context, 'F', 4, controller),
                _buildDayButton(context, 'S', 5, controller),
                _buildDayButton(context, 'S', 6, controller),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButton(
      BuildContext context,
      String label,
      int day,
      ScheduleController controller,
      ) {
    final isSelected = controller.selectedDays.contains(day);

    return GestureDetector(
      onTap: () => controller.toggleDay(day),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEnabledToggle(BuildContext context, ScheduleController controller) {
    return SwitchListTile(
      title: const Text('Enable Schedule'),
      subtitle: Text(
        controller.isEnabled.value
            ? 'Schedule is active'
            : 'Schedule is inactive',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      value: controller.isEnabled.value,
      onChanged: (value) => controller.isEnabled.value = value,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
