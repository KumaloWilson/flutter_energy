import 'package:flutter_energy/core/core/utilities/logs.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/auth/services/auth_service.dart';

import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final RxBool isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      DevLogs.logInfo('Logging in with email: $email $password');
      isLoading.value = true;
      await _authService.login(email, password);
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      DevLogs.logError(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String email, String password, String name) async {
    try {
      isLoading.value = true;
      await _authService.signup(email, password, name);
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

