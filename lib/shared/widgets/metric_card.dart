import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool showTrend;
  final double? trendValue;
  final bool animate;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.showTrend = false,
    this.trendValue,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (showTrend && trendValue != null)
                  _buildTrendIndicator(context),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (animate) {
      return card
          .animate()
          .fadeIn()
          .scale(
        begin: const Offset(0.95, 0.95),
        duration: 250.ms,
      )
          .then()
          .shimmer(
        duration: 1000.ms,
        color: color.withOpacity(0.1),
      );
    }

    return card;
  }

  Widget _buildTrendIndicator(BuildContext context) {
    final isPositive = trendValue! >= 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: isPositive ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${trendValue!.abs().toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
