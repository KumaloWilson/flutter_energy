import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PredictionCard extends StatelessWidget {
  final double predictedUsage;
  final double costSavingTarget;

  const PredictionCard({
    super.key,
    required this.predictedUsage,
    required this.costSavingTarget,
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
                  'Predictions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _PredictionItem(
              icon: Icons.calendar_month,
              title: 'Predicted Monthly Usage',
              value: '${predictedUsage.toStringAsFixed(2)} kWh',
              subtitle: 'Based on current consumption pattern',
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 16),
            _PredictionItem(
              icon: Icons.savings,
              title: 'Potential Cost Savings',
              value: '\$${costSavingTarget.toStringAsFixed(2)}',
              subtitle: 'Achievable through optimized usage',
              positive: true,
            ).animate().fadeIn(delay: 200.ms).slideX(),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('View Detailed Report'),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _PredictionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool positive;

  const _PredictionItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.positive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: positive ? Colors.green : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

