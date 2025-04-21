import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/analytics/views/peak_demand_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/analytics_widget.dart';
import '../../../shared/widgets/navigation_widget.dart';
import '../controller/analytics_controller.dart';
import 'comparison_view.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.find<AnalyticsController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Analytics'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllData(),
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.bolt), text: 'Peak Demand'),
            Tab(icon: Icon(Icons.devices), text: 'Devices'),
            Tab(icon: Icon(Icons.compare_arrows), text: 'Compare'),
          ],
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,

        ),
      ),
      drawer: Obx(() => AnalyticsNavigationDrawer(devices: controller.devices)),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Dashboard Tab
          _buildDashboardTab(),

          // Peak Demand Tab
          const PeakDemandView(),

          // Devices Tab
          _buildDevicesTab(),

          // Compare Tab
          const ComparisonView(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final theme = Theme.of(context);

    return RefreshIndicator(
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
            _buildQuickActionsCard(controller),

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
    );
  }

  Widget _buildDevicesTab() {
    return Obx(() {
      if (controller.isLoadingDevices.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.devices.isEmpty) {
        return const Center(
          child: Text('No devices found. Please add devices to track energy usage.'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.devices.length,
        itemBuilder: (context, index) {
          final device = controller.devices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDeviceIcon(device.appliance),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                device.appliance,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Rated Power: ${device.ratedPower}'),
                  Text('Added: ${DateFormat('MMM d, yyyy').format(device.dateAdded)}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  Get.toNamed('/device/${device.id}', parameters: {'name': device.appliance});
                },
              ),
              onTap: () {
                Get.toNamed('/device/${device.id}', parameters: {'name': device.appliance});
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildQuickActionsCard(AnalyticsController controller) {
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
                  onTap: () => _tabController.animateTo(1),
                ),
                _buildQuickActionItem(
                  icon: Icons.compare_arrows,
                  label: 'Compare',
                  onTap: () => _tabController.animateTo(3),
                ),
                _buildQuickActionItem(
                  icon: Icons.devices,
                  label: 'Devices',
                  onTap: () => _tabController.animateTo(2),
                ),
                _buildQuickActionItem(
                  icon: Icons.lightbulb_outline,
                  label: 'Tips',
                  onTap: () => _showEnergyTipsDialog(),
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

  void _showEnergyTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Energy Saving Tips'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipItem('Turn off devices when not in use', Icons.power_settings_new),
              _buildTipItem('Use energy-efficient appliances', Icons.eco),
              _buildTipItem('Avoid peak hours (9:00 - 12:00)', Icons.access_time),
              _buildTipItem('Lower thermostat when away', Icons.thermostat),
              _buildTipItem('Use smart plugs to automate device usage', Icons.smart_toy),
              _buildTipItem('Regularly maintain appliances for optimal efficiency', Icons.build),
              _buildTipItem('Use natural light during the day', Icons.wb_sunny),
              _buildTipItem('Unplug chargers when not in use', Icons.battery_charging_full),
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

  Widget _buildTipItem(String tip, IconData icon) {
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
