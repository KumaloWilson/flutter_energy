import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;
  String themeColor;
  String role;
  String? connectedTo;
  String? photoUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    required this.themeColor,
    required this.role,
    this.connectedTo,
    this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      themeColor: map['themeColor'] ?? 'blue',
      role: map['role'] ?? 'member',
      connectedTo: map['connectedTo'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'themeColor': themeColor,
      'role': role,
      'connectedTo': connectedTo,
      'photoUrl': photoUrl,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? themeColor,
    String? role,
    String? connectedTo,
    String? photoUrl,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: this.createdAt,
      themeColor: themeColor ?? this.themeColor,
      role: role ?? this.role,
      connectedTo: connectedTo ?? this.connectedTo,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin' || isOwner;
  bool get canEditDevices => isAdmin || role == 'editor';
}
