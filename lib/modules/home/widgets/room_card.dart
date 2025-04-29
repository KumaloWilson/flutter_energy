import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/home/models/room_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final int applianceCount;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.applianceCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getRoomIcon(room.name),
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$applianceCount ${applianceCount == 1 ? 'appliance' : 'appliances'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  IconData _getRoomIcon(String roomName) {
    final name = roomName.toLowerCase();

    if (name.contains('living') || name.contains('lounge')) {
      return Icons.weekend;
    } else if (name.contains('kitchen')) {
      return Icons.kitchen;
    } else if (name.contains('bed') || name.contains('master')) {
      return Icons.bed;
    } else if (name.contains('bath')) {
      return Icons.bathtub;
    } else if (name.contains('office') || name.contains('study')) {
      return Icons.computer;
    } else if (name.contains('dining')) {
      return Icons.dinner_dining;
    } else if (name.contains('garage')) {
      return Icons.garage;
    } else if (name.contains('garden') || name.contains('yard')) {
      return Icons.yard;
    } else {
      return Icons.home;
    }
  }
}
