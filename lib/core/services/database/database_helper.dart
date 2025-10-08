import 'dart:convert';

import 'package:exim_project_monitor/core/models/server_models/secondary_crops_model/secondary_crops_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/district_model.dart';
import '../../models/farm_model.dart';
import '../../models/farmer_model.dart';
import '../../models/projects_model.dart';
import '../../models/region_model.dart';
import '../../models/server_models/farmers_model/farmers_from_server.dart';

/// Database helper class that manages the SQLite database for the application.
/// Handles database creation, version management, and CRUD operations for both Farm and Farmer models.
class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Database version
  static const int _databaseVersion = 2;

  // Database name
  static const String _databaseName = 'exim_monitor.db';

  // Table names
  static const String tableFarms = 'farms';
  static const String tableFarmers = 'farmers';
  static const String tableRegions = 'regions';
  static const String tableDistricts = 'districts';
  static const String tableProjects = 'projects';
  static const String tableFarmersFromServer = 'farmers_from_server';
  static const String tableFarmersFarmsFromServer = 'farmer_farms_from_server';
  static const String tableSecondaryCrops = 'secondary_crops';

  // Common column names
  static const String columnId = 'id';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnIsSynced = 'isSynced';

  // Projects table columns
  static const String columnName = 'name';
  static const String columnCode = 'code';
  static const String columnDescription = 'description';
  static const String columnStartDate = 'start_date';
  static const String columnEndDate = 'end_date';
  static const String columnStatus = 'status';
  static const String columnTotalBudget = 'total_budget';
  static const String columnManager = 'manager';
  static const String columnManagerName = 'manager_name';
  static const String columnTotalFarmers = 'total_farmers';
  static const String columnCreatedAtt = 'created_at';
  static const String columnUpdatedAtt = 'updated_at';

  // Regions table columns
  static const String regionColumn = 'region';
  static const String regionCodeColumn = 'reg_code';
  static const String createdAtColumn = 'created_at';
  static const String updatedAtColumn = 'updated_at';

  // Districts table columns
  static const String districtNameColumn = 'district';
  static const String districtCodeColumn = 'district_code';
  static const String regionNameColumn = 'region';

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
  static const String columnCooperativesOrFarmerGroups =
      'cooperativesOrFarmerGroups';
  static const String columnValueChainLinkages = 'valueChainLinkages';
  static const String columnOfficerName = 'officerName';
  static const String columnOfficerId = 'officerId';
  static const String columnObservations = 'observations';
  static const String columnIssuesIdentified = 'issuesIdentified';
  static const String columnInfrastructureIdentified =
      'infrastructureIdentified';
  static const String columnRecommendedActions = 'recommendedActions';
  static const String columnFollowUpStatus = 'followUpStatus';
  static const String columnFarmSize = 'farmSize';
  static const String columnLocation = 'location';

  // Farmers table columns
  static const String columnFarmerName = 'name';
  static const String columnPhoneNumber = 'phoneNumber';
  static const String columnPhoneNumberr = 'phone_number';
  static const String columnDistrictName = 'districtName';
  static const String columnDistrictNamee = 'district_name';
  static const String columnFarmerIdNumber = 'farmerIdNumber';
  static const String columnGender = 'gender';
  static const String columnDateOfBirth = 'dateOfBirth';
  static const String columnDateOfBirthh = 'date_of_birth';
  static const String columnPhotoPath = 'photoPath';
  static const String columnCommunity = 'community';
  static const String columnBusinessName = 'businessName';
  static const String columnBusinessNamee = 'business_name';
  static const String columnCropType = 'cropType';
  static const String columnVarietyBreed = 'varietyBreed';
  static const String columnPlantingDate = 'plantingDate';
  static const String columnPlantingDensity = 'plantingDensity';
  static const String columnLaborHired = 'laborHired';
  static const String columnEstimatedYield = 'estimatedYield';
  static const String columnPreviousYield = 'previousYield';
  static const String columnHarvestDate = 'harvestDate';

  // Farmers from server table columns
  static const String columnFirstName = 'first_name';
  static const String columnLastName = 'last_name';
  static const String columnEmail = 'email';
  static const String columnBankAccountNumber = 'bank_account_number';
  static const String columnBankName = 'bank_name';
  static const String columnNationalId = 'national_id';
  static const String columnYearsOfExperience = 'years_of_experience';
  static const String columnPrimaryCrop = 'primary_crop';
  static const String columnCooperativeMembership = 'cooperative_membership';
  static const String columnExtensionServices = 'extension_services';
  static const String columnServerCropType = 'crop_type';
  static const String columnServerVariety = 'variety';
  static const String columnServerPlantingDate = 'planting_date';
  static const String columnServerLabourHired = 'labour_hired';
  static const String columnServerEstimatedYield = 'estimated_yield';
  static const String columnServerYieldInPreSeason = 'yield_in_pre_season';
  static const String columnServerHarvestDate = 'harvest_date';
  static const String columnAddress = 'address';
  static const String columnRegionName = 'region_name';

  static const String columnSecondaryCrops = 'secondary_crops';
  static const String columnFarmsCount = 'farms_count';
  static const String columnServerCreatedAt = 'created_at';
  static const String columnServerUpdatedAt = 'updated_at';

  // Add these to your column constants section
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  // static const String columnCropType = 'cropType';
  // static const String columnVarietyBreed = 'varietyBreed';
  // static const String columnPlantingDate = 'plantingDate';
  // static const String columnPlantingDensity = 'plantingDensity';
  static const String columnLabourHired = 'labourHired';
  static const String columnMaleWorkers = 'maleWorkers';
  static const String columnFemaleWorkers = 'femaleWorkers';
  // static const String columnEstimatedYield = 'estimatedYield';
  // static const String columnPreviousYield = 'previousYield';
  // static const String columnHarvestDate = 'harvestDate';

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
    $columnIsSynced INTEGER NOT NULL,
    
    $columnLatitude REAL NOT NULL DEFAULT 0.0,
    $columnLongitude REAL NOT NULL DEFAULT 0.0,
    $columnCropType TEXT NOT NULL DEFAULT '',
    $columnVarietyBreed TEXT NOT NULL DEFAULT '',
    $columnPlantingDate TEXT NOT NULL DEFAULT '',
    $columnPlantingDensity TEXT NOT NULL DEFAULT '',
    $columnLabourHired INTEGER NOT NULL DEFAULT 0,
    $columnMaleWorkers INTEGER NOT NULL DEFAULT 0,
    $columnFemaleWorkers INTEGER NOT NULL DEFAULT 0,
    $columnEstimatedYield TEXT NOT NULL DEFAULT '',
    $columnPreviousYield TEXT NOT NULL DEFAULT '',
    $columnHarvestDate TEXT NOT NULL DEFAULT ''
  )
