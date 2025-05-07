import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/scheduling/models/schedule_model.dart';
import 'package:flutter_energy/modules/scheduling/services/schedule_service.dart';
import 'package:get/get.dart';

class ScheduleController extends GetxController {
  final ScheduleService _scheduleService = Get.find<ScheduleService>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<Schedule> schedules = <Schedule>[].obs;
  final RxList<Schedule> deviceSchedules = <Schedule>[].obs;

  // Form variables for creating/editing schedules
  final Rx<TimeOfDay> selectedStartTime = TimeOfDay.now().obs;
  final Rx<TimeOfDay?> selectedEndTime = Rx<TimeOfDay?>(null);
  final Rx<ScheduleAction> selectedAction = ScheduleAction.turnOn.obs;
  final Rx<ScheduleRepeatType> selectedRepeatType = ScheduleRepeatType.daily.obs;
  final RxList<int> selectedDays = <int>[].obs;
  final RxBool isEnabled = true.obs;

  // Current device being scheduled
  final Rx<ApplianceInfo?> currentDevice = Rx<ApplianceInfo?>(null);

  // Current schedule being edited
  final Rx<Schedule?> currentSchedule = Rx<Schedule?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAllSchedules();
  }

  // Set current device for scheduling
  void setDevice(ApplianceInfo device) {
    currentDevice.value = device;
    fetchDeviceSchedules(device.id.toString());
  }

  // Fetch all schedules
  Future<void> fetchAllSchedules() async {
    try {
      isLoading.value = true;
      final fetchedSchedules = await _scheduleService.getSchedules();
      schedules.value = fetchedSchedules;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch schedules',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch schedules for a specific device
  Future<void> fetchDeviceSchedules(String deviceId) async {
    try {
      isLoading.value = true;
      final fetchedSchedules = await _scheduleService.getDeviceSchedules(deviceId);
      deviceSchedules.value = fetchedSchedules;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch device schedules',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Initialize form for creating a new schedule
  void initNewSchedule() {
    selectedStartTime.value = TimeOfDay.now();
    selectedEndTime.value = null;
    selectedAction.value = ScheduleAction.turnOn;
    selectedRepeatType.value = ScheduleRepeatType.daily;
    selectedDays.value = [0, 1, 2, 3, 4]; // Monday to Friday
    isEnabled.value = true;
    currentSchedule.value = null;
  }

  // Initialize form for editing an existing schedule
  void initEditSchedule(Schedule schedule) {
    selectedStartTime.value = schedule.startTime;
    selectedEndTime.value = schedule.endTime;
    selectedAction.value = schedule.action;
    selectedRepeatType.value = schedule.repeatType;
    selectedDays.value = List.from(schedule.activeDays);
    isEnabled.value = schedule.isEnabled;
    currentSchedule.value = schedule;
  }

  // Save schedule (create or update)
  Future<bool> saveSchedule() async {
    try {
      if (currentDevice.value == null) {
        throw Exception('No device selected');
      }

      isLoading.value = true;

      final device = currentDevice.value!;
      final isEditing = currentSchedule.value != null;

      // Create schedule object
      final schedule = Schedule(
        id: isEditing ? currentSchedule.value!.id : null,
        deviceId: device.id.toString(),
        deviceName: device.appliance,
        startTime: selectedStartTime.value,
        endTime: selectedAction.value == ScheduleAction.both ? selectedEndTime.value : null,
        action: selectedAction.value,
        repeatType: selectedRepeatType.value,
        activeDays: selectedDays,
        isEnabled: isEnabled.value,
        createdAt: isEditing ? currentSchedule.value!.createdAt : null,
        lastExecuted: isEditing ? currentSchedule.value!.lastExecuted : null,
      );

      // Save to Firestore
      if (isEditing) {
        await _scheduleService.updateSchedule(schedule);
      } else {
        await _scheduleService.addSchedule(schedule);
      }

      // Refresh schedules
      await fetchDeviceSchedules(device.id.toString());

      Get.snackbar(
        'Success',
        isEditing ? 'Schedule updated' : 'Schedule created',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save schedule: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      isLoading.value = true;
      await _scheduleService.deleteSchedule(scheduleId);

      // Refresh schedules
      if (currentDevice.value != null) {
        await fetchDeviceSchedules(currentDevice.value!.id.toString());
      }

      Get.snackbar(
        'Success',
        'Schedule deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete schedule: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle schedule enabled state
  Future<bool> toggleScheduleEnabled(String scheduleId, bool isEnabled) async {
    try {
      await _scheduleService.toggleSchedule(scheduleId, isEnabled);

      // Update local state
      final index = deviceSchedules.indexWhere((s) => s.id == scheduleId);
      if (index >= 0) {
        deviceSchedules[index] = deviceSchedules[index].copyWith(isEnabled: isEnabled);
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle schedule: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Toggle day selection for custom repeat
  void toggleDay(int day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  // Set action type
  void setAction(ScheduleAction action) {
    selectedAction.value = action;
    if (action != ScheduleAction.both) {
      selectedEndTime.value = null;
    }
  }

  // Set repeat type
  void setRepeatType(ScheduleRepeatType type) {
    selectedRepeatType.value = type;

    // Initialize days based on repeat type
    switch (type) {
      case ScheduleRepeatType.once:
      case ScheduleRepeatType.daily:
        selectedDays.value = [0, 1, 2, 3, 4, 5, 6]; // All days
        break;
      case ScheduleRepeatType.weekdays:
        selectedDays.value = [0, 1, 2, 3, 4]; // Monday to Friday
        break;
      case ScheduleRepeatType.weekends:
        selectedDays.value = [5, 6]; // Saturday and Sunday
        break;
      case ScheduleRepeatType.custom:
      // Keep current selection
        break;
    }
  }
}
