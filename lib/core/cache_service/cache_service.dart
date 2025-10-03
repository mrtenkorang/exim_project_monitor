
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class CacheService {


  Future<void> saveLoginStatus(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<bool?> getLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn');
  }

  Future<void> saveUserInfo(User userInfo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', jsonEncode(userInfo));

  }

  Future<User?> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userInfo = prefs.getString('user_info');
    if (userInfo != null) {
      return User.fromMap(jsonDecode(userInfo));
    }
    return null;
  }

}