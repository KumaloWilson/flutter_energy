import 'package:cloud_firestore/cloud_firestore.dart';

class Appliance {
  final String id;
  final String name;
  final String type;
  final String iconName;
  final String status;
  final double power;
  final double voltage;
  final double current;
  final DateTime lastUpdated;
  final bool isOn;
  final Map<String, dynamic>? additionalData;

  Appliance({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.status,
    required this.power,
    required this.voltage,
    required this.current,
    required this.lastUpdated,
    required this.isOn,
    this.additionalData,
  });

  factory Appliance.fromMap(Map<String, dynamic> map, String id) {
    return Appliance(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      iconName: map['iconName'] ?? 'device_unknown',
      status: map['status'] ?? 'Unknown',
      power: (map['power'] ?? 0.0).toDouble(),
      voltage: (map['voltage'] ?? 0.0).toDouble(),
      current: (map['current'] ?? 0.0).toDouble(),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      isOn: map['isOn'] ?? false,
      additionalData: map['additionalData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'iconName': iconName,
      'status': status,
      'power': power,
      'voltage': voltage,
      'current': current,
      'lastUpdated': lastUpdated,
      'isOn': isOn,
      'additionalData': additionalData,
    };
  }

  Appliance copyWith({
    String? name,
    String? type,
    String? iconName,
    String? status,
    double? power,
    double? voltage,
    double? current,
    DateTime? lastUpdated,
    bool? isOn,
    Map<String, dynamic>? additionalData,
  }) {
    return Appliance(
      id: this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      status: status ?? this.status,
      power: power ?? this.power,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOn: isOn ?? this.isOn,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
