import 'package:flutter/foundation.dart';

import '../../../core/constants/constants.dart';
import '../../../core/models/farmer_model.dart';
import '../../../core/services/database/database_helper.dart';

class FarmerHistoryProvider with ChangeNotifier {
  final List<Farmer> _farmers = [];

  Future<void> loadFarmers() async {
    final dbHelper = DatabaseHelper();
    final farmers = await dbHelper.getAllFarmers();

    // debugPrint("FARMERSSSSSSSSSSSSSSSSSSSS ::::::::::::::: ${farmers.first.toMap()}");
    _farmers.clear();
    _farmers.addAll(farmers);
    notifyListeners();

    debugPrint("THE FARMERS: $_farmers");
  }

  String _searchQuery = '';
  int _currentTabIndex = 0;



  List<Farmer> get pendingFarmers => _farmers
      .where((farmer) =>
  farmer.isSynced == SyncStatus.notSynced &&
      (_searchQuery.isEmpty ||
          farmer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farmer.phoneNumber.contains(_searchQuery) ||
          farmer.community.toLowerCase().contains(_searchQuery.toLowerCase())))
      .toList();

  List<Farmer> get submittedFarmers => _farmers
      .where((farmer) =>
  farmer.isSynced == SyncStatus.synced &&
      (_searchQuery.isEmpty ||
          farmer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farmer.phoneNumber.contains(_searchQuery) ||
          farmer.community.toLowerCase().contains(_searchQuery.toLowerCase())))
      .toList();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Farmer? getFarmerById(String id) {
    try {
      return _farmers.firstWhere((farmer) => farmer.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteFarmer(int id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteFarmer(id);
    await loadFarmers();
  }

}