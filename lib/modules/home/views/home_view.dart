import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/home/controllers/home_controller.dart';
import 'package:flutter_energy/modules/home/views/room_detail_view.dart';
import 'package:flutter_energy/modules/home/widgets/room_card.dart';
import 'package:flutter_energy/modules/home/widgets/meter_reading_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Home'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchDevices(),
          ),
        ],
      ),
      body: Obx(() {
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

        return RefreshIndicator(
          onRefresh: () => controller.fetchHomeData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Meter Reading Card
              if (controller.currentHome.value != null)
                MeterReadingCard(
                  currentReading: controller.currentHome.value!.currentReading,
                  lastUpdated: controller.currentHome.value!.lastUpdated,
                  onUpdateReading: (reading) => controller.updateMeterReading(reading),
                ),

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

              if (controller.rooms.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.room,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withAlpha(150),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No rooms added yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add rooms to organize your appliances',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: controller.rooms.length,
                  itemBuilder: (context, index) {
                    final room = controller.rooms[index];
                    final devices = controller.devicesByRoom[room.id] ?? [];

                    return RoomCard(
                      room: room,
                      deviceCount: devices.length,
                      onTap: () => Get.to(() => RoomDetailView(room: room)),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQuickActionButton(
                        context,
                        'Add New Appliance',
                        Icons.add_circle,
                            () => Get.toNamed('/add-appliance'),
                      ),
                      const Divider(height: 32),
                      _buildQuickActionButton(
                        context,
                        'View Energy Analytics',
                        Icons.analytics,
                            () => Get.toNamed('/analytics'),
                      ),
                      const Divider(height: 32),
                      _buildQuickActionButton(
                        context,
                        'Energy Saving Tips',
                        Icons.lightbulb,
                            () => Get.toNamed('/tips'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-appliance'),
        icon: const Icon(Icons.add),
        label: const Text('Add Appliance'),
      ),
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context,
      String label,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context, HomeController controller) {
    final nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Room'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Room Name',
            hintText: 'e.g., Living Room, Kitchen',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final success = await controller.addRoom(name);
                Get.back();

                if (success) {
                  Get.snackbar(
                    'Success',
                    'Room added successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withAlpha(200),
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    controller.errorMessage.value,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withAlpha(200),
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
