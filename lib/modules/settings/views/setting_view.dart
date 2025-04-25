import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controller/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

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
                onTap: () => _showEnergyRateDialog(context, controller),
              ),
              ListTile(
                leading: const Icon(Icons.track_changes),
                title: const Text('Daily Energy Target'),
                trailing: Obx(() =>
                    Text('${controller.dailyEnergyTarget.value.round()} kWh')),
                onTap: () => _showDailyTargetDialog(context, controller),
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
                  value: _isDarkMode(controller),
                  onChanged: (value) => _toggleDarkMode(controller, value),
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

  // Helper method to check if dark mode is enabled based on theme setting
  bool _isDarkMode(SettingsController controller) {
    return controller.selectedTheme.value == 'dark';
  }

  // Helper method to toggle dark mode
  void _toggleDarkMode(SettingsController controller, bool value) {
    controller.setTheme(value ? 'dark' : 'light');
  }

  // Show dialog to update energy rate
  void _showEnergyRateDialog(BuildContext context, SettingsController controller) {
    final TextEditingController textController = TextEditingController(
      text: controller.energyRate.value.toString(),
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Update Energy Rate'),
        content: TextField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Rate (\$/kWh)',
            hintText: 'Enter your energy rate',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final double? newRate = double.tryParse(textController.text);
              if (newRate != null) {
                controller.updateEnergyRate(newRate);
              }
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show dialog to update daily target
  void _showDailyTargetDialog(BuildContext context, SettingsController controller) {
    final TextEditingController textController = TextEditingController(
      text: controller.dailyEnergyTarget.value.toString(),
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Update Daily Target'),
        content: TextField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Target (kWh)',
            hintText: 'Enter your daily energy target',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final double? newTarget = double.tryParse(textController.text);
              if (newTarget != null) {
                controller.updateDailyTarget(newTarget);
              }
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}