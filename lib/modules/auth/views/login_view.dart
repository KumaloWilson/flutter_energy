import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';


class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final theme = Theme.of(context);

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
                // App logo and title
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                      const SizedBox(height: 16),
                      Text(
                        'Smart Energy',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor and optimize your energy usage',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Home image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/smart_home.jpg',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(),

                const SizedBox(height: 40),

                // Login form
                Text(
                  'Login',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),

                CustomTextField(
                  controller: emailController,
                  hint: 'Email',
                  prefixIcon: Icons.email,
                ).animate().fadeIn(delay: 700.ms).slideX(),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: passwordController,
                  hint: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                ).animate().fadeIn(delay: 800.ms).slideX(),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password logic
                    },
                    child: Text('Forgot Password?'),
                  ),
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 24),

                Obx(() => CustomButton(
                  onPressed: () => controller.login(
                    emailController.text,
                    passwordController.text,
                  ),
                  text: 'Login',
                  isLoading: controller.isLoading.value,
                )).animate().fadeIn(delay: 1000.ms).slideY(),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.SIGNUP),
                      child: Text('Sign Up'),
                    ),
                  ],
                ).animate().fadeIn(delay: 1100.ms),

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
