import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final DateTime createdAt;
  final String location;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
       required this.location,
       required this.createdAt,
  });

  // ================= FROM FIRESTORE =================

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id:        doc.id,
      name:      data['name']      ?? '',
      email:     data['email']     ?? '',
      phone:     data['phone']     ?? '',
      location:  data['location']  ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ================= TO FIRESTORE =================

  Map<String, dynamic> toMap() {
    return {
      'name':      name,
      'email':     email,
      'phone':     phone,
      'avatarUrl': avatarUrl,
    };
  }
}