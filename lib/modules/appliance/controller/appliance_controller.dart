import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../dashboard/models/appliance_reading.dart';
import '../../dashboard/services/api_service.dart';
import '../service/appliance_service.dart';

class ApplianceController extends GetxController {
  final ApplianceService _applianceService = ApplianceService();
  final ApiService _apiService = Get.find<ApiService>();
  final RxBool isLoading = true.obs;
  final RxBool isControlLoading = false.obs;

  // Main appliance data
  final Rx<ApplianceReading> appliance = ApplianceReading(
    id: 0,
    applianceInfo: ApplianceInfo(
      id: 0,
      ratedPower: '',
      dateAdded: DateTime.now(),
      appliance: '',
    ),
    voltage: '',
    current: '',
    timeOn: '',
    activeEnergy: '',
    readingTimeStamp: DateTime.now(),
  ).obs;

  // Timeline and power readings
  final RxList<TimelineEntry> timelineData = <TimelineEntry>[].obs;
  final RxList<PowerReading> powerReadings = <PowerReading>[].obs;

  // Schedule settings
  final Rx<Schedule> schedule = Schedule(
    startTime: const TimeOfDay(hour: 7, minute: 0),
    endTime: const TimeOfDay(hour: 22, minute: 0),
    activeDays: [0, 1, 2, 3, 4],
    enabled: false,
  ).obs;

  final RxBool powerSavingEnabled = false.obs;

