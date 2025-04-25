import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/widgets/appliance_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controller/room_controller.dart';

class RoomDetailView extends StatelessWidget {
  const RoomDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final roomController = Get.find<RoomController>();
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(roomController.selectedRoom.value?.name ?? 'Room')),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditRoomDialog(context, roomController),
          ),
        ],
      ),
      body: Obx(() {
        if (roomController.selectedRoom.value == null) {
          return Center(child: Text('No room selected'));
        }

        final room = roomController.selectedRoom.value!;

        return RefreshIndicator(
          onRefresh: () => roomController.fetchAppliancesInRoom(room.id),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room header
                  _buildRoomHeader(context, room).animate().fadeIn().slideX(),

                  const SizedBox(height: 24),

                  // Appliances section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Appliances',
                        style: theme.textTheme.titleLarge,
                      ),
                      if (authController.canEditDevices)
                        TextButton.icon(
                          onPressed: () => _showAddApplianceDialog(context, roomController),
                          icon: Icon(Icons.add),
                          label: Text('Add Device'),
                        ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 16),

                  // Appliances grid
                  Obx(() {
                    if (roomController.isLoadingAppliances.value) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (roomController.appliances.isEmpty) {
                      return _buildEmptyAppliancesView(context, roomController);
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: roomController.appliances.length,
                      itemBuilder: (context, index) {
                        final appliance = roomController.appliances[index];
                        return ApplianceCard(
                          appliance: appliance,
                          onTap: () => Get.toNamed(
                            Routes.APPLIANCE_DETAIL,
                            arguments: appliance,
                          ),
                          onToggle: (value) {
                            final updatedAppliance = appliance.copyWith(isOn: value);
                            roomController.updateAppliance(updatedAppliance);
                          },
                        ).animate().fadeIn(delay: (300 + (index * 100)).ms).scale();
                      },
                    );
                  }),

                  const SizedBox(height: 24),

                  // Room stats
                  Text(
                    'Room Stats',
                    style: theme.textTheme.titleLarge,
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  _buildRoomStatsCard(context, roomController)
                      .animate().fadeIn(delay: 500.ms).slideY(),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() => roomController.selectedRoom.value != null && authController.canEditDevices
          ? FloatingActionButton(
        onPressed: () => _showAddApplianceDialog(context, roomController),
        child: Icon(Icons.add),
        tooltip: 'Add Device',
      )
          : SizedBox.shrink(),
      ),
    );
  }

  Widget _buildRoomHeader(BuildContext context, room) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: room.imageUrl.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(room.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          )
              : null,
          gradient: room.imageUrl.isEmpty
              ? LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                room.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${room.deviceCount} ${room.deviceCount == 1 ? 'Device' : 'Devices'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAppliancesView(BuildContext context, RoomController controller) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Devices Added Yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add devices to monitor energy usage',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddApplianceDialog(context, controller),
            icon: Icon(Icons.add),
            label: Text('Add Device'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStatsCard(BuildContext context, RoomController controller) {
    final theme = Theme.of(context);

    // Calculate total power consumption
    double totalPower = 0.0;
    for (var appliance in controller.appliances) {
      if (appliance.isOn) {
        totalPower += appliance.power;
      }
    }

    // Count active devices
    int activeDevices = controller.appliances.where((a) => a.isOn).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Usage',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  DateFormat('h:mm a').format(DateTime.now()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Power',
                  '${totalPower.toStringAsFixed(1)} W',
                  Icons.bolt,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  'Active',
                  '$activeDevices ${activeDevices == 1 ? 'Device' : 'Devices'}',
                  Icons.power,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'Est. Cost',
                  '\$${(totalPower * 0.00015).toStringAsFixed(2)}/hr',
                  Icons.attach_money,
                  Colors.blue,
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
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showEditRoomDialog(BuildContext context, RoomController controller) {
    final room = controller.selectedRoom.value!;
    final nameController = TextEditingController(text: room.name);

    Get.dialog(
      AlertDialog(
        title: Text('Edit Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.defaultDialog(
                title: 'Delete Room',
                middleText: 'Are you sure you want to delete this room? All devices in this room will also be deleted.',
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  controller.deleteRoom(room.id);
                  Get.back();
                  Get.back();
                  Get.back();
                },
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text;

              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a room name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
                return;
              }

              final updatedRoom = room.copyWith(name: name);
              controller.updateRoom(updatedRoom);
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddApplianceDialog(BuildContext context, RoomController controller) {
    final nameController = TextEditingController();
    final applianceTypes = [
      {'name': 'Light', 'icon': Icons.lightbulb, 'type': 'lighting'},
      {'name': 'TV', 'icon': Icons.tv, 'type': 'entertainment'},
      {'name': 'AC', 'icon': Icons.ac_unit, 'type': 'climate'},
      {'name': 'Fridge', 'icon': Icons.kitchen, 'type': 'appliance'},
      {'name': 'Washer', 'icon': Icons.local_laundry_service, 'type': 'appliance'},
      {'name': 'Fan', 'icon': Icons.air, 'type': 'climate'},
    ];

    String selectedType = 'lighting';
    String selectedIconName = 'lightbulb';

    Get.dialog(
      AlertDialog(
        title: Text('Add Device'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Device Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Select Device Type'),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: applianceTypes.map((type) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedType = type['type'] as String;
                            selectedIconName = (type['icon'] as IconData).toString();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedType == type['type']
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                color: selectedType == type['type']
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type['name'] as String,
                                style: TextStyle(
                                  color: selectedType == type['type']
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text;

              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a device name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
                return;
              }

              controller.addAppliance(name, selectedType, selectedIconName);
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
