class RoomModel {
  final String id;
  final String name;
  final String homeId;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.homeId,
    required this.createdAt,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      name: map['name'] ?? '',
      homeId: map['homeId'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'homeId': homeId,
      'createdAt': createdAt,
    };
  }
}
