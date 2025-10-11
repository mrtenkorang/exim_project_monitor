
// lib/core/services/background_sync_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundSyncService {
  static const String syncTaskName = 'backgroundSyncTask';
  static const String checkConnectivityTask = 'checkConnectivityTask';

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final SyncCallback _syncCallback;

  BackgroundSyncService(this._syncCallback);

  // Initialize background sync
  Future<void> initialize() async {
    await _initializeWorkManager();
    await _startConnectivityListener();
  }

  // Initialize WorkManager for background tasks
  Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Register periodic connectivity check (every 15 minutes)
    await Workmanager().registerPeriodicTask(
      checkConnectivityTask,
      checkConnectivityTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    // Register one-off sync task that can be triggered when connectivity is detected
    await Workmanager().registerOneOffTask(
      syncTaskName,
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  // Listen for connectivity changes
  Future<void> _startConnectivityListener() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) async {
        // Check if any of the connectivity results indicate an active connection
        if (results.isNotEmpty && results.any((result) => result != ConnectivityResult.none)) {
          // Internet connection detected
          await _triggerSync();
        }
      },
    );
  }

  // Trigger synchronization
  Future<void> _triggerSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt('lastSync') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Only sync if last sync was more than 5 minutes ago
      if (now - lastSync > 5 * 60 * 1000) {
        await _syncCallback();
        await prefs.setInt('lastSync', now);

        if (kDebugMode) {
          print('Background sync completed at ${DateTime.now()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Background sync error: $e');
      }
    }
  }

  // Manual sync trigger
  Future<void> triggerManualSync() async {
    await _triggerSync();
  }

  // Check if sync is needed
  Future<bool> isSyncNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt('lastSync') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - lastSync > 5 * 60 * 1000; // 5 minutes
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

// Callback signature for sync operations
typedef SyncCallback = Future<void> Function();

// Background task callback dispatcher
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