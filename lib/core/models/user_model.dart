class User {

  String? firstName;
  String? lastName;
  String? userName;
  String? staffId;
  String? districtName;
  String? districtCode;
  int? districtId;
  String? regionName;
  String? regionCode;

  User({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.staffId,
    required this.districtName,
    required this.districtCode,
    required this.districtId,
    required this.regionName,
    required this.regionCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      lastName: json['last_name'],
      userName: json['username'],
      staffId: json['staff_id'],
      districtName: json['district_name'],
      districtCode: json['district_code'],
      districtId: json['district_id'],
      regionName: json['region_name'],
      regionCode: json['region_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName ?? "TEST",
      'last_name': lastName ?? "TEST",
      'username': userName ?? "TEST",
      'staff_id': staffId ?? "TEST",
      'district_name': districtName ?? "TEST",
      'district_code': districtCode ?? "TEST",
      'district_id': districtId,
      'region_name': regionName ?? "TEST",
      'region_code': regionCode ?? "TEST",
    };
  }

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