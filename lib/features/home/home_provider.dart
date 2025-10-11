import 'dart:developer';
import 'package:exim_project_monitor/widgets/globals/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ChangeNotifier, debugPrint;
import 'package:exim_project_monitor/core/models/farmer_model.dart';
import 'package:exim_project_monitor/core/services/api/api.dart';
import 'package:exim_project_monitor/core/services/database/database_helper.dart';
import 'package:exim_project_monitor/widgets/custom_snackbar.dart';

class HomeProvider extends ChangeNotifier {

  BuildContext? homeContext;

  String _greeting = '';
  String _userNameGreeting = '';

  String get userNameGreeting => _userNameGreeting;
  String get greeting => _greeting;

  getUserNameGreeting(){
    _userNameGreeting = 'Hello, Kwame!';
    notifyListeners();
  }

  getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 18) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }

    debugPrint(_greeting);
    debugPrint(greeting);
    notifyListeners();
  }

  // Sync state
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  String? _syncError;
  String? get syncError => _syncError;
  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  /// Loads the count of pending farmers that need to be synced
  // Future<void> loadPendingCount() async {
  //   try {
  //     final dbHelper = DatabaseHelper();
  //     _pendingCount = await dbHelper.getUnsyncedFarmersCount();
  //     notifyListeners();
  //   } catch (e) {
  //     log('Error loading pending count: $e');
  //   }
  // }

  /// Syncs all pending farms with the server
  /// Syncs all pending farms with the server
  syncPendingFarms() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper();
      final apiService = APIService();

      if(homeContext!.mounted){
        Globals().startWait(homeContext!);
      }

      // Get all unsynced farms
      final unsyncedFarms = await dbHelper.getUnsyncedFarms();

      if (unsyncedFarms.isEmpty) {
        _syncError = 'No pending farms to sync';
        if(homeContext!.mounted){
          Globals().endWait(homeContext!);
        }
        CustomSnackbar.show(homeContext!, message: _syncError!, type: SnackbarType.warning);
        notifyListeners();
        return;
      }

      int successCount = 0;

      for (final farm in unsyncedFarms) {
        try {
          // Submit farm to server
          final farmRes = await apiService.submitFarm(farm);

          if(farmRes.id != null){
            final updatedFarm = farm.copyWith(isSynced: true);
            await dbHelper.updateFarm(updatedFarm);
            successCount++;
          }

        } catch (e) {
          log('Error syncing farm ${farm.id}: $e');
          // Continue with next farm even if one fails
          continue;
        }
      }

      if (successCount < unsyncedFarms.length) {
        _syncError = 'Synced $successCount of ${unsyncedFarms.length} farms. Some failed to sync.';
        return false;
      }

      if(homeContext!.mounted){
        Globals().endWait(homeContext!);
      }

      return true;

    } catch (e) {
      if(homeContext!.mounted){
        Globals().endWait(homeContext!);
      }
      log('Error in syncPendingFarms: $e');
      _syncError = 'Failed to sync farms: ${e.toString()}';
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Syncs all pending farmers with the server
  syncPendingFarmers() async {
    if (_isSyncing) return false;
    
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper();
      final apiService = APIService();

      if(homeContext!.mounted){
        Globals().startWait(homeContext!);
      }
      
      // Get all unsynced farmers
      final unsyncedFarmers = await dbHelper.getFarmerBySyncId(0);

      debugPrint('THE FARMERS ::::::::: ${unsyncedFarmers.first.toJsonOnline()}');
      
      if (unsyncedFarmers.isEmpty) {
        _syncError = 'No pending farmers to sync';
        if(homeContext!.mounted){
          Globals().endWait(homeContext!);
        }
        CustomSnackbar.show(homeContext!, message: _syncError!, type: SnackbarType.warning);
        notifyListeners();
        return ;
      }

      int successCount = 0;
      
      for (final farmer in unsyncedFarmers) {
        try {
          // Submit farmer to server
          Farmer farmerRes = await apiService.submitFarmer(farmer);

          if(farmerRes.id != null){
            final updatedFarmer = farmer.copyWith(isSynced: 1);
            await dbHelper.updateFarmer(updatedFarmer);
            successCount++;
          }

        } catch (e) {
          log('Error syncing farmer ${farmer.id}: $e');
          // Continue with next farmer even if one fails
          continue;
        }
      }

      if (successCount < unsyncedFarmers.length) {
        _syncError = 'Synced $successCount of ${unsyncedFarmers.length} farmers. Some failed to sync.';
        return false;
      }

      if(homeContext!.mounted){
        Globals().endWait(homeContext!);
      }

      return true;
      
    } catch (e) {
      if(homeContext!.mounted){
        Globals().endWait(homeContext!);
      }
      log('Error in syncPendingFarmers: $e');
      _syncError = 'Failed to sync farmers: ${e.toString()}';
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Resets the sync error
  void resetSyncError() {
    _syncError = null;
    notifyListeners();
  }}