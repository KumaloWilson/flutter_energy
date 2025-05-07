import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/core/utilities/logger.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/modules/home/models/room_model.dart';
import 'package:flutter_energy/modules/home/models/home_model.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/modules/dashboard/services/api_service.dart';
import 'package:flutter_energy/modules/home/models/appliance_model.dart';

import '../service/firestore_service.dart';

class HomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final ApiService _apiService = Get.find<ApiService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<HomeModel?> currentHome = Rx<HomeModel?>(null);
  final RxList<RoomModel> rooms = <RoomModel>[].obs;
  final RxMap<String, List<ApplianceInfo>> devicesByRoom = <String, List<ApplianceInfo>>{}.obs;

  final Rx<RoomModel?> selectedRoom = Rx<RoomModel?>(null);
  final RxList<ApplianceInfo> allDevices = <ApplianceInfo>[].obs;

  // For device control
  final RxMap<int, bool> deviceControlLoading = <int, bool>{}.obs;

  // For device deletion and update
  final RxMap<int, bool> deviceActionLoading = <int, bool>{}.obs;

  // Add a flag to track if auth is initialized
  final RxBool isAuthInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listener for auth state changes
    ever(_authController.currentUser, _onAuthChanged);

    // Check if auth is already initialized
    if (_authController.currentUser.value != null) {
      isAuthInitialized.value = true;
      fetchHomeData();
    }
  }

  // Handle auth state changes
  void _onAuthChanged(user) {
    if (user != null && !isAuthInitialized.value) {
      isAuthInitialized.value = true;
      fetchHomeData();
    } else if (user == null) {
      // Handle logout if needed
      isAuthInitialized.value = false;
      currentHome.value = null;
      rooms.clear();
      devicesByRoom.clear();
      selectedRoom.value = null;
      allDevices.clear();
    }
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Make sure auth is initialized before proceeding
      if (!isAuthInitialized.value) {
        DevLogs.logInfo('Waiting for auth to initialize before fetching home data');
        // Don't set error here - we'll wait for auth to initialize through the listener
        return;
      }

      // Double check current user is available
      if (_authController.currentUser.value == null) {
        hasError.value = true;
        errorMessage.value = 'User not logged in';
        return;
      }

      // Get home data from Firestore
      final userId = _authController.currentUser.value!.id;
      final homeData = await _firestoreService.getUserHome(userId);

      if (homeData != null) {
        currentHome.value = homeData;
      } else {
        // Create default home if none exists
        final newHome = HomeModel(
          id: await _firestoreService.createHome(
            userId: userId,
            name: 'My Home',
            meterNumber: '12345',
          ),
          name: 'My Home',
          meterNumber: '12345',
          currentReading: 0.0,
          createdAt: DateTime.now(),
        );
        currentHome.value = newHome;
      }

      // Fetch rooms from Firestore
      await fetchRooms();

      // Fetch devices from API
      await fetchDevices();

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load home data';
      DevLogs.logError('Error fetching home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRooms() async {
    try {
      if (currentHome.value == null) return;

      final homeId = currentHome.value!.id;
      final roomsList = await _firestoreService.getRooms(homeId);

      if (roomsList.isEmpty) {
        // Create default rooms if none exist
        final defaultRooms = [
          await _firestoreService.createRoom(homeId: homeId, name: 'Living Room'),
          await _firestoreService.createRoom(homeId: homeId, name: 'Kitchen'),
          await _firestoreService.createRoom(homeId: homeId, name: 'Bedroom'),
          await _firestoreService.createRoom(homeId: homeId, name: 'Bathroom'),
        ];

        rooms.value = defaultRooms;
      } else {
        rooms.value = roomsList;
      }

      // Select first room by default if available
      if (rooms.isNotEmpty && selectedRoom.value == null) {
        selectedRoom.value = rooms.first;
      }
    } catch (e) {
      DevLogs.logError('Error fetching rooms: $e');
      // Don't set hasError here to allow partial data loading
    }
  }

  Future<void> fetchDevices() async {
    try {
      // Get all registered devices from API
      final devices = await _apiService.getRegisteredDevices();
      allDevices.value = devices;

      if (currentHome.value == null) return;

      // Get device-room mappings from Firestore
      final homeId = currentHome.value!.id;
      final deviceRoomMappings = await _firestoreService.getDeviceRoomMappings(homeId);

      // Organize devices by room based on Firestore mappings
      final Map<String, List<ApplianceInfo>> roomDevices = {};

      for (final room in rooms) {
        roomDevices[room.id] = [];
      }

      // First, assign devices based on Firestore mappings
      for (final device in devices) {
        final deviceId = device.id.toString();
        final roomId = deviceRoomMappings[deviceId];

        if (roomId != null && roomDevices.containsKey(roomId)) {
          roomDevices[roomId]!.add(device);
        } else {
          // If device not mapped to a room, assign to default room
          final defaultRoomId = rooms.isNotEmpty ? rooms.first.id : '';
          if (defaultRoomId.isNotEmpty) {
            roomDevices[defaultRoomId]!.add(device);

            // Update mapping in Firestore
            await _firestoreService.assignDeviceToRoom(
              homeId: homeId,
              deviceId: deviceId,
              roomId: defaultRoomId,
              deviceName: device.appliance,
              deviceType: _determineDeviceType(device.appliance),
              meterNumber: device.meterNumber,
            );
          }
        }
      }

      devicesByRoom.value = roomDevices;
    } catch (e) {
      DevLogs.logError('Error fetching devices: $e');
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

  void selectRoom(RoomModel room) {
    selectedRoom.value = room;
  }

  Future<bool> addRoom(String name) async {
    try {
      isLoading.value = true;

      if (currentHome.value == null) {
        errorMessage.value = 'No home selected';
        return false;
      }

      // Check if room with same name exists
      if (rooms.any((room) => room.name.toLowerCase() == name.toLowerCase())) {
        errorMessage.value = 'A room with this name already exists';
        return false;
      }

      // Add room to Firestore
      final homeId = currentHome.value!.id;
      final newRoom = await _firestoreService.createRoom(
        homeId: homeId,
        name: name,
      );

      rooms.add(newRoom);
      devicesByRoom[newRoom.id] = [];

      // Select the newly created room
      selectRoom(newRoom);

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to add room';
      DevLogs.logError('Error adding room: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMeterReading(double reading) async {
    try {
      isLoading.value = true;

      if (currentHome.value == null) return false;

      // Update meter reading in Firestore
      await _firestoreService.updateMeterReading(
        homeId: currentHome.value!.id,
        reading: reading,
      );

      // Update the current home model
      currentHome.value = HomeModel(
        id: currentHome.value!.id,
        name: currentHome.value!.name,
        meterNumber: currentHome.value!.meterNumber,
        currentReading: reading,
        createdAt: currentHome.value!.createdAt,
        lastUpdated: DateTime.now(),
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to update meter reading';
      DevLogs.logError('Error updating meter reading: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAppliance(String name, String ratedPower, String meterNumber) async {
    try {
      isLoading.value = true;

      // Call the API to add the device
      final success = await _apiService.addDevice(
        name: name,
        ratedPower: ratedPower,
        meterNumber: meterNumber,
      );

      if (success) {
        // Refresh devices list
        await fetchDevices();

        Get.snackbar(
          'Success',
          'Appliance added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        return true;
      } else {
        errorMessage.value = 'Failed to add appliance';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to add appliance';
      DevLogs.logError('Error adding appliance: $e');

      Get.snackbar(
        'Error',
        'Failed to add appliance: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAppliance(ApplianceInfo device) async {
    try {
      deviceActionLoading[device.id] = true;

      if (device.meterNumber.isEmpty) {
        throw Exception('Device has no meter number');
      }

      // Delete from API
      final success = await _apiService.deleteDevice(device.meterNumber);

      if (success) {
        // Remove from Firestore
        if (currentHome.value != null) {
          await _firestoreService.removeDeviceFromRoom(
            homeId: currentHome.value!.id,
            deviceId: device.id.toString(),
          );
        }

        // Remove from local lists
        allDevices.removeWhere((d) => d.id == device.id);

        // Remove from room devices
        for (final roomId in devicesByRoom.keys) {
          devicesByRoom[roomId]!.removeWhere((d) => d.id == device.id);
        }

        // Refresh UI
        devicesByRoom.refresh();

        Get.snackbar(
          'Success',
          'Device deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      DevLogs.logError('Failed to delete device: $e');
      Get.snackbar(
        'Error',
        'Failed to delete device: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      deviceActionLoading.remove(device.id);
    }
  }

  Future<bool> updateAppliance(ApplianceInfo device, {String? newName, String? newRatedPower}) async {
    try {
      deviceActionLoading[device.id] = true;

      if (device.meterNumber.isEmpty) {
        throw Exception('Device has no meter number');
      }

      // Update in API
      final success = await _apiService.updateDevice(
        meterNumber: device.meterNumber,
        deviceName: newName,
        ratedPower: newRatedPower,
      );

      if (success) {
        // Update in local lists
        final updatedDevice = ApplianceInfo(
          id: device.id,
          appliance: newName ?? device.appliance,
          ratedPower: newRatedPower ?? device.ratedPower,
          dateAdded: device.dateAdded,
          meterNumber: device.meterNumber,
          relayStatus: device.relayStatus,
        );

        // Update in all devices
        final index = allDevices.indexWhere((d) => d.id == device.id);
        if (index >= 0) {
          allDevices[index] = updatedDevice;
        }

        // Update in room devices
        for (final roomId in devicesByRoom.keys) {
          final roomDevices = devicesByRoom[roomId]!;
          final deviceIndex = roomDevices.indexWhere((d) => d.id == device.id);

          if (deviceIndex >= 0) {
            roomDevices[deviceIndex] = updatedDevice;
          }
        }

        // Update in Firestore if name changed
        if (newName != null && currentHome.value != null) {
          await _firestoreService.updateDeviceName(
            homeId: currentHome.value!.id,
            deviceId: device.id.toString(),
            newName: newName,
          );
        }

        // Refresh UI
        devicesByRoom.refresh();

        Get.snackbar(
          'Success',
          'Device updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      DevLogs.logError('Failed to update device: $e');
      Get.snackbar(
        'Error',
        'Failed to update device: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      deviceActionLoading.remove(device.id);
    }
  }

  Future<bool> assignDeviceToRoom(int deviceId, String roomId) async {
    try {
      isLoading.value = true;

      if (currentHome.value == null) return false;

      // Find the device in all devices
      final device = allDevices.firstWhereOrNull((d) => d.id == deviceId);
      if (device == null) return false;

      // Update mapping in Firestore
      await _firestoreService.assignDeviceToRoom(
        homeId: currentHome.value!.id,
        deviceId: deviceId.toString(),
        roomId: roomId,
        deviceName: device.appliance,
        deviceType: _determineDeviceType(device.appliance),
        meterNumber: device.meterNumber,
      );

      // Remove from current room if it exists in any
      for (final entry in devicesByRoom.entries) {
        final roomDevices = entry.value;
        final deviceIndex = roomDevices.indexWhere((d) => d.id == deviceId);

        if (deviceIndex >= 0) {
          roomDevices.removeAt(deviceIndex);
        }
      }

      // Add to new room
      if (!devicesByRoom.containsKey(roomId)) {
        devicesByRoom[roomId] = [];
      }

      devicesByRoom[roomId]!.add(device);

      // Update the UI
      devicesByRoom.refresh();

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to assign device to room';
      DevLogs.logError('Error assigning device to room: $e');
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
        final index = allDevices.indexWhere((d) => d.id == device.id);
        if (index >= 0) {
          final updatedDevice = ApplianceInfo(
            id: device.id,
            appliance: device.appliance,
            ratedPower: device.ratedPower,
            dateAdded: device.dateAdded,
            meterNumber: device.meterNumber,
            relayStatus: isCurrentlyOn ? 'OFF' : 'ON',
          );

          allDevices[index] = updatedDevice;

          // Update in room devices
          for (final roomId in devicesByRoom.keys) {
            final roomDevices = devicesByRoom[roomId]!;
            final deviceIndex = roomDevices.indexWhere((d) => d.id == device.id);

            if (deviceIndex >= 0) {
              roomDevices[deviceIndex] = updatedDevice;
            }
          }

          // Update device status in Firestore
          if (currentHome.value != null) {
            await _firestoreService.updateDeviceStatus(
              homeId: currentHome.value!.id,
              deviceId: device.id.toString(),
              isActive: !isCurrentlyOn,
            );
          }
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
        Get.snackbar(
          'Error',
          'Failed to toggle device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      DevLogs.logError('Failed to toggle device: $e');
      Get.snackbar(
        'Error',
        'Failed to toggle device: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      deviceControlLoading[device.id] = false;
    }
  }

  // Check if a device is currently being controlled
  bool isDeviceControlLoading(int deviceId) {
    return deviceControlLoading[deviceId] ?? false;
  }

  // Check if a device is currently being edited or deleted
  bool isDeviceActionLoading(int deviceId) {
    return deviceActionLoading[deviceId] ?? false;
  }

  // Add this method to get the list of rooms for dropdown selection
  List<DropdownMenuItem<String>> getRoomDropdownItems() {
    return rooms.map((room) {
      return DropdownMenuItem<String>(
        value: room.id,
        child: Text(room.name),
      );
    }).toList();
  }
}
