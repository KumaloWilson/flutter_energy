import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/navigation_widgets.dart';
import '../../../core/theme/app_colors.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllData(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      drawer: Obx(() => AnalyticsNavigationDrawer(devices: controller.devices)),
      body: RefreshIndicator(
        onRefresh: controller.fetchAllData,
        child: Obx(() {
          if (controller.isLoading.value && controller.stats.value.dailyData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value && controller.stats.value.dailyData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load data',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      controller.errorMessage.value,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchAllData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Energy Overview Card
              EnergyOverviewCard(controller: controller),

              const SizedBox(height: 24),

              // Quick Actions Card
              _buildQuickActionsCard(controller, context),

              const SizedBox(height: 24),

              // Device Selection and Date Filter
              DeviceSelector(controller: controller),

              const SizedBox(height: 16),

              // Daily Predictions Card
              EnergyPredictionCard(controller: controller),

              const SizedBox(height: 24),

              // Peak Demand Card
              PeakDemandCard(controller: controller),

              const SizedBox(height: 24),

              // Weekly Usage Chart
              WeeklyUsageCard(controller: controller),

              const SizedBox(height: 24),

              // Device Breakdown
              DeviceBreakdownCard(controller: controller),
            ],
          );
        }),
      ),
      bottomNavigationBar: AnalyticsBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
            // Already on dashboard
              break;
            case 1:
              Get.toNamed('/peak-demand');
              break;
            case 2:
            // Show device selection dialog
              _showDeviceSelectionDialog(context, controller);
              break;
            case 3:
              Get.toNamed('/comparison');
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickActionsCard(AnalyticsController controller, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionItem(
                  icon: Icons.bolt,
                  label: 'Peak Demand',
                  onTap: () => Get.toNamed('/peak-demand'),
                  context: context,
                ),
                _buildQuickActionItem(
                  icon: Icons.compare_arrows,
                  label: 'Compare',
                  onTap: () => Get.toNamed('/comparison'),
                  context: context,
                ),
                _buildQuickActionItem(
                  icon: Icons.devices,
                  label: 'Devices',
                  onTap: () => _showDeviceSelectionDialog(context, controller),
                  context: context,
                ),
                _buildQuickActionItem(
                  icon: Icons.lightbulb_outline,
                  label: 'Tips',
                  onTap: () => _showEnergyTipsDialog(context),
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceSelectionDialog(BuildContext context, AnalyticsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Device'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.devices.length,
            itemBuilder: (context, index) {
              final device = controller.devices[index];
              return ListTile(
                leading: Icon(_getDeviceIcon(device.appliance)),
                title: Text(device.appliance),
                subtitle: Text(device.ratedPower),
                onTap: () {
                  Get.back();
                  Get.toNamed('/device/${device.id}', parameters: {'name': device.appliance});
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEnergyTipsDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Energy Saving Tips'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipItem(
                'Turn off devices when not in use',
                Icons.power_settings_new,
                context,
              ),
              _buildTipItem(
                'Use energy-efficient appliances',
                Icons.eco,
                context,
              ),
              _buildTipItem(
                'Avoid peak hours (9:00 - 12:00)',
                Icons.access_time,
                context,
              ),
              _buildTipItem(
                'Lower thermostat when away',
                Icons.thermostat,
                context,
              ),
              _buildTipItem(
                'Use smart plugs to automate device usage',
                Icons.smart_toy,
                context,
              ),
              _buildTipItem(
                'Regularly maintain appliances for optimal efficiency',
                Icons.build,
                context,
              ),
              _buildTipItem(
                'Use natural light during the day',
                Icons.wb_sunny,
                context,
              ),
              _buildTipItem(
                'Unplug chargers when not in use',
                Icons.battery_charging_full,
                context,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, IconData icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(tip),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('fridge') || name.contains('refrigerator')) {
      return Icons.kitchen;
    } else if (name.contains('tv') || name.contains('television')) {
      return Icons.tv;
    } else if (name.contains('washer') || name.contains('washing')) {
      return Icons.local_laundry_service;
    } else if (name.contains('light') || name.contains('lamp')) {
      return Icons.lightbulb;
    } else if (name.contains('ac') || name.contains('air') || name.contains('conditioner')) {
      return Icons.ac_unit;
    } else if (name.contains('heater') || name.contains('heat')) {
      return Icons.whatshot;
    } else if (name.contains('fan')) {
      return Icons.flip_camera_android_sharp;
    } else if (name.contains('oven') || name.contains('stove')) {
      return Icons.microwave;
    } else if (name.contains('computer') || name.contains('pc')) {
      return Icons.computer;
    } else {
      return Icons.electrical_services;
    }
  }
}
