import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter_energy/shared/widgets/energy_card.dart';
import 'package:flutter_energy/shared/widgets/quick_actions.dart';
import 'package:flutter_energy/shared/widgets/usage_chart.dart';

import '../../../shared/widgets/appliance_list.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.fetchLastReadings,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Energy Dashboard',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EnergyCard(totalEnergy: 200,).animate().fadeIn().slideX(),
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
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              sliver: ApplianceList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-device'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

