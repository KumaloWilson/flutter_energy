import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:intl/intl.dart';

class DeviceControlCard extends StatelessWidget {
  final ApplianceReading reading;
  final bool isControlLoading;
  final VoidCallback onToggle;
  final double monthlyConsumption;

  const DeviceControlCard({
    super.key,
    required this.reading,
    required this.isControlLoading,
    required this.onToggle,
    this.monthlyConsumption = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = reading.applianceInfo.relayStatus == 'ON';
    final deviceName = reading.applianceInfo.appliance;
    final energy = double.parse(reading.activeEnergy);
    final formattedEnergy = energy.toStringAsFixed(2);
    final formattedDate = DateFormat('MMM d, h:mm a').format(reading.readingTimeStamp);

    final deviceIcon = _getDeviceIcon(deviceName);
    final deviceColor = isOn ? Colors.green : Colors.grey;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOn ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
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
                      deviceIcon,
                      color: deviceColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deviceName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rated: ${reading.applianceInfo.ratedPower}W',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildDeviceSwitch(isOn),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  context,
                  'Current',
                  '${reading.current}A',
                  Icons.bolt,
                ),
                _buildInfoColumn(
                  context,
                  'Voltage',
                  '${reading.voltage}V',
                  Icons.electrical_services,
                ),
                _buildInfoColumn(
                  context,
                  'Energy',
                  '$formattedEnergy kWh',
                  Icons.power,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly: ${monthlyConsumption.toStringAsFixed(2)} kWh',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Last updated: $formattedDate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSwitch(bool isOn) {
    return isControlLoading
        ? const SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    )
        : Switch(
      value: isOn,
      onChanged: (_) => onToggle(),
      activeColor: Colors.green,
    );
  }

  Widget _buildInfoColumn(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();

    if (name.contains('light') || name.contains('lamp')) {
      return Icons.lightbulb;
    } else if (name.contains('tv') || name.contains('television')) {
      return Icons.tv;
    } else if (name.contains('fridge') || name.contains('refrigerator')) {
      return Icons.kitchen;
    } else if (name.contains('ac') || name.contains('air')) {
      return Icons.ac_unit;
    } else if (name.contains('heater')) {
      return Icons.whatshot;
    } else if (name.contains('fan')) {
      return Icons.toys;
    } else if (name.contains('oven') || name.contains('stove')) {
      return Icons.microwave;
    } else if (name.contains('washer') || name.contains('washing')) {
      return Icons.local_laundry_service;
    } else if (name.contains('computer') || name.contains('pc')) {
      return Icons.computer;
    } else {
      return Icons.electrical_services;
    }
  }
}
