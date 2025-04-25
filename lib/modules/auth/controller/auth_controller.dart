import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_energy/core/utilities/logger.dart';
import 'package:flutter_energy/routes/app_pages.dart';
import 'package:flutter_energy/modules/auth/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxList<UserModel> familyMembers = <UserModel>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkUserLoggedIn();

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        isLoggedIn.value = true;
        fetchUserData(user.uid);
        fetchFamilyMembers();
      } else {
        isLoggedIn.value = false;
        currentUser.value = null;
        familyMembers.clear();
      }
    });
  }

  Future<void> checkUserLoggedIn() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        isLoggedIn.value = true;
        await fetchUserData(user.uid);
      }
    } catch (e) {
      DevLogs.logError('Error checking logged in user: $e');
    }
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data()!, doc.id);

        // Save user preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', uid);
        await prefs.setString('user_name', currentUser.value?.name ?? '');
      } else {
        DevLogs.logError('User document does not exist');
      }
    } catch (e) {
      DevLogs.logError('Error fetching user data: $e');
    }
  }

  Future<void> fetchFamilyMembers() async {
    try {
      if (currentUser.value == null) return;

      final String homeId = currentUser.value!.homeId;
      final snapshot = await _firestore
          .collection('users')
          .where('homeId', isEqualTo: homeId)
          .get();

      familyMembers.value = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      DevLogs.logError('Error fetching family members: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await fetchUserData(userCredential.user!.uid);
        await fetchFamilyMembers();
        Get.offAllNamed(Routes.HOME);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
      return false;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      DevLogs.logError('Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signup(String email, String password, String name, String meterNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create a new home
        final homeRef = await _firestore.collection('homes').add({
          'name': '$name\'s Home',
          'createdAt': FieldValue.serverTimestamp(),
          'meterNumber': meterNumber,
          'currentReading': 0,
        });

        // Create user document
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'homeId': homeRef.id,
          'role': 'owner',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Create default rooms
        final rooms = ['Living Room', 'Kitchen', 'Bedroom', 'Bathroom'];
        for (final room in rooms) {
          await _firestore.collection('rooms').add({
            'name': room,
            'homeId': homeRef.id,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await fetchUserData(userCredential.user!.uid);
        Get.offAllNamed(Routes.HOME);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
      return false;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      DevLogs.logError('Signup error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // First time Google sign-in, redirect to complete profile
          Get.toNamed(Routes.COMPLETE_PROFILE, arguments: {
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName,
          });
          return true;
        }

        // Existing user, update last login
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        await fetchUserData(user.uid);
        await fetchFamilyMembers();
        Get.offAllNamed(Routes.HOME);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to sign in with Google';
      DevLogs.logError('Google sign in error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeProfile(String uid, String name, String meterNumber) async {
    try {
      isLoading.value = true;

      // Create a new home
      final homeRef = await _firestore.collection('homes').add({
        'name': '$name\'s Home',
        'createdAt': FieldValue.serverTimestamp(),
        'meterNumber': meterNumber,
        'currentReading': 0,
      });

      // Update user document
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': _auth.currentUser?.email,
        'homeId': homeRef.id,
        'role': 'owner',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Create default rooms
      final rooms = ['Living Room', 'Kitchen', 'Bedroom', 'Bathroom'];
      for (final room in rooms) {
        await _firestore.collection('rooms').add({
          'name': room,
          'homeId': homeRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await fetchUserData(uid);
      await fetchFamilyMembers();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      errorMessage.value = 'Failed to complete profile';
      DevLogs.logError('Complete profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      DevLogs.logError('Logout error: $e');
    }
  }

  Future<bool> addFamilyMember(String email, String role) async {
    try {
      isLoading.value = true;

      if (currentUser.value == null) return false;

      // Check if email exists
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // User exists, update their homeId
        await _firestore.collection('users').doc(userQuery.docs.first.id).update({
          'homeId': currentUser.value!.homeId,
          'role': role,
        });
      } else {
        // Create invitation
        await _firestore.collection('invitations').add({
          'email': email,
          'homeId': currentUser.value!.homeId,
          'invitedBy': currentUser.value!.id,
          'role': role,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await fetchFamilyMembers();
      return true;
    } catch (e) {
      DevLogs.logError('Add family member error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> removeFamilyMember(String userId) async {
    try {
      isLoading.value = true;

      // Only owners can remove family members
      if (currentUser.value?.role != 'owner') {
        errorMessage.value = 'Only the owner can remove family members';
        return false;
      }

      // Remove user from home
      await _firestore.collection('users').doc(userId).update({
        'homeId': '',
        'role': '',
      });

      await fetchFamilyMembers();
      return true;
    } catch (e) {
      DevLogs.logError('Remove family member error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(String name) async {
    try {
      isLoading.value = true;

      if (currentUser.value == null) return false;

      await _firestore.collection('users').doc(currentUser.value!.id).update({
        'name': name,
      });

      await fetchUserData(currentUser.value!.id);
      return true;
    } catch (e) {
      DevLogs.logError('Update profile error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMeterReading(double reading) async {
    try {
      isLoading.value = true;

      if (currentUser.value == null) return false;

      await _firestore.collection('homes').doc(currentUser.value!.homeId).update({
        'currentReading': reading,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      DevLogs.logError('Update meter reading error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        errorMessage.value = 'No user found with this email';
        break;
      case 'wrong-password':
        errorMessage.value = 'Wrong password';
        break;
      case 'email-already-in-use':
        errorMessage.value = 'Email is already in use';
        break;
      case 'weak-password':
        errorMessage.value = 'Password is too weak';
        break;
      case 'invalid-email':
        errorMessage.value = 'Invalid email format';
        break;
      default:
        errorMessage.value = 'Authentication failed: ${e.message}';
    }
    DevLogs.logError('Auth error: ${e.code} - ${e.message}');
  }
}
