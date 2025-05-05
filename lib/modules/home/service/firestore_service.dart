import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_energy/modules/home/models/room_model.dart';
import 'package:flutter_energy/modules/home/models/home_model.dart';
import 'package:flutter_energy/core/utilities/logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Home methods
  Future<HomeModel?> getUserHome(String userId) async {
    try {
      final homeSnapshot = await _firestore
          .collection('homes')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (homeSnapshot.docs.isNotEmpty) {
        final doc = homeSnapshot.docs.first;
        return HomeModel(
          id: doc.id,
          name: doc['name'],
          meterNumber: doc['meterNumber'],
          currentReading: doc['currentReading']?.toDouble() ?? 0.0,
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      DevLogs.logError('Error getting user home: $e');
      return null;
    }
  }

  Future<String> createHome({
    required String userId,
    required String name,
    required String meterNumber,
  }) async {
    try {
      final docRef = await _firestore.collection('homes').add({
        'userId': userId,
        'name': name,
        'meterNumber': meterNumber,
        'currentReading': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      DevLogs.logError('Error creating home: $e');
      throw Exception('Failed to create home: $e');
    }
  }

  Future<void> updateMeterReading({
    required String homeId,
    required double reading,
  }) async {
    try {
      await _firestore.collection('homes').doc(homeId).update({
        'currentReading': reading,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      DevLogs.logError('Error updating meter reading: $e');
      throw Exception('Failed to update meter reading: $e');
    }
  }

  // Room methods
  Future<List<RoomModel>> getRooms(String homeId) async {
    try {
      final roomsSnapshot = await _firestore
          .collection('homes')
          .doc(homeId)
          .collection('rooms')
          .get();

      return roomsSnapshot.docs.map((doc) {
        return RoomModel(
          id: doc.id,
          name: doc['name'],
          homeId: homeId,
          // createdAt: (doc['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      DevLogs.logError('Error getting rooms: $e');
      return [];
    }
  }

  Future<RoomModel> createRoom({
    required String homeId,
    required String name,
  }) async {
    try {
      final docRef = await _firestore
          .collection('homes')
          .doc(homeId)
          .collection('rooms')
          .add({
        'name': name,
        'homeId': homeId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return RoomModel(
        id: docRef.id,
        name: name,
        homeId: homeId,
        //createdAt: DateTime.now(),
      );
    } catch (e) {
      DevLogs.logError('Error creating room: $e');
      throw Exception('Failed to create room: $e');
    }
  }

  Future<String> getDefaultRoomId(String homeId) async {
    try {
      final rooms = await getRooms(homeId);
      if (rooms.isNotEmpty) {
        return rooms.first.id;
      }

      // Create a default room if none exists
      final defaultRoom = await createRoom(
        homeId: homeId,
        name: 'Default Room',
      );
      return defaultRoom.id;
    } catch (e) {
      DevLogs.logError('Error getting default room: $e');
      throw Exception('Failed to get default room: $e');
    }
  }

  // Device-room mapping methods
  Future<Map<String, String>> getDeviceRoomMappings(String homeId) async {
    try {
      final mappingsSnapshot = await _firestore
          .collection('homes')
          .doc(homeId)
          .collection('device_mappings')
          .get();

      final Map<String, String> mappings = {};
      for (final doc in mappingsSnapshot.docs) {
        mappings[doc.id] = doc['roomId'];
      }
      return mappings;
    } catch (e) {
      DevLogs.logError('Error getting device mappings: $e');
      return {};
    }
  }

  Future<void> assignDeviceToRoom({
    required String homeId,
    required String deviceId,
    required String roomId,
    required String deviceName,
    required String deviceType,
    required String meterNumber,
  }) async {
    try {
      await _firestore
          .collection('homes')
          .doc(homeId)
          .collection('device_mappings')
          .doc(deviceId)
          .set({
        'roomId': roomId,
        'deviceName': deviceName,
        'deviceType': deviceType,
        'meterNumber': meterNumber,
        'isActive': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      DevLogs.logError('Error assigning device to room: $e');
      throw Exception('Failed to assign device to room: $e');
    }
  }

  Future<void> updateDeviceStatus({
    required String homeId,
    required String deviceId,
    required bool isActive,
  }) async {
    try {
      await _firestore
          .collection('homes')
          .doc(homeId)
          .collection('device_mappings')
          .doc(deviceId)
          .update({
        'isActive': isActive,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      DevLogs.logError('Error updating device status: $e');
      // Don't throw, as this is a background operation
    }
  }

  Future<String?> getCurrentHomeId() async {
    try {
      // This would typically come from a user preferences service
      // For now, we'll just get the first home
      final homesSnapshot = await _firestore
          .collection('homes')
          .limit(1)
          .get();

      if (homesSnapshot.docs.isNotEmpty) {
        return homesSnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      DevLogs.logError('Error getting current home ID: $e');
      return null;
    }
  }
}
