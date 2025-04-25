import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/settings/controller/settings_controller.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/routes/app_pages.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final authController = Get.find<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildSection(
            context,
            'Account',
            [
              Obx(() => ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                subtitle: Text(authController.currentUser.value?.name ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showProfileDialog(context, authController),
              )),
              ListTile(
                leading: const Icon(Icons.family_restroom),
                title: const Text('Family Access'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(Routes.FAMILY_ACCESS),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Obx(() => Switch(
                  value: settingsController.notificationsEnabled.value,
                  onChanged: settingsController.toggleNotifications,
                  activeColor: colorScheme.primary,
                )),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => authController.logout(),
              ),
            ],
          ).animate().fadeIn().slideX(),
          
          // Appearance Section
          _buildSection(
            context,
            'Appearance',
            [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                trailing: Obx(() => DropdownButton<String>(
                  value: settingsController.selectedTheme.value,
                  onChanged: (value) {
                    if (value != null) {
                      settingsController.setTheme(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'light',
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: 'dark',
                      child: Text('Dark'),
                    ),
                    DropdownMenuItem(
                      value: 'system',
                      child: Text('System'),
                    ),
                  ],
                  underline: const SizedBox(),
                )),
              ),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Custom Colors'),
                subtitle: const Text('Personalize your app colors'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showColorPickerDialog(context, settingsController),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(),
          
          // Energy Settings Section
          _buildSection(
            context,
            'Energy Settings',
            [
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Energy Rate'),
                trailing: Obx(() => Text('\$${settingsController.energyRate.value}/kWh')),
                onTap: () => _showEnergyRateDialog(context, settingsController),
              ),
              ListTile(
                leading: const Icon(Icons.track_changes),
                title: const Text('Daily Energy Target'),
                trailing: Obx(() =>
                    Text('${settingsController.dailyEnergyTarget.value.round()} kWh')),
                onTap: () => _showDailyTargetDialog(context, settingsController),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideX(),
          
          // About Section
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
  
  void _showProfileDialog(BuildContext context, AuthController controller) {
    final nameController = TextEditingController(
      text: controller.currentUser.value?.name ?? '',
    );
    
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.updateProfile(nameController.text.trim());
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showEnergyRateDialog(BuildContext context, SettingsController controller) {
    final rateController = TextEditingController(
      text: controller.energyRate.value.toString(),
    );
    
    Get.dialog(
      AlertDialog(
        title: const Text('Update Energy Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: 'Rate per kWh',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final rate = double.tryParse(rateController.text);
              if (rate != null) {
                controller.updateEnergyRate(rate);
                Get.back();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  void _showDailyTargetDialog(BuildContext context, SettingsController controller) {
    final targetController = TextEditingController(
      text: controller.dailyEnergyTarget.value.toString(),
    );
    
    Get.dialog(
      AlertDialog(
        title: const Text('Update Daily Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              decoration: const InputDecoration(
                labelText: 'Daily Energy Target (kWh)',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final target = double.tryParse(targetController.text);
              if (target != null) {
                controller.updateDailyTarget(target);
                Get.back();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  void _showColorPickerDialog(BuildContext context, SettingsController controller) {
    Color primaryColor = controller.customColors.value.primary;
    Color secondaryColor = controller.customColors.value.secondary;
    Color accentColor = controller.customColors.value.accent;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Customize Colors'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Primary Color'),
              const SizedBox(height: 8),
              ColorPicker(
                pickerColor: primaryColor,
                onColorChanged: (color) => primaryColor = color,
                pickerAreaHeightPercent: 0.2,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hsl,
              ),
              const Divider(),
              const Text('Secondary Color'),
              const SizedBox(height: 8),
              ColorPicker(
                pickerColor: secondaryColor,
                onColorChanged: (color) => secondaryColor = color,
                pickerAreaHeightPercent: 0.2,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hsl,
              ),
              const Divider(),
              const Text('Accent Color'),
              const SizedBox(height: 8),
              ColorPicker(
                pickerColor: accentColor,
                onColorChanged: (color) => accentColor = color,
                pickerAreaHeightPercent: 0.2,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hsl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.setCustomColors(primaryColor, secondaryColor, accentColor);
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
