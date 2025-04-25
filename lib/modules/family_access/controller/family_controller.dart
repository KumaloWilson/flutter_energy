import 'package:get/get.dart';

import '../../../core/core/utilities/logs.dart';
import '../../auth/model/user_profile.dart';
import '../../auth/services/auth_service.dart';


class FamilyController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxList<UserProfile> familyMembers = <UserProfile>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFamilyMembers();
  }

  Future<void> fetchFamilyMembers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<UserProfile> members = await _firebaseService.getFamilyMembers();
      familyMembers.value = members;
    } catch (e) {
      errorMessage.value = 'Failed to fetch family members: $e';
      DevLogs.logError('Fetch family members error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFamilyMember(String email, String role) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firebaseService.addFamilyMember(email, role);
      await fetchFamilyMembers();
    } catch (e) {
      errorMessage.value = 'Failed to add family member: $e';
      DevLogs.logError('Add family member error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMemberRole(String memberId, String newRole) async {
    try {
      isLoading.value = true;

      // Find the member
      UserProfile? member = familyMembers.firstWhereOrNull((m) => m.id == memberId);
      if (member == null) return;

      // Update role
      UserProfile updatedMember = member.copyWith(role: newRole);
      await _firebaseService.updateUserProfile(updatedMember);

      // Refresh list
      await fetchFamilyMembers();
    } catch (e) {
      DevLogs.logError('Update member role error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFamilyMember(String memberId) async {
    try {
      isLoading.value = true;

      // Find the member
      UserProfile? member = familyMembers.firstWhereOrNull((m) => m.id == memberId);
      if (member == null) return;

      // Update connectedTo to null
      UserProfile updatedMember = member.copyWith(connectedTo: null);
      await _firebaseService.updateUserProfile(updatedMember);

      // Refresh list
      await fetchFamilyMembers();
    } catch (e) {
      DevLogs.logError('Remove family member error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
