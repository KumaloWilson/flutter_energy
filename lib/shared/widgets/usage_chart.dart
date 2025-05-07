import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:intl/intl.dart';

class UsageChart extends StatefulWidget {
  // Add deviceId parameter, which can be null to show all devices
  final int? deviceId;

  const UsageChart({
    this.deviceId,
    super.key
  });

  @override
  State<UsageChart> createState() => _UsageChartState();
}

class _UsageChartState extends State<UsageChart> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final DashboardController _controller = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initial fetch with the device ID if provided
    _controller.fetchUsageData(deviceId: widget.deviceId);
    _animationController.forward();
  }

  @override
  void didUpdateWidget(UsageChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the deviceId changes, refetch data
    if (widget.deviceId != oldWidget.deviceId) {
      _controller.fetchUsageData(deviceId: widget.deviceId);
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // If data changes, restart the animation
      if (_controller.usageDataUpdated.value) {
        _animationController.reset();
        _animationController.forward();
        // Reset the flag
        _controller.usageDataUpdated.value = false;
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title shows if we're viewing a specific device
              if (widget.deviceId != null)
                Expanded(
                  child: Text(
                    _getDeviceName(widget.deviceId!),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              DropdownButton<String>(
                value: _controller.selectedTimeRange.value,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _controller.updateTimeRange(newValue, deviceId: widget.deviceId);
                  }
                },
                items: ['Today', 'Week', 'Month', 'Year']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (_controller.isLoadingUsageData.value)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              Chip(
                label: Text(
                  'Last updated: ${_formatLastUpdated(_controller.lastUsageDataUpdate.value)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _controller.usageData.isEmpty
                    ? _buildEmptyChart(context)
                    : _buildChart(context, _animation.value);
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                context,
                'Energy Usage',
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 24),
              _buildLegendItem(
                context,
                'Average',
                Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                isDashed: true,
              ),
            ],
          ),
        ],
      );
    });
  }

  // Helper method to get a device name for the title
  String _getDeviceName(int deviceId) {
    final device = _controller.devices.firstWhereOrNull((device) => device.id == deviceId);
    return device?.appliance ?? 'Device $deviceId';
  }

  Widget _buildChart(BuildContext context, double animationValue) {
    // Calculate maxY and ensure it's not zero or too small
    final calculatedMaxY = _controller.maxUsageValue.value * 1.2;
    final maxY = calculatedMaxY <= 0.01 ? 1.0 : calculatedMaxY; // Use default value if too small
    final minY = 0.0;

    // Calculate a safe interval value that won't be zero
    final horizontalInterval = maxY / 4 <= 0.01 ? 0.25 : maxY / 4;

    // Figure out the chart's approximate width to help with x-axis label spacing
    final chartWidth = MediaQuery.of(context).size.width - 40; // Approximate chart width

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: horizontalInterval, // Now using safe value
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  '${value.toStringAsFixed(1)} kWh',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
              interval: horizontalInterval, // Using the same safe interval
            ),
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
                if (value < 0 || value >= _controller.usageData.length) {
                  return const Text('');
                }

                // Calculate how many labels we can show based on available width
                // Only show every nth label to avoid overcrowding
                final totalLabels = _controller.usageData.length;
                int interval = 1;

                // Estimate available width per label
                final estimatedAvailableWidthPerLabel = chartWidth / totalLabels;
                final averageLabelWidth = 40.0; // Estimate of average label width in pixels

                // Adjust interval based on number of data points and available width
                if (estimatedAvailableWidthPerLabel < averageLabelWidth) {
                  // Calculate how many labels we can fit
                  interval = (averageLabelWidth / estimatedAvailableWidthPerLabel).ceil();
                  // Ensure we show at least 4 labels and at most 10
                  interval = interval.clamp(totalLabels ~/ 10, totalLabels ~/ 4).clamp(1, 10);
                }

                // Only show label if it's at the interval or first/last point
                if (value.toInt() % interval == 0 ||
                    value.toInt() == 0 ||
                    value.toInt() == totalLabels - 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RotatedBox(
                      quarterTurns: estimatedAvailableWidthPerLabel < 30 ? 1 : 0, // Rotate text if labels are crowded
                      child: Text(
                        _controller.usageLabels[value.toInt()],
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                } else {
                  return const Text('');
                }
              },
              reservedSize: 30, // Increase space for labels
              interval: 1,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: _controller.usageData.isEmpty ? 0 : _controller.usageData.length - 1.0,
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index < 0 || index >= _controller.usageData.length) {
                  return null;
                }

                final value = barSpot.y;
                final label = _controller.usageLabels[index];

                // Add device name to tooltip if viewing a specific device
                final deviceName = widget.deviceId != null ? _getDeviceName(widget.deviceId!) + ': ' : '';

                return LineTooltipItem(
                  '$deviceName$label: ${value.toStringAsFixed(2)} kWh',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          // Main usage line
          LineChartBarData(
            spots: _controller.usageData.isEmpty
                ? [const FlSpot(0, 0)]
                : List.generate(_controller.usageData.length, (index) {
              return FlSpot(
                index.toDouble(),
                _controller.usageData[index] * animationValue,
              );
            }),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).colorScheme.surface,
                );
              },
              checkToShowDot: (spot, barData) {
                // Only show dots if we have data
                if (_controller.usageData.isEmpty) return false;

                // Only show dots for the first and last points, and for significant changes
                final index = spot.x.toInt();
                if (index == 0 || index == _controller.usageData.length - 1) {
                  return true;
                }

                // Show dot if there's a significant change
                if (index > 0 && index < _controller.usageData.length - 1) {
                  final prev = _controller.usageData[index - 1];
                  final curr = _controller.usageData[index];
                  final next = _controller.usageData[index + 1];

                  final changeFromPrev = (curr - prev).abs();
                  final changeToNext = (next - curr).abs();

                  // If this point represents a peak or valley
                  if ((curr > prev && curr > next) || (curr < prev && curr < next)) {
                    return true;
                  }

                  final significanceThreshold = _controller.maxUsageValue.value * 0.15;
                  // If there's a significant change
                  if ((significanceThreshold > 0) &&
                      (changeFromPrev > significanceThreshold ||
                          changeToNext > significanceThreshold)) {
                    return true;
                  }
                }

                return false;
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Average line
          if (_controller.showAverage.value && _controller.averageUsage.value > 0)
            LineChartBarData(
              spots: _controller.usageData.isEmpty
                  ? [const FlSpot(0, 0)]
                  : List.generate(_controller.usageData.length, (index) {
                return FlSpot(
                  index.toDouble(),
                  _controller.averageUsage.value * animationValue,
                );
              }),
              isCurved: false,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            widget.deviceId == null
                ? 'No usage data available'
                : 'No usage data available for this device',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _controller.fetchUsageData(deviceId: widget.deviceId),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: isDashed
              ? LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final dashWidth = width / 5;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                      (index) => Container(
                    width: dashWidth,
                    height: 3,
                    color: color,
                  ),
                ),
              );
            },
          )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatLastUpdated(DateTime? dateTime) {
    if (dateTime == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }
}