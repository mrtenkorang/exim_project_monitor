import 'package:flutter/foundation.dart';

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
  final List<String> secondaryCrops;
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
  final List<FarmFromServer> farms;
  final int farmsCount;
  final String createdAt;
  final String updatedAt;

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
    required this.secondaryCrops,
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
    required this.farms,
    required this.farmsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmerFromServerModel.fromJson(Map<String, dynamic> json) {
    return FarmerFromServerModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name']?.toString() ?? "",
      lastName: json['last_name']?.toString() ?? "",
      phoneNumber: json['phone_number']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      districtName: json['district_name']?.toString() ?? "",
      regionName: json['region_name']?.toString() ?? "",
      gender: json['gender']?.toString() ?? "",
      dateOfBirth: json['date_of_birth']?.toString() ?? "",
      address: json['address']?.toString() ?? "",
      bankAccountNumber: json['bank_account_number']?.toString() ?? "",
      bankName: json['bank_name']?.toString() ?? "",
      nationalId: json['national_id']?.toString() ?? "",
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      primaryCrop: json['primary_crop']?.toString() ?? "",
      secondaryCrops: (json['secondary_crops'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          [],
      cooperativeMembership: json['cooperative_membership']?.toString() ?? "",
      extensionServices: json['extension_services'] as bool? ?? false,
      businessName: json['business_name']?.toString() ?? "",
      community: json['community']?.toString() ?? "",
      cropType: json['crop_type']?.toString() ?? "",
      variety: json['variety']?.toString() ?? "",
      plantingDate: json['planting_date']?.toString() ?? "",
      labourHired: json['labour_hired'] as int? ?? 0,
      estimatedYield: json['estimated_yield']?.toString() ?? "",
      yieldInPreSeason: json['yield_in_pre_season']?.toString() ?? "",
      harvestDate: json['harvest_date']?.toString() ?? "",
      farms: (json['farms'] as List<dynamic>?)
          ?.map((farmJson) => FarmFromServer.fromJson(farmJson as Map<String, dynamic>))
          .toList() ??
          [],
      farmsCount: json['farms_count'] as int? ?? 0,
      createdAt: json['created_at']?.toString() ?? "",
      updatedAt: json['updated_at']?.toString() ?? "",
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
      'secondary_crops': secondaryCrops,
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
      'farms': farms.map((FarmFromServer) => FarmFromServer.toJson()).toList(),
      'farms_count': farmsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
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
    List<String>? secondaryCrops,
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
    List<FarmFromServer>? farms,
    int? farmsCount,
    String? createdAt,
    String? updatedAt,
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
      secondaryCrops: secondaryCrops ?? this.secondaryCrops,
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
      farms: farms ?? this.farms,
      farmsCount: farmsCount ?? this.farmsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FarmerFromServerModel(id: $id, name: $firstName $lastName, phone: $phoneNumber, district: $districtName, farms: ${farms.length})';
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
        listEquals(other.secondaryCrops, secondaryCrops) &&
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
        other.harvestDate == harvestDate &&
        listEquals(other.farms, farms) &&
        other.farmsCount == farmsCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
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
      Object.hashAll(secondaryCrops),
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
      Object.hashAll(farms),
      farmsCount,
      createdAt,
      updatedAt,
    ]);
  }
}

class FarmFromServer {
  final int id;
  final int farmer;
  final String farmerName;
  final String farmerNationalId;
  final String name;
  final String farmCode;
  final int project;
  final String projectName;
  final String mainBuyers;
  final String landUseClassification;
  final bool hasFarmBoundaryPolygon;
  final String accessibility;
  final String proximityToProcessingPlants;
  final String serviceProvider;
  final String farmerGroupsAffiliated;
  final String valueChainLinkages;
  final String visitId;
  final int officer;
  final String officerName;
  final String observation;
  final String issuesIdentified;
  final String infrastructureIdentified;
  final String recommendedActions;
  final String followUpActions;
  final double areaHectares;
  final String soilType;
  final String irrigationType;
  final double irrigationCoverage;
  final List<List<double>>? boundaryCoordinates;
  final double latitude;
  final double longitude;
  final String? geom;
  final double altitude;
  final double slope;
  final String status;
  final String registrationDate;
  final String? lastVisitDate;
  final bool validationStatus;
  final String createdAt;
  final String updatedAt;

