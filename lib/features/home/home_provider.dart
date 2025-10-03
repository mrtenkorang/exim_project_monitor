import 'package:flutter/material.dart' show ChangeNotifier, debugPrint;

class HomeProvider extends ChangeNotifier {

  String _greeting = '';
  String _userNameGreeting = '';

  String get userNameGreeting => _userNameGreeting;
  String get greeting => _greeting;

  getUserNameGreeting(){
    _userNameGreeting = 'Hello, Kwame!';
    notifyListeners();
  }

  getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 18) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }

    debugPrint(_greeting);
    debugPrint(greeting);
    notifyListeners();
  }

}