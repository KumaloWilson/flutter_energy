import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/meter_info_card.dart';
import '../../../shared/widgets/room_card.dart';
import '../../meter/controller/meter_controller.dart';
import '../../rooms/controller/room_controller.dart';
import '../controllers/auth_controller.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final roomController = Get.find<RoomController>();
    final meterController = Get.find<MeterController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Energy'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
      ),
      drawer: _buildDrawer(context, authController),
      body: RefreshIndicator(
        onRefresh: () async {
          await roomController.fetchRooms();
          await meterController.fetchMeterInfo();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User greeting
                Obx(() => authController.userProfile.value != null
                    ? _buildUserGreeting(context, authController)
                    : SizedBox.shrink(),
                ).animate().fadeIn().slideX(),

                const SizedBox(height: 24),

                // Meter info card
                Obx(() => meterController.meter.value != null
                    ? MeterInfoCard(meter: meterController.meter.value!)
                    : _buildAddMeterCard(context, meterController),
                ).animate().fadeIn(delay: 200.ms).slideY(),

                const SizedBox(height: 24),

                // Rooms section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rooms',
                      style: theme.textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddRoomDialog(context, roomController),
                      icon: Icon(Icons.add),
                      label: Text('Add Room'),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                // Rooms grid
                Obx(() {
                  if (roomController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (roomController.rooms.isEmpty) {
                    return _buildEmptyRoomsView(context);
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
                    itemCount: roomController.rooms.length,
                    itemBuilder: (context, index) {
                      final room = roomController.rooms[index];
                      return RoomCard(
                        room: room,
                        onTap: () {
                          roomController.selectRoom(room);
                          Get.toNamed(Routes.ROOM_DETAIL);
                        },
                      ).animate().fadeIn(delay: (400 + (index * 100)).ms).scale();
                    },
                  );
                }),

                const SizedBox(height: 24),

                // Quick stats
                Text(
                  'Quick Stats',
                  style: theme.textTheme.titleLarge,
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 16),

                // Energy usage stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Today',
                        '3.2 kWh',
                        Icons.bolt,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'This Month',
                        '87.5 kWh',
                        Icons.calendar_month,
                        Colors.blue,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Active Devices',
                        '8',
                        Icons.devices,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Savings',
                        '12%',
                        Icons.savings,
                        Colors.purple,
                        showTrend: true,
                        trendUp: true,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.ANALYTICS),
        child: Icon(Icons.analytics),
        tooltip: 'Energy Analytics',
      ),
    );
  }

  Widget _buildUserGreeting(BuildContext context, AuthController controller) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(now),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '$greeting, ${controller.userProfile.value?.name ?? 'User'}!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.PROFILE),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary,
                child: controller.userProfile.value?.photoUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    controller.userProfile.value!.photoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
                    : Text(
                  controller.userProfile.value?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildAddMeterCard(BuildContext context, MeterController controller) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => _showAddMeterDialog(context, controller),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Add Meter Information',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your electricity meter details to track usage',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMeterDialog(BuildContext context, MeterController controller) {
    final meterNumberController = TextEditingController();
    final currentReadingController = TextEditingController();
    final providerController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Add Meter Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: meterNumberController,
                decoration: InputDecoration(
                  labelText: 'Meter Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: currentReadingController,
                decoration: InputDecoration(
                  labelText: 'Current Reading (kWh)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: providerController,
                decoration: InputDecoration(
                  labelText: 'Provider',
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
          ElevatedButton(
            onPressed: () {
              final meterNumber = meterNumberController.text;
              final currentReading = double.tryParse(currentReadingController.text) ?? 0.0;
              final provider = providerController.text;

              if (meterNumber.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a meter number',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
                return;
              }

              controller.updateMeterInfo(meterNumber, currentReading, provider);
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRoomsView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Rooms Added Yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add rooms to organize your devices',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddRoomDialog(context, Get.find<RoomController>()),
            icon: Icon(Icons.add),
            label: Text('Add Room'),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context, RoomController controller) {
    final nameController = TextEditingController();
    final iconOptions = [
      {'name': 'Living Room', 'icon': Icons.weekend},
      {'name': 'Bedroom', 'icon': Icons.bed},
      {'name': 'Kitchen', 'icon': Icons.kitchen},
      {'name': 'Bathroom', 'icon': Icons.bathtub},
      {'name': 'Office', 'icon': Icons.computer},
      {'name': 'Dining Room', 'icon': Icons.dining},
    ];

    String selectedIconName = 'weekend';

    Get.dialog(
      AlertDialog(
        title: Text('Add Room'),
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
              const SizedBox(height: 16),
              Text('Select Icon'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: iconOptions.map((option) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedIconName = option['name']!.toString().toLowerCase().replaceAll(' ', '_');
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedIconName == option['name']!.toString().toLowerCase().replaceAll(' ', '_')
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                option['icon'] as IconData,
                                color: selectedIconName == option['name']!.toString().toLowerCase().replaceAll(' ', '_')
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option['name'] as String,
                                style: TextStyle(
                                  color: selectedIconName == option['name']!.toString().toLowerCase().replaceAll(' ', '_')
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
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
                  'Please enter a room name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
                return;
              }

              controller.addRoom(name, selectedIconName, '');
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color, {
        bool showTrend = false,
        bool trendUp = false,
      }) {
    final theme = Theme.of(context);

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
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showTrend) ...[
                  const SizedBox(width: 8),
                  Icon(
                    trendUp ? Icons.trending_up : Icons.trending_down,
                    color: trendUp ? Colors.green : Colors.red,
                    size: 16,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthController controller) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() => UserAccountsDrawerHeader(
            accountName: Text(controller.userProfile.value?.name ?? 'User'),
            accountEmail: Text(controller.userProfile.value?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: controller.userProfile.value?.photoUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  controller.userProfile.value!.photoUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
                  : Text(
                controller.userProfile.value?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
          )),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Get.back();
              Get.offAllNamed(Routes.HOME);
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Energy Analytics'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.ANALYTICS);
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Family Access'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.FAMILY);
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.NOTIFICATIONS);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.SETTINGS);
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.HELP);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Get.back();
              controller.logout();
            },
          ),
        ],
      ),
    );
  }
}