  // Total energy consumption
  final RxDouble totalEnergyConsumption = 0.0.obs;
  final DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  final DateTime endDate = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    // Get appliance data from arguments
    final ApplianceReading args = Get.arguments;
    appliance.value = args;
    fetchApplianceData();
    fetchTotalConsumption();
  }

  Future<void> fetchApplianceData() async {
    try {
      isLoading.value = true;

      // Get all readings for this device
      final readings = await _applianceService.getDeviceReadings(appliance.value.applianceInfo.id);

      if (readings.isNotEmpty) {
        // Update the appliance with the latest reading
        readings.sort((a, b) => b.readingTimeStamp.compareTo(a.readingTimeStamp));

        // Preserve the appliance info but update the reading data
        final latestReading = readings.first;
        appliance.value = ApplianceReading(
          id: appliance.value.id,
          applianceInfo: appliance.value.applianceInfo,
          voltage: latestReading.voltage,
          current: latestReading.current,
          timeOn: latestReading.timeOn,
          activeEnergy: latestReading.activeEnergy,
          readingTimeStamp: latestReading.readingTimeStamp,
        );

        // Process reading data into timeline and power chart data
        _processApplianceReadings(readings);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch appliance data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _processApplianceReadings(List<ApplianceReading> readings) {
    // Generate timeline data
    timelineData.clear();

    for (int i = 0; i < readings.length; i++) {
      final reading = readings[i];

      // Detect significant events
      String event;

      if (i == 0) {
        event = 'Latest reading';
      } else {
        final prevReading = readings[i-1];
        double currentDiff = double.parse(reading.current) - double.parse(prevReading.current);

        if (double.parse(reading.current) < 0.2) {
          event = 'Appliance off';
        } else if (currentDiff > 0.3) {
          event = 'Power usage increased';
        } else if (currentDiff < -0.3) {
          event = 'Power usage decreased';
        } else {
          event = 'Normal operation';
        }
      }

      timelineData.add(
        TimelineEntry(
          timestamp: reading.readingTimeStamp,
          event: event,
          value: '${(double.parse(reading.current) * double.parse(reading.voltage)).toStringAsFixed(1)} W',
        ),
      );

      // Limit timeline entries
      if (timelineData.length >= 10) break;
    }

    // Generate power readings data for chart
    powerReadings.clear();

    for (final reading in readings) {
      final power = double.parse(reading.current) * double.parse(reading.voltage);

      powerReadings.add(
        PowerReading(
          timestamp: reading.readingTimeStamp,
          power: power,
        ),
      );
    }

    // Sort by timestamp (oldest first for chart)
    powerReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Limit to 24 readings for the chart
    if (powerReadings.length > 24) {
      powerReadings.value = powerReadings.sublist(powerReadings.length - 24);
    }
  }

  Future<void> fetchTotalConsumption() async {
    try {
      final formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} 00:00:00";
      final formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} 23:59:59";

      final consumption = await _applianceService.getTotalConsumption(
        [appliance.value.applianceInfo.id],
        formattedStartDate,
        formattedEndDate,
      );

      for (var item in consumption) {
        if (item['Appliance_Info_id'] == appliance.value.applianceInfo.id) {
          totalEnergyConsumption.value = item['total_energy'] ?? 0.0;
          break;
        }
      }
    } catch (e) {
      print('Failed to fetch total consumption: $e');
    }
  }

  void toggleSchedule(bool enabled) {
    final updatedSchedule = schedule.value.copyWith(enabled: enabled);
    schedule.value = updatedSchedule;
    updateSchedule(updatedSchedule);
  }

  void updateScheduleStartTime(TimeOfDay time) {
    final updatedSchedule = schedule.value.copyWith(startTime: time);
    schedule.value = updatedSchedule;
  }

  void updateScheduleEndTime(TimeOfDay time) {
    final updatedSchedule = schedule.value.copyWith(endTime: time);
    schedule.value = updatedSchedule;
  }

  void toggleScheduleDay(int day, bool active) {
    List<int> days = List.from(schedule.value.activeDays);

    if (active && !days.contains(day)) {
      days.add(day);
    } else if (!active && days.contains(day)) {
      days.remove(day);
    }

    final updatedSchedule = schedule.value.copyWith(activeDays: days);
    schedule.value = updatedSchedule;
  }

  Future<void> saveSchedule() async {
    try {
      await updateSchedule(schedule.value);
      Get.snackbar(
        'Success',
        'Schedule updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update schedule',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      isLoading.value = true;
      await _applianceService.updateSchedule(appliance.value.id, schedule);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> togglePowerSavingMode(bool enabled) async {
    try {
      isLoading.value = true;
      await _applianceService.togglePowerSaving(appliance.value.id, enabled);
      powerSavingEnabled.value = enabled;

      Get.snackbar(
        'Success',
        'Power saving mode ${enabled ? 'enabled' : 'disabled'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update power saving mode',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle device on/off
  Future<void> toggleDeviceState() async {
    try {
      isControlLoading.value = true;

      final device = appliance.value.applianceInfo;
      final isCurrentlyOn = device.relayStatus == 'ON';
      final meterNumber = device.meterNumber;

      if (meterNumber.isEmpty) {
        throw Exception('Device has no meter number');
      }

      bool success;
      if (isCurrentlyOn) {
        // Turn off
        success = await _apiService.turnDeviceOff(meterNumber);
      } else {
        // Turn on
        success = await _apiService.turnDeviceOn(meterNumber);
      }

      if (success) {
        // Update the device status locally
        final updatedDevice = ApplianceInfo(
          id: device.id,
          appliance: device.appliance,
          ratedPower: device.ratedPower,
          dateAdded: device.dateAdded,
          meterNumber: device.meterNumber,
          relayStatus: isCurrentlyOn ? 'OFF' : 'ON',
        );

        // Update the appliance info
        appliance.update((val) {
          if (val != null) {
            val.applianceInfo = updatedDevice;
          }
        });

        // Show success message
        Get.snackbar(
          'Success',
          'Device ${isCurrentlyOn ? 'turned off' : 'turned on'} successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to toggle device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle device: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isControlLoading.value = false;
    }
  }

  double getAveragePower() {
    if (powerReadings.isEmpty) return 0;
    final sum = powerReadings.fold(
      0.0,
          (sum, reading) => sum + reading.power,
    );
    return sum / powerReadings.length;
  }

  double getMaxPower() {
    if (powerReadings.isEmpty) return 0;
    return powerReadings.map((e) => e.power).reduce(max);
  }

  String getEfficiencyStatus() {
    final avgPower = getAveragePower();
    final ratedPower = double.parse(
      appliance.value.applianceInfo.ratedPower.replaceAll(' W', ''),
    );

    if (avgPower < ratedPower * 0.8) return 'Efficient';
    if (avgPower < ratedPower * 1.2) return 'Normal';
    return 'High Usage';
  }

  Color getEfficiencyColor() {
    switch (getEfficiencyStatus()) {
      case 'Efficient':
        return Colors.green;
      case 'Normal':
        return Colors.orange;
      case 'High Usage':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double getEfficiencyPercentage() {
    switch (getEfficiencyStatus()) {
      case 'Efficient':
        return 0.9;
      case 'Normal':
        return 0.6;
      case 'High Usage':
        return 0.3;
      default:
        return 0.5;
    }
  }
}
