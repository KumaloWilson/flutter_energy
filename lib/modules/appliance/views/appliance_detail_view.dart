import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/usage_timeline.dart';
import '../controller/appliance_controller.dart';


class ApplianceDetailView extends StatelessWidget {
  const ApplianceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApplianceController());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                controller.appliance.value.applianceInfo.appliance,
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
                child: Center(
                  child: Icon(
                    _getApplianceIcon(
                      controller.appliance.value.applianceInfo.appliance,
                    ),
                    size: 64,
                    color: Theme.of(context).colorScheme.onPrimary,
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
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Current Power',
                          value: '${controller.appliance.value.current}A',
                          icon: Icons.electric_bolt,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MetricCard(
                          title: 'Voltage',
                          value: '${controller.appliance.value.voltage}V',
                          icon: Icons.power,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Active Energy',
                          value: '${controller.appliance.value.activeEnergy}Wh',
                          icon: Icons.energy_savings_leaf,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MetricCard(
                          title: 'Time On',
                          value: '${controller.appliance.value.timeOn}min',
                          icon: Icons.timer,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                  const SizedBox(height: 24),
                  Text(
                    'Usage Timeline',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  const UsageTimeline().animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                  Text(
                    'Power Consumption',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const hours = [
                                  '12AM',
                                  '4AM',
                                  '8AM',
                                  '12PM',
                                  '4PM',
                                  '8PM',
                                ];
                                if (value.toInt() % 4 == 0 &&
                                    value.toInt() < hours.length) {
                                  return Text(
                                    hours[value.toInt()],
                                    style: Theme.of(context).textTheme.bodySmall,
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(24, (index) {
                              return FlSpot(
                                index.toDouble(),
                                2.5 +
                                    (index < 8
                                        ? index * 0.1
                                        : (24 - index) * 0.1) +
                                    (Random().nextDouble() * 0.5),
                              );
                            }),
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 24),
                  Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Daily Schedule'),
                            subtitle: const Text('7:00 AM - 10:00 PM'),
                            trailing: Switch(
                              value: true,
                              onChanged: (value) {},
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Power Saving Mode'),
                            subtitle:
                            const Text('Automatically adjust power usage'),
                            trailing: Switch(
                              value: false,
                              onChanged: (value) {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.edit),
        label: const Text('Edit Schedule'),
      ),
    );
  }

  IconData _getApplianceIcon(String appliance) {
    switch (appliance.toLowerCase()) {
      case 'television':
        return Icons.tv;
      case 'refrigerator':
        return Icons.kitchen;
      case 'air conditioner':
        return Icons.ac_unit;
      default:
        return Icons.electrical_services;
    }
  }
}

