import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxBool darkMode = false.obs;
  final RxDouble energyRate = 0.12.obs;
  final RxDouble dailyEnergyTarget = 30.0.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void toggleDarkMode(bool value) {
    darkMode.value = value;
    // Implement theme change
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> updateEnergyRate() async {
    final result = await Get.dialog<double>(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update Energy Rate'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rate per kWh',
                  prefixText: '\$',
                ),
                onSubmitted: (value) {
                  final rate = double.tryParse(value);
                  if (rate != null) {
                    Get.back(result: rate);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      energyRate.value = result;
    }
  }

  Future<void> updateDailyTarget() async {
    final result = await Get.dialog<double>(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update Daily Target'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Daily Energy Target (kWh)',
                ),
                onSubmitted: (value) {
                  final target = double.tryParse(value);
                  if (target != null) {
                    Get.back(result: target);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      dailyEnergyTarget.value = result;
    }
  }
}

