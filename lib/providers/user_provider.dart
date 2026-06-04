import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:near_vibe/core/exceptions/app_exception.dart';
import 'package:near_vibe/models/user_model.dart';

import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ================= STATE =================

  UserModel? user;
  List<User> users = [];

  bool isLoading = false;
  AppException? exception; // ← AppException instead of String?

  StreamSubscription<User>? _userSubscription;

  // ================= FETCH SINGLE USER =================

  Future<void> fetchUser(String userId) async {
    isLoading = true;
    exception = null;
    notifyListeners();

    try {
      user = await _repository.getUserById(userId);
    } on AppException catch (e) {
      exception = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= FETCH CURRENT USER =================

  Future<void> fetchCurrentUser() async {
    isLoading = true;
    exception = null;
    notifyListeners();

    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        throw const AppException('No user logged in.');
      }

      user = await _repository.getCurrentUser(uid);
    } on AppException catch (e) {
      exception = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // ================= CLEAR =================

  void clearUser() {
    user = null;
    exception = null;
    notifyListeners();
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
