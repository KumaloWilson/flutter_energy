import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/core/utilities/logs.dart';
import '../../meter/model/meter.dart';
import '../../rooms/model/appliance.dart';
import '../../rooms/model/room.dart';
import '../model/user_profile.dart';



class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth methods
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      DevLogs.logError('Sign in error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'owner', // Default role
        'themeColor': 'blue', // Default theme
      });

      return userCredential;
    } catch (e) {
      DevLogs.logError('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      DevLogs.logError('Sign out error: $e');
      rethrow;
    }
  }

  // User profile methods
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      DevLogs.logError('Get user profile error: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).update(profile.toMap());
    } catch (e) {
      DevLogs.logError('Update user profile error: $e');
      rethrow;
    }
  }

  Future<void> updateUserTheme(String userId, String themeColor) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'themeColor': themeColor,
      });
    } catch (e) {
      DevLogs.logError('Update user theme error: $e');
      rethrow;
    }
  }

  // Family access methods
  Future<void> addFamilyMember(String email, String role) async {
    try {
      String ownerId = _auth.currentUser!.uid;

      // Check if user exists
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      String memberId = userQuery.docs.first.id;

      // Add to family group
      await _firestore.collection('families').doc(ownerId).collection('members').doc(memberId).set({
        'role': role,
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Update user's role
      await _firestore.collection('users').doc(memberId).update({
        'connectedTo': ownerId,
      });
    } catch (e) {
      DevLogs.logError('Add family member error: $e');
      rethrow;
    }
  }

  Future<List<UserProfile>> getFamilyMembers() async {
    try {
      String ownerId = _auth.currentUser!.uid;

      QuerySnapshot membersSnapshot = await _firestore
          .collection('families')
          .doc(ownerId)
          .collection('members')
          .get();

      List<UserProfile> members = [];

      for (var doc in membersSnapshot.docs) {
        String memberId = doc.id;
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(memberId).get();

        if (userDoc.exists) {
          UserProfile profile = UserProfile.fromMap(
            userDoc.data() as Map<String, dynamic>,
            userDoc.id,
          );
          // Add role from family document
          profile.role = (doc.data() as Map<String, dynamic>)['role'] ?? 'member';
          members.add(profile);
        }
      }

      return members;
    } catch (e) {
      DevLogs.logError('Get family members error: $e');
      return [];
    }
  }

  // Room methods
  Future<List<Room>> getRooms() async {
    try {
      String userId = _auth.currentUser!.uid;

      QuerySnapshot roomsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .orderBy('order')
          .get();

      return roomsSnapshot.docs.map((doc) {
        return Room.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      DevLogs.logError('Get rooms error: $e');
      return [];
    }
  }

  Future<void> addRoom(Room room) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .add(room.toMap());
    } catch (e) {
      DevLogs.logError('Add room error: $e');
      rethrow;
    }
  }

  Future<void> updateRoom(Room room) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .doc(room.id)
          .update(room.toMap());
    } catch (e) {
      DevLogs.logError('Update room error: $e');
      rethrow;
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      String userId = _auth.currentUser!.uid;

      // Delete all appliances in the room first
      QuerySnapshot appliancesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .doc(roomId)
          .collection('appliances')
          .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in appliancesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the room
      batch.delete(_firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .doc(roomId));

      await batch.commit();
    } catch (e) {
      DevLogs.logError('Delete room error: $e');
      rethrow;
    }
  }

  // Appliance methods
  Future<List<Appliance>> getAppliancesInRoom(String roomId) async {
    try {
      String userId = _auth.currentUser!.uid;

      QuerySnapshot appliancesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .doc(roomId)
          .collection('appliances')
          .get();

      return appliancesSnapshot.docs.map((doc) {
        return Appliance.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      DevLogs.logError('Get appliances error: $e');
      return [];
    }
  }

  Future<void> addAppliance(String roomId, Appliance appliance) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .doc(roomId)
          .collection('appliances')
          .add(appliance.toMap());
    } catch (e) {
      DevLogs.logError('Add appliance error: $e');
      rethrow;
    }
  }

  Future<void> updateAppliance(String roomId, Appliance appliance) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .doc(roomId)
          .collection('appliances')
          .doc(appliance.id)
          .update(appliance.toMap());
    } catch (e) {
      DevLogs.logError('Update appliance error: $e');
      rethrow;
    }
  }

  Future<void> deleteAppliance(String roomId, String applianceId) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .doc(roomId)
          .collection('appliances')
          .doc(applianceId)
          .delete();
    } catch (e) {
      DevLogs.logError('Delete appliance error: $e');
      rethrow;
    }
  }

  // Meter methods
  Future<Meter?> getMeterInfo() async {
    try {
      String userId = _auth.currentUser!.uid;

      DocumentSnapshot meterDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meters')
          .doc('primary')
          .get();

      if (meterDoc.exists) {
        return Meter.fromMap(meterDoc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      DevLogs.logError('Get meter info error: $e');
      return null;
    }
  }

  Future<void> updateMeterInfo(Meter meter) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meters')
          .doc('primary')
          .set(meter.toMap());
    } catch (e) {
      DevLogs.logError('Update meter info error: $e');
      rethrow;
    }
  }

  // Stream methods for real-time updates
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Stream<UserProfile?> userProfileStream() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromMap(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
      }
      return null;
    });
  }

  Stream<List<Room>> roomsStream() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('rooms')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Room.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Appliance>> appliancesInRoomStream(String roomId) {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('rooms')
        .doc(roomId)
        .collection('appliances')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Appliance.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
