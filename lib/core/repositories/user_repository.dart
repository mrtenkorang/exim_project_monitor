import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';
import '../services/database/database_helper.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static User? _currentUser;

  UserRepository();

  // Get current user
  User? get currentUser => _currentUser;

  // Set current user
  set currentUser(User? user) => _currentUser = user;

  // Add a new user
  Future<String> addUser(User user) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.tableUsers,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return user.id;
  }

  // Get user by ID
  Future<User?> getUserById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get user by username
  Future<User?> getUserByUsername(String username) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      where: '${DatabaseHelper.columnUsername} = ?',
      whereArgs: [username.toLowerCase()],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get all users with optional filters
  Future<List<User>> getUsers({
    String? role,
    String? zoneId,
    bool? isActive,
  }) async {
    final db = await _databaseHelper.database;
    
    final List<dynamic> whereArgs = [];
    final List<String> whereClauses = [];

    if (role != null) {
      whereClauses.add('${DatabaseHelper.columnRole} = ?');
      whereArgs.add(role);
    }
    
    if (zoneId != null) {
      whereClauses.add('${DatabaseHelper.columnZoneId} = ?');
      whereArgs.add(zoneId);
    }
    
    if (isActive != null) {
      whereClauses.add('${DatabaseHelper.columnIsActive} = ?');
      whereArgs.add(isActive ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs,
      orderBy: DatabaseHelper.columnFullName,
    );

    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.tableUsers,
      user.toMap()..[DatabaseHelper.columnUpdatedAt] = DateTime.now().toIso8601String(),
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user
  Future<int> deleteUser(String id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableUsers,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
  }

  // Authenticate user
  Future<User?> authenticate(String username, String password) async {
    // In a real app, you should hash the password before comparing
    final user = await getUserByUsername(username);
    if (user != null) {
      // This is a simplified example - in production, use proper password hashing
      // and verification (e.g., bcrypt, Argon2, etc.)
      if (user.passwordHash == _hashPassword(password)) {
        _currentUser = user;
        return user;
      }
    }
    return null;
  }

  // Change password
  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    final user = await getUserById(userId);
    if (user != null && user.passwordHash == _hashPassword(currentPassword)) {
      // Update password
      await updateUser(user.copyWith(
        passwordHash: _hashPassword(newPassword),
      ));
      return true;
    }
    return false;
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableUsers} WHERE ${DatabaseHelper.columnUsername} = ?',
      [username.toLowerCase()],
    );
    return (result.first['count'] as int) > 0;
  }

  // Helper method to hash password (in a real app, use a proper hashing algorithm)
  String _hashPassword(String password) {
    // In a real app, use a proper password hashing algorithm like bcrypt or Argon2
    // This is just a simple example and not secure for production
    return password; // Replace with proper hashing
  }

  // Get users by role
  Future<List<User>> getUsersByRole(String role) => getUsers(role: role);

  // Get field collectors in a zone
  Future<List<User>> getFieldCollectorsInZone(String zoneId) {
    return getUsers(role: 'field_collector', zoneId: zoneId);
  }

  // Get all admins
  Future<List<User>> getAdmins() => getUsers(role: 'admin');

  // Get all QA/QC users
  Future<List<User>> getQaQcUsers() => getUsers(role: 'qa_qc');

  // Logout current user
  void logout() {
    _currentUser = null;
  }
}

// Extension to convert between model and database formats
// extension UserExtensions on User {
//   Map<String, dynamic> toJson() {
//     return {
//       DatabaseHelper.columnId: this.id,
//       DatabaseHelper.columnUsername: this.username.toLowerCase(),
//       DatabaseHelper.columnEmail: this.email,
//       DatabaseHelper.columnFullName: this.fullName,
//       DatabaseHelper.columnRole: this.role,
//       DatabaseHelper.columnZoneId: this.zoneId,
//       DatabaseHelper.columnIsActive: this.isActive ? 1 : 0,
//       DatabaseHelper.columnProfileImageUrl: this.profileImageUrl,
//       DatabaseHelper.columnPhoneNumber: this.phoneNumber,
//       DatabaseHelper.columnCreatedAt: DateTime.now().toIso8601String(),
//       DatabaseHelper.columnUpdatedAt: DateTime.now().toIso8601String(),
//       DatabaseHelper.columnIsSynced: 1, // Users are synced when created
//     };
//   }
// }
