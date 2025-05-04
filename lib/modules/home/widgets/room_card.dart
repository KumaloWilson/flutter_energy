import 'package:flutter/material.dart';
import 'package:flutter_energy/modules/home/models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final int deviceCount;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.deviceCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Icon with background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRoomIcon(room.name),
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),

              const Spacer(),

              // Room Name
              Text(
                room.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Device Count
              Row(
                children: [
                  Icon(
                    Icons.devices,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$deviceCount ${deviceCount == 1 ? 'Device' : 'Devices'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      return Icons.dining;
    } else if (name.contains('game') || name.contains('entertainment')) {
      return Icons.sports_esports;
    } else if (name.contains('laundry')) {
      return Icons.local_laundry_service;
    } else if (name.contains('garage')) {
      return Icons.garage;
    } else {
      return Icons.home;
    }
  }
}
