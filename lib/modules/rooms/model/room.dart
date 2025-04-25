class Room {
  final String id;
  final String name;
  final String iconName;
  final int deviceCount;
  final int order;
  final String imageUrl;

  Room({
    required this.id,
    required this.name,
    required this.iconName,
    required this.deviceCount,
    required this.order,
    required this.imageUrl,
  });

  factory Room.fromMap(Map<String, dynamic> map, String id) {
    return Room(
      id: id,
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? 'home',
      deviceCount: map['deviceCount'] ?? 0,
      order: map['order'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconName': iconName,
      'deviceCount': deviceCount,
      'order': order,
      'imageUrl': imageUrl,
    };
  }

  Room copyWith({
    String? name,
    String? iconName,
    int? deviceCount,
    int? order,
    String? imageUrl,
  }) {
    return Room(
      id: this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      deviceCount: deviceCount ?? this.deviceCount,
      order: order ?? this.order,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
