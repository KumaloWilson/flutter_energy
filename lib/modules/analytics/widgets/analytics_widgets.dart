import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../controllers/analytics_controller.dart';


class EnergyOverviewCard extends StatelessWidget {
  final AnalyticsController controller;

  const EnergyOverviewCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = controller.stats.value;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.primary,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Energy Consumption Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOverviewItem(
                    icon: Icons.today,
                    title: 'Today',
                    value: '${stats.dailyUsage.toStringAsFixed(1)} kWh',
                    context: context,
                  ),
                  _buildOverviewItem(
                    icon: Icons.calendar_view_week,
                    title: 'This Week',
                    value: '${stats.weeklyUsage.toStringAsFixed(1)} kWh',
                    context: context,
                  ),
                  _buildOverviewItem(
                    icon: Icons.calendar_month,
                    title: 'This Month',
                    value: '${stats.monthlyUsage.toStringAsFixed(1)} kWh',
                    context: context,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Cost',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${stats.monthlyCost.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Show cost savings tips
                      Get.dialog(
                        AlertDialog(
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
                                  'Avoid peak hours (${controller.peakDemandData.isNotEmpty ? '${controller.peakDemandData.first.hour}:00 - ${controller.peakDemandData.last.hour}:00' : '18:00 - 21:00'})',
                                  Icons.access_time,
                                  context,
                                ),
                                _buildTipItem(
                                  'Lower thermostat when away',
                                  Icons.thermostat,
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
                    },
                    icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                    label: const Text('Saving Tips'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
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
}

class DeviceSelector extends StatelessWidget {
  final AnalyticsController controller;

  const DeviceSelector({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Analysis',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingDevices.value) {
            return const Center(child: LinearProgressIndicator());
          }

          if (controller.devices.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('No devices found. Please add devices to track energy usage.'),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final device in controller.devices)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(device.appliance),
                      selected: controller.selectedDeviceId.value == device.id,
                      onSelected: (selected) {
                        if (selected) {
                          controller.setSelectedDevice(device.id);
                        }
                      },
                      avatar: Icon(
                        _getDeviceIcon(device.appliance),
                        size: 18,
                      ),
                      labelStyle: TextStyle(
                        color: controller.selectedDeviceId.value == device.id
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                      selectedColor: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        // Date selector
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: controller.selectedDate.value,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                );
                if (picked != null) {
                  controller.setSelectedDate(picked);
                }
              },
              tooltip: 'Select Date',
            ),
            Obx(() => Text(
              DateFormat('EEEE, MMM d, yyyy').format(controller.selectedDate.value),
              style: theme.textTheme.bodyLarge,
            )),
            const Spacer(),
            // Time range selector
            Obx(() => DropdownButton<String>(
              value: controller.timeRange.value,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.setTimeRange(newValue);
                }
              },
              items: controller.availableTimeRanges
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )),
          ],
        ),
      ],
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

class EnergyPredictionCard extends StatelessWidget {
  final AnalyticsController controller;

