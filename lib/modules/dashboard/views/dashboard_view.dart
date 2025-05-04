import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter_energy/shared/widgets/energy_card.dart';
import '../../../shared/widgets/device_control_card.dart';
import '../../../shared/widgets/quick_actions.dart';
import '../../../shared/widgets/usage_chart.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshDashboard(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.readings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value && controller.readings.isEmpty) {
          return _buildErrorView(context, controller);
        }

        if (controller.readings.isEmpty) {
          return _buildEmptyView(context, controller);
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshDashboard(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EnergyCard(
                        totalEnergy: controller.totalEnergy.value,
                        monthlyEnergy: controller.totalMonthlyEnergy.value,
                        isLoadingMonthly: controller.isLoadingMonthly.value,
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 24),
                      const QuickActions().animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                      Text(
                        'Usage Overview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 16),
                      const UsageChart().animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Appliances',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Chip(
                            label: Text(
                              '${controller.getActiveDevicesCount()} active',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final reading = controller.readings[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: DeviceControlCard(
                        reading: reading,
                        isControlLoading: controller.isDeviceControlLoading(reading.applianceInfo.id),
                        onToggle: () => controller.toggleDevice(reading.applianceInfo),
                        monthlyConsumption: controller.getDeviceMonthlyConsumption(reading.applianceInfo.id),
                      ).animate().fadeIn(delay: (300 + (index * 100)).ms).slideX(),
                    );
                  },
                  childCount: controller.readings.length,
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-device'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, DashboardController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              controller.errorMessage.value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.retryFetch,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, DashboardController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.device_unknown,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No appliances found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'No energy readings available at the moment',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.retryFetch,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/add-device'),
            icon: const Icon(Icons.add),
            label: const Text('Add Device'),
          ),
        ],
      ),
    );
  }
}
