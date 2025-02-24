import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';

import '../service/applince_service.dart';


class ApplianceController extends GetxController {
  final ApplianceService _applianceService = ApplianceService();
  final RxBool isLoading = false.obs;
  final Rx<ApplianceReading> appliance = ApplianceReading(
    id: 0,
    applianceInfo: ApplianceInfo(
      id: 0,
      appliance: '',
      ratedPower: '',
      dateAdded: DateTime.now(),
    ),
    voltage: '',
    current: '',
    timeOn: '',
    activeEnergy: '',
  ).obs;

  final RxList<TimelineEntry> timelineData = <TimelineEntry>[].obs;
  final RxList<PowerReading> powerReadings = <PowerReading>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Get appliance data from arguments
    final ApplianceReading args = Get.arguments;
    appliance.value = args;
    fetchApplianceData();
  }

  Future<void> fetchApplianceData() async {
    try {
      isLoading.value = true;
      final data = await _applianceService.getApplianceDetails(appliance.value.id);
      timelineData.value = data.timeline;
      powerReadings.value = data.powerReadings;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch appliance data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      isLoading.value = true;
      await _applianceService.updateSchedule(appliance.value.id, schedule);
      Get.snackbar('Success', 'Schedule updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update schedule');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> togglePowerSavingMode(bool enabled) async {
    try {
      isLoading.value = true;
      await _applianceService.togglePowerSaving(appliance.value.id, enabled);
      Get.snackbar(
        'Success',
        'Power saving mode ${enabled ? 'enabled' : 'disabled'}',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update power saving mode');
    } finally {
      isLoading.value = false;
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
}

