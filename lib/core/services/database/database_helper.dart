

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/farm_model.dart';
import '../../models/farmer_model.dart';

/// Database helper class that manages the SQLite database for the application.
/// Handles database creation, version management, and CRUD operations for both Farm and Farmer models.
class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Database version
  static const int _databaseVersion = 1;
  
  // Database name
  static const String _databaseName = 'exim_monitor.db';

  // Table names
  static const String tableFarms = 'farms';
  static const String tableFarmers = 'farmers';

  // Common column names
  static const String columnId = 'id';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnIsSynced = 'isSynced';

  // Farms table columns
  static const String columnProjectId = 'projectId';
  static const String columnVisitId = 'visitId';
  static const String columnDateOfVisit = 'dateOfVisit';
  static const String columnMainBuyers = 'mainBuyers';
  static const String columnFarmBoundaryPolygon = 'farmBoundaryPolygon';
  static const String columnLandUseClassification = 'landUseClassification';
  static const String columnAccessibility = 'accessibility';
  static const String columnProximityToFacility = 'proximityToFacility';
  static const String columnServiceProvider = 'serviceProvider';
  static const String columnCooperativesOrFarmerGroups = 'cooperativesOrFarmerGroups';
  static const String columnValueChainLinkages = 'valueChainLinkages';
  static const String columnOfficerName = 'officerName';
  static const String columnOfficerId = 'officerId';
  static const String columnObservations = 'observations';
  static const String columnIssuesIdentified = 'issuesIdentified';
  static const String columnInfrastructureIdentified = 'infrastructureIdentified';
  static const String columnRecommendedActions = 'recommendedActions';
  static const String columnFollowUpStatus = 'followUpStatus';
  static const String columnFarmSize = 'farmSize';
  static const String columnLocation = 'location';

  // Farmers table columns
  static const String columnName = 'name';
  static const String columnPhoneNumber = 'phoneNumber';
  static const String columnFarmerIdNumber = 'farmerIdNumber';
  static const String columnGender = 'gender';
  static const String columnDateOfBirth = 'dateOfBirth';
  static const String columnPhotoPath = 'photoPath';
  static const String columnRegionId = 'regionId';
  static const String columnRegionName = 'regionName';
  static const String columnDistrictId = 'districtId';
  static const String columnDistrictName = 'districtName';
  static const String columnCommunity = 'community';
  static const String columnCropType = 'cropType';
  static const String columnVarietyBreed = 'varietyBreed';
  static const String columnPlantingDate = 'plantingDate';
  static const String columnPlantingDensity = 'plantingDensity';
  static const String columnLaborHired = 'laborHired';
  static const String columnEstimatedYield = 'estimatedYield';
  static const String columnPreviousYield = 'previousYield';
  static const String columnHarvestDate = 'harvestDate';

  // Private constructor
  DatabaseHelper._internal();

  // Factory constructor to return the same instance (singleton)
  factory DatabaseHelper() => _instance;

  // Getter for database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create farms table
    await db.execute('''
      CREATE TABLE $tableFarms (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnProjectId TEXT NOT NULL,
        $columnVisitId TEXT NOT NULL UNIQUE,
        $columnDateOfVisit TEXT NOT NULL,
        $columnMainBuyers TEXT NOT NULL,
        $columnFarmBoundaryPolygon TEXT NOT NULL,
        $columnLandUseClassification TEXT NOT NULL,
        $columnAccessibility TEXT NOT NULL,
        $columnProximityToFacility TEXT NOT NULL,
        $columnServiceProvider TEXT NOT NULL,
        $columnCooperativesOrFarmerGroups TEXT NOT NULL,
        $columnValueChainLinkages TEXT NOT NULL,
        $columnOfficerName TEXT NOT NULL,
        $columnOfficerId TEXT NOT NULL,
        $columnObservations TEXT NOT NULL,
        $columnIssuesIdentified TEXT NOT NULL,
        $columnInfrastructureIdentified TEXT NOT NULL,
        $columnRecommendedActions TEXT NOT NULL,
        $columnFollowUpStatus TEXT NOT NULL,
        $columnFarmSize TEXT NOT NULL,
        $columnLocation TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create farmers table
    await db.execute('''
      CREATE TABLE $tableFarmers (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnFarmerIdNumber TEXT NOT NULL,
        $columnPhoneNumber TEXT NOT NULL,
        $columnGender TEXT NOT NULL,
        $columnDateOfBirth TEXT NOT NULL,
        $columnPhotoPath TEXT,
        $columnRegionName TEXT NOT NULL,
        $columnDistrictName TEXT NOT NULL,
        $columnCommunity TEXT NOT NULL,
        $columnCropType TEXT NOT NULL,
        $columnVarietyBreed TEXT NOT NULL,
        $columnPlantingDate TEXT,
        $columnPlantingDensity TEXT NOT NULL,
        $columnLaborHired TEXT NOT NULL,
        $columnEstimatedYield TEXT NOT NULL,
        $columnPreviousYield TEXT NOT NULL,
        $columnHarvestDate TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // indexes for better query performance
    // await db.execute('CREATE INDEX idx_farms_project_id ON $tableFarms($columnProjectId)');
    // await db.execute('CREATE INDEX idx_farms_visit_id ON $tableFarms($columnVisitId)');
    // await db.execute('CREATE INDEX idx_farmers_project_id ON $tableFarmers($columnProjectId)');
    // await db.execute('CREATE INDEX idx_farmers_id_number ON $tableFarmers($columnFarmerIdNumber)');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add any new tables or columns here for future versions
    }
  }

  // Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // =================== FARM CRUD OPERATIONS ===================

  /// Inserts a new farm record into the database
  Future<int> insertFarm(Farm farm) async {
    try {
      final db = await database;
      final map = farm.toMap();
      debugPrint('Inserting farm with polygon data: ${farm.farmBoundaryPolygon}');
      return await db.insert(tableFarms, map);
    } catch (e) {
      debugPrint('Error inserting farm: $e');
      rethrow;
    }
  }

  /// Retrieves a farm by its ID
  Future<Farm?> getFarm(int id) async {
    final db = await database;
    final maps = await db.query(
      tableFarms,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Farm.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all farms, optionally filtered by project ID
  Future<List<Farm>> getAllFarms({String? projectId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    
    if (projectId != null) {
      maps = await db.query(
        tableFarms,
        where: '$columnProjectId = ?',
        whereArgs: [projectId],
      );
    } else {
      maps = await db.query(tableFarms);
    }
    
    return List.generate(maps.length, (i) => Farm.fromMap(maps[i]));
  }

  /// Updates an existing farm record
  Future<int> updateFarm(Farm farm) async {
    final db = await database;
    return await db.update(
      tableFarms,
      farm.toMap()..[columnUpdatedAt] = DateTime.now().toIso8601String(),
      where: '$columnId = ?',
      whereArgs: [farm.id],
    );
  }

  /// Deletes a farm record by ID
  Future<int> deleteFarm(int id) async {
    final db = await database;
    return await db.delete(
      tableFarms,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // =================== FARMER CRUD OPERATIONS ===================

  /// Inserts a new farmer record into the database
  Future<int> insertFarmer(Farmer farmer) async {
    final db = await database;
    try {
      return await db.insert(tableFarmers, farmer.toMap());
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('A farmer with this ID number already exists');
      }
      rethrow;
    }
  }

  /// Retrieves a farmer by ID
  Future<Farmer?> getFarmer(String id) async {
    final db = await database;
    final maps = await db.query(
      tableFarmers,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Farmer.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves a farmer by ID number
  Future<Farmer?> getFarmerByIdNumber(String idNumber) async {
    final db = await database;
    final maps = await db.query(
      tableFarmers,
      where: '$columnFarmerIdNumber = ?',
      whereArgs: [idNumber],
    );
    if (maps.isNotEmpty) {
      return Farmer.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all farmers, optionally filtered by project ID
  Future<List<Farmer>> getAllFarmers({String? projectId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    
    if (projectId != null) {
      maps = await db.query(
        tableFarmers,
        where: '$columnProjectId = ?',
        whereArgs: [projectId],
      );
    } else {
      maps = await db.query(tableFarmers);
    }
    
    return List.generate(maps.length, (i) => Farmer.fromMap(maps[i]));
  }

  /// Updates an existing farmer record
  Future<int> updateFarmer(Farmer farmer) async {
    final db = await database;
    try {
      final map = farmer.toMap()..remove(columnId); // Remove ID to prevent update of primary key
      return await db.update(
        tableFarmers,
        map,
        where: '$columnId = ?',
        whereArgs: [farmer.id],
      );
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('A farmer with this ID number already exists');
      }
      rethrow;
    }
  }

  /// Deletes a farmer record by ID
  Future<int> deleteFarmer(String id) async {
    final db = await database;
    return await db.delete(
      tableFarmers,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // =================== UTILITY METHODS ===================

  /// Returns the number of records in a table
  Future<int> getCount(String tableName) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Deletes all records from a table
  Future<int> clearTable(String tableName) async {
    final db = await database;
    return await db.delete(tableName);
  }

  /// Executes a raw query
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments ?? []);
  }
}

