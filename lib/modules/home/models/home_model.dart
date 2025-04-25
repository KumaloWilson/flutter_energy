class HomeModel {
  final String id;
  final String name;
  final String meterNumber;
  final double currentReading;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  HomeModel({
    required this.id,
    required this.name,
    required this.meterNumber,
    required this.currentReading,
    required this.createdAt,
    this.lastUpdated,
  });

  factory HomeModel.fromMap(Map<String, dynamic> map, String id) {
    return HomeModel(
      id: id,
      name: map['name'] ?? '',
      meterNumber: map['meterNumber'] ?? '',
      currentReading: (map['currentReading'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
      lastUpdated: map['lastUpdated'] != null 
          ? (map['lastUpdated'] as dynamic).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'meterNumber': meterNumber,
      'currentReading': currentReading,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
    };
  }
}
