import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnergyCard extends StatelessWidget {
  final double totalEnergy;

  const EnergyCard({
    super.key,
    required this.totalEnergy,
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
                  'Total Energy',
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
            const SizedBox(height: 8),
            Text(
              '${totalEnergy.toStringAsFixed(2)} Wh',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.7, // This would be calculated based on daily target
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Text(
              '70% of daily target',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

