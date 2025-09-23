import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/farm_model.dart';
import '../models/user_model.dart';
import 'database/database_helper.dart';
import '../repositories/farm_repository.dart';
import '../repositories/user_repository.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Initialize and register the database helper
  final databaseHelper = DatabaseHelper();
  await databaseHelper.database; // Initialize the database
  locator.registerSingleton<DatabaseHelper>(databaseHelper);

  // Register repositories
  locator.registerLazySingleton<FarmRepository>(
    () => FarmRepository(databaseHelper: locator<DatabaseHelper>()),
  );

  locator.registerLazySingleton<UserRepository>(
    () => UserRepository(),
  );


  // Example of initializing with some test data in development
  await _initializeTestData();
}

// Initialize with test data (for development only)
Future<void> _initializeTestData() async {
  final userRepo = locator<UserRepository>();
  final farmRepo = locator<FarmRepository>();

  // Check if we already have users
  final users = await userRepo.getUsers();
  if (users.isEmpty) {
    // Create test admin user
    final adminUser = User(
      id: "",
      email: "",
      role: "admin",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await userRepo.addUser(adminUser);

    // Create test field collector
    final collectorUser = User(
      id: 'collector-001',
      // username: 'collector1',
      email: 'collector1@mangofarm.com',
      fullName: 'Field Collector',
      role: 'field_collector',
      // zoneId: 'zone-001',
      isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );

    await userRepo.addUser(collectorUser);

    // Create test farm
    final testFarm = Farm(
      id: 'farm-001',
      farmerName: 'Test Farmer',
      farmSize: 5.5,
      boundaryPoints: const [
        LatLng(5.55, -0.2),
        LatLng(5.55, -0.19),
        LatLng(5.54, -0.19),
        LatLng(5.54, -0.2),
      ],
      status: 'pending',
      assignedTo: 'collector-001',
      zoneId: 'zone-001',
      additionalData: const {
        'soilType': 'Loamy',
        'irrigation': true,
        'cropVariety': 'Keitt',
      }, name: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await farmRepo.addFarm(testFarm);
  }
}
