import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../auth/controllers/auth_controller.dart';
import '../controller/family_controller.dart';

class FamilyView extends StatelessWidget {
  const FamilyView({super.key});

  @override
  Widget build(BuildContext context) {
    final familyController = Get.find<FamilyController>();
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Family Access'),
      ),
      body: Obx(() {
        if (familyController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Manage Family Access',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideX(),

                const SizedBox(height: 8),

                Text(
                  'Add family members to share access to your energy monitoring system',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(),

                const SizedBox(height: 24),

                // Owner card
                _buildOwnerCard(context, authController)
                    .animate().fadeIn(delay: 200.ms).slideY(),

                const SizedBox(height: 24),

                // Family members section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Family Members',
                      style: theme.textTheme.titleLarge,
                    ),
                    if (authController.isOwner)
                      TextButton.icon(
                        onPressed: () => _showAddMemberDialog(context, familyController),
                        icon: Icon(Icons.add),
                        label: Text('Add Member'),
                      ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                // Family members list
                if (familyController.familyMembers.isEmpty)
                  _buildEmptyMembersView(context, familyController, authController)
                      .animate().fadeIn(delay: 400.ms)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: familyController.familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = familyController.familyMembers[index];
                      return _buildMemberCard(
                        context,
                        member,
                        familyController,
                        authController,
                      ).animate().fadeIn(delay: (400 + (index * 100)).ms).slideX();
                    },
                  ),

                const SizedBox(height: 24),

                // Access levels explanation
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Access Levels',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAccessLevelItem(
                          context,
                          'Owner',
                          'Full access to all features and settings',
                          Icons.admin_panel_settings,
                          Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildAccessLevelItem(
                          context,
                          'Admin',
                          'Can manage devices and view analytics',
                          Icons.supervisor_account,
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildAccessLevelItem(
                          context,
                          'Editor',
                          'Can control devices and view analytics',
                          Icons.edit,
                          Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildAccessLevelItem(
                          context,
                          'Viewer',
                          'Can only view devices and analytics',
                          Icons.visibility,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() => authController.isOwner
          ? FloatingActionButton(
        onPressed: () => _showAddMemberDialog(context, familyController),
        child: Icon(Icons.person_add),
        tooltip: 'Add Family Member',
      )
          : SizedBox.shrink(),
      ),
    );
  }

  Widget _buildOwnerCard(BuildContext context, AuthController controller) {
    final theme = Theme.of(context);
    final profile = controller.userProfile.value;

    if (profile == null) return SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primary,
              child: profile.photoUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  profile.photoUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
                  : Text(
                profile.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profile.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Owner',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
      BuildContext context,
      member,
      FamilyController familyController,
      AuthController authController,
      ) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getRoleColor(member.role).withOpacity(0.2),
              child: member.photoUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  member.photoUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
                  : Text(
                member.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(member.role),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    member.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (authController.isOwner)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    _showRemoveMemberDialog(context, member, familyController);
                  } else {
                    familyController.updateMemberRole(member.id, value);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'admin',
                    child: Text('Set as Admin'),
                  ),
                  PopupMenuItem(
                    value: 'editor',
                    child: Text('Set as Editor'),
                  ),
                  PopupMenuItem(
                    value: 'viewer',
                    child: Text('Set as Viewer'),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(member.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getRoleDisplayName(member.role),
                        style: TextStyle(
                          color: _getRoleColor(member.role),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: _getRoleColor(member.role),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(member.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRoleDisplayName(member.role),
                  style: TextStyle(
                    color: _getRoleColor(member.role),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMembersView(
      BuildContext context,
      FamilyController familyController,
      AuthController authController,
      ) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Family Members Yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add family members to share access',
            style: theme.textTheme.bodySmall,
          ),
          if (authController.isOwner) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddMemberDialog(context, familyController),
              icon: Icon(Icons.person_add),
              label: Text('Add Family Member'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccessLevelItem(
      BuildContext context,
      String role,
      String description,
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddMemberDialog(BuildContext context, FamilyController controller) {
    final emailController = TextEditingController();
    String selectedRole = 'viewer';

    Get.dialog(
      AlertDialog(
        title: Text('Add Family Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Access Level'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'editor',
                            child: Text('Editor'),
                          ),
                          DropdownMenuItem(
                            value: 'viewer',
                            child: Text('Viewer'),
                          ),
                        ],
                      ),
                    ],
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
              final email = emailController.text;

              if (email.isEmpty || !GetUtils.isEmail(email)) {
                Get.snackbar(
                  'Error',
                  'Please enter a valid email address',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
                return;
              }

              controller.addFamilyMember(email, selectedRole);
              Get.back();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(
      BuildContext context,
      member,
      FamilyController controller,
      ) {
    Get.dialog(
      AlertDialog(
        title: Text('Remove Family Member'),
        content: Text('Are you sure you want to remove ${member.name} from your family?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.removeFamilyMember(member.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.purple;
      case 'admin':
        return Colors.blue;
      case 'editor':
        return Colors.green;
      case 'viewer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'owner':
        return 'Owner';
      case 'admin':
        return 'Admin';
      case 'editor':
        return 'Editor';
      case 'viewer':
        return 'Viewer';
      default:
        return 'Unknown';
    }
  }
}