  const EnergyPredictionCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Energy Prediction',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  if (controller.isLoadingPredictions.value) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return const Icon(Icons.insights, color: Colors.blue);
                }),
              ],
            ),
            const SizedBox(height: 4),
            Obx(() {
              final selectedDevice = controller.devices.isEmpty
                  ? null
                  : controller.devices.firstWhere(
                    (d) => d.id == controller.selectedDeviceId.value,
                orElse: () => controller.devices.first,
              );

              return Text(
                selectedDevice != null
                    ? 'Hourly prediction for ${selectedDevice.appliance}'
                    : 'Hourly energy prediction',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (controller.hourlyEnergyData.isEmpty) {
                  return const Center(child: Text('No prediction data available'));
                }

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 100,
                      verticalInterval: 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 4,
                          getTitlesWidget: (value, meta) {
                            final hour = value.toInt();
                            if (hour % 4 == 0) {
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 100,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                    ),
                    minX: 0,
                    maxX: 23,
                    minY: 0,
                    maxY: controller.hourlyEnergyData.map((e) => e.usage).reduce((a, b) => a > b ? a : b) * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.hourlyEnergyData
                            .map((data) => FlSpot(data.hour!.toDouble(), data.usage))
                            .toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.7),
                            theme.colorScheme.primary,
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: false,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.3),
                              theme.colorScheme.primary.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final hour = spot.x.toInt();
                            return LineTooltipItem(
                              '${hour.toString().padLeft(2, '0')}:00\n',
                              theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '${spot.y.toStringAsFixed(1)} Wh',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Obx(() {
              // Calculate average, min, max from the hourly data
              if (controller.hourlyEnergyData.isEmpty) {
                return const SizedBox.shrink();
              }

              final values = controller.hourlyEnergyData.map((e) => e.usage).toList();
              final avg = values.reduce((a, b) => a + b) / values.length;
              final min = values.reduce((a, b) => a < b ? a : b);
              final max = values.reduce((a, b) => a > b ? a : b);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPredictionStat('Average', '${avg.toStringAsFixed(1)} Wh', Colors.blue, context),
                  _buildPredictionStat('Min', '${min.toStringAsFixed(1)} Wh', Colors.green, context),
                  _buildPredictionStat('Max', '${max.toStringAsFixed(1)} Wh', Colors.orange, context),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionStat(String label, String value, Color color, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class PeakDemandCard extends StatelessWidget {
  final AnalyticsController controller;

  const PeakDemandCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Peak Demand Hours',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  if (controller.isLoadingPeakDemand.value) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'High Cost',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Hours when energy demand and costs are highest',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Obx(() {
                if (controller.peakDemandData.isEmpty) {
                  return const Center(child: Text('No peak demand data available'));
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: controller.peakDemandData.map((e) => e.usage).reduce((a, b) => a > b ? a : b) * 1.2,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 200,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < controller.peakDemandData.length) {
                              final hour = controller.peakDemandData[index].hour;
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  '${hour}:00',
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          interval: 200,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                    ),
                    barGroups: List.generate(
                      controller.peakDemandData.length,
                          (index) {
                        final data = controller.peakDemandData[index];
                        // Determine color based on usage level
                        Color barColor;
                        if (data.usage > 500) {
                          barColor = Colors.red;
                        } else if (data.usage > 300) {
                          barColor = Colors.orange;
                        } else {
                          barColor = Colors.green;
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.usage,
                              color: barColor,
                              width: 16,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final data = controller.peakDemandData[group.x];
                          return BarTooltipItem(
                            '${data.hour}:00\n',
                            theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '${data.usage.toStringAsFixed(1)} W',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeakLegendItem('Low', Colors.green, context),
                const SizedBox(width: 16),
                _buildPeakLegendItem('Medium', Colors.orange, context),
                const SizedBox(width: 16),
                _buildPeakLegendItem('High', Colors.red, context),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Avoid using high-power appliances during peak hours to reduce your energy costs.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakLegendItem(String label, Color color, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class WeeklyUsageCard extends StatelessWidget {
  final AnalyticsController controller;

  const WeeklyUsageCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Usage Trend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.calendar_view_week, color: theme.colorScheme.secondary),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Energy usage over the past week',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                final dailyData = controller.stats.value.dailyData;

                if (dailyData.isEmpty) {
                  return const Center(child: Text('No weekly data available'));
                }

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 500,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final int index = value.toInt();
                            if (index >= 0 && index < dailyData.length) {
                              final date = dailyData[index].date;
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  DateFormat('E').format(date),
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 500,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                    ),
                    minX: 0,
                    maxX: dailyData.length - 1.0,
                    minY: 0,
                    maxY: dailyData.map((e) => e.usage).reduce((a, b) => a > b ? a : b) * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(dailyData.length, (index) {
                          return FlSpot(index.toDouble(), dailyData[index].usage);
                        }),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary.withOpacity(0.7),
                            theme.colorScheme.secondary,
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: theme.colorScheme.secondary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.secondary.withOpacity(0.3),
                              theme.colorScheme.secondary.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            final date = dailyData[index].date;
                            return LineTooltipItem(
                              DateFormat('MMM d').format(date),
                              theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '\n${spot.y.toStringAsFixed(1)} kWh',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final dailyData = controller.stats.value.dailyData;
              if (dailyData.isEmpty) {
                return const SizedBox.shrink();
              }

              // Calculate total, avg, min and max
              final total = dailyData.map((e) => e.usage).reduce((a, b) => a + b);
              final avg = total / dailyData.length;
              final min = dailyData.map((e) => e.usage).reduce((a, b) => a < b ? a : b);
              final max = dailyData.map((e) => e.usage).reduce((a, b) => a > b ? a : b);

              // Find peak day
              final maxIndex = dailyData.indexWhere((e) => e.usage == max);
              final peakDay = maxIndex >= 0 ? DateFormat('EEEE').format(dailyData[maxIndex].date) : 'Unknown';

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeeklyStat('Total', '${total.toStringAsFixed(1)} kWh', Colors.blue, context),
                      _buildWeeklyStat('Average', '${avg.toStringAsFixed(1)} kWh/day', Colors.green, context),
                      _buildWeeklyStat('Peak', '${max.toStringAsFixed(1)} kWh ($peakDay)', Colors.orange, context),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: theme.colorScheme.secondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your weekly usage is ${controller.stats.value.weeklyUsage > controller.stats.value.weeklyUsage * 0.9 ? 'higher' : 'lower'} than last week. ${controller.stats.value.weeklyUsage > controller.stats.value.weeklyUsage * 0.9 ? 'Try to reduce usage during peak hours.' : 'Keep up the good work!'}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStat(String label, String value, Color color, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class DeviceBreakdownCard extends StatelessWidget {
  final AnalyticsController controller;

  const DeviceBreakdownCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              'Device Energy Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Distribution of energy consumption by device',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (controller.devices.isEmpty) {
                  return const Center(child: Text('No devices found'));
                }

                // Create pie chart data from devices
                double totalPower = 0;
                final pieData = <PieData>[];

                for (final device in controller.devices) {
                  // Get total energy for this device from the API data
                  final energy = controller.getDeviceTotalEnergy(device.id);
                  totalPower += energy;

                  pieData.add(PieData(
                    name: device.appliance,
                    power: energy,
                    color: _getDeviceColor(pieData.length),
                  ));
                }

                // Calculate percentages
                for (final data in pieData) {
                  data.percentage = (data.power / totalPower) * 100;
                }

                // Sort by power consumption (descending)
                pieData.sort((a, b) => b.power.compareTo(a.power));

                return Row(
                  children: [
                    // Pie Chart
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: pieData.map((data) {
                            return PieChartSectionData(
                              color: data.color,
                              value: data.power,
                              title: '${data.percentage.toStringAsFixed(0)}%',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Legend
                    Expanded(
                      flex: 4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pieData.length > 5 ? 5 : pieData.length,
                        itemBuilder: (context, index) {
                          final data = pieData[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: data.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data.name,
                                    style: theme.textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${data.percentage.toStringAsFixed(1)}%',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.devices.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.eco,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Energy Saving Opportunities',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on your device usage pattern, you could save up to ${(controller.stats.value.monthlyCost * 0.15).toStringAsFixed(2)} per month by optimizing your highest-consuming devices.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    if (controller.devices.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          // Show optimization recommendations
                          final highestConsumingDevice = controller.devices.reduce((a, b) {
                            final powerA = controller.parseWattage(a.ratedPower);
                            final powerB = controller.parseWattage(b.ratedPower);
                            return powerA > powerB ? a : b;
                          });

                          Get.dialog(
                            AlertDialog(
                              title: const Text('Optimization Recommendations'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Your ${highestConsumingDevice.appliance} is your highest energy consumer.'),
                                    const SizedBox(height: 12),
                                    _buildTipItem(
                                      'Consider upgrading to an energy-efficient model',
                                      Icons.upgrade,
                                      context,
                                    ),
                                    _buildTipItem(
                                      'Use it during off-peak hours (before 5 PM)',
                                      Icons.access_time,
                                      context,
                                    ),
                                    _buildTipItem(
                                      'Regularly maintain for optimal performance',
                                      Icons.build,
                                      context,
                                    ),
                                    _buildTipItem(
                                      'Consider using eco-mode if available',
                                      Icons.eco,
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('See Recommendations'),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getDeviceColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.lime,
    ];

    return colors[index % colors.length];
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
}

class PieData {
  final String name;
  final double power;
  final Color color;
  double percentage = 0;

  PieData({
    required this.name,
    required this.power,
    required this.color,
  });
}