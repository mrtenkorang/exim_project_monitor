import 'dart:async';
import 'dart:convert';
import 'package:latlng/latlng.dart';
import 'package:sqflite/sqflite.dart';
import '../models/farm_model.dart';
import '../services/database/database_helper.dart';

class FarmRepository {
  final DatabaseHelper _databaseHelper;

  FarmRepository({required DatabaseHelper databaseHelper}) 
      : _databaseHelper = databaseHelper;

  // Add a new farm
  Future<String> addFarm(Farm farm) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.tableFarms,
      farm.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return farm.id;
  }

  // Get a farm by ID
  Future<Farm?> getFarmById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableFarms,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Farm.fromMap(maps.first);
    }
    return null;
  }

  // Search farms by name or farmer name
  Future<List<Farm>> searchFarms(String query) async {
    final db = await _databaseHelper.database;
    
    final searchTerm = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableFarms,
      where: ' ${DatabaseHelper.columnFarmerName} LIKE ?',
      whereArgs: [searchTerm],
    );

    return List.generate(maps.length, (i) => Farm.fromMap(maps[i]));
  }

  // Get all farms with optional filters
  Future<List<Farm>> getFarms({
    String? status,
    String? assignedTo,
    String? zoneId,
    bool? isSynced,
  }) async {
    final db = await _databaseHelper.database;
    
    final List<dynamic> whereArgs = [];
    final List<String> whereClauses = [];

    if (status != null) {
      whereClauses.add('${DatabaseHelper.columnStatus} = ?');
      whereArgs.add(status);
    }
    
    if (assignedTo != null) {
      whereClauses.add('${DatabaseHelper.columnAssignedTo} = ?');
      whereArgs.add(assignedTo);
    }
    
    if (zoneId != null) {
      whereClauses.add('${DatabaseHelper.columnZoneId} = ?');
      whereArgs.add(zoneId);
    }
    
    if (isSynced != null) {
      whereClauses.add('${DatabaseHelper.columnIsSynced} = ?');
      whereArgs.add(isSynced ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableFarms,
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs,
      orderBy: '${DatabaseHelper.columnCreatedAt} DESC',
    );

    return List.generate(maps.length, (i) => Farm.fromMap(maps[i]));
  }

  // Update a farm
  Future<int> updateFarm(Farm farm) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.tableFarms,
      farm.toJson()..[DatabaseHelper.columnUpdatedAt] = DateTime.now().toIso8601String(),
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [farm.id],
    );
  }

  // Delete a farm
  Future<int> deleteFarm(String id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableFarms,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
  }

  // Get farms within a geographical boundary
  Future<List<Farm>> getFarmsInBoundary(List<LatLng> boundary) async {
    // This is a simplified implementation
    // In a real app, you'd want to use spatialite or a similar solution
    // for efficient spatial queries
    final allFarms = await getFarms();
    
    // For now, just return all farms
    // TODO: Implement proper spatial filtering
    return allFarms;
  }

  // Get unsynced farms
  Future<List<Farm>> getUnsyncedFarms() async {
    return getFarms(isSynced: false);
  }

  // Mark farm as synced
  Future<void> markAsSynced(String farmId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableFarms,
      {
        DatabaseHelper.columnIsSynced: 1,
        DatabaseHelper.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [farmId],
    );
  }

  // Get farm statistics
  Future<Map<String, dynamic>> getFarmStats({String? zoneId}) async {
    final db = await _databaseHelper.database;
    
    // Get total farms
    final totalFarmsResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM ${DatabaseHelper.tableFarms}
      ${zoneId != null ? 'WHERE ${DatabaseHelper.columnZoneId} = ?' : ''}
    ''', zoneId != null ? [zoneId] : []);
    
    final totalFarms = totalFarmsResult.first['count'] as int;
    
    // Get farms by status
    final farmsByStatus = await db.rawQuery('''
      SELECT ${DatabaseHelper.columnStatus}, COUNT(*) as count 
      FROM ${DatabaseHelper.tableFarms}
      ${zoneId != null ? 'WHERE ${DatabaseHelper.columnZoneId} = ?' : ''}
      GROUP BY ${DatabaseHelper.columnStatus}
    ''', zoneId != null ? [zoneId] : []);
    
    // Calculate total farm area
    final totalAreaResult = await db.rawQuery('''
      SELECT SUM(${DatabaseHelper.columnFarmSize}) as total_area 
      FROM ${DatabaseHelper.tableFarms}
      ${zoneId != null ? 'WHERE ${DatabaseHelper.columnZoneId} = ?' : ''}
    ''', zoneId != null ? [zoneId] : []);
    
    final totalArea = (totalAreaResult.first['total_area'] as num?)?.toDouble() ?? 0.0;
    
    return {
      'totalFarms': totalFarms,
      'totalArea': totalArea,
      'farmsByStatus': {
        for (var e in farmsByStatus) 
          e[DatabaseHelper.columnStatus] as String: e['count'] as int
      },
    };
  }
}

// Extension to convert between model and database formats
extension FarmExtensions on Farm {
  Map<String, dynamic> toJson() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnFarmerName: farmerName,
      DatabaseHelper.columnFarmSize: farmSize,
      DatabaseHelper.columnBoundaryPoints: jsonEncode(
        boundaryPoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      ),
      DatabaseHelper.columnStatus: status,
      DatabaseHelper.columnAssignedTo: assignedTo,
      DatabaseHelper.columnVerifiedBy: verifiedBy,
      DatabaseHelper.columnAdditionalData: jsonEncode(additionalData),
      DatabaseHelper.columnImageUrls: imageUrls != null ? jsonEncode(imageUrls) : null,
      DatabaseHelper.columnZoneId: zoneId,
      DatabaseHelper.columnCreatedAt: createdAt.toIso8601String(),
      DatabaseHelper.columnUpdatedAt: updatedAt?.toIso8601String(),
      DatabaseHelper.columnIsSynced: isSynced ? 1 : 0,
    };
  }
}
