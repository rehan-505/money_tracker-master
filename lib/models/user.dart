import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{
  final String name;
  final String id;
  final String email;
  final String phone;
  final Timestamp createdAt;
  final String abx;
  final List fcmTokens;


  AppUser({
    required this.name,
    required this.id,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.abx,
    required this.fcmTokens,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
      'abx': abx,
      'fcmTokens': fcmTokens
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      name: map['name'] as String,
      id: map['id'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      createdAt: map['createdAt'] as Timestamp,
      abx: map['abx'] as String,
      fcmTokens: map['fcmTokens']
    );
  }
}