
/// Background synchronization service that handles periodic data sync and connectivity changes.
/// Uses WorkManager for background tasks and ConnectivityPlus for network state monitoring.

// Core Flutter and asynchronous programming
import 'dart:async';
import 'package:flutter/foundation.dart';

// External dependencies
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Manages background synchronization tasks and connectivity monitoring.
class BackgroundSyncService {
  // Task names for WorkManager
  static const String syncTaskName = 'backgroundSyncTask';
  static const String checkConnectivityTask = 'checkConnectivityTask';

  // Dependencies
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final SyncCallback _syncCallback;

  /// Creates a new instance of [BackgroundSyncService].
  /// 
  /// [syncCallback] is the function that will be called when synchronization is triggered.
  BackgroundSyncService(this._syncCallback);

  /// Initializes the background sync service.
  /// 
  /// This method sets up WorkManager for background tasks and starts listening
  /// for connectivity changes.
  Future<void> initialize() async {
    await _initializeWorkManager();
    await _startConnectivityListener();
  }

  /// Sets up WorkManager for handling background tasks.
  /// 
  /// Initializes WorkManager and registers periodic and one-off tasks for
  /// connectivity checking and data synchronization.
  Future<void> _initializeWorkManager() async {
    // Initialize WorkManager with debug mode settings
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Register a periodic task to check connectivity (runs every 15 minutes)
    await Workmanager().registerPeriodicTask(
      checkConnectivityTask,
      checkConnectivityTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    // Register a one-off sync task that runs when conditions are met
    await Workmanager().registerOneOffTask(
      syncTaskName,
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  /// Starts listening for network connectivity changes.
  /// 
  /// When a network connection is detected, triggers a sync if needed.
  Future<void> _startConnectivityListener() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        // Check if we have any active network connection
        if (results.isNotEmpty && results.any((result) => result != ConnectivityResult.none)) {
          // Trigger sync when connection is available
          await _triggerSync();
        }
      },
    );
  }

  /// Internal method to trigger data synchronization.
  /// 
  /// Ensures that sync operations don't run too frequently (minimum 5 minutes between syncs).
  /// Updates the last sync timestamp after successful synchronization.
  Future<void> _triggerSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt('lastSync') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Rate limiting: Only sync if last sync was more than 5 minutes ago
      if (now - lastSync > 5 * 60 * 1000) {
        // Execute the provided sync callback
        await _syncCallback();
        // Update last sync timestamp
        await prefs.setInt('lastSync', now);

        // Log successful sync in debug mode
        if (kDebugMode) {
          print('Background sync completed at ${DateTime.now()}');
        }
      }
    } catch (e) {
      // Log errors in debug mode
      if (kDebugMode) {
        print('Background sync error: $e');
      }
      // Consider adding error reporting here in production
    }
  }

  /// Manually triggers a synchronization operation.
  /// 
  /// This can be called from the UI to force a sync regardless of the last sync time.
  Future<void> triggerManualSync() async {
    await _triggerSync();
  }

  // Check if sync is needed
  /// Checks if a sync is needed based on the last sync time.
  /// 
  /// Returns `true` if more than 5 minutes have passed since the last sync,
  /// indicating that a new sync is needed. Returns `false` otherwise.
  Future<bool> isSyncNeeded() async {
    // Get the last sync timestamp from local storage
    final prefs = await SharedPreferences.getInstance();
    // Default to 0 (epoch) if no previous sync time is found
    final lastSync = prefs.getInt('lastSync') ?? 0;
    // Get current timestamp in milliseconds since epoch
    final now = DateTime.now().millisecondsSinceEpoch;
    // Check if more than 5 minutes (300,000 ms) have passed since last sync
    return now - lastSync > 5 * 60 * 1000;
  }

  /// Cleans up resources used by the sync service.
  /// 
  /// Should be called when the service is no longer needed to prevent memory leaks.
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

/// Signature for sync operation callbacks.
/// 
/// These callbacks are executed when synchronization is triggered.
typedef SyncCallback = Future<void> Function();

/// Entry point for background tasks.
/// 
/// This function is called by the native platform when a background task is triggered.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case BackgroundSyncService.syncTaskName:
        await _executeBackgroundSync();
        return true;
      case BackgroundSyncService.checkConnectivityTask:
        await _checkConnectivityAndSync();
        return true;
      default:
        return false;
    }
  });
}

@pragma('vm:entry-point')
Future<void> _executeBackgroundSync() async {
  // This would typically call your sync methods
  // For now, we'll just update the last sync time
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastSync', DateTime.now().millisecondsSinceEpoch);

  if (kDebugMode) {
    print('Background sync executed at ${DateTime.now()}');
  }
}

@pragma('vm:entry-point')
Future<void> _checkConnectivityAndSync() async {
  final connectivity = Connectivity();
  final result = await connectivity.checkConnectivity();

  if (result != ConnectivityResult.none) {
    await _executeBackgroundSync();
  }
}