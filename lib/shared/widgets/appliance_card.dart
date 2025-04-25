import 'package:flutter/material.dart';

import '../../modules/rooms/model/appliance.dart';

class ApplianceCard extends StatelessWidget {
  final Appliance appliance;
  final VoidCallback onTap;
  final Function(bool) onToggle;

  const ApplianceCard({
    super.key,
    required this.appliance,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(appliance.iconName),
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  Switch(
                    value: appliance.isOn,
                    onChanged: onToggle,
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                appliance.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.bolt,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${appliance.power.toStringAsFixed(1)} W',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'lightbulb':
        return Icons.lightbulb;
      case 'tv':
        return Icons.tv;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'kitchen':
        return Icons.kitchen;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'air':
        return Icons.air;
      default:
        return Icons.devices;
    }
  }
}
