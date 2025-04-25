import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/shared/widgets/custom_button.dart';
import 'package:flutter_energy/shared/widgets/custom_text_field.dart';

class CompleteProfileView extends StatelessWidget {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>;
    
    final nameController = TextEditingController(text: args['name'] ?? '');
    final meterNumberController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.home,
                  size: 80,
                  color: colorScheme.primary,
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                
                const SizedBox(height: 24),
                
                Text(
                  'Set Up Your Home',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 16),
                
                Text(
                  'We need a few more details to complete your profile',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 32),
                
                CustomTextField(
                  controller: nameController,
                  hint: 'Your Name',
                  prefixIcon: Icons.person,
                ).animate().fadeIn(delay: 500.ms).slideX(),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: meterNumberController,
                  hint: 'Meter Number',
                  prefixIcon: Icons.pin,
                  keyboardType: TextInputType.number,
                ).animate().fadeIn(delay: 600.ms).slideX(),
                
                const SizedBox(height: 8),
                
                // Error message
                Obx(() => controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: colorScheme.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink()),
                
                const SizedBox(height: 24),
                
                Obx(() => CustomButton(
                  onPressed: () => controller.completeProfile(
                    args['uid'],
                    nameController.text,
                    meterNumberController.text,
                  ),
                  text: 'Complete Setup',
                  isLoading: controller.isLoading.value,
                )).animate().fadeIn(delay: 700.ms).slideY(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
