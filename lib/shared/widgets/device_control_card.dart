import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../modules/analytics/views/device_details_view.dart';
import '../../modules/home/controllers/home_controller.dart';

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

    final deviceIcon = _getDeviceIcon(deviceName);
    final deviceColor = isOn ? Colors.green : Colors.grey;
    final HomeController homeController = Get.find<HomeController>();

    return Slidable(
      key: ValueKey(reading.applianceInfo.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showEditDialog(context),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          // Navigate to device details screen
          Get.to(
                () => DeviceDetailsView(
              deviceId: reading.applianceInfo.id,
              deviceName: deviceName,
            ),
          );
        },
        child: Card(
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
                              'Rated: ${reading.applianceInfo.ratedPower}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Obx(() => homeController.isDeviceActionLoading(reading.applianceInfo.id)
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : _buildDeviceSwitch(isOn),
                    ),
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
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditDialog(context),
                          tooltip: 'Edit device',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _confirmDelete(context),
                          tooltip: 'Delete device',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap for detailed analytics',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final TextEditingController nameController = TextEditingController(text: reading.applianceInfo.appliance);
    final TextEditingController powerController = TextEditingController(
      text: reading.applianceInfo.ratedPower.replaceAll(' W', ''),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                hintText: 'Enter device name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: powerController,
              decoration: const InputDecoration(
                labelText: 'Rated Power (W)',
                hintText: 'Enter rated power in watts',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Update the device
              homeController.updateAppliance(
                reading.applianceInfo,
                newName: nameController.text.trim(),
                newRatedPower: '${powerController.text.trim()} W',
              );

              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete ${reading.applianceInfo.appliance}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete the device
              homeController.deleteAppliance(reading.applianceInfo);

              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
