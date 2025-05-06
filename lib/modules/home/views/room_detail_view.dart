import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/analytics/views/device_details_view.dart';
import 'package:flutter_energy/modules/home/models/appliance_model.dart';
import 'package:flutter_energy/modules/home/views/add_appliance_view.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/home/controllers/home_controller.dart';
import 'package:flutter_energy/modules/home/models/room_model.dart';
import 'package:flutter_energy/shared/widgets/appliance_card.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';

import '../../appliance/view/appliance_detail_view.dart';

class RoomDetailView extends StatelessWidget {
  final RoomModel room;

  const RoomDetailView({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchDevices(),
            tooltip: 'Refresh Devices',
          ),
        ],
      ),
      body: Obx(() {
        final devices = controller.devicesByRoom[room.id] ?? [];

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDevices(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: devices.isEmpty
                ? _buildEmptyState(context)
                : ListView(
              children: [
                // Room Stats Card
                _buildRoomStatsCard(context, devices),

                const SizedBox(height: 24),

                // Devices Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Devices',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Get.to(
                        () => AddApplianceView(),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Device'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Devices List
                ...devices.map((device) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildApplianceCard(context, controller, device),
                )),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(
              () => AddApplianceView(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
      ),
    );
  }

  Widget _buildApplianceCard(BuildContext context, HomeController controller, ApplianceInfo device) {
    // Convert ApplianceInfo to ApplianceModel for the card
    final applianceModel = ApplianceModel(
      id: device.id.toString(),
      name: device.appliance,
      type: _determineDeviceType(device.appliance),
      wattage: double.parse(device.ratedPower.split(' ').first),
      roomId: room.id,
      meterNumber: device.meterNumber,
      createdAt: DateTime.now(),
      isActive: device.relayStatus == 'ON',
    );

    return ApplianceCard(
      appliance: applianceModel,
      onTap: () => Get.to(
        () => DeviceDetailsView(deviceId: device.id ,deviceName: applianceModel.name,),
      ),
      onToggle: (_) => _toggleDevice(controller, device),
      showDetails: true,
      showRoomTransfer: true,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 72,
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
          const SizedBox(height: 24),
          Text(
            'No devices in this room',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add devices to monitor energy usage',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => AddApplianceView(),
            icon: const Icon(Icons.add),
            label: const Text('Add Device'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStatsCard(BuildContext context, List<ApplianceInfo> devices) {
    // Calculate total power consumption
    double totalConsumption = 0;
    int activeDevices = 0;

    for (final device in devices) {
      // Check if the device is active
      if (device.relayStatus == 'ON') {
        activeDevices++;
      }

      final power = double.tryParse(device.ratedPower.split(' ').first) ?? 0;
      totalConsumption += device.relayStatus == 'ON' ? power * 0.1 : 0;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Total Devices',
                  devices.length.toString(),
                  Icons.devices,
                ),
                _buildStatItem(
                  context,
                  'Active Devices',
                  activeDevices.toString(),
                  Icons.power,
                  activeDevices > 0 ? Theme.of(context).colorScheme.primary : null,
                ),
                _buildStatItem(
                  context,
                  'Est. Usage',
                  '${totalConsumption.toStringAsFixed(1)} kWh',
                  Icons.show_chart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      String label,
      String value,
      IconData icon, [
        Color? color,
      ]) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.primary.withAlpha(180),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
          ),
        ),
      ],
    );
  }

  void _toggleDevice(HomeController controller, ApplianceInfo device) {
    controller.toggleDevice(device).then((success) {
      if (!success) {
        Get.snackbar(
          'Error',
          'Failed to toggle device: ${controller.errorMessage.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withAlpha(150),
          colorText: Colors.white,
        );
      }
    });
  }

  String _determineDeviceType(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('light') || name.contains('lamp')) return 'lighting';
    if (name.contains('tv') || name.contains('television')) return 'entertainment';
    if (name.contains('fridge') || name.contains('refrigerator')) return 'refrigeration';
    if (name.contains('ac') || name.contains('air')) return 'cooling';
    if (name.contains('heater')) return 'heating';
    if (name.contains('oven') || name.contains('stove')) return 'cooking';
    return 'other';
  }
}
