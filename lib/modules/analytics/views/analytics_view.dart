import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/prediction_card.dart';
import '../../../shared/widgets/stats_card.dart';
import '../controller/analytics_controller.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StatsCard(
              title: 'Monthly Overview',
              stats: [
                Stat(
                  label: 'Usage',
                  value: '${controller.stats.value.monthlyUsage.toStringAsFixed(2)} kWh',
                  icon: Icons.power,
                ),
                Stat(
                  label: 'Cost',
                  value: '\$${controller.stats.value.monthlyCost.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                ),
                Stat(
                  label: 'vs Last Month',
                  value: '+5%',
                  icon: Icons.trending_up,
                  isPositive: false,
                ),
              ],
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 24),
            PredictionCard(
              predictedUsage: controller.stats.value.predictedUsage,
              costSavingTarget: controller.stats.value.costSavingTarget,
            ).animate().fadeIn(delay: 200.ms).slideX(),
            const SizedBox(height: 24),
            Text(
              'Usage Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 35,
                      title: 'HVAC',
                      color: Colors.blue,
                    ),
                    PieChartSectionData(
                      value: 25,
                      title: 'Lighting',
                      color: Colors.orange,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: 'Kitchen',
                      color: Colors.green,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: 'Other',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        );
      }),
    );
  }
}