  FarmFromServer({
    required this.id,
    required this.farmer,
    required this.farmerName,
    required this.farmerNationalId,
    required this.name,
    required this.farmCode,
    required this.project,
    required this.projectName,
    required this.mainBuyers,
    required this.landUseClassification,
    required this.hasFarmBoundaryPolygon,
    required this.accessibility,
    required this.proximityToProcessingPlants,
    required this.serviceProvider,
    required this.farmerGroupsAffiliated,
    required this.valueChainLinkages,
    required this.visitId,
    required this.officer,
    required this.officerName,
    required this.observation,
    required this.issuesIdentified,
    required this.infrastructureIdentified,
    required this.recommendedActions,
    required this.followUpActions,
    required this.areaHectares,
    required this.soilType,
    required this.irrigationType,
    required this.irrigationCoverage,
    required this.boundaryCoordinates,
    required this.latitude,
    required this.longitude,
    required this.geom,
    required this.altitude,
    required this.slope,
    required this.status,
    required this.registrationDate,
    required this.lastVisitDate,
    required this.validationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmFromServer.fromJson(Map<String, dynamic> json) {
    return FarmFromServer(
      id: json['id'] as int? ?? 0,
      farmer: json['farmer'] as int? ?? 0,
      farmerName: json['farmer_name']?.toString() ?? "",
      farmerNationalId: json['farmer_national_id']?.toString() ?? "",
      name: json['name']?.toString() ?? "",
      farmCode: json['farm_code']?.toString() ?? "",
      project: json['project'] as int? ?? 0,
      projectName: json['project_name']?.toString() ?? "",
      mainBuyers: json['main_buyers']?.toString() ?? "",
      landUseClassification: json['land_use_classification']?.toString() ?? "",
      hasFarmBoundaryPolygon: json['has_farm_boundary_polygon'] as bool? ?? false,
      accessibility: json['accessibility']?.toString() ?? "",
      proximityToProcessingPlants: json['proximity_to_processing_plants']?.toString() ?? "",
      serviceProvider: json['service_provider']?.toString() ?? "",
      farmerGroupsAffiliated: json['farmer_groups_affiliated']?.toString() ?? "",
      valueChainLinkages: json['value_chain_linkages']?.toString() ?? "",
      visitId: json['visit_id']?.toString() ?? "",
      officer: json['officer'] as int? ?? 0,
      officerName: json['officer_name']?.toString() ?? "",
      observation: json['observation']?.toString() ?? "",
      issuesIdentified: json['issues_identified']?.toString() ?? "",
      infrastructureIdentified: json['infrastructure_identified']?.toString() ?? "",
      recommendedActions: json['recommended_actions']?.toString() ?? "",
      followUpActions: json['follow_up_actions']?.toString() ?? "",
      areaHectares: (json['area_hectares'] as num?)?.toDouble() ?? 0.0,
      soilType: json['soil_type']?.toString() ?? "",
      irrigationType: json['irrigation_type']?.toString() ?? "",
      irrigationCoverage: (json['irrigation_coverage'] as num?)?.toDouble() ?? 0.0,
      boundaryCoordinates: (json['boundary_coordinates'] as List<dynamic>?)
          ?.map((coordList) => (coordList as List<dynamic>)
          .map((coord) => (coord as num).toDouble())
          .toList())
          .toList(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      geom: json['geom']?.toString(),
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      slope: (json['slope'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? "",
      registrationDate: json['registration_date']?.toString() ?? "",
      lastVisitDate: json['last_visit_date']?.toString(),
      validationStatus: json['validation_status'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? "",
      updatedAt: json['updated_at']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer': farmer,
      'farmer_name': farmerName,
      'farmer_national_id': farmerNationalId,
      'name': name,
      'farm_code': farmCode,
      'project': project,
      'project_name': projectName,
      'main_buyers': mainBuyers,
      'land_use_classification': landUseClassification,
      'has_farm_boundary_polygon': hasFarmBoundaryPolygon,
      'accessibility': accessibility,
      'proximity_to_processing_plants': proximityToProcessingPlants,
      'service_provider': serviceProvider,
      'farmer_groups_affiliated': farmerGroupsAffiliated,
      'value_chain_linkages': valueChainLinkages,
      'visit_id': visitId,
      'officer': officer,
      'officer_name': officerName,
      'observation': observation,
      'issues_identified': issuesIdentified,
      'infrastructure_identified': infrastructureIdentified,
      'recommended_actions': recommendedActions,
      'follow_up_actions': followUpActions,
      'area_hectares': areaHectares,
      'soil_type': soilType,
      'irrigation_type': irrigationType,
      'irrigation_coverage': irrigationCoverage,
      'boundary_coordinates': boundaryCoordinates,
      'latitude': latitude,
      'longitude': longitude,
      'geom': geom,
      'altitude': altitude,
      'slope': slope,
      'status': status,
      'registration_date': registrationDate,
      'last_visit_date': lastVisitDate,
      'validation_status': validationStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FarmFromServer &&
        other.id == id &&
        other.farmer == farmer &&
        other.farmerName == farmerName &&
        other.farmerNationalId == farmerNationalId &&
        other.name == name &&
        other.farmCode == farmCode &&
        other.project == project &&
        other.projectName == projectName &&
        other.mainBuyers == mainBuyers &&
        other.landUseClassification == landUseClassification &&
        other.hasFarmBoundaryPolygon == hasFarmBoundaryPolygon &&
        other.accessibility == accessibility &&
        other.proximityToProcessingPlants == proximityToProcessingPlants &&
        other.serviceProvider == serviceProvider &&
        other.farmerGroupsAffiliated == farmerGroupsAffiliated &&
        other.valueChainLinkages == valueChainLinkages &&
        other.visitId == visitId &&
        other.officer == officer &&
        other.officerName == officerName &&
        other.observation == observation &&
        other.issuesIdentified == issuesIdentified &&
        other.infrastructureIdentified == infrastructureIdentified &&
        other.recommendedActions == recommendedActions &&
        other.followUpActions == followUpActions &&
        other.areaHectares == areaHectares &&
        other.soilType == soilType &&
        other.irrigationType == irrigationType &&
        other.irrigationCoverage == irrigationCoverage &&
        listEquals(other.boundaryCoordinates, boundaryCoordinates) &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.geom == geom &&
        other.altitude == altitude &&
        other.slope == slope &&
        other.status == status &&
        other.registrationDate == registrationDate &&
        other.lastVisitDate == lastVisitDate &&
        other.validationStatus == validationStatus &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      farmer,
      farmerName,
      farmerNationalId,
      name,
      farmCode,
      project,
      projectName,
      mainBuyers,
      landUseClassification,
      hasFarmBoundaryPolygon,
      accessibility,
      proximityToProcessingPlants,
      serviceProvider,
      farmerGroupsAffiliated,
      valueChainLinkages,
      visitId,
      officer,
      officerName,
      observation,
      issuesIdentified,
      infrastructureIdentified,
      recommendedActions,
      followUpActions,
      areaHectares,
      soilType,
      irrigationType,
      irrigationCoverage,
      Object.hashAll(boundaryCoordinates?.expand((e) => e) ?? []),
      latitude,
      longitude,
      geom,
      altitude,
      slope,
      status,
      registrationDate,
      lastVisitDate,
      validationStatus,
      createdAt,
      updatedAt,
    ]);
  }
}