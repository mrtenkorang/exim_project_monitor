class Farmer {
  final int? id;
  final String name;
  final String idNumber;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String? photoPath;
  final String regionName;
  final String districtName;
  final String community;
  final String cropType;
  final String varietyBreed;
  final DateTime? plantingDate;
  final String plantingDensity;
  final String laborHired;
  final String estimatedYield;
  final String previousYield;
  final DateTime? harvestDate;
  final DateTime createdAt;
  final bool isSynced;

  Farmer({
    this.id,
    required this.name,
    required this.idNumber,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    this.photoPath,
    required this.regionName,
    required this.districtName,
    required this.community,
    required this.cropType,
    required this.varietyBreed,
    this.plantingDate,
    required this.plantingDensity,
    required this.laborHired,
    required this.estimatedYield,
    required this.previousYield,
    this.harvestDate,
    DateTime? createdAt,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerIdNumber': idNumber,
      'name': name,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'photoPath': photoPath,
      'regionName': regionName,
      'districtName': districtName,
      'community': community,
      'cropType': cropType,
      'varietyBreed': varietyBreed,
      'plantingDate': plantingDate?.toIso8601String(),
      'plantingDensity': plantingDensity,
      'laborHired': laborHired,
      'estimatedYield': estimatedYield,
      'previousYield': previousYield,
      'harvestDate': harvestDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'],
      name: map['name'],
      idNumber: map['farmerIdNumber'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      dateOfBirth: map['dateOfBirth'],
      photoPath: map['photoPath'],
      regionName: map['regionName'],
      districtName: map['districtName'],
      community: map['community'],
      cropType: map['cropType'],
      varietyBreed: map['varietyBreed'],
      plantingDate: map['plantingDate'] != null ? DateTime.parse(map['plantingDate']) : null,
      plantingDensity: map['plantingDensity'],
      laborHired: map['laborHired'],
      estimatedYield: map['estimatedYield'],
      previousYield: map['previousYield'],
      harvestDate: map['harvestDate'] != null ? DateTime.parse(map['harvestDate']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      isSynced: map['isSynced'] == 1,
    );
  }
}
