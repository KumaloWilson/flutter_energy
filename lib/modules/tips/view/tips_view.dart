import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controller/tips_controller.dart';
import '../model/energy_tips.dart';

class TipsView extends StatelessWidget {
  const TipsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TipsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Saving Tips'),
      ),
      body: Column(
        children: [
          _CategoryFilter(controller: controller)
              .animate()
              .fadeIn()
              .slideY(begin: -0.2),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredTips.length,
                itemBuilder: (context, index) {
                  final tip = controller.filteredTips[index];
                  return _TipCard(
                    tip: tip,
                    controller: controller,
                  ).animate().fadeIn(delay: (index * 100).ms).slideX();
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final TipsController controller;

  const _CategoryFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'All',
            icon: Icons.all_inclusive,
            color: Colors.grey,
            selected: controller.selectedCategory.value == null,
            onTap: () => controller.setCategory(null),
          ),
          ...TipCategory.values.map((category) {
            return _FilterChip(
              label: category.name.capitalize!,
              icon: controller.getCategoryIcon(category),
              color: controller.getCategoryColor(category),
              selected: controller.selectedCategory.value == category,
              onTap: () => controller.setCategory(category),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: color.withOpacity(0.1),
        selectedColor: color,
        checkmarkColor: Theme.of(context).colorScheme.onPrimary,
        labelStyle: TextStyle(
          color: selected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final EnergyTip tip;
  final TipsController controller;

  const _TipCard({
    required this.tip,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: controller.getCategoryColor(tip.category).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  controller.getCategoryIcon(tip.category),
                  color: controller.getCategoryColor(tip.category),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tip.category.name.capitalize!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: controller.getCategoryColor(tip.category),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    tip.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border_outlined,
                    color: tip.isBookmarked
                        ? controller.getCategoryColor(tip.category)
                        : null,
                  ),
                  onPressed: () => controller.toggleBookmark(tip),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.description),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.savings,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Potential Savings: ${tip.savingEstimate}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Steps to Follow:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...tip.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: controller
                                .getCategoryColor(tip.category)
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                color: controller.getCategoryColor(tip.category),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

