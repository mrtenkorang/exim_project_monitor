// import 'dart:convert';

// import 'package:exim_project_monitor/core/models/custom_user.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CacheService {
//   static final CacheService _instance = CacheService._internal();

//   factory CacheService() => _instance;

//   CacheService._internal();

//   Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('token', token);
//   }

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   Future<String?> saveUserInfo(CmUser userInfo) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user_info', jsonEncode(userInfo));
//     return prefs.getString('user_info');
//   }

//   Future<CmUser?> getUserInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userInfo = prefs.getString('user_info');
//     if (userInfo != null) {
//       return CmUser.fromJson(jsonDecode(userInfo));
//     }
//     //return a default user
//     return CmUser(
//       firstName: "Kwame",
//       lastName: "Nkrumah",
//       userId: "1",
//       group: "Admin",
//       district: "Accra",
//       userID: 4,
//       lbc: "Accra",
//     );
//   }
// }