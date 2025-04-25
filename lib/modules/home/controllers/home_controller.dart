import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_energy/core/utilities/logger.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/modules/home/models/room_model.dart';
import 'package:flutter_energy/modules/home/models/home_model.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  final Rx<HomeModel?> currentHome = Rx<HomeModel?>(null);
  final RxList<RoomModel> rooms = <RoomModel>[].obs;
  final RxMap<String, List<ApplianceReading>> appliancesByRoom = <String, List<ApplianceReading>>{}.obs;
  
  final Rx<RoomModel?> selectedRoom = Rx<RoomModel?>(null);
  
  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    fetchRooms();
  }
  
  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      if (_authController.currentUser.value == null) {
        hasError.value = true;
        errorMessage.value = 'User not logged in';
        return;
      }
      
      final homeId = _authController.currentUser.value!.homeId;
      final homeDoc = await _firestore.collection('homes').doc(homeId).get();
      
      if (homeDoc.exists) {
        currentHome.value = HomeModel.fromMap(homeDoc.data()!, homeDoc.id);
      } else {
        hasError.value = true;
        errorMessage.value = 'Home not found';
      }
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
      isLoading.value = true;
      
      if (_authController.currentUser.value == null) return;
      
      final homeId = _authController.currentUser.value!.homeId;
      final roomsSnapshot = await _firestore
          .collection('rooms')
          .where('homeId', isEqualTo: homeId)
          .orderBy('name')
          .get();
      
      rooms.value = roomsSnapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Fetch appliances for each room
      for (final room in rooms) {
        await fetchAppliancesForRoom(room.id);
      }
      
      // Select first room by default if available
      if (rooms.isNotEmpty && selectedRoom.value == null) {
        selectedRoom.value = rooms.first;
      }
    } catch (e) {
      DevLogs.logError('Error fetching rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> fetchAppliancesForRoom(String roomId) async {
    try {
      final appliancesSnapshot = await _firestore
          .collection('appliances')
          .where('roomId', isEqualTo: roomId)
          .get();
      
      final appliances = appliancesSnapshot.docs
          .map((doc) {
            final data = doc.data();
            final applianceInfo = ApplianceInfo(
              id: int.parse(doc.id),
              appliance: data['name'] ?? '',
              ratedPower: data['ratedPower'] ?? '0 W',
              dateAdded: (data['createdAt'] as Timestamp).toDate(),
            );
            
            return ApplianceReading(
              id: int.parse(doc.id),
              applianceInfo: applianceInfo,
              voltage: data['voltage'] ?? '0',
              current: data['current'] ?? '0',
              timeOn: data['timeOn'] ?? '0',
              activeEnergy: data['activeEnergy'] ?? '0',
              readingTimeStamp: (data['lastReading'] as Timestamp).toDate(),
            );
          })
          .toList();
      
      appliancesByRoom[roomId] = appliances;
    } catch (e) {
      DevLogs.logError('Error fetching appliances for room $roomId: $e');
    }
  }
  
  void selectRoom(RoomModel room) {
    selectedRoom.value = room;
  }
  
  Future<bool> addRoom(String name) async {
    try {
      isLoading.value = true;
      
      if (_authController.currentUser.value == null) return false;
      
      final homeId = _authController.currentUser.value!.homeId;
      
      // Check if room with same name exists
      final existingRooms = await _firestore
          .collection('rooms')
          .where('homeId', isEqualTo: homeId)
          .where('name', isEqualTo: name)
          .get();
      
      if (existingRooms.docs.isNotEmpty) {
        errorMessage.value = 'A room with this name already exists';
        return false;
      }
      
      // Add new room
      final roomRef = await _firestore.collection('rooms').add({
        'name': name,
        'homeId': homeId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Refresh rooms list
      await fetchRooms();
      
      // Select the newly created room
      final newRoom = rooms.firstWhere((room) => room.id == roomRef.id);
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
      
      await _firestore.collection('homes').doc(currentHome.value!.id).update({
        'currentReading': reading,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Refresh home data
      await fetchHomeData();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to update meter reading';
      DevLogs.logError('Error updating meter reading: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> addAppliance(String name, String ratedPower, String roomId) async {
    try {
      isLoading.value = true;
      
      if (_authController.currentUser.value == null) return false;
      
      // Add new appliance
      await _firestore.collection('appliances').add({
        'name': name,
        'ratedPower': '$ratedPower W',
        'roomId': roomId,
        'homeId': _authController.currentUser.value!.homeId,
        'voltage': '220',
        'current': '0',
        'timeOn': '0',
        'activeEnergy': '0',
        'createdAt': FieldValue.serverTimestamp(),
        'lastReading': FieldValue.serverTimestamp(),
      });
      
      // Refresh appliances for this room
      await fetchAppliancesForRoom(roomId);
      
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to add appliance';
      DevLogs.logError('Error adding appliance: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> moveApplianceToRoom(String applianceId, String newRoomId) async {
    try {
      isLoading.value = true;
      
      await _firestore.collection('appliances').doc(applianceId).update({
        'roomId': newRoomId,
      });
      
      // Refresh appliances for both rooms
      final oldRoomId = appliancesByRoom.entries
          .firstWhere((entry) => entry.value.any((a) => a.id.toString() == applianceId))
          .key;
      
      await fetchAppliancesForRoom(oldRoomId);
      await fetchAppliancesForRoom(newRoomId);
      
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to move appliance';
      DevLogs.logError('Error moving appliance: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
