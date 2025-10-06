import 'dart:convert';

import 'package:exim_project_monitor/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/screens/auth/login_screen.dart';
import '../models/user_model.dart';

class CacheService {
  static const String _loginStatusKey = 'isLoggedIn';
  static const String _userInfoKey = 'user_info';

  final SharedPreferences _prefs;

  // Private constructor
  CacheService._(this._prefs);

  // Factory constructor to handle async initialization
  static Future<CacheService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService._(prefs);
  }

  /// Saves the login status to shared preferences
  Future<void> saveLoginStatus(bool isLoggedIn) async {
    try {
      await _prefs.setBool(_loginStatusKey, isLoggedIn);
    } catch (e) {
      debugPrint('Error saving login status: $e');
      rethrow;
    }
  }

  /// Retrieves the login status from shared preferences
  bool? getLoginStatus() {
    try {
      return _prefs.getBool(_loginStatusKey);
    } catch (e) {
      debugPrint('Error getting login status: $e');
      return null;
    }
  }

  /// Saves user information to shared preferences
  Future<void> saveUserInfo(User userInfo) async {
    try {
      final userJson = userInfo.toJson();
      await _prefs.setString(_userInfoKey, jsonEncode(userJson));
    } catch (e) {
      debugPrint('Error saving user info: $e');
      rethrow;
    }
  }

  /// Retrieves user information from shared preferences
  Future<User?> getUserInfo() async {
    try {
      final userInfo = _prefs.getString(_userInfoKey);
      if (userInfo != null) {
        final userMap = jsonDecode(userInfo) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user info: $e');
      return null;
    }
  }

  /// Clears all user data (logout)
  Future<void> clearUserData() async {
    try {
      await _prefs.remove(_userInfoKey);
      await _prefs.remove(_loginStatusKey);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout(BuildContext context) async {
    try {
      await clearUserData();
      await saveLoginStatus(false);

      CustomSnackbar.show(
        context,
        message: "Logged out successfully",
        type: SnackbarType.success,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }
}
