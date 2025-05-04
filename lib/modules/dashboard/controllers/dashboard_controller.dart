import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/core/utilities/logger.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/dashboard/services/api_service.dart';

import '../../home/service/firestore_service.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ApplianceReading> readings = <ApplianceReading>[].obs;
  final RxDouble totalEnergy = 0.0.obs;
  final RxList<ApplianceInfo> devices = <ApplianceInfo>[].obs;

  // For monthly consumption
  final RxBool isLoadingMonthly = false.obs;
  final RxBool hasMonthlyError = false.obs;
  final RxString monthlyErrorMessage = ''.obs;
  final RxMap<int, double> monthlyConsumption = <int, double>{}.obs;
  final RxDouble totalMonthlyEnergy = 0.0.obs;

  // For device control
  final RxMap<int, bool> deviceControlLoading = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> refreshDashboard() async {
    await fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Get complete appliance data (devices + readings)
      final completeData = await _apiService.getCompleteApplianceData();
      readings.value = completeData;

      // Extract device info
      devices.value = completeData.map((reading) => reading.applianceInfo).toList();

      // Calculate total energy
      _calculateTotalEnergy();

      // Get monthly consumption
      await fetchMonthlyConsumption();

      // Update Firestore with latest device data
      await _updateFirestoreDeviceData();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      DevLogs.logError('Failed to fetch data: $e');
      showErrorSnackbar('Failed to fetch data', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateFirestoreDeviceData() async {
    try {
      // Get current user's home ID
      final homeId = await _firestoreService.getCurrentHomeId();
      if (homeId == null) return;

      // Get room mappings from Firestore
      final roomMappings = await _firestoreService.getDeviceRoomMappings(homeId);

      // Update device-room mappings in Firestore
      for (final device in devices) {
        final deviceId = device.id.toString();

        // Check if device exists in mappings
        if (!roomMappings.containsKey(deviceId)) {
          // Device not yet mapped to a room, assign to default room
          await _firestoreService.assignDeviceToRoom(
            homeId: homeId,
            deviceId: deviceId,
            roomId: await _firestoreService.getDefaultRoomId(homeId),
            deviceName: device.appliance,
            deviceType: _determineDeviceType(device.appliance),
            meterNumber: device.meterNumber,
          );
        }

        // Update device status in Firestore
        await _firestoreService.updateDeviceStatus(
          homeId: homeId,
          deviceId: deviceId,
          isActive: device.relayStatus == 'ON',
        );
      }
    } catch (e) {
      DevLogs.logError('Error updating Firestore device data: $e');
      // Don't throw, as this is a background operation
    }
  }

  String _determineDeviceType(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('light') || name.contains('lamp')) return 'lighting';
    if (name.contains('tv') || name.contains('television')) return 'entertainment';
    if (name.contains('fridge') || name.contains('refrigerator')) return 'refrigeration';
    if (name.contains('ac') || name.contains('air')) return 'cooling';
    if (name.contains('heater')) return 'heating';
    if (name.contains('oven') || name.contains('stove')) return 'cooking';
    return 'other';
  }

  Future<void> fetchMonthlyConsumption() async {
    try {
      isLoadingMonthly.value = true;
      hasMonthlyError.value = false;
      monthlyErrorMessage.value = '';

      if (devices.isEmpty) {
        hasMonthlyError.value = true;
        monthlyErrorMessage.value = 'No devices available';
        return;
      }

      // Extract device IDs
      final deviceIds = devices.map((device) => device.id).toList();

      // Fetch monthly consumption for all devices
      final consumption = await _apiService.getCurrentMonthConsumption(deviceIds);

      if (consumption.isEmpty) {
        hasMonthlyError.value = true;
        monthlyErrorMessage.value = 'No monthly consumption data available';
      } else {
        monthlyConsumption.value = consumption;
        _calculateTotalMonthlyEnergy();
      }
    } catch (e) {
      hasMonthlyError.value = true;
      monthlyErrorMessage.value = e.toString();
      DevLogs.logError('Monthly consumption error: $e');
      showErrorSnackbar('Failed to fetch monthly consumption', e.toString());
    } finally {
      isLoadingMonthly.value = false;
    }
  }

  void _calculateTotalEnergy() {
    totalEnergy.value = readings.fold(
      0,
          (sum, reading) => sum + double.parse(reading.activeEnergy),
    );
  }

  void _calculateTotalMonthlyEnergy() {
    totalMonthlyEnergy.value = monthlyConsumption.values.fold(
      0.0,
          (sum, energy) => sum + energy,
    );
  }

  // Retry fetching data when an error occurs
  void retryFetch() {
    fetchAllData();
  }

  // Get monthly consumption for a specific device
  double getDeviceMonthlyConsumption(int deviceId) {
    return monthlyConsumption[deviceId] ?? 0.0;
  }

  // Get count of active devices
  int getActiveDevicesCount() {
    return devices.where((device) => device.relayStatus == 'ON').length;
  }

  // Add a new device
  Future<bool> addDevice(String name, String ratedPower, String meterNumber) async {
    try {
      isLoading.value = true;

      final success = await _apiService.addDevice(
        name: name,
        ratedPower: ratedPower,
        meterNumber: meterNumber,
      );

      if (success) {
        // Refresh devices and readings
        await fetchAllData();

        Get.snackbar(
          'Success',
          'Device added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        return true;
      } else {
        errorMessage.value = 'Failed to add device';
        showErrorSnackbar('Error', 'Failed to add device');
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      DevLogs.logError('Failed to add device: $e');
      showErrorSnackbar('Error', 'Failed to add device: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle device on/off
  Future<bool> toggleDevice(ApplianceInfo device) async {
    try {
      // Set loading state for this device
      deviceControlLoading[device.id] = true;

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
        final index = devices.indexWhere((d) => d.id == device.id);
        if (index >= 0) {
          final updatedDevice = ApplianceInfo(
            id: device.id,
            appliance: device.appliance,
            ratedPower: device.ratedPower,
            dateAdded: device.dateAdded,
            meterNumber: device.meterNumber,
            relayStatus: isCurrentlyOn ? 'OFF' : 'ON',
          );

          devices[index] = updatedDevice;

          // Also update in readings
          final readingIndex = readings.indexWhere((r) => r.applianceInfo.id == device.id);
          if (readingIndex >= 0) {
            readings[readingIndex] = readings[readingIndex].copyWithApplianceInfo(updatedDevice);
          }

          // Update device status in Firestore
          _updateDeviceStatusInFirestore(device.id.toString(), !isCurrentlyOn);
        }

        // Show success message
        Get.snackbar(
          'Success',
          'Device ${isCurrentlyOn ? 'turned off' : 'turned on'} successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        return true;
      } else {
        showErrorSnackbar('Error', 'Failed to toggle device');
        return false;
      }
    } catch (e) {
      DevLogs.logError('Failed to toggle device: $e');
      showErrorSnackbar('Error', 'Failed to toggle device: $e');
      return false;
    } finally {
      deviceControlLoading[device.id] = false;
    }
  }

  Future<void> _updateDeviceStatusInFirestore(String deviceId, bool isActive) async {
    try {
      final homeId = await _firestoreService.getCurrentHomeId();
      if (homeId != null) {
        await _firestoreService.updateDeviceStatus(
          homeId: homeId,
          deviceId: deviceId,
          isActive: isActive,
        );
      }
    } catch (e) {
      DevLogs.logError('Error updating device status in Firestore: $e');
      // Don't throw, as this is a background operation
    }
  }

  // Check if a device is currently being controlled
  bool isDeviceControlLoading(int deviceId) {
    return deviceControlLoading[deviceId] ?? false;
  }

  // Show error snackbar
  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
