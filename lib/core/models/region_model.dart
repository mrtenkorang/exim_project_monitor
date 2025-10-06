class Region {
  final int id;
  final String region;
  final String regCode;
  final String createdAt;
  final String updatedAt;

  Region({
    required this.id,
    required this.region,
    required this.regCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as int? ?? 0,
      region: json['region'] as String? ?? '',
      regCode: json['reg_code'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'reg_code': regCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method to convert to DateTime objects
  DateTime get createdDateTime => DateTime.tryParse(createdAt) ?? DateTime.now();
  DateTime get updatedDateTime => DateTime.tryParse(updatedAt) ?? DateTime.now();

  // Copy with method for immutability
  Region copyWith({
    int? id,
    String? region,
    String? regCode,
    String? createdAt,
    String? updatedAt,
  }) {
    return Region(
      id: id ?? this.id,
      region: region ?? this.region,
      regCode: regCode ?? this.regCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Region(id: $id, region: $region, regCode: $regCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Region && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}