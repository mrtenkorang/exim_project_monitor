import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/farm_model.dart';

class FarmDatabaseHelper {
  static final FarmDatabaseHelper instance = FarmDatabaseHelper._init();
  static Database? _database;

  FarmDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('farms_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE farms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        farmerName TEXT NOT NULL,
        farmSize REAL NOT NULL,
        boundaryPoints TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // Create a new farm
  Future<Farm> createFarm(Farm farm) async {
    final db = await instance.database;
    
    await db.insert(
      'farms',
      farm.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return farm;
  }

  // Get a single farm by id
  Future<Farm?> getFarm(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'farms',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Farm.fromMap(maps.first);
    }
    return null;
  }

  // Get all farms
  Future<List<Farm>> getAllFarms() async {
    final db = await instance.database;
    final result = await db.query('farms', orderBy: 'name');
    return result.map((json) => Farm.fromMap(json)).toList();
  }

  // Update a farm
  Future<int> updateFarm(Farm farm) async {
    final db = await instance.database;
    return await db.update(
      'farms',
      farm.toMap(),
      where: 'id = ?',
      whereArgs: [farm.id],
    );
  }

  // Delete a farm
  Future<int> deleteFarm(String id) async {
    final db = await instance.database;
    return await db.delete(
      'farms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search farms by name or farmer name
  Future<List<Farm>> searchFarms(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'farms',
      where: 'name LIKE ? OR farmerName LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Farm.fromMap(json)).toList();
  }

  // Close the database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
