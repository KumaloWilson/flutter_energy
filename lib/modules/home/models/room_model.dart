class RoomModel {
  final String id;
  final String name;
  final String homeId;

  RoomModel({
    required this.id,
    required this.name,
    required this.homeId,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      name: map['name'] ?? '',
      homeId: map['homeId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'homeId': homeId,
    };
  }
}
