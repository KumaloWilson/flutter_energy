import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../modules/analytics/controllers/comparison_controller.dart';

/// Settings card for comparison configuration
class ComparisonSettingsCard extends StatelessWidget {
  const ComparisonSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();
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
            _DeviceSelectionList(),
            const SizedBox(height: 16),
            Text(
              'Select Time Periods',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _TimePeriodSelectors(),
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
}

/// Device selection list with optimized rendering
class _DeviceSelectionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();

    return Obx(() {
      // Memoize the device list to prevent rebuilds
      final devices = controller.devices;
      final selectedIds = controller.selectedDeviceIds;

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(devices.length, (index) {
          final device = devices[index];
          return ChoiceChip(
            label: Text(device.appliance),
            selected: selectedIds.contains(device.id),
            onSelected: (selected) {
              controller.toggleDeviceSelection(device.id);
            },
            avatar: Icon(
              _getDeviceIcon(device.appliance),
              size: 18,
            ),
          );
        }),
      );
    });
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

/// Time period selection widgets
class _TimePeriodSelectors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();
    final theme = Theme.of(context);

    return Row(
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
              _DateRangeSelector(
                startDate: controller.period1Start,
                endDate: controller.period1End,
                onSelect: controller.setPeriod1,
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
              _DateRangeSelector(
                startDate: controller.period2Start,
                endDate: controller.period2End,
                onSelect: controller.setPeriod2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Reusable date range selector
class _DateRangeSelector extends StatelessWidget {
  final Rx<DateTime> startDate;
  final Rx<DateTime> endDate;
  final Function(DateTime, DateTime) onSelect;

  const _DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showDateRangePicker(context),
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
              '${DateFormat('MMM d').format(startDate.value)} - ${DateFormat('MMM d').format(endDate.value)}',
              style: theme.textTheme.bodyMedium,
            )),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: startDate.value,
        end: endDate.value,
      ),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (picked != null) {
      onSelect(picked.start, picked.end);
    }
  }
}

/// Device comparison card with optimized chart
class DeviceComparisonCard extends StatelessWidget {
  const DeviceComparisonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();
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
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _DeviceComparisonChart(),
            ),
            const SizedBox(height: 16),
            _DeviceComparisonInsights(),
          ],
        ),
      ),
    );
  }
}

/// Optimized device comparison chart
class _DeviceComparisonChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();
    final theme = Theme.of(context);

    return Obx(() {
      final data = controller.deviceComparisonData;

      if (data.isEmpty) {
        return const Center(child: Text('No device comparison data available'));
      }

      // Pre-calculate max value to avoid doing it in the build method
      final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.dividerColor.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: _buildTitlesData(data, theme),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          barGroups: _buildBarGroups(data),
          barTouchData: _buildBarTouchData(data, theme),
        ),
      );
    });
  }

  FlTitlesData _buildTitlesData(List<ComparisonData> data, ThemeData theme) {
    return FlTitlesData(
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
            if (index >= 0 && index < data.length) {
              final deviceName = data[index].name;
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
        sideTitles: SideTitles(showTitles: false),
        // sideTitles: SideTitles(
        //   showTitles: true,
        //   reservedSize: 42,
        //   interval: 5,
        //   getTitlesWidget: (value, meta) {
        //     return SideTitleWidget(
        //       meta: meta,
        //       child: Text(
        //         value.toInt().toString(),
        //         style: theme.textTheme.bodySmall,
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<ComparisonData> data) {
    return List.generate(
      data.length,
          (index) {
        final item = data[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item.value,
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
    );
  }

  BarTouchData _buildBarTouchData(List<ComparisonData> data, ThemeData theme) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final item = data[group.x];
          return BarTooltipItem(
            item.name,
            theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: '\n${item.value.toStringAsFixed(2)} kWh',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              TextSpan(
                text: '\nCost: \${(item.value * 0.15).toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        },
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
}

/// Device comparison insights widget
class _DeviceComparisonInsights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();
    final theme = Theme.of(context);

    return Obx(() {
      final data = controller.deviceComparisonData;

      if (data.isEmpty) {
        return const SizedBox.shrink();
      }

      // Sort data by energy consumption (descending)
      final sortedData = List<ComparisonData>.from(data)
        ..sort((a, b) => b.value.compareTo(a.value));

      final highestConsumer = sortedData.first;
      final lowestConsumer = sortedData.last;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
    });
  }
}

/// Time period comparison card
class TimePeriodComparisonCard extends StatelessWidget {
  const TimePeriodComparisonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();
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
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _TimePeriodComparisonChart(),
            ),
            const SizedBox(height: 16),
            _TimePeriodComparisonInsights(),
          ],
        ),
      ),
    );
  }
}