''');

    // await db.execute('''
    //   CREATE TABLE $tableFarmersFarmsFromServer (
    //     id INTEGER PRIMARY KEY,
    //     farmer INTEGER NOT NULL,
    //     farmer_name TEXT NOT NULL,
    //     farmer_national_id TEXT,
    //     name TEXT NOT NULL,
    //     farm_code TEXT NOT NULL,
    //     project INTEGER,
    //     project_name TEXT,
    //     main_buyers TEXT,
    //     land_use_classification TEXT,
    //     has_farm_boundary_polygon INTEGER DEFAULT 0,
    //     accessibility TEXT,
    //     proximity_to_processing_plants TEXT,
    //     service_provider TEXT,
    //     farmer_groups_affiliated TEXT,
    //     value_chain_linkages TEXT,
    //     visit_id TEXT,
    //     officer INTEGER,
    //     officer_name TEXT,
    //     observation TEXT,
    //     issues_identified TEXT,
    //     infrastructure_identified TEXT,
    //     recommended_actions TEXT,
    //     follow_up_actions TEXT,
    //     area_hectares REAL,
    //     soil_type TEXT,
    //     irrigation_type TEXT,
    //     irrigation_coverage REAL,
    //     boundary_coordinates TEXT,
    //     latitude REAL,
    //     longitude REAL,
    //     geom TEXT,
    //     altitude REAL,
    //     slope REAL,
    //     status TEXT,
    //     registration_date TEXT,
    //     last_visit_date TEXT,
    //     validation_status INTEGER DEFAULT 0,
    //     created_at TEXT,
    //     updated_at TEXT,
    //     UNIQUE(farm_code)
    //   )
    // ''');

    await db.execute('''
      CREATE TABLE $tableFarmersFarmsFromServer (
        id INTEGER PRIMARY KEY,
        farmer INTEGER NOT NULL,
        farmer_name TEXT NOT NULL,
        farmer_national_id TEXT,
        name TEXT NOT NULL,
        farm_code TEXT NOT NULL UNIQUE,
        project INTEGER,
        project_name TEXT,
        main_buyers TEXT,
        land_use_classification TEXT,
        has_farm_boundary_polygon INTEGER DEFAULT 0,
        accessibility TEXT,
        proximity_to_processing_plants TEXT,
        service_provider TEXT,
        farmer_groups_affiliated TEXT,
        value_chain_linkages TEXT,
        visit_id TEXT,
        officer INTEGER,
        officer_name TEXT,
        observation TEXT,
        issues_identified TEXT,
        infrastructure_identified TEXT,
        recommended_actions TEXT,
        follow_up_actions TEXT,
        area_hectares REAL,
        soil_type TEXT,
        irrigation_type TEXT,
        irrigation_coverage REAL,
        boundary_coordinates TEXT, -- Store as JSON string
        latitude REAL,
        longitude REAL,
        geom TEXT,
        altitude REAL,
        slope REAL,
        status TEXT,
        registration_date TEXT,
        last_visit_date TEXT,
        validation_status INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (farmer) REFERENCES $tableFarmersFromServer($columnId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSecondaryCrops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        crop_name TEXT NOT NULL,
        farmer_id INTEGER NOT NULL,
        FOREIGN KEY (farmer_id) REFERENCES $tableFarmersFromServer($columnId) ON DELETE CASCADE
      )
    ''');

    // await db.execute(
    //   'CREATE INDEX idx_farmers_server_national_id ON $tableFarmersFromServer($columnNationalId)',
    // );
    // await db.execute(
    //   'CREATE INDEX idx_farmers_server_phone ON $tableFarmersFromServer($columnPhoneNumber)',
    // );
    // await db.execute(
    //   'CREATE INDEX idx_farms_farmer_id ON $tableFarmersFarmsFromServer(farmer)',
    // );
    // await db.execute(
    //   'CREATE INDEX idx_farms_farm_code ON $tableFarmersFarmsFromServer(farm_code)',
    // );
    // await db.execute(
    //   'CREATE INDEX idx_secondary_crops_farmer_id ON $tableSecondaryCrops(farmer_id)',
    // );



  // await db.execute('''
    //     CREATE TABLE $tableSecondaryCrops (
    //     id INTEGER PRIMARY KEY,
    //       cropName TEXT NOT NULL,
    //       farmerId INTEGER NOT NULL
    //     )
    //   ''');

    // Create farmers table
    await db.execute('''
      CREATE TABLE $tableFarmers (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFarmerName TEXT NOT NULL,
        $columnProjectId TEXT NOT NULL,
        $columnFarmerIdNumber TEXT NOT NULL,
        $columnPhoneNumber TEXT NOT NULL,
        $columnGender TEXT NOT NULL,
        $columnDateOfBirth TEXT NOT NULL,
        $columnRegionName TEXT NOT NULL,
        $columnDistrictName TEXT NOT NULL,
        $columnCommunity TEXT NOT NULL,
        $columnBusinessName TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDistricts (
        $columnId INTEGER PRIMARY KEY,
        $districtNameColumn TEXT NOT NULL,
        $districtCodeColumn TEXT NOT NULL,
        $regionNameColumn TEXT NOT NULL,
        $regionCodeColumn TEXT NOT NULL,
        $createdAtColumn TEXT,
        $updatedAtColumn TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableRegions (
        $columnId INTEGER PRIMARY KEY,
        $regionColumn TEXT NOT NULL,
        $regionCodeColumn TEXT NOT NULL,
        $createdAtColumn TEXT,
        $updatedAtColumn TEXT
      )
    ''');

    await db.execute('''
        CREATE TABLE $tableProjects (
          $columnId INTEGER PRIMARY KEY,
          $columnName TEXT,
          $columnCode TEXT,
          $columnDescription TEXT,
          $columnStartDate TEXT,
          $columnEndDate TEXT,
          $columnStatus TEXT,
          $columnTotalBudget TEXT,
          $columnManager INTEGER,
          $columnManagerName TEXT,
          $columnTotalFarmers INTEGER,
          $columnCreatedAtt TEXT, 
          $columnUpdatedAtt TEXT
        )
      ''');

    // Create farmers_from_server table
    // await db.execute('''
    //   CREATE TABLE $tableFarmersFromServer (
    //     $columnId INTEGER PRIMARY KEY,
    //     $columnFirstName TEXT NOT NULL,
    //     $columnLastName TEXT NOT NULL,
    //     $columnPhoneNumber TEXT NOT NULL,
    //     $columnEmail TEXT,
    //     $columnDistrictName TEXT NOT NULL,
    //     $columnRegionName TEXT NOT NULL,
    //     $columnGender TEXT NOT NULL,
    //     $columnDateOfBirth TEXT NOT NULL,
    //     $columnAddress TEXT,
    //     $columnBankAccountNumber TEXT,
    //     $columnBankName TEXT,
    //     $columnNationalId TEXT NOT NULL UNIQUE,
    //     $columnYearsOfExperience INTEGER,
    //     $columnPrimaryCrop TEXT,
    //     $columnCooperativeMembership TEXT,
    //     $columnExtensionServices INTEGER NOT NULL,
    //     $columnBusinessName TEXT,
    //     $columnCommunity TEXT,
    //     $columnServerCropType TEXT,
    //     $columnServerVariety TEXT,
    //     $columnServerPlantingDate TEXT,
    //     $columnServerLabourHired INTEGER,
    //     $columnServerEstimatedYield TEXT,
    //     $columnServerYieldInPreSeason TEXT,
    //     $columnServerHarvestDate TEXT
    //   )
    // ''');

    await db.execute('''
      CREATE TABLE $tableFarmersFromServer (
        $columnId INTEGER PRIMARY KEY,
        $columnFirstName TEXT NOT NULL,
        $columnLastName TEXT NOT NULL,
        $columnPhoneNumberr TEXT NOT NULL,
        $columnEmail TEXT,
        $columnDistrictNamee TEXT NOT NULL,
        $columnRegionName TEXT NOT NULL,
        $columnGender TEXT NOT NULL,
        $columnDateOfBirthh TEXT NOT NULL,
        $columnAddress TEXT,
        $columnBankAccountNumber TEXT,
        $columnBankName TEXT,
        $columnNationalId TEXT NOT NULL UNIQUE,
        $columnYearsOfExperience INTEGER,
        $columnPrimaryCrop TEXT,
        $columnSecondaryCrops TEXT, -- Store as JSON string
        $columnCooperativeMembership TEXT,
        $columnExtensionServices INTEGER NOT NULL,
        $columnBusinessNamee TEXT,
        $columnCommunity TEXT,
        $columnServerCropType TEXT,
        $columnServerVariety TEXT,
        $columnServerPlantingDate TEXT,
        $columnServerLabourHired INTEGER,
        $columnServerEstimatedYield TEXT,
        $columnServerYieldInPreSeason TEXT,
        $columnServerHarvestDate TEXT,
        $columnFarmsCount INTEGER DEFAULT 0,
        $columnServerCreatedAt TEXT,
        $columnServerUpdatedAt TEXT
      )
    ''');


    // Create index for better query performance
    await db.execute(
      'CREATE INDEX idx_farmers_server_national_id ON $tableFarmersFromServer($columnNationalId)',
    );
    await db.execute(
      'CREATE INDEX idx_farmers_server_phone ON $tableFarmersFromServer($columnPhoneNumberr)',
    );
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add any new tables or columns for version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableFarmersFromServer (
          $columnId INTEGER PRIMARY KEY,
          $columnFirstName TEXT NOT NULL,
          $columnLastName TEXT NOT NULL,
          $columnPhoneNumber TEXT NOT NULL,
          $columnEmail TEXT,
          $columnDistrictName TEXT NOT NULL,
          $columnRegionName TEXT NOT NULL,
          $columnGender TEXT NOT NULL,
          $columnDateOfBirth TEXT NOT NULL,
          $columnAddress TEXT,
          $columnBankAccountNumber TEXT,
          $columnBankName TEXT,
          $columnNationalId TEXT NOT NULL UNIQUE,
          $columnYearsOfExperience INTEGER,
          $columnPrimaryCrop TEXT,
          $columnCooperativeMembership TEXT,
          $columnExtensionServices INTEGER NOT NULL,
          $columnBusinessName TEXT,
          $columnCommunity TEXT,
          $columnServerCropType TEXT,
          $columnServerVariety TEXT,
          $columnServerPlantingDate TEXT,
          $columnServerLabourHired INTEGER,
          $columnServerEstimatedYield TEXT,
          $columnServerYieldInPreSeason TEXT,
          $columnServerHarvestDate TEXT
        )
      ''');

      // Create indexes
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_farmers_server_national_id ON $tableFarmersFromServer($columnNationalId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_farmers_server_phone ON $tableFarmersFromServer($columnPhoneNumber)',
      );
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
      debugPrint(
        'Inserting farm with polygon data: ${farm.farmBoundaryPolygon}',
      );
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
    return await db.delete(tableFarms, where: '$columnId = ?', whereArgs: [id]);
  }

  // =================== FARMER CRUD OPERATIONS ===================

  /// Inserts a new farmer record into the database
  Future<int> insertFarmer(Map<String, dynamic> farmer) async {
    final db = await database;
    try {
      return await db.insert(tableFarmers, farmer);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('A farmer with this ID number already exists');
      }
      rethrow;
    }
  }

  /// Retrieves a farmer by ID
  Future<Farmer?> getFarmer(int id) async {
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
      final map = farmer.toMap()
        ..remove(columnId); // Remove ID to prevent update of primary key
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
  Future<int> deleteFarmer(int id) async {
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
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Deletes all records from a table
  Future<int> clearTable(String tableName) async {
    final db = await database;
    return await db.delete(tableName);
  }

  /// Executes a raw query
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments ?? []);
  }

  // District query methods

  /// Bulk insert districts
  Future<int> bulkInsertDistricts(List<District> districts) async {
    final db = await database;
    final batch = db.batch();

    for (var district in districts) {
      batch.insert(
        tableDistricts,
        district.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final results = await batch.commit();
    return results.length;
  }

  // Single district operations
  Future<int> insertDistrict(District district) async {
    final db = await database;
    return await db.insert(
      tableDistricts,
      district.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<District>> getAllDistricts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableDistricts);
    return maps.map((map) => District.fromJson(map)).toList();
  }

  Future<District?> getDistrictById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableDistricts,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return District.fromJson(maps.first);
    }
    return null;
  }

  Future<List<District>> getDistrictsByRegion(String regionCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableDistricts,
      where: '$regionCodeColumn = ?',
      whereArgs: [regionCode],
    );
    return maps.map((map) => District.fromJson(map)).toList();
  }

  Future<int> updateDistrict(District district) async {
    final db = await database;
    return await db.update(
      tableDistricts,
      district.toJson(),
      where: '$columnId = ?',
      whereArgs: [district.id],
    );
  }

  Future<int> deleteDistrict(int id) async {
    final db = await database;
    return await db.delete(
      tableDistricts,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllDistricts() async {
    final db = await database;
    return await db.delete(tableDistricts);
  }

  /// Regions methods

  // Bulk insert regions
  Future<int> bulkInsertRegions(List<Region> regions) async {
    final db = await database;
    final batch = db.batch();

    for (var region in regions) {
      batch.insert(
        tableRegions,
        region.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final results = await batch.commit();
    return results.length;
  }

  // Single region operations
  Future<int> insertRegion(Region region) async {
    final db = await database;
    return await db.insert(
      tableRegions,
      region.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Region>> getAllRegions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableRegions);
    return maps.map((map) => Region.fromJson(map)).toList();
  }

  Future<Region?> getRegionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableRegions,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Region.fromJson(maps.first);
    }
    return null;
  }

  Future<Region?> getRegionByCode(String regCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableRegions,
      where: '$regionCodeColumn = ?',
      whereArgs: [regCode],
    );
    if (maps.isNotEmpty) {
      return Region.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateRegion(Region region) async {
    final db = await database;
    return await db.update(
      tableRegions,
      region.toJson(),
      where: '$columnId = ?',
      whereArgs: [region.id],
    );
  }

  Future<int> deleteRegion(int id) async {
    final db = await database;
    return await db.delete(
      tableRegions,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllRegions() async {
    final db = await database;
    return await db.delete(tableRegions);
  }

  /// Projects methods

  // Bulk insert projects
  Future<int> bulkInsertProjects(List<Project> projects) async {
    final db = await database;
    final batch = db.batch();

    for (var project in projects) {
      batch.insert(
        tableProjects,
        project.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final results = await batch.commit();
    return results.length;
  }

  // Single project operations
  Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert(
      tableProjects,
      project.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Project>> getAllProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableProjects);
    return maps.map((map) => Project.fromJson(map)).toList();
  }

  Future<Project?> getProjectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableProjects,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Project.fromJson(maps.first);
    }
    return null;
  }

  Future<Project?> getProjectByCode(String projectCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableProjects,
      where: '$columnCode = ?',
      whereArgs: [projectCode],
    );
    if (maps.isNotEmpty) {
      return Project.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateProject(Project project) async {
    final db = await database;
    return await db.update(
      tableProjects,
      project.toJson(),
      where: '$columnId = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete(
      tableProjects,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllProjects() async {
    final db = await database;
    return await db.delete(tableProjects);
  }

  // =================== FARMERS FROM SERVER CRUD OPERATIONS ===================
  Future<int> bulkInsertFarmers(List<FarmerFromServerModel> farmers) async {
    final db = await database;
    final batch = db.batch();

    for (var farmer in farmers) {
      batch.insert(
        tableFarmersFromServer,
        farmer.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final results = await batch.commit();
    return results.length;
  }

  // Future<int> deleteAllFarmersFromServer() async {
  //   final db = await database;
  //   return await db.delete(tableFarmersFromServer);
  // }

  Future<List<FarmerFromServerModel>> getAllFarmersFromServer() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableFarmersFromServer,
    );
    return maps.map((map) => FarmerFromServerModel.fromJson(map)).toList();
  }

  Future<FarmerFromServerModel?> getFarmerFromServerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableFarmersFromServer,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return FarmerFromServerModel.fromJson(maps.first);
    }
    return null;
  }

  // =================== FARMERS FROM SERVER CRUD OPERATIONS ===================


  /// Secondary Crops CRUD OPERATIONS

  // bulk insert
  Future<int> bulkInsertSecondaryCrops(List<SecondaryCropModel> secondaryCrops) async {
    final db = await database;
    final batch = db.batch();

    for (var secondaryCrop in secondaryCrops) {
      batch.insert(
        tableSecondaryCrops,
        secondaryCrop.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final results = await batch.commit();
    return results.length;
  }

  // single insert
  Future<int> insertSecondaryCrop(SecondaryCropModel secondaryCrop) async {
    final db = await database;
    return await db.insert(
      tableSecondaryCrops,
      secondaryCrop.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Bulk insert farmers with their farms and secondary crops
  Future<int> bulkInsertFarmersWithRelations(List<FarmerFromServerModel> farmers) async {
    final db = await database;
    final batch = db.batch();

    for (var farmer in farmers) {
      // Convert secondary crops list to JSON string
      final secondaryCropsJson = jsonEncode(farmer.secondaryCrops);

      // Get the farmer data without the farms field
      final farmerData = farmer.toJson()..remove('farms');
      
      // Insert farmer
      batch.insert(
        tableFarmersFromServer,
        {
          ...farmerData,
          columnSecondaryCrops: secondaryCropsJson,
          columnFarmsCount: farmer.farms.length,
          columnServerCreatedAt: farmer.createdAt,
          columnServerUpdatedAt: farmer.updatedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert farms for this farmer
      for (var farm in farmer.farms) {
        final boundaryCoordinatesJson = farm.boundaryCoordinates != null
            ? jsonEncode(farm.boundaryCoordinates)
            : null;

        batch.insert(
          tableFarmersFarmsFromServer,
          {
            'id': farm.id,
            'farmer': farmer.id,
            'farmer_name': farm.farmerName,
            'farmer_national_id': farm.farmerNationalId,
            'name': farm.name,
            'farm_code': farm.farmCode,
            'project': farm.project,
            'project_name': farm.projectName,
            'main_buyers': farm.mainBuyers,
            'land_use_classification': farm.landUseClassification,
            'has_farm_boundary_polygon': farm.hasFarmBoundaryPolygon ? 1 : 0,
            'accessibility': farm.accessibility,
            'proximity_to_processing_plants': farm.proximityToProcessingPlants,
            'service_provider': farm.serviceProvider,
            'farmer_groups_affiliated': farm.farmerGroupsAffiliated,
            'value_chain_linkages': farm.valueChainLinkages,
            'visit_id': farm.visitId,
            'officer': farm.officer,
            'officer_name': farm.officerName,
            'observation': farm.observation,
            'issues_identified': farm.issuesIdentified,
            'infrastructure_identified': farm.infrastructureIdentified,
            'recommended_actions': farm.recommendedActions,
            'follow_up_actions': farm.followUpActions,
            'area_hectares': farm.areaHectares,
            'soil_type': farm.soilType,
            'irrigation_type': farm.irrigationType,
            'irrigation_coverage': farm.irrigationCoverage,
            'boundary_coordinates': boundaryCoordinatesJson,
            'latitude': farm.latitude,
            'longitude': farm.longitude,
            'geom': farm.geom,
            'altitude': farm.altitude,
            'slope': farm.slope,
            'status': farm.status,
            'registration_date': farm.registrationDate,
            'last_visit_date': farm.lastVisitDate,
            'validation_status': farm.validationStatus ? 1 : 0,
            'created_at': farm.createdAt,
            'updated_at': farm.updatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Insert secondary crops for this farmer
      for (var crop in farmer.secondaryCrops) {
        if (crop.isNotEmpty) {
          batch.insert(
            tableSecondaryCrops,
            {
              'crop_name': crop,
              'farmer_id': farmer.id,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }

    final results = await batch.commit();
    return results.length;
  }


  /// Fetches all farmers with detailed relationships and comprehensive statistics
  Future<AllFarmersData> fetchAllFarmersData() async {
    final db = await database;

    try {
      debugPrint('Fetching comprehensive farmers data...');

      final farmers = await getAllFarmersFromServerWithRelations();

      final allFarms = <FarmFromServer>[];
      final allSecondaryCrops = <String>{};

      // Additional collections for detailed analysis
      final farmsByStatus = <String, List<FarmFromServer>>{};
      final cropsByFarmer = <String, int>{};
      final farmersByRegion = <String, List<FarmerFromServerModel>>{};

      for (final farmer in farmers) {
        // Collect all farms
        allFarms.addAll(farmer.farms);

        // Collect secondary crops
        allSecondaryCrops.addAll(farmer.secondaryCrops.where((crop) => crop.isNotEmpty));

        // Categorize farms by status
        for (final farm in farmer.farms) {
          farmsByStatus.putIfAbsent(farm.status, () => []).add(farm);
        }

        // Count crops per farmer
        cropsByFarmer[farmer.nationalId] = farmer.secondaryCrops.length;

        // Group farmers by region
        farmersByRegion.putIfAbsent(farmer.regionName, () => []).add(farmer);
      }

      final uniqueSecondaryCrops = allSecondaryCrops.toList()..sort();

      // Calculate comprehensive statistics
      final statistics = <String, dynamic>{
        'totalFarmers': farmers.length,
        'totalFarms': allFarms.length,
        'totalSecondaryCrops': allSecondaryCrops.length,
        'farmersWithFarms': farmers.where((f) => f.farms.isNotEmpty).length,
        'farmersWithoutFarms': farmers.where((f) => f.farms.isEmpty).length,
        'farmsByStatus': {
          for (var entry in farmsByStatus.entries)
            entry.key: entry.value.length
        },
        'farmersByRegion': {
          for (var entry in farmersByRegion.entries)
            entry.key: entry.value.length
        },
        'topCrops': _getTopCrops(allSecondaryCrops.toList()),
        'averageExperience': _calculateAverageExperience(farmers),
        'extensionServiceAdoption': farmers.where((f) => f.extensionServices).length,
        'cooperativeMembership': farmers.where((f) => f.cooperativeMembership.isNotEmpty).length,
      };

      debugPrint('Comprehensive data fetch completed successfully');

      return AllFarmersData(
        farmers: farmers,
        allFarms: allFarms,
        allSecondaryCrops: uniqueSecondaryCrops,
        statistics: statistics,
      );
    } catch (e) {
      debugPrint('Error fetching comprehensive farmers data: $e');
      rethrow;
    }
  }

// Helper methods for statistics
  Map<String, int> _getTopCrops(List<String> crops) {
    final cropCounts = <String, int>{};
    for (final crop in crops) {
      cropCounts[crop] = (cropCounts[crop] ?? 0) + 1;
    }

    final sortedCrops = cropCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedCrops.take(10)); // Top 10 crops
  }

  double _calculateAverageExperience(List<FarmerFromServerModel> farmers) {
    if (farmers.isEmpty) return 0.0;

    final totalExperience = farmers.fold<int>(0, (sum, farmer) => sum + farmer.yearsOfExperience);
    return totalExperience / farmers.length;
  }


  /// Optimized version that uses batch queries for better performance
  Future<List<FarmerFromServerModel>> getAllFarmersFromServerWithRelations() async {
    final db = await database;

    try {
      debugPrint('Fetching all farmers with relationships (optimized)...');

      // Get all farmers, farms, and crops in parallel batch queries
      final farmerMaps = await db.query(
        tableFarmersFromServer,
        orderBy: '$columnFirstName, $columnLastName',
      );

      if (farmerMaps.isEmpty) {
        debugPrint('No farmers found in database');
        return [];
      }

      final farmerIds = farmerMaps.map((map) => map[columnId] as int).toList();

      // Get all farms for all farmers in one query
      final farmMaps = await db.query(
        tableFarmersFarmsFromServer,
        where: 'farmer IN (${List.filled(farmerIds.length, '?').join(',')})',
        whereArgs: farmerIds,
        orderBy: 'farmer, name',
      );

      // Get all secondary crops for all farmers in one query
      final cropMaps = await db.query(
        tableSecondaryCrops,
        where: 'farmer_id IN (${List.filled(farmerIds.length, '?').join(',')})',
        whereArgs: farmerIds,
      );

      // Group farms and crops by farmer ID for efficient lookup
      final farmsByFarmer = <int, List<Map<String, dynamic>>>{};
      final cropsByFarmer = <int, List<String>>{};

      for (final farmMap in farmMaps) {
        final farmerId = farmMap['farmer'] as int;
        farmsByFarmer.putIfAbsent(farmerId, () => []).add(farmMap);
      }

      for (final cropMap in cropMaps) {
        final farmerId = cropMap['farmer_id'] as int;
        final cropName = cropMap['crop_name'] as String;
        cropsByFarmer.putIfAbsent(farmerId, () => []).add(cropName);
      }

      // Build the complete farmer objects
      final farmers = <FarmerFromServerModel>[];

      for (final farmerMap in farmerMaps) {
        final farmerId = farmerMap[columnId] as int;
        final farmsForFarmer = farmsByFarmer[farmerId] ?? [];
        final cropsForFarmer = cropsByFarmer[farmerId] ?? [];

        // Parse secondary crops - try JSON first, then fallback to crops table
        List<String> secondaryCrops = [];
        final secondaryCropsJson = farmerMap[columnSecondaryCrops] as String?;

        if (secondaryCropsJson != null && secondaryCropsJson.isNotEmpty) {
          try {
            final dynamic decoded = jsonDecode(secondaryCropsJson);
            if (decoded is List) {
              secondaryCrops = List<String>.from(decoded.whereType<String>());
            }
          } catch (e) {
            debugPrint('Error parsing secondary crops JSON for farmer $farmerId: $e');
            secondaryCrops = cropsForFarmer;
          }
        } else {
          secondaryCrops = cropsForFarmer;
        }

        // Parse farms
        final farms = farmsForFarmer.map((map) => _parseFarmFromMap(map)).toList();

        // Create farmer model
        final farmer = FarmerFromServerModel(
          id: farmerId,
          firstName: farmerMap[columnFirstName] as String? ?? '',
          lastName: farmerMap[columnLastName] as String? ?? '',
          phoneNumber: farmerMap[columnPhoneNumberr] as String? ?? '',
          email: farmerMap[columnEmail] as String? ?? '',
          districtName: farmerMap[columnDistrictNamee] as String? ?? '',
          regionName: farmerMap[columnRegionName] as String? ?? '',
          gender: farmerMap[columnGender] as String? ?? '',
          dateOfBirth: farmerMap[columnDateOfBirthh] as String? ?? '',
          address: farmerMap[columnAddress] as String? ?? '',
          bankAccountNumber: farmerMap[columnBankAccountNumber] as String? ?? '',
          bankName: farmerMap[columnBankName] as String? ?? '',
          nationalId: farmerMap[columnNationalId] as String? ?? '',
          yearsOfExperience: farmerMap[columnYearsOfExperience] as int? ?? 0,
          primaryCrop: farmerMap[columnPrimaryCrop] as String? ?? '',
          secondaryCrops: secondaryCrops,
          cooperativeMembership: farmerMap[columnCooperativeMembership] as String? ?? '',
          extensionServices: (farmerMap[columnExtensionServices] as int? ?? 0) == 1,
          businessName: farmerMap[columnBusinessName] as String? ?? '',
          community: farmerMap[columnCommunity] as String? ?? '',
          cropType: farmerMap[columnServerCropType] as String? ?? '',
          variety: farmerMap[columnServerVariety] as String? ?? '',
          plantingDate: farmerMap[columnServerPlantingDate] as String? ?? '',
          labourHired: farmerMap[columnServerLabourHired] as int? ?? 0,
          estimatedYield: farmerMap[columnServerEstimatedYield] as String? ?? '',
          yieldInPreSeason: farmerMap[columnServerYieldInPreSeason] as String? ?? '',
          harvestDate: farmerMap[columnServerHarvestDate] as String? ?? '',
          farms: farms,
          farmsCount: farmerMap[columnFarmsCount] as int? ?? farms.length,
          createdAt: farmerMap[columnServerCreatedAt] as String? ?? '',
          updatedAt: farmerMap[columnServerUpdatedAt] as String? ?? '',
        );

        farmers.add(farmer);
      }

      debugPrint('Optimized load complete: ${farmers.length} farmers, ${farmMaps.length} farms, ${cropMaps.length} crops');
      return farmers;

    } catch (e) {
      debugPrint('Error in getAllFarmersFromServerWithRelations: $e');
      rethrow;
    }
  }

  /// Helper method to parse farm from map
  FarmFromServer _parseFarmFromMap(Map<String, dynamic> map) {
    List<List<double>>? boundaryCoordinates;
    final boundaryJson = map['boundary_coordinates'] as String?;

    if (boundaryJson != null && boundaryJson.isNotEmpty) {
      try {
        final List<dynamic> rawList = jsonDecode(boundaryJson);
        boundaryCoordinates = rawList.map((innerList) {
          if (innerList is List) {
            return innerList.map((coord) {
              if (coord is num) return coord.toDouble();
              if (coord is String) return double.tryParse(coord) ?? 0.0;
              return 0.0;
            }).toList();
          }
          return <double>[];
        }).toList();
      } catch (e) {
        debugPrint('Error parsing boundary coordinates for farm ${map['id']}: $e');
      }
    }

    return FarmFromServer(
      id: map['id'] as int,
      farmer: map['farmer'] as int,
      farmerName: map['farmer_name'] as String? ?? '',
      farmerNationalId: map['farmer_national_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      farmCode: map['farm_code'] as String? ?? '',
      project: map['project'] as int? ?? 0,
      projectName: map['project_name'] as String? ?? '',
      mainBuyers: map['main_buyers'] as String? ?? '',
      landUseClassification: map['land_use_classification'] as String? ?? '',
      hasFarmBoundaryPolygon: (map['has_farm_boundary_polygon'] as int? ?? 0) == 1,
      accessibility: map['accessibility'] as String? ?? '',
      proximityToProcessingPlants: map['proximity_to_processing_plants'] as String? ?? '',
      serviceProvider: map['service_provider'] as String? ?? '',
      farmerGroupsAffiliated: map['farmer_groups_affiliated'] as String? ?? '',
      valueChainLinkages: map['value_chain_linkages'] as String? ?? '',
      visitId: map['visit_id'] as String? ?? '',
      officer: map['officer'] as int? ?? 0,
      officerName: map['officer_name'] as String? ?? '',
      observation: map['observation'] as String? ?? '',
      issuesIdentified: map['issues_identified'] as String? ?? '',
      infrastructureIdentified: map['infrastructure_identified'] as String? ?? '',
      recommendedActions: map['recommended_actions'] as String? ?? '',
      followUpActions: map['follow_up_actions'] as String? ?? '',
      areaHectares: (map['area_hectares'] as num?)?.toDouble() ?? 0.0,
      soilType: map['soil_type'] as String? ?? '',
      irrigationType: map['irrigation_type'] as String? ?? '',
      irrigationCoverage: (map['irrigation_coverage'] as num?)?.toDouble() ?? 0.0,
      boundaryCoordinates: boundaryCoordinates,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      geom: map['geom'] as String?,
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0.0,
      slope: (map['slope'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? '',
      registrationDate: map['registration_date'] as String? ?? '',
      lastVisitDate: map['last_visit_date'] as String?,
      validationStatus: (map['validation_status'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  /// Delete all farmers, farms, and secondary crops in a single transaction
  Future<void> deleteAllFarmersWithRelations() async {
    final db = await database;

    try {
      debugPrint('Starting transaction to delete all farmers with relations...');

      await db.transaction((txn) async {
        // Delete in correct order to respect foreign key constraints
        await txn.delete(tableSecondaryCrops);
        debugPrint('Deleted secondary crops');

        await txn.delete(tableFarmersFarmsFromServer);
        debugPrint('Deleted farms');

        await txn.delete(tableFarmersFromServer);
        debugPrint('Deleted farmers');
      });

      debugPrint('Successfully deleted all farmers, farms, and secondary crops');
    } catch (e) {
      debugPrint('Error in transaction deleting all farmers with relations: $e');
      rethrow;
    }
  }

}

/// Data class to hold the complete farmers data
class AllFarmersData {
  final List<FarmerFromServerModel> farmers;
  final List<FarmFromServer> allFarms;
  final List<String> allSecondaryCrops;
  final Map<String, dynamic> statistics;

  AllFarmersData({
    required this.farmers,
    required this.allFarms,
    required this.allSecondaryCrops,
    required this.statistics,
  });

  @override
  String toString() {
    return 'AllFarmersData(farmers: ${farmers.length}, farms: ${allFarms.length}, crops: ${allSecondaryCrops.length})';
  }
}
