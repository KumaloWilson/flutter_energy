import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/home/controllers/home_controller.dart';

class AddApplianceView extends StatefulWidget {
  final String? preSelectedRoomId;

  const AddApplianceView({
    super.key,
    this.preSelectedRoomId,
  });

  @override
  State<AddApplianceView> createState() => _AddApplianceViewState();
}

class _AddApplianceViewState extends State<AddApplianceView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _powerController = TextEditingController();
  String? _selectedRoomId;
  final _applianceTypes = [
    {'name': 'Television', 'icon': Icons.tv, 'power': '120'},
    {'name': 'Refrigerator', 'icon': Icons.kitchen, 'power': '150'},
    {'name': 'Air Conditioner', 'icon': Icons.ac_unit, 'power': '1500'},
    {'name': 'Washing Machine', 'icon': Icons.local_laundry_service, 'power': '500'},
    {'name': 'Microwave', 'icon': Icons.microwave, 'power': '1000'},
    {'name': 'Water Heater', 'icon': Icons.hot_tub, 'power': '3000'},
    {'name': 'Light', 'icon': Icons.lightbulb, 'power': '60'},
    {'name': 'Fan', 'icon': Icons.air, 'power': '75'},
    {'name': 'Computer', 'icon': Icons.computer, 'power': '300'},
    {'name': 'Other', 'icon': Icons.electrical_services, 'power': '100'},
  ];
  int _selectedApplianceIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedRoomId = widget.preSelectedRoomId;

    // If we have a preselected room, set it after the widget is built
    if (_selectedRoomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  void _selectApplianceType(int index) {
    setState(() {
      _selectedApplianceIndex = index;
      _powerController.text = _applianceTypes[index]['power'] as String;
      _nameController.text = _applianceTypes[index]['name'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Appliance'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick select appliance types
                Text(
                  'Select Appliance Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Appliance type grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _applianceTypes.length,
                  itemBuilder: (context, index) {
                    final appliance = _applianceTypes[index];
                    final isSelected = _selectedApplianceIndex == index;

                    return InkWell(
                      onTap: () => _selectApplianceType(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              appliance['icon'] as IconData,
                              size: 32,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${appliance['name']}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(target: isSelected ? 1 : 0)
                        .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
                        .elevation(begin: 0, end: 4);
                  },
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Appliance details form
                Text(
                  'Appliance Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Appliance Name',
                    hintText: 'e.g. Living Room TV',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an appliance name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Power rating field
                TextFormField(
                  controller: _powerController,
                  decoration: InputDecoration(
                    labelText: 'Rated Power (W)',
                    hintText: 'e.g. 100',
                    prefixIcon: const Icon(Icons.power_outlined),
                    suffixText: 'W',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the rated power';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Room selection dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRoomId,
                  decoration: InputDecoration(
                    labelText: 'Select Room',
                    prefixIcon: const Icon(Icons.room_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.getRoomDropdownItems(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoomId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a room';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.addAppliance(
                          _nameController.text.trim(),
                          _powerController.text.trim(),
                          _selectedRoomId!,
                        ).then((success) {
                          if (success) {
                            Get.back();
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Appliance'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