/// Optimized time period comparison chart
class _TimePeriodComparisonChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();
    final theme = Theme.of(context);

    return Obx(() {
      final data = controller.periodComparisonData;

      if (data.isEmpty) {
        return const Center(child: Text('No time period comparison data available'));
      }

      // Pre-calculate max value
      final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.dividerColor.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: _buildTitlesData(data, theme),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          barGroups: _buildBarGroups(data),
          barTouchData: _buildBarTouchData(data, theme),
        ),
      );
    });
  }

  FlTitlesData _buildTitlesData(List<ComparisonData> data, ThemeData theme) {
    return FlTitlesData(
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
            if (index >= 0 && index < data.length) {
              final periodName = data[index].name;
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
        sideTitles: SideTitles(showTitles: false),
        // sideTitles: SideTitles(
        //   showTitles: true,
        //   reservedSize: 42,
        //   interval: 5,
        //   getTitlesWidget: (value, meta) {
        //     return SideTitleWidget(
        //       meta: meta,
        //       child: Text(
        //         value.toInt().toString(),
        //         style: theme.textTheme.bodySmall,
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<ComparisonData> data) {
    return List.generate(
      data.length,
          (index) {
        final item = data[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item.value,
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
    );
  }

  BarTouchData _buildBarTouchData(List<ComparisonData> data, ThemeData theme) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final item = data[group.x];
          return BarTooltipItem(
            item.name,
            theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: '\n${item.value.toStringAsFixed(2)} kWh',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              TextSpan(
                text: '\nCost: \$${(item.value * 0.15).toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Time period comparison insights widget
class _TimePeriodComparisonInsights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();
    final theme = Theme.of(context);

    return Obx(() {
      final data = controller.periodComparisonData;

      if (data.length < 2) {
        return const SizedBox.shrink();
      }

      final period1 = data[0];
      final period2 = data[1];

      final difference = period2.value - period1.value;
      final percentChange = period1.value > 0
          ? (difference / period1.value) * 100
          : 0.0;

      final isIncrease = difference > 0;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isIncrease ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isIncrease ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
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
    });
  }
}

/// Efficiency comparison card
class EfficiencyComparisonCard extends StatelessWidget {
  const EfficiencyComparisonCard({super.key});

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
              'Efficiency Comparison',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _EfficiencyComparisonList(),
            const SizedBox(height: 16),
            _EfficiencyRecommendations(),
          ],
        ),
      ),
    );
  }
}

/// Efficiency comparison list with optimized rendering
class _EfficiencyComparisonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComparisonController>();

    return Obx(() {
      if (controller.deviceComparisonData.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No efficiency data available'),
          ),
        );
      }

      // Calculate efficiency data - moved to a separate method for better performance
      final efficiencyData = _calculateEfficiencyData(controller);

      // Use ListView.builder for more efficient rendering of list items
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: efficiencyData.length,
        itemBuilder: (context, index) {
          return _EfficiencyItemRow(
            rank: index + 1,
            data: efficiencyData[index],
          );
        },
      );
    });
  }

  List<EfficiencyData> _calculateEfficiencyData(ComparisonController controller) {
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

    return efficiencyData;
  }
}

/// Individual efficiency item row
class _EfficiencyItemRow extends StatelessWidget {
  final int rank;
  final EfficiencyData data;

  const _EfficiencyItemRow({
    required this.rank,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine color based on efficiency score - cached calculation
    final colorInfo = _getColorAndLabel(data.score);

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
                  color: colorInfo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  colorInfo.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorInfo.color,
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
                  color: colorInfo.color,
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

  _ColorInfo _getColorAndLabel(double score) {
    if (score >= 80) {
      return _ColorInfo(Colors.green, 'Excellent');
    } else if (score >= 60) {
      return _ColorInfo(Colors.lightGreen, 'Good');
    } else if (score >= 40) {
      return _ColorInfo(Colors.amber, 'Average');
    } else if (score >= 20) {
      return _ColorInfo(Colors.orange, 'Poor');
    } else {
      return _ColorInfo(Colors.red, 'Very Poor');
    }
  }
}

class _ColorInfo {
  final Color color;
  final String label;

  const _ColorInfo(this.color, this.label);
}

/// Efficiency recommendations widget
class _EfficiencyRecommendations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
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
    );
  }
}
