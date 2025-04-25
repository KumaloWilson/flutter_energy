import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/core/utilities/logs.dart';
import '../../../routes/app_pages.dart';
import '../model/user_profile.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to auth state changes
    firebaseUser.bindStream(_firebaseService.authStateChanges());

    // Listen to user profile changes
    ever(firebaseUser, _setInitialScreen);

    // Bind user profile stream when user is logged in
    ever(firebaseUser, (User? user) {
      if (user != null) {
        userProfile.bindStream(_firebaseService.userProfileStream());
      } else {
        userProfile.value = null;
      }
    });
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firebaseService.signIn(email, password);
    } catch (e) {
      errorMessage.value = _getAuthErrorMessage(e);
      DevLogs.logError('Login error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firebaseService.signUp(email, password, name);
    } catch (e) {
      errorMessage.value = _getAuthErrorMessage(e);
      DevLogs.logError('Register error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      DevLogs.logError('Logout error: $e');
    }
  }

  Future<void> updateProfile(String name, String? photoUrl) async {
    try {
      if (userProfile.value == null) return;

      UserProfile updatedProfile = userProfile.value!.copyWith(
        name: name,
        photoUrl: photoUrl,
      );

      await _firebaseService.updateUserProfile(updatedProfile);
    } catch (e) {
      DevLogs.logError('Update profile error: $e');
    }
  }

  Future<void> updateTheme(String themeColor) async {
    try {
      if (firebaseUser.value == null) return;

      await _firebaseService.updateUserTheme(
        firebaseUser.value!.uid,
        themeColor,
      );
    } catch (e) {
      DevLogs.logError('Update theme error: $e');
    }
  }

  String _getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        default:
          return 'Authentication failed: ${error.message}';
      }
    }
    return 'An unexpected error occurred.';
  }

  bool get isLoggedIn => firebaseUser.value != null;
  bool get isOwner => userProfile.value?.isOwner ?? false;
  bool get isAdmin => userProfile.value?.isAdmin ?? false;
  bool get canEditDevices => userProfile.value?.canEditDevices ?? false;
}
