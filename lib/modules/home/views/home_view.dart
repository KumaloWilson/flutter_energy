import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/home/views/room_detail_view.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/home/controllers/home_controller.dart';
import 'package:flutter_energy/modules/home/widgets/room_card.dart';
import 'package:flutter_energy/shared/widgets/appliance_card.dart';
import 'package:flutter_energy/modules/home/models/appliance_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchHomeData(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchHomeData(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${controller.errorMessage.value}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchHomeData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Home Info Card
                _buildHomeInfoCard(context, controller),

                const SizedBox(height: 24),

                // Rooms Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rooms',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddRoomDialog(context, controller),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Room'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rooms Grid
                _buildRoomsGrid(context, controller),

                const SizedBox(height: 24),

                // Quick Access Devices
                Text(
                  'Quick Access',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Access Devices List
                _buildQuickAccessDevices(context, controller),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRoomDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
      ),
    );
  }

  Widget _buildHomeInfoCard(BuildContext context, HomeController controller) {
    final home = controller.currentHome.value;

    if (home == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      home.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Meter #: ${home.meterNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showUpdateMeterDialog(context, controller),
                  tooltip: 'Update Meter Reading',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHomeStatItem(
                  context,
                  'Current Reading',
                  '${home.currentReading.toStringAsFixed(1)} kWh',
                  Icons.electric_meter,
                ),
                _buildHomeStatItem(
                  context,
                  'Total Rooms',
                  controller.rooms.length.toString(),
                  Icons.meeting_room,
                ),
                _buildHomeStatItem(
                  context,
                  'Total Devices',
                  controller.allDevices.length.toString(),
                  Icons.devices,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeStatItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary.withAlpha(180),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
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

  Widget _buildRoomsGrid(BuildContext context, HomeController controller) {
    final rooms = controller.rooms;

    if (rooms.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.meeting_room, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No rooms added yet'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showAddRoomDialog(context, controller),
              child: const Text('Add Room'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final devices = controller.devicesByRoom[room.id] ?? [];

        return RoomCard(
          room: room,
          deviceCount: devices.length,
          onTap: () => Get.to(() => RoomDetailView(room: room)),
        );
      },
    );
  }

  Widget _buildQuickAccessDevices(BuildContext context, HomeController controller) {
    final allDevices = controller.allDevices;

    if (allDevices.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.devices, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No devices added yet'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (controller.rooms.isEmpty) {
                  _showAddRoomDialog(context, controller);
                } else {
                  Get.toNamed('/add-appliance', arguments: {'roomId': controller.rooms.first.id});
                }
              },
              child: const Text('Add Device'),
            ),
          ],
        ),
      );
    }

    // Show only the first 3 devices for quick access
    final quickAccessDevices = allDevices.take(3).toList();

    return Column(
      children: quickAccessDevices.map((device) {
        // Find which room this device belongs to
        String roomId = '';
        String roomName = 'Unknown Room';

        for (final entry in controller.devicesByRoom.entries) {
          if (entry.value.any((d) => d.id == device.id)) {
            roomId = entry.key;
            final room = controller.rooms.firstWhereOrNull((r) => r.id == roomId);
            if (room != null) {
              roomName = room.name;
            }
            break;
          }
        }

        // Convert to ApplianceModel for the card
        final applianceModel = ApplianceModel(
          id: device.id.toString(),
          name: device.appliance,
          type: _determineDeviceType(device.appliance),
          wattage: double.parse(device.ratedPower.split(' ').first),
          roomId: roomId,
          meterNumber: device.meterNumber,
          createdAt: DateTime.now(),
          isActive: device.relayStatus == 'ON',
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ApplianceCard(
            appliance: applianceModel,
            onTap: () => Get.toNamed('/appliance-details', arguments: {'appliance': device}),
            onToggle: (_) => controller.toggleDevice(device),
            showDetails: false,
            showRoomTransfer: true,
          ),
        );
      }).toList(),
    );
  }

  void _showAddRoomDialog(BuildContext context, HomeController controller) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Room'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Room Name',
            hintText: 'e.g., Living Room, Kitchen',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Room name cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.8),
                  colorText: Colors.white,
                );
                return;
              }

              controller.addRoom(name).then((success) {
                Get.back();
                if (success) {
                  Get.snackbar(
                    'Success',
                    'Room added successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.8),
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to add room: ${controller.errorMessage.value}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.8),
                    colorText: Colors.white,
                  );
                }
              });
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUpdateMeterDialog(BuildContext context, HomeController controller) {
    final TextEditingController readingController = TextEditingController();

    if (controller.currentHome.value != null) {
      readingController.text = controller.currentHome.value!.currentReading.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Meter Reading'),
        content: TextField(
          controller: readingController,
          decoration: const InputDecoration(
            labelText: 'Current Reading (kWh)',
            hintText: 'e.g., 1250.5',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final readingText = readingController.text.trim();
              final reading = double.tryParse(readingText);

              if (reading == null) {
                Get.snackbar(
                  'Error',
                  'Please enter a valid number',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.8),
                  colorText: Colors.white,
                );
                return;
              }

              controller.updateMeterReading(reading).then((success) {
                Get.back();
                if (success) {
                  Get.snackbar(
                    'Success',
                    'Meter reading updated successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.8),
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to update meter reading: ${controller.errorMessage.value}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.8),
                    colorText: Colors.white,
                  );
                }
              });
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
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
