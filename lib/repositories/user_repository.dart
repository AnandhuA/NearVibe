import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:near_vibe/core/exceptions/app_exception.dart';
import 'package:near_vibe/models/user_model.dart';

class UserRepository {
  final CollectionReference _usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  // ================= FETCH SINGLE USER =================

  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();

      if (!doc.exists) {
        throw const AppException('User not found.');
      }

      return UserModel.fromDocument(doc);
    } on AppException {
      rethrow;
    } catch (e) {
      throw const AppException('Failed to fetch user.');
    }
  }

  // ================= FETCH ALL USERS =================

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _usersRef.get();

      return snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      throw const AppException('Failed to fetch users.');
    }
  }

  // ================= FETCH CURRENT USER =================

  Future<UserModel> getCurrentUser(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();

      if (!doc.exists) {
        throw const AppException('Current user profile not found.');
      }

      return UserModel.fromDocument(doc);
    } on AppException {
      rethrow;
    } catch (e) {
      throw const AppException('Failed to fetch current user.');
    }
  }

  // ================= REAL-TIME STREAM =================

  Stream<UserModel> streamUser(String userId) {
    try {
      return _usersRef
          .doc(userId)
          .snapshots()
          .map((doc) => UserModel.fromDocument(doc));
    } catch (e) {
      throw const AppException('Failed to stream user.');
    }
  }
}
