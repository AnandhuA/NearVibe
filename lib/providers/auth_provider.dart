import 'package:flutter/material.dart';
import 'package:near_vibe/core/exceptions/firebase_exception_mapper.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> createAccount({
    required String email,
    required String password,
    required String name
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.createAccount(email: email, password: password,name: name);
    } catch (e) {
      throw FirebaseExceptionMapper.map(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.login(email: email, password: password);
    } catch (e) {
      throw FirebaseExceptionMapper.map(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
