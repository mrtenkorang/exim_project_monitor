import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

/// Model class representing a farm entity
class Farm {
  final int? id;
  final String visitId;
  final String dateOfVisit;
  final String mainBuyers;

  /// JSON-encoded string representing the farm boundary polygon as a list of LatLng points
  /// Example: '[{"latitude":1.2345,"longitude":2.3456},...]'
  final Uint8List? farmBoundaryPolygon;
  final String landUseClassification;
  final String accessibility;
  final String proximityToProcessingFacility;
  final String serviceProvider;
  final String cooperativesOrFarmerGroups;
  final String valueChainLinkages;
  final String officerName;
  final String officerId;
  final String observations;
  final String issuesIdentified;
  final String infrastructureIdentified;
  final String recommendedActions;
  final String followUpStatus;
  final String farmSize;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  // NEW FIELDS
  final double latitude;
  final double longitude;
  final String cropType;
  final String varietyBreed;
  final String plantingDate;
  final String plantingDensity;
  final int labourHired;
  final int maleWorkers;
  final int femaleWorkers;
  final String estimatedYield;
  final String previousYield;
  final String harvestDate;
  final int? farmerId;

  Farm({
    this.id,
    required this.visitId,
    required this.dateOfVisit,
    required this.mainBuyers,
    required this.farmBoundaryPolygon,
    required this.landUseClassification,
    required this.accessibility,
    required this.proximityToProcessingFacility,
    required this.serviceProvider,
    required this.cooperativesOrFarmerGroups,
    required this.valueChainLinkages,
    required this.officerName,
    required this.officerId,
    required this.observations,
    required this.issuesIdentified,
    required this.infrastructureIdentified,
    required this.recommendedActions,
    required this.followUpStatus,
    required this.farmSize,
    required this.location,
    required this.farmerId,
    required this.isSynced,
    DateTime? createdAt,
    this.updatedAt,

    // NEW FIELDS WITH DEFAULT VALUES
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.cropType = '',
    this.varietyBreed = '',
    this.plantingDate = '',

    this.plantingDensity = '',
    this.labourHired = 0,
    this.maleWorkers = 0,
    this.femaleWorkers = 0,
    this.estimatedYield = '',
    this.previousYield = '',
    this.harvestDate = '',
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert a Farm into a Map. The keys must correspond to the names of the
  /// Converts the farm to a map for JSON serialization
  Map<String, dynamic> toJson() => toMap();

  /// Convert a Farm into a Map. The keys must correspond to the names of the
  /// columns in the database.
  Map<String, dynamic> toMap() {
    // Convert Uint8List to string for database storage
    String boundaryString = '';
    if (farmBoundaryPolygon != null && farmBoundaryPolygon!.isNotEmpty) {
      boundaryString = utf8.decode(farmBoundaryPolygon!);
    }

    return {
      'id': id,
      'farmer_id': farmerId,
      'visitId': visitId,
      'dateOfVisit': dateOfVisit,
      'mainBuyers': mainBuyers,
      'farmBoundaryPolygon': boundaryString,
      'landUseClassification': landUseClassification,
      'accessibility': accessibility,
      'proximityToFacility': proximityToProcessingFacility,
      'serviceProvider': serviceProvider,
      'cooperativesOrFarmerGroups': cooperativesOrFarmerGroups,
      'valueChainLinkages': valueChainLinkages,
      'officerName': officerName,
      'officerId': officerId,
      'observations': observations,
      'issuesIdentified': issuesIdentified,
      'infrastructureIdentified': infrastructureIdentified,
      'recommendedActions': recommendedActions,
      'followUpStatus': followUpStatus,
      'isSynced': isSynced ? 1 : 0,
      'farmSize': farmSize,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),

      // NEW FIELDS ADDED TO MAP
      'latitude': latitude,
      'longitude': longitude,
      'cropType': cropType,
      'varietyBreed': varietyBreed,
      'plantingDate': plantingDate,
      'plantingDensity': plantingDensity,
      'labourHired': labourHired,
      'maleWorkers': maleWorkers,
      'femaleWorkers': femaleWorkers,
      'estimatedYield': estimatedYield,
      'previousYield': previousYield,
      'harvestDate': harvestDate,
    };
  }

  /// Create a Farm from a Map
  factory Farm.fromMap(Map<String, dynamic> map) {
    // Handle potential null or empty polygon data
    Uint8List? boundaryPolygon;
    final boundaryString = map['farmBoundaryPolygon'];
    if (boundaryString != null &&
        boundaryString is String &&
        boundaryString.isNotEmpty) {
      boundaryPolygon = Uint8List.fromList(utf8.encode(boundaryString));
    }

    return Farm(
      id: map['id'],
      farmerId: map['farmer_id'] ?? 0,
      visitId: map['visitId'] ?? '',
      dateOfVisit: map['dateOfVisit'] ?? '',
      mainBuyers: map['mainBuyers'] ?? '',
      farmBoundaryPolygon: boundaryPolygon,
      landUseClassification: map['landUseClassification'] ?? '',
      accessibility: map['accessibility'] ?? '',
      proximityToProcessingFacility: map['proximityToFacility'] ?? '',
      serviceProvider: map['serviceProvider'] ?? '',
      cooperativesOrFarmerGroups: map['cooperativesOrFarmerGroups'] ?? '',
      valueChainLinkages: map['valueChainLinkages'] ?? '',
      officerName: map['officerName'] ?? '',
      officerId: map['officerId'] ?? '',
      observations: map['observations'] ?? '',
      issuesIdentified: map['issuesIdentified'] ?? '',
      infrastructureIdentified: map['infrastructureIdentified'] ?? '',
      recommendedActions: map['recommendedActions'] ?? '',
      followUpStatus: map['followUpStatus'] ?? '',
      farmSize: map['farmSize'] ?? '',
      location: map['location'] ?? '',
      isSynced: map['isSynced'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,

      // NEW FIELDS WITH NULL SAFETY
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      cropType: map['cropType'] ?? '',
      varietyBreed: map['varietyBreed'] ?? '',
      plantingDate: map['plantingDate'] ?? '',
      plantingDensity: map['plantingDensity'] ?? '',
      labourHired: map['labourHired'] ?? 0,
      maleWorkers: map['maleWorkers'] ?? 0,
      femaleWorkers: map['femaleWorkers'] ?? 0,
      estimatedYield: map['estimatedYield'] ?? '',
      previousYield: map['previousYield'] ?? '',
      harvestDate: map['harvestDate'] ?? '',
    );
  }

  /// Create a copy of the Farm with updated fields
  Farm copyWith({
    int? id,
    String? projectId,
    String? visitId,
    String? dateOfVisit,
    String? mainBuyers,
    Uint8List? farmBoundaryPolygon,
    String? landUseClassification,
    String? accessibility,
    String? proximityToProcessingFacility,
    String? serviceProvider,
    String? cooperativesOrFarmerGroups,
    String? valueChainLinkages,
    String? officerName,
    String? officerId,
    String? observations,
    String? issuesIdentified,
    String? infrastructureIdentified,
    String? recommendedActions,
    String? followUpStatus,
    String? farmSize,
    String? location,
    DateTime? updatedAt,
    bool? isSynced,

    // NEW FIELDS FOR COPYWITH
    double? latitude,
    double? longitude,
    String? cropType,
    String? varietyBreed,
    String? plantingDate,
    String? plantingDensity,
    int? labourHired,
    int? maleWorkers,
    int? femaleWorkers,
    String? estimatedYield,
    String? previousYield,
    String? harvestDate,
  }) {
    return Farm(
      farmerId: farmerId ?? this.farmerId,
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      dateOfVisit: dateOfVisit ?? this.dateOfVisit,
      mainBuyers: mainBuyers ?? this.mainBuyers,
      farmBoundaryPolygon: farmBoundaryPolygon ?? this.farmBoundaryPolygon,
      landUseClassification:
          landUseClassification ?? this.landUseClassification,
      accessibility: accessibility ?? this.accessibility,
      proximityToProcessingFacility:
          proximityToProcessingFacility ?? this.proximityToProcessingFacility,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      cooperativesOrFarmerGroups:
          cooperativesOrFarmerGroups ?? this.cooperativesOrFarmerGroups,
      valueChainLinkages: valueChainLinkages ?? this.valueChainLinkages,
      officerName: officerName ?? this.officerName,
      officerId: officerId ?? this.officerId,
      observations: observations ?? this.observations,
      issuesIdentified: issuesIdentified ?? this.issuesIdentified,
      infrastructureIdentified:
          infrastructureIdentified ?? this.infrastructureIdentified,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      followUpStatus: followUpStatus ?? this.followUpStatus,
      farmSize: farmSize ?? this.farmSize,
      location: location ?? this.location,
      createdAt: createdAt,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? DateTime.now(),

      // NEW FIELDS FOR COPYWITH
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cropType: cropType ?? this.cropType,
      varietyBreed: varietyBreed ?? this.varietyBreed,
      plantingDate: plantingDate ?? this.plantingDate,
      plantingDensity: plantingDensity ?? this.plantingDensity,
      labourHired: labourHired ?? this.labourHired,
      maleWorkers: maleWorkers ?? this.maleWorkers,
      femaleWorkers: femaleWorkers ?? this.femaleWorkers,
      estimatedYield: estimatedYield ?? this.estimatedYield,
      previousYield: previousYield ?? this.previousYield,
      harvestDate: harvestDate ?? this.harvestDate,
    );
  }

  /// Helper method to get coordinates as LatLng
  LatLng get coordinates => LatLng(latitude, longitude);

  /// Helper method to check if farm has coordinates
  bool get hasCoordinates => latitude != 0.0 && longitude != 0.0;

  /// Helper method to get total area as double
  double get areaInHectares => double.tryParse(farmSize) ?? 0.0;

  /// Helper method to check if farm has boundary polygon
  bool get hasBoundaryPolygon {
    return farmBoundaryPolygon != null && farmBoundaryPolygon!.isNotEmpty;
  }

  /// Helper method to parse boundary coordinates from Uint8List
  List<LatLng> get boundaryCoordinates {
    if (!hasBoundaryPolygon) return [];

    try {
      final boundaryString = utf8.decode(farmBoundaryPolygon!);
      final List<dynamic> points = jsonDecode(boundaryString);
      return points.map((point) {
        return LatLng(
          (point['latitude'] as num?)?.toDouble() ?? 0.0,
          (point['longitude'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error parsing boundary coordinates: $e');
      return [];
    }
  }

  /// Helper method to set boundary coordinates from LatLng list
  static Uint8List? boundaryFromLatLngList(List<LatLng> points) {
    if (points.isEmpty) return null;

    try {
      final jsonData = jsonEncode(
        points
            .map(
              (point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              },
            )
            .toList(),
      );
      return Uint8List.fromList(utf8.encode(jsonData));
    } catch (e) {
      debugPrint('Error encoding boundary coordinates: $e');
      return null;
    }
  }

  /// Helper method to get farm summary for display
  Map<String, dynamic> get summary {
    return {
      'id': id,
      'name': '$cropType Farm',
      'size': '$farmSize ha',
      'crop': cropType,
      'location':
          'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}',
      'coordinates': coordinates,
      'hasBoundary': hasBoundaryPolygon,
      'boundaryPoints': boundaryCoordinates.length,
      'plantingDate': plantingDate,
      'harvestDate': harvestDate,
      'status': followUpStatus,
    };
  }

  @override
  String toString() {
    return 'Farm{id: $id, visitId: $visitId, cropType: $cropType, area: $farmSize ha, coordinates: ($latitude, $longitude), isSynced: $isSynced}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Farm &&
        other.id == id &&
        other.visitId == visitId &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(id, visitId, latitude, longitude);
  }

  // Convert to JSON for API submission
  Map<String, dynamic> toJsonOnline() {
    // For API, we'll send the boundary coordinates as a list of [lat, lng] pairs
    List<List<double>> boundaryCoordsList = [];
    if (boundaryCoordinates.isNotEmpty) {
      // Convert each LatLng to a [lat, lng] pair
      boundaryCoordsList = boundaryCoordinates
          .map((latLng) => [latLng.latitude, latLng.longitude])
          .toList();
    }

    // Format dates to YYYY-MM-DD
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final date = DateTime.tryParse(dateStr);
        return date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
      } catch (e) {
        return '';
      }
    }

    // Ensure area_hectares is a double and at least 0.1
    final area = max(0.1, double.tryParse(farmSize) ?? 0.1);

    // Ensure officer is an integer (PK)
    final officerIdInt = int.tryParse(officerId) ?? 0;

    return {
      'farmer': farmerId,
      'name': "Farm ${DateTime.now().millisecondsSinceEpoch}",
      'project': null,
      'main_buyers': mainBuyers,
      'land_use_classification': landUseClassification,
      'accessibility': accessibility,
      'proximity_to_processing_plants': proximityToProcessingFacility,
      'service_provider': serviceProvider,
      'farmer_groups_affiliated': cooperativesOrFarmerGroups,
      'value_chain_linkages': valueChainLinkages,
      'visit_id': visitId,
      'visit_date': formatDate(dateOfVisit),
      'officer': officerIdInt,
      'observation': observations,
      'issues_identified': issuesIdentified,
      'infrastructure_identified': infrastructureIdentified,
      'recommended_actions': recommendedActions,
      'follow_up_actions': followUpStatus,
      'area_hectares': area.toString(),
      'soil_type': "None",
      'irrigation_type': "None",
      'irrigation_coverage': "0",
      'boundary_coordinates': boundaryCoordsList,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'altitude': "0",
      'slope': "0",
      'status': "active",
      'last_visit_date': formatDate(DateTime.now().toIso8601String()),
      'validation_status': false,

      "crop_type": cropType,
      "variety": varietyBreed,
      "planting_date": formatDate(plantingDate),
      "labours_hired": labourHired,
      "male_labors": maleWorkers,
      "female_labors": femaleWorkers,
      "planting_density": plantingDensity,
      "total_trees": 0,
      "tree_density": 0,
      "estimated_yield": estimatedYield,
      "yield_in_pre_season": previousYield,
      "harvest_date": formatDate(harvestDate),
    };
  }
}
