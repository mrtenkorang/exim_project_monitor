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
  static const String regionNameColumn = 'region_name';

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
  static const String columnDistrictName = 'districtName';
  static const String columnFarmerIdNumber = 'farmerIdNumber';
  static const String columnGender = 'gender';
  static const String columnDateOfBirth = 'dateOfBirth';
  static const String columnPhotoPath = 'photoPath';
  static const String columnCommunity = 'community';
  static const String columnBusinessName = 'businessName';
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
        $columnIsSynced INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableFarmersFarmsFromServer (
        id INTEGER PRIMARY KEY,
        farmer INTEGER NOT NULL,
        farmer_name TEXT NOT NULL,
        farmer_national_id TEXT,
        name TEXT NOT NULL,
        farm_code TEXT NOT NULL,
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
        boundary_coordinates TEXT,
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
        UNIQUE(farm_code)
      )
    ''');

    await db.execute('''
        CREATE TABLE $tableSecondaryCrops (
        id INTEGER PRIMARY KEY,
          cropName TEXT NOT NULL,
          farmerId INTEGER NOT NULL
        )
      ''');

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
    await db.execute('''
      CREATE TABLE $tableFarmersFromServer (
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

    // Create index for better query performance
    await db.execute(
      'CREATE INDEX idx_farmers_server_national_id ON $tableFarmersFromServer($columnNationalId)',
    );
    await db.execute(
      'CREATE INDEX idx_farmers_server_phone ON $tableFarmersFromServer($columnPhoneNumber)',
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

  Future<int> deleteAllFarmersFromServer() async {
    final db = await database;
    return await db.delete(tableFarmersFromServer);
  }

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


}
