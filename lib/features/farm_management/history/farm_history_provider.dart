import 'package:exim_project_monitor/core/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/database/database_helper.dart';

class FarmHistoryProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  String _searchQuery = '';
  
  String get searchQuery => _searchQuery;
  
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }
  
  List<Farm> _filterFarms(List<Farm> farms) {
    if (_searchQuery.isEmpty) return farms;
    
    return farms.where((farm) {
      return

             farm.location.toString().toLowerCase().contains(_searchQuery);
    }).toList();
  }
  
  // Sample data with polygon coordinates
  final List<Farm> _pendingFarms = [];
  final List<Farm> _submittedFarms = [];


  // load farms from database
  Future<void> loadFarms() async {
    try {
      debugPrint('Loading farms from database');
      final dbHelper = DatabaseHelper();
      final farms = await dbHelper.getAllFarms();
      
      if (farms.isEmpty) {
        debugPrint('No farms found in the database');
      } else {
        debugPrint('Loaded ${farms.length} farms from database');
      }
      
      _pendingFarms.clear();
      _submittedFarms.clear();

      _pendingFarms.addAll(
        farms.where((farm) => !farm.isSynced).toList()
      );
      _submittedFarms.addAll(
        farms.where((farm) => farm.isSynced).toList()
      );
      
      debugPrint('Pending farms: ${_pendingFarms.length}, Submitted farms: ${_submittedFarms.length}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error loading farms: $e');
      debugPrint('Stack trace: $stackTrace');
      // Re-throw to allow UI to handle the error if needed
      rethrow;
    }
  }


  int get currentTabIndex => _currentTabIndex;
  List<Farm> get pendingFarms => _filterFarms(_pendingFarms);
  List<Farm> get submittedFarms => _filterFarms(_submittedFarms);
  
  // Get unfiltered lists when needed
  List<Farm> get allPendingFarms => _pendingFarms;
  List<Farm> get allSubmittedFarms => _submittedFarms;

  // Get farm by ID
  Farm? getFarmById(String id) {
    final allFarms = [..._pendingFarms, ..._submittedFarms];
    try {
      return allFarms.firstWhere((farm) => farm.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Add methods to load data from API in the future
  Future<void> loadPendingFarms() async {
    // Implement API call to load pending farms
    notifyListeners();
  }

  Future<void> loadSubmittedFarms() async {
    // Implement API call to load submitted farms
    notifyListeners();
  }

  Future<void> deleteFarm(int farmId) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteFarm(farmId);
      
      // Remove from both pending and submitted lists
      _pendingFarms.removeWhere((farm) => farm.id == farmId);
      _submittedFarms.removeWhere((farm) => farm.id == farmId);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting farm: $e');
      rethrow; // Re-throw to handle in the UI
    }
  }
}