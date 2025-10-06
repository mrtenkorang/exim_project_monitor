class District {
  final int id;
  final String district;
  final String districtCode;
  final String region;
  final String regCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  District({
    required this.id,
    required this.district,
    required this.districtCode,
    required this.region,
    required this.regCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int? ?? 0,
      district: json['district'] as String? ?? '',
      districtCode: json['district_code'] as String? ?? '',
      region: json['region'] as String? ?? '',
      regCode: json['reg_code'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district': district,
      'district_code': districtCode,
      'region': region,
      'reg_code': regCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}