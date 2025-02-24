import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final List<Stat> stats;

  const StatsCard({
    super.key,
    required this.title,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: stats.map((stat) {
                final index = stats.indexOf(stat);
                return Expanded(
                  child: StatItem(
                    stat: stat,
                    showDivider: index < stats.length - 1,
                  ).animate().fadeIn(delay: (200 * index).ms).slideY(),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final Stat stat;
  final bool showDivider;

  const StatItem({
    super.key,
    required this.stat,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Icon(
                stat.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                stat.label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                stat.value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: stat.isPositive == null
                      ? null
                      : (stat.isPositive!
                      ? Colors.green
                      : Colors.red),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        if (showDivider)
          VerticalDivider(
            color: Theme.of(context).colorScheme.outlineVariant,
            indent: 8,
            endIndent: 8,
          ),
      ],
    );
  }
}

class Stat {
  final String label;
  final String value;
  final IconData icon;
  final bool? isPositive;

  Stat({
    required this.label,
    required this.value,
    required this.icon,
    this.isPositive,
  });
}

