import 'package:get/get.dart';
import '../../../core/core/utilities/logs.dart';
import '../../auth/services/auth_service.dart';
import '../model/appliance.dart';
import '../model/room.dart';

class RoomController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxList<Room> rooms = <Room>[].obs;
  final Rx<Room?> selectedRoom = Rx<Room?>(null);
  final RxList<Appliance> appliances = <Appliance>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingAppliances = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();

    // Bind rooms stream
    rooms.bindStream(_firebaseService.roomsStream());

    // When selected room changes, fetch appliances
    ever(selectedRoom, (Room? room) {
      if (room != null) {
        fetchAppliancesInRoom(room.id);

        // Bind appliances stream
        appliances.bindStream(_firebaseService.appliancesInRoomStream(room.id));
      } else {
        appliances.clear();
      }
    });
  }

  Future<void> fetchRooms() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<Room> fetchedRooms = await _firebaseService.getRooms();
      rooms.value = fetchedRooms;

      // Select first room if available and none selected
      if (selectedRoom.value == null && fetchedRooms.isNotEmpty) {
        selectedRoom.value = fetchedRooms.first;
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch rooms: $e';
      DevLogs.logError('Fetch rooms error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAppliancesInRoom(String roomId) async {
    try {
      isLoadingAppliances.value = true;

      List<Appliance> fetchedAppliances = await _firebaseService.getAppliancesInRoom(roomId);
      appliances.value = fetchedAppliances;
    } catch (e) {
      DevLogs.logError('Fetch appliances error: $e');
    } finally {
      isLoadingAppliances.value = false;
    }
  }

  Future<void> addRoom(String name, String iconName, String imageUrl) async {
    try {
      Room newRoom = Room(
        id: '',
        name: name,
        iconName: iconName,
        deviceCount: 0,
        order: rooms.length,
        imageUrl: imageUrl,
      );

      await _firebaseService.addRoom(newRoom);
    } catch (e) {
      DevLogs.logError('Add room error: $e');
    }
  }

  Future<void> updateRoom(Room room) async {
    try {
      await _firebaseService.updateRoom(room);
    } catch (e) {
      DevLogs.logError('Update room error: $e');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _firebaseService.deleteRoom(roomId);

      // If deleted room was selected, select another room
      if (selectedRoom.value?.id == roomId) {
        if (rooms.isNotEmpty) {
          final otherRooms = rooms.where((room) => room.id != roomId).toList();
          selectedRoom.value = otherRooms.isNotEmpty ? otherRooms.first : null;
        } else {
          selectedRoom.value = null;
        }
      }

    } catch (e) {
      DevLogs.logError('Delete room error: $e');
    }
  }

  Future<void> addAppliance(String name, String type, String iconName) async {
    try {
      if (selectedRoom.value == null) return;

      Appliance newAppliance = Appliance(
        id: '',
        name: name,
        type: type,
        iconName: iconName,
        status: 'Connected',
        power: 0.0,
        voltage: 220.0,
        current: 0.0,
        lastUpdated: DateTime.now(),
        isOn: false,
      );

      await _firebaseService.addAppliance(selectedRoom.value!.id, newAppliance);

      // Update device count in room
      Room updatedRoom = selectedRoom.value!.copyWith(
        deviceCount: selectedRoom.value!.deviceCount + 1,
      );
      await _firebaseService.updateRoom(updatedRoom);
    } catch (e) {
      DevLogs.logError('Add appliance error: $e');
    }
  }

  Future<void> updateAppliance(Appliance appliance) async {
    try {
      if (selectedRoom.value == null) return;

      await _firebaseService.updateAppliance(selectedRoom.value!.id, appliance);
    } catch (e) {
      DevLogs.logError('Update appliance error: $e');
    }
  }

  Future<void> deleteAppliance(String applianceId) async {
    try {
      if (selectedRoom.value == null) return;

      await _firebaseService.deleteAppliance(selectedRoom.value!.id, applianceId);

      // Update device count in room
      Room updatedRoom = selectedRoom.value!.copyWith(
        deviceCount: selectedRoom.value!.deviceCount - 1,
      );
      await _firebaseService.updateRoom(updatedRoom);
    } catch (e) {
      DevLogs.logError('Delete appliance error: $e');
    }
  }

  void selectRoom(Room room) {
    selectedRoom.value = room;
  }
}
