import 'package:flutter/material.dart';
import 'package:flutter_energy/constants/image_paths.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.energy_savings_leaf,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms),
                const SizedBox(height: 32),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                Text(
                  'Monitor and optimize your energy usage',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: nameController,
                  hint: 'Full Name',
                  prefixIcon: Icons.person_outline,
                ).animate().fadeIn(delay: 500.ms).slideX(),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: emailController,
                  hint: 'Email',
                  prefixIcon: Icons.email_outlined,
                ).animate().fadeIn(delay: 600.ms).slideX(),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hint: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ).animate().fadeIn(delay: 700.ms).slideX(),
                const SizedBox(height: 24),
                Obx(() => CustomButton(
                  onPressed: () => controller.signup(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                  ),
                  text: 'Sign Up',
                  isLoading: controller.isLoading.value,
                )).animate().fadeIn(delay: 800.ms).slideY(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 900.ms),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.asset(
                    ImageAssetPaths.googleIcon,
                    height: 24,
                  ),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms).slideY(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Login'),
                    ),
                  ],
                ).animate().fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

