import 'dart:math' as math;

class FarmerFarm {
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
  final List<List<double>> boundaryCoordinates;
  final double latitude;
  final double longitude;
  final String geom;
  final double altitude;
  final double slope;
  final String status;
  final String registrationDate;
  final String lastVisitDate;
  final bool validationStatus;
  final String createdAt;
  final String updatedAt;

  FarmerFarm({
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

  factory FarmerFarm.fromJson(Map<String, dynamic> json) {
    return FarmerFarm(
      id: json['id'] as int,
      farmer: json['farmer'] as int,
      farmerName: json['farmer_name'] as String,
      farmerNationalId: json['farmer_national_id'] as String,
      name: json['name'] as String,
      farmCode: json['farm_code'] as String,
      project: json['project'] as int,
      projectName: json['project_name'] as String,
      mainBuyers: json['main_buyers'] as String,
      landUseClassification: json['land_use_classification'] as String,
      hasFarmBoundaryPolygon: json['has_farm_boundary_polygon'] as bool,
      accessibility: json['accessibility'] as String,
      proximityToProcessingPlants: json['proximity_to_processing_plants'] as String,
      serviceProvider: json['service_provider'] as String,
      farmerGroupsAffiliated: json['farmer_groups_affiliated'] as String,
      valueChainLinkages: json['value_chain_linkages'] as String,
      visitId: json['visit_id'] as String,
      officer: json['officer'] as int,
      officerName: json['officer_name'] as String,
      observation: json['observation'] as String,
      issuesIdentified: json['issues_identified'] as String,
      infrastructureIdentified: json['infrastructure_identified'] as String,
      recommendedActions: json['recommended_actions'] as String,
      followUpActions: json['follow_up_actions'] as String,
      areaHectares: (json['area_hectares'] as num).toDouble(),
      soilType: json['soil_type'] as String,
      irrigationType: json['irrigation_type'] as String,
      irrigationCoverage: (json['irrigation_coverage'] as num).toDouble(),
      boundaryCoordinates: _parseBoundaryCoordinates(json['boundary_coordinates']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      geom: json['geom'] as String,
      altitude: (json['altitude'] as num).toDouble(),
      slope: (json['slope'] as num).toDouble(),
      status: json['status'] as String,
      registrationDate: json['registration_date'] as String,
      lastVisitDate: json['last_visit_date'] as String,
      validationStatus: json['validation_status'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  static List<List<double>> _parseBoundaryCoordinates(dynamic coordinates) {
    if (coordinates is List) {
      return coordinates.map<List<double>>((coord) {
        if (coord is List) {
          return coord.map<double>((value) => (value as num).toDouble()).toList();
        }
        return [];
      }).toList();
    }
    return [];
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

  FarmerFarm copyWith({
    int? id,
    int? farmer,
    String? farmerName,
    String? farmerNationalId,
    String? name,
    String? farmCode,
    int? project,
    String? projectName,
    String? mainBuyers,
    String? landUseClassification,
    bool? hasFarmBoundaryPolygon,
    String? accessibility,
    String? proximityToProcessingPlants,
    String? serviceProvider,
    String? farmerGroupsAffiliated,
    String? valueChainLinkages,
    String? visitId,
    int? officer,
    String? officerName,
    String? observation,
    String? issuesIdentified,
    String? infrastructureIdentified,
    String? recommendedActions,
    String? followUpActions,
    double? areaHectares,
    String? soilType,
    String? irrigationType,
    double? irrigationCoverage,
    List<List<double>>? boundaryCoordinates,
    double? latitude,
    double? longitude,
    String? geom,
    double? altitude,
    double? slope,
    String? status,
    String? registrationDate,
    String? lastVisitDate,
    bool? validationStatus,
    String? createdAt,
    String? updatedAt,
  }) {
    return FarmerFarm(
      id: id ?? this.id,
      farmer: farmer ?? this.farmer,
      farmerName: farmerName ?? this.farmerName,
      farmerNationalId: farmerNationalId ?? this.farmerNationalId,
      name: name ?? this.name,
      farmCode: farmCode ?? this.farmCode,
      project: project ?? this.project,
      projectName: projectName ?? this.projectName,
      mainBuyers: mainBuyers ?? this.mainBuyers,
      landUseClassification: landUseClassification ?? this.landUseClassification,
      hasFarmBoundaryPolygon: hasFarmBoundaryPolygon ?? this.hasFarmBoundaryPolygon,
      accessibility: accessibility ?? this.accessibility,
      proximityToProcessingPlants: proximityToProcessingPlants ?? this.proximityToProcessingPlants,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      farmerGroupsAffiliated: farmerGroupsAffiliated ?? this.farmerGroupsAffiliated,
      valueChainLinkages: valueChainLinkages ?? this.valueChainLinkages,
      visitId: visitId ?? this.visitId,
      officer: officer ?? this.officer,
      officerName: officerName ?? this.officerName,
      observation: observation ?? this.observation,
      issuesIdentified: issuesIdentified ?? this.issuesIdentified,
      infrastructureIdentified: infrastructureIdentified ?? this.infrastructureIdentified,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      followUpActions: followUpActions ?? this.followUpActions,
      areaHectares: areaHectares ?? this.areaHectares,
      soilType: soilType ?? this.soilType,
      irrigationType: irrigationType ?? this.irrigationType,
      irrigationCoverage: irrigationCoverage ?? this.irrigationCoverage,
      boundaryCoordinates: boundaryCoordinates ?? this.boundaryCoordinates,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geom: geom ?? this.geom,
      altitude: altitude ?? this.altitude,
      slope: slope ?? this.slope,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      validationStatus: validationStatus ?? this.validationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Utility method to get center point of farm
  Map<String, double> get centerPoint {
    if (boundaryCoordinates.isNotEmpty) {
      double sumLat = 0;
      double sumLng = 0;
      for (var coord in boundaryCoordinates) {
        if (coord.length >= 2) {
          sumLat += coord[1]; // latitude
          sumLng += coord[0]; // longitude
        }
      }
      return {
        'latitude': sumLat / boundaryCoordinates.length,
        'longitude': sumLng / boundaryCoordinates.length,
      };
    }
    return {'latitude': latitude, 'longitude': longitude};
  }

  // Utility method to check if farm has valid coordinates
  bool get hasValidCoordinates =>
      latitude != 0 && longitude != 0 && boundaryCoordinates.isNotEmpty;

  @override
  String toString() {
    return 'FarmerFarm(id: $id, name: $name, farmCode: $farmCode, area: ${areaHectares}ha, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FarmerFarm &&
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
        _listEquals(other.boundaryCoordinates, boundaryCoordinates) &&
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

  bool _listEquals(List<List<double>>? a, List<List<double>>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].length != b[i].length) return false;
      for (int j = 0; j < a[i].length; j++) {
        if (a[i][j] != b[i][j]) return false;
      }
    }
    return true;
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
      Object.hashAll(boundaryCoordinates.expand((coord) => coord)),
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