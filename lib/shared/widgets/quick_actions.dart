import 'package:flutter/material.dart';
import 'package:flutter_energy/routes/app_pages.dart';
import 'package:get/get.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // _QuickActionCard(
          //   icon: Icons.analytics,
          //   label: 'Analytics',
          //   onTap: () => Get.toNamed(Routes.ANALYTICS),
          //   color: Colors.blue,
          // ),
          // _QuickActionCard(
          //   icon: Icons.schedule,
          //   label: 'Schedules',
          //   onTap: () => Get.toNamed(Routes.SCHEDULES),
          //   color: Colors.orange,
          // ),
          _QuickActionCard(
            icon: Icons.tips_and_updates,
            label: 'Tips',
            onTap: () => Get.toNamed(Routes.TIPS),
            color: Colors.green,
          ),
          _QuickActionCard(
            icon: Icons.notifications,
            label: 'Alerts',
            onTap: () => Get.toNamed(Routes.ALERTS),
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
