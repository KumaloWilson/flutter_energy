import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnergyCard extends StatelessWidget {
  final double totalEnergy;
  final double monthlyEnergy;
  final bool isLoadingMonthly;

  const EnergyCard({
    super.key,
    required this.totalEnergy,
    required this.monthlyEnergy,
    this.isLoadingMonthly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Energy Consumption',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  Icons.bolt,
                  color: Theme.of(context).colorScheme.primary,
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).shimmer(
                  duration: 2000.ms,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEnergyInfo(
                  context: context,
                  title: 'Current',
                  value: totalEnergy,
                  unit: 'Wh',
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                _buildEnergyInfo(
                  context: context,
                  title: 'This Month',
                  value: monthlyEnergy,
                  unit: 'kWh',
                  isLoading: isLoadingMonthly,
                  valueScale: 0.001, // Convert Wh to kWh
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.7, // This would be calculated based on daily target
              backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: .2),
            ),
            const SizedBox(height: 8),
            Text(
              'Energy Consumption this month',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyInfo({
    required BuildContext context,
    required String title,
    required double value,
    required String unit,
    bool isLoading = false,
    double valueScale = 1.0,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          isLoading
              ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(
            '${(value * valueScale).toStringAsFixed(2)} $unit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}