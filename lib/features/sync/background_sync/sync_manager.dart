// lib/core/services/sync_manager.dart
import 'dart:async';
import 'package:exim_project_monitor/features/sync/background_sync/background_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncManager with ChangeNotifier {
  final BackgroundSyncService _backgroundSyncService;
  bool _isSyncing = false;
  String? _lastSyncError;
  DateTime? _lastSuccessfulSync;

  SyncManager(this._backgroundSyncService);

  bool get isSyncing => _isSyncing;
  String? get lastSyncError => _lastSyncError;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  // Initialize sync manager
  Future<void> initialize() async {
    await _loadLastSyncTime();
    await _backgroundSyncService.initialize();
  }

  // Load last sync time from preferences
  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMillis = prefs.getInt('lastSync');
    if (lastSyncMillis != null) {
      _lastSuccessfulSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
      notifyListeners();
    }
  }

  // Main sync method that syncs all data
  Future<void> syncAllData() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      // Sync farmers first
      await _syncFarmers();

      // Sync farms
      await _syncFarms();

      // Sync other data types...
      await _syncOtherData();

      // Update last successful sync
      _lastSuccessfulSync = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastSync', _lastSuccessfulSync!.millisecondsSinceEpoch);

      if (kDebugMode) {
        print('All data synced successfully at ${DateTime.now()}');
      }
    } catch (e) {
      _lastSyncError = e.toString();
      if (kDebugMode) {
        print('Sync error: $e');
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Sync farmers data
  Future<void> _syncFarmers() async {
    // Implement your farmer sync logic here
    // Example:
    // final unsyncedFarmers = await dbHelper.getUnsyncedFarmers();
    // for (final farmer in unsyncedFarmers) {
    //   await apiService.submitFarmer(farmer);
    //   await dbHelper.markFarmerAsSynced(farmer.id);
    // }
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate work
  }

  // Sync farms data
  Future<void> _syncFarms() async {
    // Implement your farm sync logic here
    // Example:
    // final unsyncedFarms = await dbHelper.getUnsyncedFarms();
    // for (final farm in unsyncedFarms) {
    //   await apiService.submitFarm(farm);
    //   await dbHelper.markFarmAsSynced(farm.id);
    // }
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate work
  }

  // Sync other data types
  Future<void> _syncOtherData() async {
    // Add other data types you need to sync
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate work
  }

  // Manual sync trigger
  Future<void> triggerManualSync() async {
    await syncAllData();
  }

  // Check if any data needs syncing
  Future<bool> hasPendingSync() async {
    // Implement logic to check if there's any unsynced data
    // Example:
    // final hasUnsyncedFarmers = await dbHelper.hasUnsyncedFarmers();
    // final hasUnsyncedFarms = await dbHelper.hasUnsyncedFarms();
    // return hasUnsyncedFarmers || hasUnsyncedFarms;
    return await _backgroundSyncService.isSyncNeeded();
  }

  @override
  void dispose() {
    _backgroundSyncService.dispose();
    super.dispose();
  }
}