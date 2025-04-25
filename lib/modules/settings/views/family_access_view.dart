import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/settings/controller/settings_controller.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';

class FamilyAccessView extends StatelessWidget {
  const FamilyAccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final authController = Get.find<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Access'),
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.family_restroom,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Family Members',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage access to your home energy system',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn().slideY(),
          
          // Family Members List
          Expanded(
            child: Obx(() {
              if (settingsController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (settingsController.familyMembers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No family members yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add family members to share access',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: settingsController.familyMembers.length,
                itemBuilder: (context, index) {
                  final member = settingsController.familyMembers[index];
                  final isCurrentUser = member.id == authController.currentUser.value?.id;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrentUser
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          color: isCurrentUser
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        member.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.email),
                          Text(
                            'Role: ${_capitalizeRole(member.role)}',
                            style: TextStyle(
                              color: _getRoleColor(member.role, colorScheme),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: isCurrentUser || authController.currentUser.value?.role != 'owner'
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _showRemoveMemberDialog(
                                context,
                                settingsController,
                                member,
                              ),
                            ),
                      isThreeLine: true,
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms).slideX();
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() => authController.currentUser.value?.role == 'owner'
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMemberDialog(context, settingsController),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
            )
          : const SizedBox.shrink()),
    );
  }
  
  String _capitalizeRole(String role) {
    return role.isEmpty ? 'Member' : role[0].toUpperCase() + role.substring(1);
  }
  
  Color _getRoleColor(String role, ColorScheme colorScheme) {
    switch (role) {
      case 'owner':
        return Colors.orange;
      case 'admin':
        return colorScheme.primary;
      default:
        return Colors.green;
    }
  }
  
  void _showAddMemberDialog(BuildContext context, SettingsController controller) {
    final emailController = TextEditingController();
    final selectedRole = 'member'.obs;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add Family Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter email address',
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text('Role:'),
            Obx(() => Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Admin'),
                  subtitle: const Text('Can manage devices and rooms'),
                  value: 'admin',
                  groupValue: selectedRole.value,
                  onChanged: (value) => selectedRole.value = value!,
                ),
                RadioListTile<String>(
                  title: const Text('Member'),
                  subtitle: const Text('Can view and control devices'),
                  value: 'member',
                  groupValue: selectedRole.value,
                  onChanged: (value) => selectedRole.value = value!,
                ),
              ],
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.trim().isNotEmpty) {
                controller.addFamilyMember(
                  emailController.text.trim(),
                  selectedRole.value,
                );
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _showRemoveMemberDialog(
    BuildContext context,
    SettingsController controller,
    dynamic member,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Family Member'),
        content: Text('Are you sure you want to remove ${member.name} from your home?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.removeFamilyMember(member.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
