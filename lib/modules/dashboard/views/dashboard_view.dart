import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter_energy/shared/widgets/energy_card.dart';
import 'package:flutter_energy/shared/widgets/appliance_card.dart';

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
            onPressed: controller.fetchLastReadings,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLastReadings,
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
                      Text(
                        'Active Appliances',
                        style: Theme.of(context).textTheme.titleLarge,
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
                      child: ApplianceCard(reading: reading)
                          .animate()
                          .fadeIn(delay: (300 + (index * 100)).ms)
                          .slideX(),
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
    );
  }
}

