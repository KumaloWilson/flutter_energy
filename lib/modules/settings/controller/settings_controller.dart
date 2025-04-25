import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/core/utilities/logger.dart';
import 'package:flutter_energy/modules/auth/models/user_model.dart';
import 'package:flutter_energy/core/theme/app_colors.dart';

class SettingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  
  final RxBool notificationsEnabled = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Theme settings
  final RxString selectedTheme = 'system'.obs; // 'light', 'dark', 'system'
  final Rx<CustomColors> customColors = CustomColors().obs;
  
  // Energy settings
  final RxDouble energyRate = 0.12.obs;
  final RxDouble dailyEnergyTarget = 30.0.obs;
  
  // Family members
  final RxList<UserModel> familyMembers = <UserModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSettings();
    fetchFamilyMembers();
  }
  
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme settings
      selectedTheme.value = prefs.getString('theme') ?? 'system';
      
      // Load custom colors if available
      final primaryHex = prefs.getString('primaryColor');
      final secondaryHex = prefs.getString('secondaryColor');
      final accentHex = prefs.getString('accentColor');
      
      if (primaryHex != null && secondaryHex != null && accentHex != null) {
        customColors.value = CustomColors(
          primary: Color(int.parse(primaryHex)),
          secondary: Color(int.parse(secondaryHex)),
          accent: Color(int.parse(accentHex)),
        );
      }
      
      // Load other settings
      notificationsEnabled.value = prefs.getBool('notifications') ?? true;
      energyRate.value = prefs.getDouble('energyRate') ?? 0.12;
      dailyEnergyTarget.value = prefs.getDouble('dailyTarget') ?? 30.0;
    } catch (e) {
      DevLogs.logError('Error loading settings: $e');
    }
  }
  
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save theme settings
      await prefs.setString('theme', selectedTheme.value);
      
      // Save custom colors
      await prefs.setString('primaryColor', customColors.value.primary.value.toString());
      await prefs.setString('secondaryColor', customColors.value.secondary.value.toString());
      await prefs.setString('accentColor', customColors.value.accent.value.toString());
      
      // Save other settings
      await prefs.setBool('notifications', notificationsEnabled.value);
      await prefs.setDouble('energyRate', energyRate.value);
      await prefs.setDouble('dailyTarget', dailyEnergyTarget.value);
    } catch (e) {
      DevLogs.logError('Error saving settings: $e');
    }
  }
  
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    saveSettings();
  }
  
  void setTheme(String theme) {
    selectedTheme.value = theme;
    saveSettings();
  }
  
  void setCustomColors(Color primary, Color secondary, Color accent) {
    customColors.value = CustomColors(
      primary: primary,
      secondary: secondary,
      accent: accent,
    );
    saveSettings();
  }
  
  Future<void> updateEnergyRate(double rate) async {
    energyRate.value = rate;
    await saveSettings();
  }
  
  Future<void> updateDailyTarget(double target) async {
    dailyEnergyTarget.value = target;
    await saveSettings();
  }
  
  Future<void> fetchFamilyMembers() async {
    try {
      isLoading.value = true;
      
      if (_authController.currentUser.value == null) return;
      
      final String homeId = _authController.currentUser.value!.homeId;
      final snapshot = await _firestore
          .collection('users')
          .where('homeId', isEqualTo: homeId)
          .get();
      
      familyMembers.value = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      DevLogs.logError('Error fetching family members: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> addFamilyMember(String email, String role) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _authController.addFamilyMember(email, role);
      if (result) {
        await fetchFamilyMembers();
        return true;
      }
      
      errorMessage.value = 'Failed to add family member';
      return false;
    } catch (e) {
      errorMessage.value = 'An error occurred';
      DevLogs.logError('Error adding family member: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> removeFamilyMember(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _authController.removeFamilyMember(userId);
      if (result) {
        await fetchFamilyMembers();
        return true;
      }
      
      errorMessage.value = 'Failed to remove family member';
      return false;
    } catch (e) {
      errorMessage.value = 'An error occurred';
      DevLogs.logError('Error removing family member: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> updateProfile(String name) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _authController.updateProfile(name);
      return result;
    } catch (e) {
      errorMessage.value = 'An error occurred';
      DevLogs.logError('Error updating profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
