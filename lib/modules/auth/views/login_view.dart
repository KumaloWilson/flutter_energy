import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/shared/widgets/custom_button.dart';
import 'package:flutter_energy/shared/widgets/custom_text_field.dart';
import 'package:flutter_energy/routes/app_pages.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // App Logo and Title
                Column(
                  children: [
                    Icon(
                      Icons.energy_savings_leaf,
                      size: 80,
                      color: colorScheme.primary,
                    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Energy Management',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
                

                
                const SizedBox(height: 40),
                
                // Login Form
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: 24),
                
                CustomTextField(
                  controller: emailController,
                  hint: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ).animate().fadeIn(delay: 600.ms).slideX(),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: passwordController,
                  hint: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
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
                
                // Login Button
                Obx(() => CustomButton(
                  onPressed: () => controller.login(
                    emailController.text,
                    passwordController.text,
                  ),
                  text: 'Login',
                  isLoading: controller.isLoading.value,
                )).animate().fadeIn(delay: 800.ms).slideY(),
                
                const SizedBox(height: 16),
                
                // Google Sign In
                OutlinedButton.icon(
                  onPressed: () => controller.signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms),
                
                const SizedBox(height: 24),
                
                // Sign Up Link
                TextButton(
                  onPressed: () => Get.toNamed(Routes.SIGNUP),
                  child: const Text('Don\'t have an account? Sign up'),
                ).animate().fadeIn(delay: 1000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
