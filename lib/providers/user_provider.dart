import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:near_vibe/core/exceptions/app_exception.dart';
import 'package:near_vibe/models/user_model.dart';
import 'package:near_vibe/repositories/local_storage_repository.dart';

import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  final LocalStorageRepository _localRepository = LocalStorageRepository();

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
      user = await _localRepository.getUser();

      if (user == null) {
        throw const AppException('No local user found.');
      }
    } on AppException catch (e) {
      exception = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //============LOAD LOCAL USER DATA =============

  Future<void> loadLocalUser() async {
    isLoading = true;
    exception = null;
    notifyListeners();

    try {
      user = await _localRepository.getUser();
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
