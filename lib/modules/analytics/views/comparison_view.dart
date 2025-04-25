import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../controllers/comparison_controller.dart';
import '../widgets/comparison_widgets.dart';

class ComparisonView extends StatelessWidget {
  const ComparisonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find or create the controller only once
    final controller = Get.put(ComparisonController());
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: controller.fetchAllData,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return ErrorDisplay(
            errorMessage: controller.errorMessage.value,
            onRetry: controller.fetchAllData,
          );
        }

        // Use ListView.builder for more efficient rendering
        return ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            // Split into separate widget components
            ComparisonSettingsCard(),
            SizedBox(height: 24),
            DeviceComparisonCard(),
            SizedBox(height: 24),
            TimePeriodComparisonCard(),
            SizedBox(height: 24),
            EfficiencyComparisonCard(),
          ],
        );
      }),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorDisplay({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
