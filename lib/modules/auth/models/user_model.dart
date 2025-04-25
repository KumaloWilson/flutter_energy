class UserModel {
  final String id;
  final String name;
  final String email;
  final String homeId;
  final String role; // owner, admin, member
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.homeId,
    required this.role,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      homeId: map['homeId'] ?? '',
      role: map['role'] ?? 'member',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null 
          ? (map['lastLogin'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'homeId': homeId,
      'role': role,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }
}
