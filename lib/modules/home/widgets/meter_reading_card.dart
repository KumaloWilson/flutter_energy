import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_energy/modules/home/models/home_model.dart';

class MeterReadingCard extends StatelessWidget {
  final HomeModel home;
  final Function(double) onUpdateReading;

  const MeterReadingCard({
    super.key,
    required this.home,
    required this.onUpdateReading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.electric_meter,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Meter Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showUpdateReadingDialog(context),
                  tooltip: 'Update Reading',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Meter Number',
                    home.meterNumber,
                    Icons.pin,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Current Reading',
                    '${home.currentReading.toStringAsFixed(1)} kWh',
                    Icons.power,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (home.lastUpdated != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Last updated: ${DateFormat('MMM d, h:mm a').format(home.lastUpdated!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
          ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showUpdateReadingDialog(BuildContext context) {
    final readingController = TextEditingController(
      text: home.currentReading.toString(),
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Update Meter Reading'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: readingController,
              decoration: const InputDecoration(
                labelText: 'Current Reading (kWh)',
                hintText: 'Enter your meter reading',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reading = double.tryParse(readingController.text);
              if (reading != null) {
                onUpdateReading(reading);
                Get.back();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
