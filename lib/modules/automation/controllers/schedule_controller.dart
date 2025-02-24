import 'package:get/get.dart';
import 'package:flutter_energy/modules/automation/models/schedule.dart';
import 'package:flutter_energy/modules/automation/services/schedule_service.dart';

class ScheduleController extends GetxController {
  final ScheduleService _scheduleService = ScheduleService();
  final RxBool isLoading = false.obs;
  final RxList<Schedule> schedules = <Schedule>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    try {
      isLoading.value = true;
      final data = await _scheduleService.getSchedules();
      schedules.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch schedules');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSchedule(Schedule schedule) async {
    try {
      await _scheduleService.toggleSchedule(schedule.id, !schedule.isEnabled);
      await fetchSchedules();
      Get.snackbar(
        'Success',
        'Schedule ${schedule.isEnabled ? 'disabled' : 'enabled'}',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update schedule');
    }
  }

  Future<void> deleteSchedule(Schedule schedule) async {
    try {
      await _scheduleService.deleteSchedule(schedule.id);
      await fetchSchedules();
      Get.snackbar('Success', 'Schedule deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete schedule');
    }
  }

  String getScheduleDays(Schedule schedule) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return schedule.activeDays.map((day) => days[day - 1]).join(', ');
  }
}

