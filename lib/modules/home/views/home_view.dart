import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_energy/modules/home/controllers/home_controller.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/modules/home/widgets/room_card.dart';
import 'package:flutter_energy/modules/home/widgets/meter_reading_card.dart';
import 'package:flutter_energy/routes/app_pages.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final authController = Get.find<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await homeController.fetchHomeData();
          await homeController.fetchRooms();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar with User Greeting
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Date
                          Text(
                            DateFormat('MMMM d, yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: colorScheme.onPrimary.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Greeting
                          Obx(() => Text(
                            'Welcome, ${authController.currentUser.value?.name ?? 'User'}!',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                title: Text(
                  'Home',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Get.toNamed(Routes.ALERTS),
                  tooltip: 'Notifications',
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => Get.toNamed(Routes.SETTINGS),
                  tooltip: 'Profile',
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meter Reading Card
                    Obx(() => homeController.currentHome.value != null
                        ? MeterReadingCard(
                            home: homeController.currentHome.value!,
                            onUpdateReading: (reading) => 
                                homeController.updateMeterReading(reading),
                          ).animate().fadeIn().slideY(begin: 0.2, end: 0)
                        : const SizedBox.shrink()),
                    
                    const SizedBox(height: 24),
                    
                    // Rooms Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rooms',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddRoomDialog(context, homeController),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Room'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Rooms Grid
            Obx(() {
              if (homeController.isLoading.value && homeController.rooms.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (homeController.rooms.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 64,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No rooms added yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add rooms to organize your appliances',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddRoomDialog(context, homeController),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Room'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final room = homeController.rooms[index];
                      final appliances = homeController.appliancesByRoom[room.id] ?? [];
                      
                      return RoomCard(
                        room: room,
                        applianceCount: appliances.length,
                        onTap: () {
                          homeController.selectRoom(room);
                          Get.toNamed(Routes.ROOM_DETAIL);
                        },
                      ).animate().fadeIn(delay: (300 + (index * 100)).ms).scale();
                    },
                    childCount: homeController.rooms.length,
                  ),
                ),
              );
            }),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                hintText: 'e.g. Living Room, Kitchen',
              ),
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
              if (nameController.text.trim().isNotEmpty) {
                controller.addRoom(nameController.text.trim());
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
