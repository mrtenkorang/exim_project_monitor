import 'package:exim_project_monitor/core/services/database/database_helper.dart';
import 'package:exim_project_monitor/features/farms/providers/farm_provider.dart';
import 'package:exim_project_monitor/features/farms/repositories/farm_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Services
  locator.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  
  // Repositories
  locator.registerLazySingleton<FarmRepository>(
    () => FarmRepository(databaseHelper: locator<DatabaseHelper>()),
  );
  
  // Providers
  locator.registerFactory<FarmProvider>(
    () => FarmProvider(repository: locator<FarmRepository>()),
  );
  
  // Initialize database
  await locator<DatabaseHelper>().database;
}
