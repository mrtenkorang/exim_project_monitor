import 'dart:convert';

import 'package:exim_project_monitor/core/services/api/api.dart';
import 'package:flutter/material.dart' show ChangeNotifier, debugPrint, TextEditingController;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/cache_service/cache_service.dart';
import '../../../../core/models/user_model.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final APIService _apiService = APIService();
  CacheService? _cacheService;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      _errorMessage = 'Please enter both username and password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = LoginUser(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      final response = await _apiService.login(user);

      debugPrint("THE LOGIN RES ::::::: $response");

      // Parse the response into a User object


      // initialize cache service
      _cacheService ??= await CacheService.getInstance();

      // Save login status and user data
      await _cacheService!.saveLoginStatus(true);
      await _cacheService!.saveUserInfo(response);
      
      debugPrint('User logged in successfully: ${response.firstName} ${response.lastName} (${response.staffId})');
      return true;
      
    } catch (e, stackTrace) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Login error: $_errorMessage');
      debugPrint('Login error: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
