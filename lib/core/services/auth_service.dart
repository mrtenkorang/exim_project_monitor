import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

class AuthService {
  final UserRepository _userRepository;
  final SharedPreferences _prefs;
  
  static const String _authTokenKey = 'auth_token';
  static const String _currentUserIdKey = 'current_user_id';
  
  AuthService(this._userRepository, this._prefs);
  
  // Check if user is logged in
  bool get isLoggedIn => _prefs.getString(_authTokenKey) != null;
  
  // Get current user
  User? get currentUser => _userRepository.currentUser;
  
  // Get auth token
  String? get authToken => _prefs.getString(_authTokenKey);
  
  // Login with username and password
  Future<User?> login(String username, String password) async {
    final user = await _userRepository.authenticate(username, password);
    if (user != null) {
      await _saveAuthState(user);
    }
    return user;
  }
  
  // Logout current user
  Future<void> logout() async {
    _userRepository.logout();
    await _clearAuthState();
  }
  
  // Check if user has a specific role
  bool hasRole(String role) => currentUser?.role == role;
  
  // Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) => 
      currentUser != null && roles.contains(currentUser!.role);
  
  // Check if user has permission to access a feature
  bool hasPermission(String permission) {
    if (currentUser == null) return false;
    
    // Admin has all permissions
    if (currentUser!.role == 'admin') return true;
    
    // Define role-based permissions
    final rolePermissions = {
      'field_collector': [
        'view_assigned_farms',
        'edit_assigned_farms',
        'submit_farm_data',
        'upload_photos',
      ],
      'qa_qc': [
        'view_all_farms',
        'verify_farm_data',
        'generate_reports',
      ],
    };
    
    // Check if user's role has the required permission
    return rolePermissions[currentUser!.role]?.contains(permission) ?? false;
  }
  
  // Initialize auth state from shared preferences
  Future<User?> initAuthState() async {
    final userId = _prefs.getString(_currentUserIdKey);
    if (userId != null) {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        _userRepository.currentUser = user;
        return user;
      }
    }
    return null;
  }
  
  // Save auth state to shared preferences
  Future<void> _saveAuthState(User user) async {
    await _prefs.setString(_authTokenKey, 'dummy_token_${user.id}');
    await _prefs.setString(_currentUserIdKey, user.id);
  }
  
  // Clear auth state
  Future<void> _clearAuthState() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_currentUserIdKey);
  }
  
  // Change password
  Future<bool> changePassword(
    String currentPassword, 
    String newPassword,
  ) async {
    if (currentUser == null) return false;
    
    return await _userRepository.changePassword(
      currentUser!.id,
      currentPassword,
      newPassword,
    );
  }
}
