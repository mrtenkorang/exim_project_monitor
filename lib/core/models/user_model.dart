class User {
  final int id;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final String? profilePicture;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bankAccountNumber;
  final String? bankName;
  final String role;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? addedBy;
  final int? modifiedBy;
  final int? deletedBy;
  final int userId;
  final int? districtId;
  final String? password;

  const User({
    required this.id,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.profilePicture,
    this.address = '',
    this.dateOfBirth,
    this.gender,
    this.bankAccountNumber,
    this.bankName,
    this.role = 'user',
    this.isActive = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.addedBy,
    this.modifiedBy,
    this.deletedBy,
    required this.userId,
    this.districtId,
    this.password,
  });

  // login map


  // Convert User to a Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'address': address,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'role': role,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'added_by': addedBy,
      'modified_by': modifiedBy,
      'deleted_by': deletedBy,
      'user': userId,
      'district': districtId,
    };
  }

  // Create User from a Map (from API response)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int? ?? 0,
      email: map['email'] as String?,
      fullName: map['full_name'] as String?,
      phoneNumber: map['phone_number'] as String?,
      profilePicture: map['profile_picture'] as String?,
      address: map['address'] as String? ?? '',
      dateOfBirth: map['date_of_birth'] != null 
          ? DateTime.tryParse(map['date_of_birth']) 
          : null,
      gender: map['gender'] as String?,
      bankAccountNumber: map['bank_account_number'] as String?,
      bankName: map['bank_name'] as String?,
      role: map['role'] as String? ?? 'user',
      isActive: map['is_active'] as bool? ?? true,
      isDeleted: map['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null 
          ? DateTime.tryParse(map['deleted_at'] as String) 
          : null,
      addedBy: map['added_by'] as int?,
      modifiedBy: map['modified_by'] as int?,
      deletedBy: map['deleted_by'] as int?,
      userId: map['user'] as int? ?? 0,
      districtId: map['district'] as int?,
    );
  }

  // Create a copy of User with some fields updated
  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profilePicture,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? bankAccountNumber,
    String? bankName,
    String? role,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? addedBy,
    int? modifiedBy,
    int? deletedBy,
    int? userId,
    int? districtId,
    bool? isSynced,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      addedBy: addedBy ?? this.addedBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      deletedBy: deletedBy ?? this.deletedBy,
      userId: userId ?? this.userId,
      districtId: districtId ?? this.districtId,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;



}


class LoginUser {
  String username;
  String password;

  LoginUser({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> loginMap() {
    return {
      'username': username,
      'password': password,
    };
  }
}
