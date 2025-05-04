import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/home/models/appliance_model.dart';
import 'package:intl/intl.dart';

class ApplianceCard extends StatelessWidget {
  final ApplianceModel appliance;
  final VoidCallback onTap;
  final Function(bool) onToggle;
  final bool showDetails;

  const ApplianceCard({
    super.key,
    required this.appliance,
    required this.onTap,
    required this.onToggle,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: appliance.isActive
              ? Theme.of(context).colorScheme.primary.withAlpha(100)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appliance.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getApplianceType(appliance.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Power toggle
                  Switch(
                    value: appliance.isActive,
                    onChanged: (value) => onToggle(value),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (showDetails && appliance.currentReading != null) ...[
                Row(
                  children: [
                    _buildInfoTile(
                      context,
                      'Current',
                      '${appliance.currentReading!.toStringAsFixed(1)} kWh',
                      Icons.power,
                    ),
                    if (appliance.dailyUsage != null)
                      _buildInfoTile(
                        context,
                        'Daily',
                        '${appliance.dailyUsage!.toStringAsFixed(1)} kWh',
                        Icons.today,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                if (appliance.lastUpdated != null)
                  Text(
                    'Last reading: ${DateFormat('MMM d, h:mm a').format(appliance.lastUpdated!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                      fontSize: 10,
                    ),
                  ),
              ] else if (showDetails) ...[
                const Text(
                  'No reading data available',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Status indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appliance.isActive
                          ? Theme.of(context).colorScheme.primary.withAlpha(50)
                          : Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          appliance.isActive ? Icons.check_circle : Icons.power_off,
                          size: 12,
                          color: appliance.isActive
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appliance.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: appliance.isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                        ),
                      ],
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

  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary.withAlpha(180),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getApplianceType(String type) {
    // Convert type like 'refrigerator' to 'Refrigerator'
    if (type.isEmpty) return 'Unknown Type';
    return type[0].toUpperCase() + type.substring(1);
  }
}
