import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Static instance getter
  static DatabaseHelper get instance => _instance;

  static Database? _database;
  final _lock = Lock();

  // Database version
  static const int _databaseVersion = 1;
  
  // Database name
  static const String _databaseName = 'mango_gis.db';

  // Table names
  static const String tableUsers = 'users';
  static const String tableFarms = 'farms';
  static const String tableFarmVisits = 'farm_visits';
  static const String tableTasks = 'tasks';
  static const String tableAttachments = 'attachments';
  static const String tableSyncLogs = 'sync_logs';

  // Common column names
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnIsSynced = 'is_synced';

  // Users table columns
  static const String columnUsername = 'username';
  static const String columnEmail = 'email';
  static const String columnFullName = 'full_name';
  static const String columnRole = 'role';
  static const String columnZoneId = 'zone_id';
  static const String columnIsActive = 'is_active';
  static const String columnProfileImageUrl = 'profile_image_url';
  static const String columnPhoneNumber = 'phone_number';

  // Farms table columns
  static const String columnName = 'name';
  static const String columnFarmerName = 'farmer_name';
  static const String columnFarmSize = 'farm_size';
  static const String columnBoundaryPoints = 'boundary_points';
  static const String columnStatus = 'status';
  static const String columnAssignedTo = 'assigned_to';
  static const String columnVerifiedBy = 'verified_by';
  static const String columnAdditionalData = 'additional_data';
  static const String columnImageUrls = 'image_urls';

  // Farm visits table columns
  static const String columnFarmId = 'farm_id';
  static const String columnVisitDate = 'visit_date';
  static const String columnOfficerName = 'officer_name';
  static const String columnOfficerId = 'officer_id';
  static const String columnObservations = 'observations';
  static const String columnIssues = 'issues';
  static const String columnRecommendedActions = 'recommended_actions';
  static const String columnFollowUpStatus = 'follow_up_status';
  static const String columnPostHarvestLoss = 'post_harvest_loss';
  static const String columnSalesVolume = 'sales_volume';
  static const String columnSellingPrice = 'selling_price';
  static const String columnTotalRevenue = 'total_revenue';
  static const String columnMainBuyers = 'main_buyers';
  static const String columnLandUseClassification = 'land_use_classification';
  static const String columnAccessibility = 'accessibility';
  static const String columnProximityToFacilities = 'proximity_to_facilities';
  static const String columnSatelliteDataLink = 'satellite_data_link';
  static const String columnProjectPartner = 'project_partner';
  static const String columnExtensionOfficer = 'extension_officer';
  static const String columnInputSupplier = 'input_supplier';
  static const String columnCooperativeGroups = 'cooperative_groups';
  static const String columnValueChainLinkages = 'value_chain_linkages';

  // Tasks table columns
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnDueDate = 'due_date';
  static const String columnPriority = 'priority';
  static const String columnCompleted = 'completed';
  static const String columnAssignedBy = 'assigned_by';

  // Attachments table columns
  static const String columnEntityType = 'entity_type';
  static const String columnEntityId = 'entity_id';
  static const String columnFilePath = 'file_path';
  static const String columnFileType = 'file_type';
  static const String columnFileSize = 'file_size';
  static const String columnThumbnailPath = 'thumbnail_path';
  static const String columnNotes = 'notes';

  // Sync logs table columns
  static const String columnEntityName = 'entity_name';
  static const String columnRecordId = 'record_id';
  static const String columnAction = 'action';
  static const String columnSyncStatus = 'sync_status';
  static const String columnErrorMessage = 'error_message';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Ensure database is only initialized once
    await _lock.synchronized(() async {
      if (_database == null) {
        _database = await _initDatabase();
      }
    });
    
    return _database!;
  }

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

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnId TEXT PRIMARY KEY,
        $columnUsername TEXT,
        $columnEmail TEXT,
        $columnFullName TEXT,
        $columnRole TEXT NOT NULL,
        $columnZoneId TEXT,
        $columnIsActive INTEGER NOT NULL DEFAULT 1,
        $columnProfileImageUrl TEXT,
        $columnPhoneNumber TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create farms table
    await db.execute('''
      CREATE TABLE $tableFarms (
        $columnId TEXT PRIMARY KEY,
        $columnFarmerName TEXT NOT NULL,
        $columnFarmSize REAL NOT NULL,
        $columnBoundaryPoints TEXT NOT NULL,
        $columnStatus TEXT NOT NULL,
        $columnAssignedTo TEXT,
        $columnVerifiedBy TEXT,
        $columnAdditionalData TEXT,
        $columnImageUrls TEXT,
        $columnZoneId TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($columnAssignedTo) REFERENCES $tableUsers ($columnId),
        FOREIGN KEY ($columnVerifiedBy) REFERENCES $tableUsers ($columnId)
      )
    ''');

    // Create farm visits table
    await db.execute('''
      CREATE TABLE $tableFarmVisits (
        $columnId TEXT PRIMARY KEY,
        $columnFarmId TEXT NOT NULL,
        $columnVisitDate TEXT NOT NULL,
        $columnOfficerName TEXT NOT NULL,
        $columnOfficerId TEXT NOT NULL,
        $columnObservations TEXT,
        $columnIssues TEXT,
        $columnRecommendedActions TEXT,
        $columnFollowUpStatus TEXT,
        $columnPostHarvestLoss REAL,
        $columnSalesVolume REAL,
        $columnSellingPrice REAL,
        $columnTotalRevenue REAL,
        $columnMainBuyers TEXT,
        $columnLandUseClassification TEXT,
        $columnAccessibility TEXT,
        $columnProximityToFacilities TEXT,
        $columnSatelliteDataLink TEXT,
        $columnProjectPartner TEXT,
        $columnExtensionOfficer TEXT,
        $columnInputSupplier TEXT,
        $columnCooperativeGroups TEXT,
        $columnValueChainLinkages TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($columnFarmId) REFERENCES $tableFarms ($columnId) ON DELETE CASCADE,
        FOREIGN KEY ($columnOfficerId) REFERENCES $tableUsers ($columnId)
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE $tableTasks (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnAssignedTo TEXT NOT NULL,
        $columnAssignedBy TEXT NOT NULL,
        $columnDueDate TEXT,
        $columnPriority TEXT,
        $columnStatus TEXT NOT NULL,
        $columnCompleted INTEGER NOT NULL DEFAULT 0,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($columnAssignedTo) REFERENCES $tableUsers ($columnId),
        FOREIGN KEY ($columnAssignedBy) REFERENCES $tableUsers ($columnId)
      )
    ''');

    // Create attachments table
    await db.execute('''
      CREATE TABLE $tableAttachments (
        $columnId TEXT PRIMARY KEY,
        $columnEntityType TEXT NOT NULL,
        $columnEntityId TEXT NOT NULL,
        $columnFilePath TEXT NOT NULL,
        $columnFileType TEXT NOT NULL,
        $columnFileSize INTEGER NOT NULL,
        $columnThumbnailPath TEXT,
        $columnNotes TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create sync logs table
    await db.execute('''
      CREATE TABLE $tableSyncLogs (
        $columnId TEXT PRIMARY KEY,
        $columnEntityName TEXT NOT NULL,
        $columnRecordId TEXT NOT NULL,
        $columnAction TEXT NOT NULL,
        $columnSyncStatus TEXT NOT NULL,
        $columnErrorMessage TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_farms_zone ON $tableFarms($columnZoneId)');
    await db.execute('CREATE INDEX idx_farms_assigned_to ON $tableFarms($columnAssignedTo)');
    await db.execute('CREATE INDEX idx_farm_visits_farm_id ON $tableFarmVisits($columnFarmId)');
    await db.execute('CREATE INDEX idx_tasks_assigned_to ON $tableTasks($columnAssignedTo)');
    await db.execute('CREATE INDEX idx_attachments_entity ON $tableAttachments($columnEntityType, $columnEntityId)');
    await db.execute('CREATE INDEX idx_sync_logs_entity ON $tableSyncLogs($columnEntityName, $columnRecordId)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here when version changes
    if (oldVersion < 2) {
      // Example of a future upgrade
      // await db.execute('ALTER TABLE $tableFarms ADD COLUMN new_column TEXT');
    }
  }

  // Helper method to convert a Map to a database-compatible map
  static Map<String, dynamic> toDatabaseMap(Map<String, dynamic> map) {
    final dbMap = Map<String, dynamic>.from(map);
    
    // Convert DateTime to ISO 8601 string
    dbMap.forEach((key, value) {
      if (value is DateTime) {
        dbMap[key] = value.toIso8601String();
      } else if (value is bool) {
        dbMap[key] = value ? 1 : 0;
      } else if (value is Map || value is List) {
        dbMap[key] = value.toString();
      }
    });
    
    return dbMap;
  }

  // Helper method to parse database map to model
  static Map<String, dynamic> fromDatabaseMap(Map<String, dynamic> map) {
    final modelMap = Map<String, dynamic>.from(map);
    
    // Convert strings back to appropriate types
    modelMap.forEach((key, value) {
      if (value is String) {
        // Try to parse DateTime
        try {
          if (key.endsWith('_at') || key.endsWith('_date') || key == 'due_date') {
            modelMap[key] = DateTime.parse(value);
          }
        } catch (e) {
          // If parsing fails, keep the original string value
        }
        
        // Convert '1'/'0' to boolean
        if (value == '1' || value == '0') {
          modelMap[key] = value == '1';
        }
      }
    });
    
    return modelMap;
  }

  // Close the database connection
  Future<void> close() async {
    await _lock.synchronized(() async {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
    });
  }
}
