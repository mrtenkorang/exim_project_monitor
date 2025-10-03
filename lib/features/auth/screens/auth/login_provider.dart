import 'dart:convert';

import 'package:exim_project_monitor/core/services/api/api.dart';
import 'package:flutter/material.dart' show ChangeNotifier, debugPrint, TextEditingController;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/cache_service/cache_service.dart';
import '../../../../core/models/user_model.dart';

class LoginProvider extends ChangeNotifier {


  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  APIService apiService = APIService();

  Future<bool> login(LoginUser user) async {
    try {
      final response = await apiService.login(user);

      if(response.fullName!.isNotEmpty){
        await CacheService().saveLoginStatus(true);
        /// cache user
        await CacheService().saveUserInfo(response);
      }

      debugPrint("THE USER RESPONSE IS :::::::::::: $response");
      return true;
    } catch (e) {
      rethrow;
    }
  }



}