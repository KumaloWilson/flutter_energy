import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/shared/widgets/custom_button.dart';
import 'package:flutter_energy/shared/widgets/custom_text_field.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final meterNumberController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                  Icons.account_circle,
                  size: 80,
                  color: colorScheme.primary,
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                
                const SizedBox(height: 24),
                
                Text(
                  'Join Energy Management',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 32),
                
                CustomTextField(
                  controller: nameController,
                  hint: 'Full Name',
                  prefixIcon: Icons.person,
                ).animate().fadeIn(delay: 400.ms).slideX(),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: emailController,
                  hint: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ).animate().fadeIn(delay: 500.ms).slideX(),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: passwordController,
                  hint: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                ).animate().fadeIn(delay: 600.ms).slideX(),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: meterNumberController,
                  hint: 'Meter Number',
                  prefixIcon: Icons.pin,
                  keyboardType: TextInputType.number,
                ).animate().fadeIn(delay: 700.ms).slideX(),
                
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
                  onPressed: () => controller.signup(
                    emailController.text,
                    passwordController.text,
                    nameController.text,
                    meterNumberController.text,
                  ),
                  text: 'Create Account',
                  isLoading: controller.isLoading.value,
                )).animate().fadeIn(delay: 800.ms).slideY(),
                
                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Already have an account? Login'),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
