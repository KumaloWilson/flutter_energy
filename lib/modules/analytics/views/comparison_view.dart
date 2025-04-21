import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/comparison_controller.dart';
import '../../../core/theme/app_colors.dart';

class ComparisonView extends StatelessWidget {
  const ComparisonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComparisonController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Comparison'),
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
              // Comparison Settings Card
              _buildComparisonSettingsCard(controller, context),

              const SizedBox(height: 24),

              // Device Comparison Chart
              _buildDeviceComparisonCard(controller, context),

              const SizedBox(height: 24),

              // Time Period Comparison Chart
              _buildTimePeriodComparisonCard(controller, context),

              const SizedBox(height: 24),

              // Efficiency Comparison Card
              _buildEfficiencyComparisonCard(controller, context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildComparisonSettingsCard(ComparisonController controller, BuildContext context) {
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
              'Comparison Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Devices',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final device in controller.devices)
                  ChoiceChip(
                    label: Text(device.appliance),
                    selected: controller.selectedDeviceIds.contains(device.id),
                    onSelected: (selected) {
                      controller.toggleDeviceSelection(device.id);
                    },
                    avatar: Icon(
                      _getDeviceIcon(device.appliance),
                      size: 18,
                    ),
                  ),
              ],
            )),
            const SizedBox(height: 16),
            Text(
              'Select Time Periods',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Period 1',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _showDateRangePicker(
                          context,
                          controller.period1Start.value,
                          controller.period1End.value,
                              (start, end) {
                            controller.setPeriod1(start, end);
                          },
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => Text(
                                '${DateFormat('MMM d').format(controller.period1Start.value)} - ${DateFormat('MMM d').format(controller.period1End.value)}',
                                style: theme.textTheme.bodyMedium,
                              )),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Period 2',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _showDateRangePicker(
                          context,
                          controller.period2Start.value,
                          controller.period2End.value,
                              (start, end) {
                            controller.setPeriod2(start, end);
                          },
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => Text(
                                '${DateFormat('MMM d').format(controller.period2Start.value)} - ${DateFormat('MMM d').format(controller.period2End.value)}',
                                style: theme.textTheme.bodyMedium,
                              )),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.applyComparison(),
                child: const Text('Apply Comparison'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(
      BuildContext context,
      DateTime initialStart,
      DateTime initialEnd,
      Function(DateTime, DateTime) onSelect,
      ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd,
      ),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (picked != null) {
      onSelect(picked.start, picked.end);
    }
  }

  Widget _buildDeviceComparisonCard(ComparisonController controller, BuildContext context) {
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
                  'Device Comparison',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  if (controller.isLoadingDeviceComparison.value) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return const Icon(Icons.devices, color: Colors.blue);
                }),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Energy consumption comparison between devices',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Obx(() {
                if (controller.deviceComparisonData.isEmpty) {
                  return const Center(child: Text('No device comparison data available'));
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: controller.deviceComparisonData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5,
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
                            if (index >= 0 && index < controller.deviceComparisonData.length) {
                              final deviceName = controller.deviceComparisonData[index].name;
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  deviceName,
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
                          interval: 5,
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
                      controller.deviceComparisonData.length,
                          (index) {
                        final data = controller.deviceComparisonData[index];

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.value,
                              color: _getDeviceColor(index),
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
                          final data = controller.deviceComparisonData[group.x];
                          return BarTooltipItem(
                            data.name,
                            theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '\n${data.value.toStringAsFixed(2)} kWh',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.primary,
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
            Obx(() {
              if (controller.deviceComparisonData.isEmpty) {
                return const SizedBox.shrink();
              }

              // Find highest and lowest energy consumers
              final sortedData = List<ComparisonData>.from(controller.deviceComparisonData)
                ..sort((a, b) => b.value.compareTo(a.value));

              final highestConsumer = sortedData.first;
              final lowestConsumer = sortedData.last;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ${highestConsumer.name} is your highest energy consumer at ${highestConsumer.value.toStringAsFixed(2)} kWh.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• ${lowestConsumer.name} is your most efficient device at ${lowestConsumer.value.toStringAsFixed(2)} kWh.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Consider optimizing usage of ${highestConsumer.name} to reduce energy costs.',
                      style: theme.textTheme.bodyMedium,
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

  Widget _buildTimePeriodComparisonCard(ComparisonController controller, BuildContext context) {
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
                  'Time Period Comparison',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  if (controller.isLoadingPeriodComparison.value) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return const Icon(Icons.date_range, color: Colors.purple);
                }),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Energy consumption comparison between time periods',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Obx(() {
                if (controller.periodComparisonData.isEmpty) {
                  return const Center(child: Text('No time period comparison data available'));
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: controller.periodComparisonData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5,
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
                            if (index >= 0 && index < controller.periodComparisonData.length) {
                              final periodName = controller.periodComparisonData[index].name;
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  periodName,
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
                          interval: 5,
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
                      controller.periodComparisonData.length,
                          (index) {
                        final data = controller.periodComparisonData[index];

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.value,
                              color: index == 0 ? Colors.purple : Colors.deepPurple,
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
                          final data = controller.periodComparisonData[group.x];
                          return BarTooltipItem(
                            data.name,
                            theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '\n${data.value.toStringAsFixed(2)} kWh',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.primary,
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
            Obx(() {
              if (controller.periodComparisonData.length < 2) {
                return const SizedBox.shrink();
              }

              final period1 = controller.periodComparisonData[0];
              final period2 = controller.periodComparisonData[1];

              final difference = period2.value - period1.value;
              final percentChange = period1.value > 0
                  ? (difference / period1.value) * 100
                  : 0.0;

              final isIncrease = difference > 0;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isIncrease ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isIncrease ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isIncrease ? Icons.trending_up : Icons.trending_down,
                          color: isIncrease ? Colors.red : Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Energy Usage ${isIncrease ? 'Increased' : 'Decreased'} by ${percentChange.abs().toStringAsFixed(1)}%',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isIncrease ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your energy consumption ${isIncrease ? 'increased' : 'decreased'} by ${difference.abs().toStringAsFixed(2)} kWh between the two periods.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This represents a cost ${isIncrease ? 'increase' : 'savings'} of \$${(difference.abs() * 0.15).toStringAsFixed(2)}.',
                      style: theme.textTheme.bodyMedium,
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

  Widget _buildEfficiencyComparisonCard(ComparisonController controller, BuildContext context) {
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
              'Efficiency Comparison',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.deviceComparisonData.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No efficiency data available'),
                  ),
                );
              }

              // Calculate efficiency for each device
              final efficiencyData = <EfficiencyData>[];

              for (final device in controller.devices.where(
                      (d) => controller.selectedDeviceIds.contains(d.id)
              )) {
                // Get device comparison data
                final comparisonData = controller.deviceComparisonData.firstWhere(
                      (d) => d.name == device.appliance,
                  orElse: () => ComparisonData(name: device.appliance, value: 0),
                );

                // Parse rated power
                final ratedPower = int.tryParse(
                    device.ratedPower.replaceAll(RegExp(r'[^\d]'), '')
                ) ?? 100;

                // Calculate efficiency score (simplified)
                final usageHours = 24 * 7; // Assuming 24/7 usage for simplicity
                final expectedEnergy = (ratedPower / 1000) * usageHours; // kWh
                final actualEnergy = comparisonData.value;

                // Higher score is better (using less than expected)
                double efficiencyScore;
                if (expectedEnergy > 0) {
                  efficiencyScore = 100 - ((actualEnergy / expectedEnergy) * 100);
                  efficiencyScore = efficiencyScore.clamp(0, 100);
                } else {
                  efficiencyScore = 50; // Default if we can't calculate
                }

                efficiencyData.add(EfficiencyData(
                  deviceName: device.appliance,
                  score: efficiencyScore,
                  actualEnergy: actualEnergy,
                  expectedEnergy: expectedEnergy,
                ));
              }

              // Sort by efficiency score (descending)
              efficiencyData.sort((a, b) => b.score.compareTo(a.score));

              return Column(
                children: [
                  for (int i = 0; i < efficiencyData.length; i++)
                    _buildEfficiencyItem(
                      i + 1,
                      efficiencyData[i],
                      context,
                    ),
                ],
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Colors.blue,
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
                  Text(
                    '• Focus on improving the efficiency of devices with the lowest scores.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Consider upgrading older devices to more energy-efficient models.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Use smart plugs to automatically turn off devices when not in use.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyItem(int rank, EfficiencyData data, BuildContext context) {
    final theme = Theme.of(context);

    // Determine color based on efficiency score
    Color color;
    String label;
    if (data.score >= 80) {
      color = Colors.green;
      label = 'Excellent';
    } else if (data.score >= 60) {
      color = Colors.lightGreen;
      label = 'Good';
    } else if (data.score >= 40) {
      color = Colors.amber;
      label = 'Average';
    } else if (data.score >= 20) {
      color = Colors.orange;
      label = 'Poor';
    } else {
      color = Colors.red;
      label = 'Very Poor';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                data.deviceName,
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: LinearProgressIndicator(
                  value: data.score / 100,
                  backgroundColor: Colors.grey[300],
                  color: color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  '${data.score.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Actual: ${data.actualEnergy.toStringAsFixed(2)} kWh | Expected: ${data.expectedEnergy.toStringAsFixed(2)} kWh',
            style: theme.textTheme.bodySmall,
          ),
        ],
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
