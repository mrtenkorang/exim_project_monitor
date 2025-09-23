class User {
  final String id;
  final String email;
  final String? fullName;  // Maps to full_name in database
  final String? photoUrl;
  final String role;  // Changed from isAdmin to role
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? passwordHash;
  final bool isSynced;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.photoUrl,
    this.role = 'user',  // Default role is 'user'
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.passwordHash,
    this.isSynced = false,
  });

  // Convert User to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': fullName,
      'full_name': fullName,
      'profile_image_url': photoUrl,
      'role': role,
      'phone_number': '',
      'is_active': isActive ? 1 : 0,
      // 'lastLogin': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      // 'passwordHash': passwordHash,
    };
  }

  // Create User from a Map (from database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      // username: map['username'],
      fullName: map['full_name'],
      photoUrl: map['profile_image_url'],
      role: map['role'] ?? 'user',
      isActive: map['is_active'] == 1,
      // lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      // passwordHash: map['passwordHash'],
    );
  }

  // Create a copy of User with some fields updated
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? photoUrl,
    String? role,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? passwordHash,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
