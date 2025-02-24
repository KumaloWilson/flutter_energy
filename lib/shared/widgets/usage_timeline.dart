import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../modules/appliance/controller/appliance_controller.dart';


class UsageTimeline extends StatelessWidget {
  const UsageTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplianceController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const _TimelineSkeleton();
      }

      return Column(
        children: controller.timelineData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == controller.timelineData.length - 1;

          return _TimelineItem(
            timestamp: item.timestamp,
            event: item.event,
            value: item.value,
            isLast: isLast,
            index: index,
          );
        }).toList(),
      );
    });
  }
}

class _TimelineItem extends StatelessWidget {
  final DateTime timestamp;
  final String event;
  final String value;
  final bool isLast;
  final int index;

  const _TimelineItem({
    required this.timestamp,
    required this.event,
    required this.value,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              timeago.format(timestamp, allowFromNow: true),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$value kWh',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(delay: (index * 100).ms).slideX(),
    );
  }
}

class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
            (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      duration: 1500.ms,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
    );
  }
}

