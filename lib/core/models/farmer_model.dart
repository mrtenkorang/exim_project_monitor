class Farmer {
  final int? id;
  final String name;
  final String idNumber;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String projectId;
  // final String? photoPath;
  final String regionName;
  late final String districtName;
  final String community;
  final String businessName;
  // final String cropType;
  // final String varietyBreed;
  // final DateTime? plantingDate;
  // final String plantingDensity;
  // final String laborHired;
  // final String estimatedYield;
  // final String previousYield;
  // final DateTime? harvestDate;
  final DateTime createdAt;
  final int isSynced;

  Farmer({
    this.id,
    required this.name,
    required this.idNumber,
    required this.projectId,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    // this.photoPath,
    required this.regionName,
    required this.districtName,
    required this.community,
    required this.businessName,
    // required this.varietyBreed,
    // this.plantingDate,
    // required this.plantingDensity,
    // required this.laborHired,
    // required this.estimatedYield,
    // required this.previousYield,
    // this.harvestDate,
    DateTime? createdAt,
    required this.isSynced,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerIdNumber': idNumber,
      'name': name,
      'phoneNumber': phoneNumber,
      'projectId': projectId,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      // 'photoPath': photoPath,
      'regionName': regionName,
      'districtName': districtName,
      'community': community,
      'businessName': businessName,
      // 'cropType': cropType,
      // 'varietyBreed': varietyBreed,
      // 'plantingDate': plantingDate?.toIso8601String(),
      // 'plantingDensity': plantingDensity,
      // 'laborHired': laborHired,
      // 'estimatedYield': estimatedYield,
      // 'previousYield': previousYield,
      // 'harvestDate': harvestDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'],
      name: map['name'],
      projectId: map['projectId'],
      idNumber: map['farmerIdNumber'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      dateOfBirth: map['dateOfBirth'],
      // photoPath: map['photoPath'],
      regionName: map['regionName'],
      districtName: map['districtName'],
      community: map['community'],
      businessName: map['businessName'],
      // cropType: map['cropType'],
      // varietyBreed: map['varietyBreed'],
      // plantingDate: map['plantingDate'] != null ? DateTime.parse(map['plantingDate']) : null,
      // plantingDensity: map['plantingDensity'],
      // laborHired: map['laborHired'],
      // estimatedYield: map['estimatedYield'],
      // previousYield: map['previousYield'],
      // harvestDate: map['harvestDate'] != null ? DateTime.parse(map['harvestDate']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      isSynced: map['isSynced'],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJsonOnline() {
    // Parse the dateOfBirth string to DateTime first if it's not already
    DateTime? parsedDob;
    try {
      parsedDob = DateTime.tryParse(dateOfBirth);
    } catch (e) {
      // If parsing fails, use current date as fallback (you might want to handle this differently)
      parsedDob = DateTime.now();
    }

    return {
      'first_name': name.split(' ').first,
      'last_name': name.split(' ').last,
      'phone_number': phoneNumber,
      'email': '',
      'district_name': districtName,
      'gender': gender,
      'date_of_birth': _formatDate(parsedDob),
      'address': '',
      'bank_account_number': '',
      'bank_name': '',
      'national_id': idNumber,
      'years_of_experience': 0,
      'primary_crop': 'a',
      'secondary_crops': [],
      'cooperative_membership': '',
      'extension_services': false,
      'business_name': businessName,
      'community': community,
      // 'variety': varietyBreed,
      // 'planting_date': _formatDate(plantingDate),
      // 'labour_hired': laborHired,
      // 'estimated_yield': estimatedYield,
      // 'yield_in_pre_season': previousYield,
      // 'harvest_date': _formatDate(harvestDate),
    };
  }

  factory Farmer.fromMapOnline(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'],
      name: '',
      idNumber: '',
      projectId: '',
      phoneNumber: '',
      gender: '',
      dateOfBirth: '',
      regionName: '',
      districtName: '',
      community: '',
      businessName: '',
      createdAt: DateTime.now(),
      isSynced: 0,
    );
  }
}
