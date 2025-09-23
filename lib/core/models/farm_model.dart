import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

class Farm {
  final String id;
  final String name;
  final String farmerName;
  final double farmSize;
  final List<LatLng> boundaryPoints;
  final String status;
  final String? assignedTo;
  final String? verifiedBy;
  final Map<String, dynamic>? additionalData;
  final List<String>? imageUrls;
  final String? zoneId;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Farm({
    required this.id,
    required this.name,
    required this.farmerName,
    required this.farmSize,
    required this.boundaryPoints,
    required this.status,
    this.assignedTo,
    this.verifiedBy,
    this.additionalData,
    this.imageUrls,
    this.zoneId,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Farm to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'farmerName': farmerName,
      'farmSize': farmSize,
      'boundaryPoints': _latLngListToString(boundaryPoints),
      'status': status,
      'assignedTo': assignedTo,
      'verifiedBy': verifiedBy,
      'additionalData': additionalData != null ? jsonEncode(additionalData) : null,
      'imageUrls': imageUrls != null ? jsonEncode(imageUrls) : null,
      'zoneId': zoneId,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Farm from a Map (from database)
  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      id: map['id'] as String,
      name: map['name'] as String,
      farmerName: map['farmerName'] as String,
      farmSize: map['farmSize'] is double ? map['farmSize'] : (map['farmSize'] as num).toDouble(),
      boundaryPoints: _stringToLatLngList(map['boundaryPoints'] as String),
      status: map['status'] as String,
      assignedTo: map['assignedTo'] as String?,
      verifiedBy: map['verifiedBy'] as String?,
      additionalData: map['additionalData'] != null
          ? jsonDecode(map['additionalData'] as String) as Map<String, dynamic>
          : null,
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(jsonDecode(map['imageUrls'] as String))
          : null,
      zoneId: map['zoneId'] as String?,
      isSynced: (map['isSynced'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Create a copy of Farm with some fields updated
  Farm copyWith({
    String? id,
    String? name,
    String? farmerName,
    double? farmSize,
    List<LatLng>? boundaryPoints,
    String? status,
    String? assignedTo,
    String? verifiedBy,
    Map<String, dynamic>? additionalData,
    List<String>? imageUrls,
    String? zoneId,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      farmerName: farmerName ?? this.farmerName,
      farmSize: farmSize ?? this.farmSize,
      boundaryPoints: boundaryPoints ?? this.boundaryPoints,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      additionalData: additionalData ?? this.additionalData,
      imageUrls: imageUrls ?? this.imageUrls,
      zoneId: zoneId ?? this.zoneId,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to convert LatLng list to JSON string
  static String _latLngListToString(List<LatLng> points) {
    return points
        .map((point) => '${point.latitude},${point.longitude}')
        .join(';');
  }

  // Helper method to convert JSON string to LatLng list
  static List<LatLng> _stringToLatLngList(String pointsString) {
    if (pointsString.isEmpty) return [];
    return pointsString
        .split(';')
        .where((pointStr) => pointStr.contains(','))
        .map((pointStr) {
      final coords = pointStr.split(',');
      return LatLng(
        double.parse(coords[0]),
        double.parse(coords[1]),
      );
    })
        .toList();
  }

  @override
  String toString() {
    return 'Farm(id: $id, name: $name, farmerName: $farmerName, farmSize: $farmSize, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Farm &&
        other.id == id &&
        other.name == name &&
        other.farmerName == farmerName &&
        other.farmSize == farmSize &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    farmerName.hashCode ^
    farmSize.hashCode ^
    status.hashCode ^
    createdAt.hashCode;
  }
}