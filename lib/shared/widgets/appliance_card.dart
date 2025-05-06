import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/home/models/appliance_model.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/home/controllers/home_controller.dart';

class ApplianceCard extends StatelessWidget {
  final ApplianceModel appliance;
  final VoidCallback onTap;
  final Function(bool) onToggle;
  final bool showDetails;
  final bool showRoomTransfer;

  const ApplianceCard({
    super.key,
    required this.appliance,
    required this.onTap,
    required this.onToggle,
    this.showDetails = true,
    this.showRoomTransfer = true,
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

                  // Menu and power toggle
                  Row(
                    children: [
                      if (showRoomTransfer)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'move') {
                              _showRoomSelectionDialog(context);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'move',
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz),
                                  SizedBox(width: 8),
                                  Text('Move to another room'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      Switch(
                        value: appliance.isActive,
                        onChanged: (value) => onToggle(value),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
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

  void _showRoomSelectionDialog(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Room'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            final rooms = homeController.rooms;

            if (rooms.isEmpty) {
              return const Text('No rooms available');
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select a room to move this device to:'),
                const SizedBox(height: 16),
                ...rooms.map((room) => ListTile(
                  title: Text(room.name),
                  leading: Icon(
                    _getRoomIcon(room.name),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // Don't move if it's already in this room
                    if (room.id == appliance.roomId) {
                      Get.back();
                      Get.snackbar(
                        'Info',
                        'Device is already in this room',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    // Move the device to the selected room
                    _moveDeviceToRoom(room.id);
                    Get.back();
                  },
                  trailing: room.id == appliance.roomId
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                )),
              ],
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _moveDeviceToRoom(String roomId) {
    final HomeController homeController = Get.find<HomeController>();

    // Convert the appliance ID to int for the API
    final deviceId = int.tryParse(appliance.id);
    if (deviceId == null) {
      Get.snackbar(
        'Error',
        'Invalid device ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    homeController.assignDeviceToRoom(deviceId, roomId).then((success) {
      if (success) {
        Get.snackbar(
          'Success',
          'Device moved to new room',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to move device: ${homeController.errorMessage.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    });
  }

  IconData _getRoomIcon(String roomName) {
    final name = roomName.toLowerCase();
    if (name.contains('living')) return Icons.weekend;
    if (name.contains('kitchen')) return Icons.kitchen;
    if (name.contains('bed')) return Icons.bed;
    if (name.contains('bath')) return Icons.bathtub;
    if (name.contains('office')) return Icons.computer;
    if (name.contains('dining')) return Icons.dining;
    return Icons.home;
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
