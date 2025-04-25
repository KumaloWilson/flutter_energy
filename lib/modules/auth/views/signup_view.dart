import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo
                Center(
                  child: Icon(
                    Icons.home_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),

                const SizedBox(height: 24),

                Text(
                  'Join Smart Energy',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 8),

                Text(
                  'Monitor and optimize your energy usage',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                // Signup form
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

                const SizedBox(height: 16),

                CustomTextField(
                  controller: confirmPasswordController,
                  hint: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ).animate().fadeIn(delay: 800.ms).slideX(),

                const SizedBox(height: 24),

                Obx(() => CustomButton(
                  onPressed: () {
                    if (passwordController.text != confirmPasswordController.text) {
                      Get.snackbar(
                        'Error',
                        'Passwords do not match',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.1),
                        colorText: Colors.red,
                      );
                      return;
                    }

                    controller.register(
                      emailController.text,
                      passwordController.text,
                      nameController.text,
                    );
                  },
                  text: 'Sign Up',
                  isLoading: controller.isLoading.value,
                )).animate().fadeIn(delay: 900.ms).slideY(),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Login'),
                    ),
                  ],
                ).animate().fadeIn(delay: 1000.ms),

                // Error message
                Obx(() => controller.errorMessage.value.isNotEmpty
                    ? Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
                    : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
