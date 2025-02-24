import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_energy/modules/auth/controllers/auth_controller.dart';
import 'package:flutter_energy/shared/widgets/custom_button.dart';
import 'package:flutter_energy/shared/widgets/custom_text_field.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: emailController,
                  hint: 'Email',
                  prefixIcon: Icons.email,
                ).animate().fadeIn(delay: 400.ms).slideX(),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hint: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                ).animate().fadeIn(delay: 500.ms).slideX(),
                const SizedBox(height: 24),
                Obx(() => CustomButton(
                      onPressed: () => controller.login(
                        emailController.text,
                        passwordController.text,
                      ),
                      text: 'Login',
                      isLoading: controller.isLoading.value,
                    )).animate().fadeIn(delay: 600.ms).slideY(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.toNamed('/signup'),
                  child: const Text('Don\'t have an account? Sign up'),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

