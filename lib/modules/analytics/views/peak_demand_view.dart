import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../controller/peak_demand_controller.dart';

class PeakDemandView extends StatelessWidget {
  const PeakDemandView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PeakDemandController>();
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: controller.fetchPeakDemandSummary,
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
                  onPressed: controller.fetchPeakDemandSummary,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Peak Demand Overview Card
            _buildPeakDemandOverviewCard(controller, context),

            const SizedBox(height: 24),

            // Date Selector
            _buildDateSelector(controller, context),

            const SizedBox(height: 16),

            // Hourly Demand Chart
            _buildHourlyDemandCard(controller, context),

            const SizedBox(height: 24),

            // Peak Hours Analysis
            _buildPeakHoursAnalysisCard(controller, context),

            const SizedBox(height: 24),

            // Cost Saving Opportunities
            _buildCostSavingCard(controller, context),
          ],
        );
      }),
    );
  }

  Widget _buildPeakDemandOverviewCard(PeakDemandController controller, BuildContext context) {
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
              Colors.red.shade700.withOpacity(0.8),
              Colors.red.shade700,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Peak Demand Overview',
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Peak Demand',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          '${controller.overallPeakDemand.value.toStringAsFixed(2)} kW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        )),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          'on ${controller.overallPeakDate.value != null ? DateFormat('MMM d, yyyy').format(controller.overallPeakDate.value!) : 'Unknown'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        )),
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Peak Hour',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          '${controller.overallPeakHour.value.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        )),
                        const SizedBox(height: 4),
                        Text(
                          'Highest demand time',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Reducing usage during peak hours can significantly lower your energy costs.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(PeakDemandController controller, BuildContext context) {
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
              'Select Date',
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
                        initialDate: controller.selectedDate.value,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      if (picked != null) {
                        controller.setSelectedDate(picked);
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
                            DateFormat('EEEE, MMM d, yyyy').format(controller.selectedDate.value),
                            style: theme.textTheme.bodyMedium,
                          )),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchPeakDemandForDate(),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyDemandCard(PeakDemandController controller, BuildContext context) {
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
                  'Hourly Demand',
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
                  return const Icon(Icons.show_chart, color: Colors.blue);
                }),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Energy demand by hour for ${DateFormat('MMM d, yyyy').format(controller.selectedDate.value)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Obx(() {
                if (controller.hourlyDemandData.isEmpty) {
                  return const Center(child: Text('No hourly demand data available'));
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: controller.hourlyDemandData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.5,
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
                            if (index >= 0 && index < controller.hourlyDemandData.length) {
                              final hour = controller.hourlyDemandData[index].hour;
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  '${hour.toString().padLeft(2, '0')}',
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
                          interval: 0.5,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(1),
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
                      controller.hourlyDemandData.length,
                          (index) {
                        final data = controller.hourlyDemandData[index];

                        // Determine color based on demand level
                        Color barColor;
                        if (data.hour == controller.dailyPeakHour.value) {
                          barColor = Colors.red;
                        } else if (data.value > controller.overallPeakDemand.value * 0.8) {
                          barColor = Colors.orange;
                        } else if (data.value > controller.overallPeakDemand.value * 0.6) {
                          barColor = Colors.amber;
                        } else {
                          barColor = Colors.green;
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.value,
                              color: barColor,
                              width: 12,
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
                          final data = controller.hourlyDemandData[group.x];
                          return BarTooltipItem(
                            '${data.hour.toString().padLeft(2, '0')}:00',
                            theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '\n${data.value.toStringAsFixed(2)} kW',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              TextSpan(
                                text: '\nCost: \$${(data.value * 0.15).toStringAsFixed(2)}/hr',
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
                _buildDemandLegendItem('Low', Colors.green, context),
                const SizedBox(width: 16),
                _buildDemandLegendItem('Medium', Colors.amber, context),
                const SizedBox(width: 16),
                _buildDemandLegendItem('High', Colors.orange, context),
                const SizedBox(width: 16),
                _buildDemandLegendItem('Peak', Colors.red, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemandLegendItem(String label, Color color, BuildContext context) {
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

  Widget _buildPeakHoursAnalysisCard(PeakDemandController controller, BuildContext context) {
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
              'Peak Hours Analysis',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.hourlyDemandData.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No peak hours data available'),
                  ),
                );
              }

              // Sort data by demand (descending)
              final sortedData = List<HourlyDemandData>.from(controller.hourlyDemandData)
                ..sort((a, b) => b.value.compareTo(a.value));

              // Take top 5 peak hours
              final topPeakHours = sortedData.take(5).toList();

              return Column(
                children: [
                  for (int i = 0; i < topPeakHours.length; i++)
                    _buildPeakHourItem(
                      i + 1,
                      topPeakHours[i].hour,
                      topPeakHours[i].value,
                      controller.overallPeakDemand.value,
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
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Understanding Peak Hours',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Peak hours are times when electricity demand is highest. Utility companies often charge higher rates during these hours to manage grid load. By shifting your energy usage to off-peak hours, you can significantly reduce your electricity costs.',
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

  Widget _buildPeakHourItem(int rank, int hour, double demand, double maxDemand, BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (demand / maxDemand) * 100;

    // Determine color based on rank
    Color color;
    if (rank == 1) {
      color = Colors.red;
    } else if (rank == 2) {
      color = Colors.orange;
    } else if (rank == 3) {
      color = Colors.amber;
    } else {
      color = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00',
                style: theme.textTheme.titleSmall,
              ),
              Text(
                '${demand.toStringAsFixed(2)} kW (${percentage.toStringAsFixed(0)}% of peak)',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Cost',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '\$${(demand * 0.15).toStringAsFixed(2)}/hr',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostSavingCard(PeakDemandController controller, BuildContext context) {
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
              'Cost Saving Opportunities',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.savings,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Potential Monthly Savings',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Obx(() {
                              // Calculate potential savings (simplified)
                              // In a real app, this would be more sophisticated
                              final peakHourUsage = controller.hourlyDemandData.isNotEmpty
                                  ? controller.hourlyDemandData.map((e) => e.value).reduce((a, b) => a > b ? a : b)
                                  : 0.0;

                              final potentialSavings = peakHourUsage * 0.15 * 30 * 0.2; // 20% reduction

                              return Text(
                                '\$${potentialSavings.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recommendations',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              'Shift high-power activities to off-peak hours (before 5 PM or after 9 PM)',
              Icons.schedule,
              context,
            ),
            _buildRecommendationItem(
              'Use smart plugs to automatically control devices during peak hours',
              Icons.power,
              context,
            ),
            _buildRecommendationItem(
              'Consider installing a home battery system to store energy during off-peak hours',
              Icons.battery_charging_full,
              context,
            ),
            _buildRecommendationItem(
              'Upgrade to energy-efficient appliances that consume less power',
              Icons.eco,
              context,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to detailed recommendations
                  Get.toNamed('/recommendations');
                },
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Get Detailed Recommendations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation, IconData icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(recommendation),
          ),
        ],
      ),
    );
  }
}
