import 'dart:convert';

import 'package:near_vibe/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  static const String userKey = 'user';

  //===SAVE USER IN LOCAL ===
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }

  //=== GET USER IN LOCAL ====
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(userKey);

    if (data == null) return null;

    return UserModel.fromJson(jsonDecode(data));
  }

  //=== REMOVE USER IN LOCAL ====
  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(userKey);
  }

  //=== SAVE STRING IN LOCAL ====
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, value);
  }

  //===== GET STRING IN LOCAL ====
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }
}
