class FarmerFromServerModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String districtName;
  final String regionName;
  final String gender;
  final String dateOfBirth;
  final String address;
  final String bankAccountNumber;
  final String bankName;
  final String nationalId;
  final int yearsOfExperience;
  final String primaryCrop;
  final String cooperativeMembership;
  final bool extensionServices;
  final String businessName;
  final String community;
  final String cropType;
  final String variety;
  final String plantingDate;
  final int labourHired;
  final String estimatedYield;
  final String yieldInPreSeason;
  final String harvestDate;

  FarmerFromServerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.districtName,
    required this.regionName,
    required this.gender,
    required this.dateOfBirth,
    required this.address,
    required this.bankAccountNumber,
    required this.bankName,
    required this.nationalId,
    required this.yearsOfExperience,
    required this.primaryCrop,
    required this.cooperativeMembership,
    required this.extensionServices,
    required this.businessName,
    required this.community,
    required this.cropType,
    required this.variety,
    required this.plantingDate,
    required this.labourHired,
    required this.estimatedYield,
    required this.yieldInPreSeason,
    required this.harvestDate,
  });

  factory FarmerFromServerModel.fromJson(Map<String, dynamic> json) {
    return FarmerFromServerModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      districtName: json['district_name'] as String,
      regionName: json['region_name'] as String,
      gender: json['gender'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      address: json['address'] as String,
      bankAccountNumber: json['bank_account_number'] as String,
      bankName: json['bank_name'] as String,
      nationalId: json['national_id'] as String,
      yearsOfExperience: json['years_of_experience'] as int,
      primaryCrop: json['primary_crop'] as String,
      cooperativeMembership: json['cooperative_membership'] as String,
      extensionServices: json['extension_services'] as bool,
      businessName: json['business_name'] as String,
      community: json['community'] as String,
      cropType: json['crop_type'] as String,
      variety: json['variety'] as String,
      plantingDate: json['planting_date'] as String,
      labourHired: json['labour_hired'] as int,
      estimatedYield: json['estimated_yield'] as String,
      yieldInPreSeason: json['yield_in_pre_season'] as String,
      harvestDate: json['harvest_date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'district_name': districtName,
      'region_name': regionName,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'address': address,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'national_id': nationalId,
      'years_of_experience': yearsOfExperience,
      'primary_crop': primaryCrop,
      'cooperative_membership': cooperativeMembership,
      'extension_services': extensionServices,
      'business_name': businessName,
      'community': community,
      'crop_type': cropType,
      'variety': variety,
      'planting_date': plantingDate,
      'labour_hired': labourHired,
      'estimated_yield': estimatedYield,
      'yield_in_pre_season': yieldInPreSeason,
      'harvest_date': harvestDate,
    };
  }

  FarmerFromServerModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? districtName,
    String? regionName,
    String? gender,
    String? dateOfBirth,
    String? address,
    String? bankAccountNumber,
    String? bankName,
    String? nationalId,
    int? yearsOfExperience,
    String? primaryCrop,
    String? cooperativeMembership,
    bool? extensionServices,
    String? businessName,
    String? community,
    String? cropType,
    String? variety,
    String? plantingDate,
    int? labourHired,
    String? estimatedYield,
    String? yieldInPreSeason,
    String? harvestDate,
  }) {
    return FarmerFromServerModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      districtName: districtName ?? this.districtName,
      regionName: regionName ?? this.regionName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      nationalId: nationalId ?? this.nationalId,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      primaryCrop: primaryCrop ?? this.primaryCrop,
      cooperativeMembership: cooperativeMembership ?? this.cooperativeMembership,
      extensionServices: extensionServices ?? this.extensionServices,
      businessName: businessName ?? this.businessName,
      community: community ?? this.community,
      cropType: cropType ?? this.cropType,
      variety: variety ?? this.variety,
      plantingDate: plantingDate ?? this.plantingDate,
      labourHired: labourHired ?? this.labourHired,
      estimatedYield: estimatedYield ?? this.estimatedYield,
      yieldInPreSeason: yieldInPreSeason ?? this.yieldInPreSeason,
      harvestDate: harvestDate ?? this.harvestDate,
    );
  }

  @override
  String toString() {
    return 'FarmerFromServerModel(id: $id, name: $firstName $lastName, phone: $phoneNumber, district: $districtName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FarmerFromServerModel &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.districtName == districtName &&
        other.regionName == regionName &&
        other.gender == gender &&
        other.dateOfBirth == dateOfBirth &&
        other.address == address &&
        other.bankAccountNumber == bankAccountNumber &&
        other.bankName == bankName &&
        other.nationalId == nationalId &&
        other.yearsOfExperience == yearsOfExperience &&
        other.primaryCrop == primaryCrop &&
        other.cooperativeMembership == cooperativeMembership &&
        other.extensionServices == extensionServices &&
        other.businessName == businessName &&
        other.community == community &&
        other.cropType == cropType &&
        other.variety == variety &&
        other.plantingDate == plantingDate &&
        other.labourHired == labourHired &&
        other.estimatedYield == estimatedYield &&
        other.yieldInPreSeason == yieldInPreSeason &&
        other.harvestDate == harvestDate;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      firstName,
      lastName,
      phoneNumber,
      email,
      districtName,
      regionName,
      gender,
      dateOfBirth,
      address,
      bankAccountNumber,
      bankName,
      nationalId,
      yearsOfExperience,
      primaryCrop,
      cooperativeMembership,
      extensionServices,
      businessName,
      community,
      cropType,
      variety,
      plantingDate,
      labourHired,
      estimatedYield,
      yieldInPreSeason,
      harvestDate,
    ]);
  }
}


