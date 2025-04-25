import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/home/models/room_model.dart';

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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getRoomIcon(room.name),
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      room.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$applianceCount ${applianceCount == 1 ? 'Device' : 'Devices'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoomIcon(String roomName) {
    final name = roomName.toLowerCase();
    if (name.contains('living')) return Icons.weekend;
    if (name.contains('kitchen')) return Icons.kitchen;
    if (name.contains('bed')) return Icons.bed;
    if (name.contains('bath')) return Icons.bathtub;
    if (name.contains('office')) return Icons.computer;
    if (name.contains('dining')) return Icons.dining;
    if (name.contains('media')) return Icons.tv;
    if (name.contains('game')) return Icons.sports_esports;
    return Icons.home;
  }
}
