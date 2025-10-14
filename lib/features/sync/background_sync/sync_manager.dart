/// Synchronization manager that coordinates data sync between local database and remote API.
/// Handles business logic for syncing different data types and manages sync state.

// Core Flutter and async programming
import 'dart:async';

// Application models
import 'package:exim_project_monitor/core/models/farm_model.dart';
import 'package:exim_project_monitor/core/models/farmer_model.dart';

// Services
import 'package:exim_project_monitor/core/services/api/api.dart';
import 'package:exim_project_monitor/core/services/database/database_helper.dart';
import 'package:exim_project_monitor/features/sync/background_sync/background_sync.dart';

// Flutter framework and plugins
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages data synchronization between local storage and remote API.
/// Implements ChangeNotifier to allow UI components to react to sync state changes.
class SyncManager with ChangeNotifier {
  // Dependencies
  final BackgroundSyncService _backgroundSyncService;
  
  // Sync state
  bool _isSyncing = false;
  String? _lastSyncError;
  DateTime? _lastSuccessfulSync;

  /// Creates a new SyncManager instance with required dependencies.
  SyncManager(this._backgroundSyncService);

  // Getters for sync state
  bool get isSyncing => _isSyncing;
  String? get lastSyncError => _lastSyncError;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  /// Initializes the sync manager.
  /// Loads the last sync time and initializes background sync service.
  Future<void> initialize() async {
    await _loadLastSyncTime();
    await _backgroundSyncService.initialize();
  }

  /// Loads the last successful sync time from shared preferences.
  /// Updates the internal state and notifies listeners if successful.
  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMillis = prefs.getInt('lastSync');
    if (lastSyncMillis != null) {
      _lastSuccessfulSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
      notifyListeners();
    }
  }

  /// Synchronizes all data types with the remote server.
  /// Manages sync state, error handling, and notifies listeners of changes.
  Future<void> syncAllData() async {
    // Prevent multiple concurrent sync operations
    if (_isSyncing) return;

    // Update sync state
    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      // Sync different data types in sequence
      await _syncFarmers();  // Sync farmers data first
      await _syncFarms();    // Then sync farms
      await _syncOtherData(); // Finally sync any other data

      // Update last successful sync timestamp
      _lastSuccessfulSync = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastSync', _lastSuccessfulSync!.millisecondsSinceEpoch);

      // Log success in debug mode
      if (kDebugMode) {
        print('All data synced successfully at ${DateTime.now()}');
      }
    } catch (e) {
      // Handle sync errors
      _lastSyncError = e.toString();
      if (kDebugMode) {
        print('Sync error: $e');
      }
      // Consider adding error reporting here in production
    } finally {
      // Always update state when sync completes
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Synchronizes unsynced farmers with the remote server.
  /// 
  /// Retrieves all farmers with sync status 0 (unsynced) and attempts to sync them.
  /// Updates the local database on successful sync.
  Future<void> _syncFarmers() async {
    debugPrint('Auto Syncing farmers init');
    final dbHelper = DatabaseHelper();
    final apiService = APIService();

    // Get all unsynced farmers (status = 0)
    final unsyncedFarmers = await dbHelper.getFarmerByStatus(0);

    if (unsyncedFarmers.isNotEmpty) {
      for (final farmer in unsyncedFarmers) {
        debugPrint('Auto Syncing farmer: ${farmer.id}');
        
        // Submit farmer to API and handle response
        apiService.submitFarmer(farmer).then((value) async {
          // Update local database on successful sync
          await dbHelper.updateFarmer(farmer);
        }).catchError((error) {
          // Log errors but continue with other farmers
          debugPrint('Error auto syncing farmer: $error');
        });
      }
    }
  }

  /// Synchronizes unsynced farms with the remote server.
  /// 
  /// Retrieves all farms with sync status 0 (unsynced) and attempts to sync them.
  /// Updates the local database on successful sync.
  Future<void> _syncFarms() async {
    debugPrint('Auto Syncing farms init');
    final dbHelper = DatabaseHelper();
    final apiService = APIService();

    // Get all unsynced farms (status = 0)
    final unsyncedFarms = await dbHelper.getFarmByStatus(0);

    if (unsyncedFarms.isNotEmpty) {
      for (final farm in unsyncedFarms) {
        debugPrint('Auto Syncing farm: ${farm.id}');
        
        // Submit farm to API and handle response
        apiService.submitFarm(farm).then((value) async {
          // Update local database on successful sync
          await dbHelper.updateFarm(farm);
        }).catchError((error) {
          // Log errors but continue with other farms
          debugPrint('Error auto syncing farm: $error');
        });
      }
    }
  }
  /// Placeholder for syncing additional data types.
  /// 
  /// This method can be extended to include synchronization for other data models.
  /// Currently includes a small delay to simulate work being done.
  Future<void> _syncOtherData() async {
    // TODO: Implement synchronization for other data types as needed
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Manually triggers a full data synchronization.
  /// This can be called from the UI to force a complete sync of all data types.
  Future<void> triggerManualSync() async {
    await syncAllData();
  }

  /// Checks if there are any unsynchronized changes.
  /// 
  /// Returns `true` if there are any unsynced farmers or farms, `false` otherwise.
  /// This can be used to show sync indicators in the UI.
  Future<bool> hasPendingSync() async {
    final dbHelper = DatabaseHelper();
    
    // Check for unsynced farmers and farms
    List<Farmer> unsyncedFarmers = await dbHelper.getFarmerByStatus(0);
    List<Farm> unsyncedFarms = await dbHelper.getFarmByStatus(0);

    // Return true if any unsynced items exist
    return unsyncedFarmers.isNotEmpty || unsyncedFarms.isNotEmpty;
  }

  @override
  void dispose() {
    _backgroundSyncService.dispose();
    super.dispose();
  }
}