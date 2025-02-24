import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controller/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Account',
            [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Obx(() => Switch(
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.toggleNotifications,
                )),
              ),
            ],
          ).animate().fadeIn().slideX(),
          _buildSection(
            context,
            'Energy Settings',
            [
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Energy Rate'),
                trailing: Obx(() => Text('\$${controller.energyRate.value}/kWh')),
                onTap: () => controller.updateEnergyRate(),
              ),
              ListTile(
                leading: const Icon(Icons.track_changes),
                title: const Text('Daily Energy Target'),
                trailing: Obx(() =>
                    Text('${controller.dailyEnergyTarget.value.round()} kWh')),
                onTap: () => controller.updateDailyTarget(),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(),
          _buildSection(
            context,
            'App Settings',
            [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Obx(() => Switch(
                  value: controller.darkMode.value,
                  onChanged: controller.toggleDarkMode,
                )),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                trailing: const Text('English'),
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideX(),
          _buildSection(
            context,
            'About',
            [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                trailing: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).slideX(),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context,
      String title,
      List<Widget> children,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

