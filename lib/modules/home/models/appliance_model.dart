class ApplianceModel {
  final String id;
  final String name;
  final String type;
  final double wattage;
  final String roomId;
  final String meterNumber;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  bool isActive;
  double? currentReading;
  double? dailyUsage;
  double? monthlyUsage;

  ApplianceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.wattage,
    required this.roomId,
    required this.meterNumber,
    required this.createdAt,
    this.lastUpdated,
    this.isActive = false,
    this.currentReading,
    this.dailyUsage,
    this.monthlyUsage,
  });

  factory ApplianceModel.fromJson(Map<String, dynamic> json) {
    return ApplianceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      wattage: (json['wattage'] ?? 0).toDouble(),
      roomId: json['room_id'] ?? '',
      meterNumber: json['meter_number'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
      isActive: json['is_active'] ?? false,
      currentReading: json['current_reading'] != null
          ? (json['current_reading']).toDouble()
          : null,
      dailyUsage: json['daily_usage'] != null
          ? (json['daily_usage']).toDouble()
          : null,
      monthlyUsage: json['monthly_usage'] != null
          ? (json['monthly_usage']).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'wattage': wattage,
      'room_id': roomId,
      'meter_number': meterNumber,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
      'is_active': isActive,
      'current_reading': currentReading,
      'daily_usage': dailyUsage,
      'monthly_usage': monthlyUsage,
    };
  }

  ApplianceModel copyWith({
    String? id,
    String? name,
    String? type,
    double? wattage,
    String? roomId,
    String? meterNumber,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isActive,
    double? currentReading,
    double? dailyUsage,
    double? monthlyUsage,
  }) {
    return ApplianceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      wattage: wattage ?? this.wattage,
      roomId: roomId ?? this.roomId,
      meterNumber: meterNumber ?? this.meterNumber,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      currentReading: currentReading ?? this.currentReading,
      dailyUsage: dailyUsage ?? this.dailyUsage,
      monthlyUsage: monthlyUsage ?? this.monthlyUsage,
    );
  }
}
