import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/routes/app_pages.dart';
import 'package:get/get.dart';

class ApplianceCard extends StatelessWidget {
  final ApplianceReading reading;
  final VoidCallback? onLongPress; // Add this parameter

  const ApplianceCard({
    super.key,
    required this.reading,
    this.onLongPress, // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.APPLIANCE_DETAIL,
          arguments: reading,
        ),
        onLongPress: onLongPress, // Add this line
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reading.applianceInfo.appliance,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rated Power: ${reading.applianceInfo.ratedPower}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${reading.activeEnergy} Wh',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    context,
                    'Voltage',
                    '${reading.voltage}V',
                    Icons.electric_bolt,
                  ),
                  _buildInfoItem(
                    context,
                    'Current',
                    '${reading.current}A',
                    Icons.speed,
                  ),
                  _buildInfoItem(
                    context,
                    'Time On',
                    '${reading.timeOn}min',
                    Icons.timer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}