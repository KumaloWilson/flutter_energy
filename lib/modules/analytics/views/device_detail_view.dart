import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../controller/device_details.controller.dart';


class DeviceDetailsView extends StatelessWidget {
  final int deviceId;
  final String deviceName;

  const DeviceDetailsView({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeviceDetailsController(deviceId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$deviceName Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllData(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchAllData,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value) {
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
              // Device Overview Card
              _buildDeviceOverviewCard(controller, context),

              const SizedBox(height: 24),

              // Date Range Selector
              _buildDateRangeSelector(controller, context),

              const SizedBox(height: 16),

              // Hourly Energy Prediction Card
              _buildHourlyPredictionCard(controller, context),

              const SizedBox(height: 24),

              // Daily Energy Prediction Card
              _buildDailyPredictionCard(controller, context),

              const SizedBox(height: 24),

              // Energy Efficiency Card
              _buildEnergyEfficiencyCard(controller, context),

              const SizedBox(height: 24),

              // Usage Patterns Card
              _buildUsagePatternsCard(controller, context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDeviceOverviewCard(DeviceDetailsController controller, BuildContext context) {
    final theme = Theme.of(context);

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
              theme.colorScheme.secondary.withOpacity(0.8),
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getDeviceIcon(deviceName),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deviceName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          'Rated Power: ${controller.deviceInfo.value?.ratedPower ?? "Unknown"}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOverviewItem(
                    title: 'Today',
                    value: '${controller.todayEnergy.value.toStringAsFixed(2)} kWh',
                    context: context,
                  ),
                  _buildOverviewItem(
                    title: 'This Week',
                    value: '${controller.weeklyEnergy.value.toStringAsFixed(2)} kWh',
                    context: context,
                  ),
                  _buildOverviewItem(
                    title: 'Total',
                    value: '${controller.totalEnergy.value.toStringAsFixed(2)} kWh',
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
                        '\$${(controller.monthlyEnergy.value * 0.15).toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to comparison view
                      Get.toNamed('/comparison', arguments: {'deviceId': deviceId});
                    },
                    icon: const Icon(Icons.compare_arrows, color: Colors.teal),
                    label: const Text('Compare'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.secondary,
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
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      children: [
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

  Widget _buildDateRangeSelector(DeviceDetailsController controller, BuildContext context) {
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
              'Select Date Range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.startDate.value,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: controller.endDate.value,
                      );
                      if (picked != null) {
                        controller.setStartDate(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                            DateFormat('MMM d, yyyy').format(controller.startDate.value),
                            style: theme.textTheme.bodyMedium,
                          )),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to'),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.endDate.value,
                        firstDate: controller.startDate.value,
                        lastDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      if (picked != null) {
                        controller.setEndDate(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                            DateFormat('MMM d, yyyy').format(controller.endDate.value),
                            style: theme.textTheme.bodyMedium,
                          )),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.fetchDeviceSummary(),
                child: const Text('Apply Date Range'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyPredictionCard(DeviceDetailsController controller, BuildContext context) {
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
                  'Hourly Energy Prediction',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  if (controller.isLoadingHourly.value) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return const Icon(Icons.access_time, color: Colors.blue);
                }),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Energy consumption prediction by hour',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (controller.hourlyData.isEmpty) {
                  return const Center(child: Text('No hourly prediction data available'));
                }

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 0.01,
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
                          interval: 0.01,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(2),
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
                    minY: controller.hourlyData.map((e) => e.value).reduce((a, b) => a < b ? a : b) * 0.9,
                    maxY: controller.hourlyData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.1,
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.hourlyData
                            .map((data) => FlSpot(data.hour.toDouble(), data.value))
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
                                  text: '${spot.y.toStringAsFixed(4)} kWh',
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
              if (controller.hourlyData.isEmpty) {
                return const SizedBox.shrink();
              }

              final values = controller.hourlyData.map((e) => e.value).toList();
              final avg = values.reduce((a, b) => a + b) / values.length;
              final min = values.reduce((a, b) => a < b ? a : b);
              final max = values.reduce((a, b) => a > b ? a : b);
              final total = values.reduce((a, b) => a + b);

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Average', '${avg.toStringAsFixed(4)} kWh', Colors.blue, context),
                      _buildStatItem('Min', '${min.toStringAsFixed(4)} kWh', Colors.green, context),
                      _buildStatItem('Max', '${max.toStringAsFixed(4)} kWh', Colors.orange, context),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Daily Energy',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${total.toStringAsFixed(4)} kWh',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estimated cost: \$${(total * 0.15).toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall,
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

  Widget _buildDailyPredictionCard(DeviceDetailsController controller, BuildContext context) {
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
                  'Daily Energy Prediction',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  if (controller.isLoadingDaily.value) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return const Icon(Icons.calendar_today, color: Colors.purple);
                }),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Energy consumption prediction by day',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (controller.dailyData.isEmpty) {
                  return const Center(child: Text('No daily prediction data available'));
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: controller.dailyData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
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
                            if (index >= 0 && index < controller.dailyData.length) {
                              final date = controller.dailyData[index].date;
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  DateFormat('E\nMMM d').format(date),
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 36,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          interval: 1,
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
                      controller.dailyData.length,
                          (index) {
                        final data = controller.dailyData[index];

                        // Determine color based on day of week
                        Color barColor;
                        final weekday = data.date.weekday;
                        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
                          barColor = Colors.purple;
                        } else {
                          barColor = theme.colorScheme.secondary;
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.value,
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
                          final data = controller.dailyData[group.x];
                          return BarTooltipItem(
                            DateFormat('MMM d, yyyy').format(data.date),
                            theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '\n${data.value.toStringAsFixed(2)} kWh',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              TextSpan(
                                text: '\nCost: \$${(data.value * 0.15).toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall,
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
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Weekday',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Weekend',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyEfficiencyCard(DeviceDetailsController controller, BuildContext context) {
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
              'Energy Efficiency Analysis',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              // Calculate efficiency score (0-100)
              final deviceRatedPower = controller.deviceInfo.value?.ratedPower ?? '0 W';
              final ratedPower = int.tryParse(deviceRatedPower.replaceAll(RegExp(r'[^\d]'), '')) ?? 100;

              // Simple efficiency calculation based on rated power and usage
              // In a real app, this would be more sophisticated
              final avgHourlyUsage = controller.hourlyData.isNotEmpty
                  ? controller.hourlyData.map((e) => e.value).reduce((a, b) => a + b) / controller.hourlyData.length
                  : 0.0;

              final efficiencyScore = 100 - ((avgHourlyUsage * 1000) / ratedPower * 100);
              final clampedScore = efficiencyScore.clamp(0.0, 100.0);

              // Determine efficiency level
              String efficiencyLevel;
              Color efficiencyColor;
              if (clampedScore >= 80) {
                efficiencyLevel = 'Excellent';
                efficiencyColor = Colors.green;
              } else if (clampedScore >= 60) {
                efficiencyLevel = 'Good';
                efficiencyColor = Colors.lightGreen;
              } else if (clampedScore >= 40) {
                efficiencyLevel = 'Average';
                efficiencyColor = Colors.amber;
              } else if (clampedScore >= 20) {
                efficiencyLevel = 'Poor';
                efficiencyColor = Colors.orange;
              } else {
                efficiencyLevel = 'Very Poor';
                efficiencyColor = Colors.red;
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Efficiency Score',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${clampedScore.toStringAsFixed(1)}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: efficiencyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              efficiencyLevel,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: efficiencyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Efficiency Breakdown',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: clampedScore / 100,
                              backgroundColor: Colors.grey[300],
                              color: efficiencyColor,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0', style: theme.textTheme.bodySmall),
                                Text('25', style: theme.textTheme.bodySmall),
                                Text('50', style: theme.textTheme.bodySmall),
                                Text('75', style: theme.textTheme.bodySmall),
                                Text('100', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: efficiencyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: efficiencyColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: efficiencyColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Efficiency Recommendations',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildEfficiencyTip(
                          'Use during off-peak hours (before 5 PM)',
                          Icons.access_time,
                          context,
                        ),
                        _buildEfficiencyTip(
                          'Consider upgrading to an energy-efficient model',
                          Icons.upgrade,
                          context,
                        ),
                        _buildEfficiencyTip(
                          'Ensure proper maintenance for optimal performance',
                          Icons.build,
                          context,
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

  Widget _buildEfficiencyTip(String tip, IconData icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsagePatternsCard(DeviceDetailsController controller, BuildContext context) {
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
                  'Usage Patterns',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.insights, color: Colors.deepPurple),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Typical usage patterns for this device',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.hourlyPatterns.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No pattern data available'),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                    radarBorderData: const BorderSide(color: Colors.transparent),
                    gridBorderData: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
                    titlePositionPercentageOffset: 0.2,
                    dataSets: [
                      RadarDataSet(
                        fillColor: theme.colorScheme.primary.withOpacity(0.2),
                        borderColor: theme.colorScheme.primary,
                        entryRadius: 2,
                        dataEntries: [
                          for (int i = 0; i < 24; i += 4)
                            RadarEntry(value: controller.hourlyPatterns[i] * 100),
                        ],
                        borderWidth: 2,
                      ),
                    ],
                    getTitle: (value, meta) {
                      final hour = (value.toInt() * 4).toString().padLeft(2, '0');
                      return RadarChartTitle(
                        text: '$hour:00',
                        angle: 0,
                      );
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.hourlyPatterns.isEmpty) {
                return const SizedBox.shrink();
              }

              // Find peak usage hours
              final entries = <MapEntry<int, double>>[];
              for (int i = 0; i < controller.hourlyPatterns.length; i++) {
                entries.add(MapEntry(i, controller.hourlyPatterns[i]));
              }

              // Sort by value (descending)
              entries.sort((a, b) => b.value.compareTo(a.value));

              // Get top 3 peak hours
              final topHours = entries.take(3).toList();

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peak Usage Hours',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final entry in topHours)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.key.toString().padLeft(2, '0')}:00 - ${(entry.key + 1).toString().padLeft(2, '0')}:00',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(entry.value * 100).toStringAsFixed(1)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Consider shifting usage to off-peak hours to reduce energy costs.',
                      style: theme.textTheme.bodySmall,
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

  Widget _buildStatItem(String label, String value, Color color, BuildContext context) {
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
