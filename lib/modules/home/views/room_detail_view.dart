import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/home/controllers/home_controller.dart';
import 'package:flutter_energy/modules/dashboard/models/appliance_reading.dart';
import 'package:flutter_energy/shared/widgets/appliance_card.dart';
import 'package:flutter_energy/routes/app_pages.dart';
import 'package:flutter_energy/modules/home/views/add_appliance_view.dart';

class RoomDetailView extends StatelessWidget {
  const RoomDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.selectedRoom.value?.name ?? 'Room')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddApplianceDialog(context, controller),
            tooltip: 'Add Appliance',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.selectedRoom.value == null) {
          return const Center(child: Text('No room selected'));
        }

        final roomId = controller.selectedRoom.value!.id;
        final appliances = controller.appliancesByRoom[roomId] ?? [];

        if (appliances.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.electrical_services_outlined,
                  size: 64,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No appliances in this room',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add appliances to monitor energy usage',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddApplianceDialog(context, controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Appliance'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appliances.length,
          itemBuilder: (context, index) {
            final appliance = appliances[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ApplianceCard(
                reading: appliance,
              ).animate().fadeIn(delay: (index * 100).ms).slideX(),
            );
          },
        );
      }),
    );
  }

  void _showAddApplianceDialog(BuildContext context, HomeController controller) {
    Get.to(() => AddApplianceView(
      preSelectedRoomId: controller.selectedRoom.value?.id,
    ));
  }

  void _showMoveApplianceDialog(
      BuildContext context, HomeController controller, ApplianceReading appliance) {
    Get.dialog(
      AlertDialog(
        title: const Text('Move Appliance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a room to move "${appliance.applianceInfo.appliance}"'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.rooms.length,
                itemBuilder: (context, index) {
                  final room = controller.rooms[index];
                  // Skip current room
                  if (room.id == controller.selectedRoom.value!.id) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    title: Text(room.name),
                    leading: const Icon(Icons.home_outlined),
                    onTap: () {
                      controller.moveApplianceToRoom(
                        appliance.id.toString(),
                        room.id,
                      );
                      Get.back();
                    },
                  );
                },
              )),
            ),
          ],
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
}
