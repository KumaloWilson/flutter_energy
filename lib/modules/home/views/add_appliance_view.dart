import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_energy/modules/home/controllers/home_controller.dart';

class AddApplianceView extends StatefulWidget {
  const AddApplianceView({super.key});

  @override
  State<AddApplianceView> createState() => _AddApplianceViewState();
}

class _AddApplianceViewState extends State<AddApplianceView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ratedPowerController = TextEditingController();
  final _meterNumberController = TextEditingController();

  final HomeController _homeController = Get.find<HomeController>();

  String? _selectedRoomId;
  String? _selectedApplianceType;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _applianceTypes = [
    {'name': 'Television', 'icon': Icons.tv, 'power': '100'},
    {'name': 'Refrigerator', 'icon': Icons.kitchen, 'power': '200'},
    {'name': 'Air Conditioner', 'icon': Icons.ac_unit, 'power': '1500'},
    {'name': 'Washing Machine', 'icon': Icons.local_laundry_service, 'power': '500'},
    {'name': 'Microwave', 'icon': Icons.microwave, 'power': '1000'},
    {'name': 'Light', 'icon': Icons.lightbulb, 'power': '60'},
    {'name': 'Fan', 'icon': Icons.air, 'power': '75'},
    {'name': 'Computer', 'icon': Icons.computer, 'power': '300'},
    {'name': 'Water Heater', 'icon': Icons.hot_tub, 'power': '1200'},
    {'name': 'Other', 'icon': Icons.devices_other, 'power': ''},
  ];

  @override
  void initState() {
    super.initState();
    // Set default room if available
    if (_homeController.rooms.isNotEmpty) {
      _selectedRoomId = _homeController.rooms.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ratedPowerController.dispose();
    _meterNumberController.dispose();
    super.dispose();
  }

  void _selectApplianceType(String typeName) {
    setState(() {
      _selectedApplianceType = typeName;

      // Pre-fill name and power based on selection
      final applianceType = _applianceTypes.firstWhere(
            (type) => type['name'] == typeName,
        orElse: () => {'name': '', 'power': ''},
      );

      _nameController.text = applianceType['name'];
      _ratedPowerController.text = applianceType['power'];
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final name = _nameController.text.trim();
        final ratedPower = '${_ratedPowerController.text.trim()} W';
        final meterNumber = _meterNumberController.text.trim();

        final success = await _homeController.addAppliance(
          name,
          ratedPower,
          meterNumber,
        );

        if (success) {
          // If a room was selected, assign the device to that room
          if (_selectedRoomId != null) {
            // In a real app, we would get the new device ID from the API response
            // For now, we'll just refresh the devices list
            await _homeController.fetchDevices();
          }

          Get.back(result: success);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Appliance'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _applianceTypes.length,
                itemBuilder: (context, index) {
                  final type = _applianceTypes[index];
                  final isSelected = _selectedApplianceType == type['name'];

                  return InkWell(
                    onTap: () => _selectApplianceType(type['name']),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type['icon'],
                            size: 32,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            type['name'],
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Form fields
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        hintText: 'e.g., Living Room TV',
                        prefixIcon: const Icon(Icons.devices),
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

                    // Rated power field
                    TextFormField(
                      controller: _ratedPowerController,
                      decoration: InputDecoration(
                        labelText: 'Rated Power (W)',
                        hintText: 'e.g., 100',
                        prefixIcon: const Icon(Icons.power),
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

                    // Meter number field
                    TextFormField(
                      controller: _meterNumberController,
                      decoration: InputDecoration(
                        labelText: 'Meter Number (Optional)',
                        hintText: 'e.g., 12345',
                        prefixIcon: const Icon(Icons.confirmation_number),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Room selection dropdown
                    Obx(() => DropdownButtonFormField<String>(
                      value: _selectedRoomId,
                      decoration: InputDecoration(
                        labelText: 'Assign to Room',
                        prefixIcon: const Icon(Icons.room),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _homeController.getRoomDropdownItems(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoomId = value;
                        });
                      },
                    )),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Add Appliance'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
