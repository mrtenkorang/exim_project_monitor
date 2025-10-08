import 'package:exim_project_monitor/core/models/server_models/farmers_model/farmers_from_server.dart';
import 'package:exim_project_monitor/core/services/database/database_helper.dart';
import 'package:flutter/material.dart';

class FarmerListProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<FarmerFromServerModel> _farmers = [];
  List<FarmerFromServerModel> _filteredFarmers = [];
  List<FarmerFromServerModel> _searchResults = [];
  String? _error;

  // Filter states
  String? _selectedRegion;
  String? _selectedDistrict;
  int _minFarmsCount = 0;

  // Getters
  List<FarmerFromServerModel> get farmers => _farmers;
  List<FarmerFromServerModel> get filteredFarmers => _filteredFarmers;
  List<FarmerFromServerModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter getters
  String? get selectedRegion => _selectedRegion;
  String? get selectedDistrict => _selectedDistrict;
  int get minFarmsCount => _minFarmsCount;

  // Available options for filters
  List<String> get availableRegions {
    final regions = _farmers.map((farmer) => farmer.regionName).where((region) => region.isNotEmpty).toSet().toList();
    regions.sort();
    return regions;
  }

  List<String> get availableDistricts {
    final districts = _farmers.map((farmer) => farmer.districtName).where((district) => district.isNotEmpty).toSet().toList();
    districts.sort();
    return districts;
  }

  bool get hasActiveFilters {
    return _selectedRegion != null || _selectedDistrict != null || _minFarmsCount > 0;
  }

  // Clear any existing error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load farmers asynchronously
  Future<void> loadFarmers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _farmers = await DatabaseHelper().getAllFarmersFromServerWithRelations();
      _filteredFarmers = List.from(_farmers);
      _searchResults = List.from(_farmers);

      if (_farmers.isNotEmpty) {
        debugPrint("Farmers loaded: ${_farmers.length} farmers");
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("Error loading farmers: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search functionality
  void searchFarmers(String query) {
    final lowerQuery = query.toLowerCase();

    _searchResults = _filteredFarmers.where((farmer) {
      // Search in multiple fields
      return farmer.firstName.toLowerCase().contains(lowerQuery) ||
          farmer.lastName.toLowerCase().contains(lowerQuery) ||
          farmer.phoneNumber.toLowerCase().contains(lowerQuery) ||
          farmer.email.toLowerCase().contains(lowerQuery) ||
          farmer.community.toLowerCase().contains(lowerQuery) ||
          farmer.districtName.toLowerCase().contains(lowerQuery) ||
          farmer.regionName.toLowerCase().contains(lowerQuery) ||
          farmer.businessName.toLowerCase().contains(lowerQuery) ||
          farmer.nationalId.toLowerCase().contains(lowerQuery) ||
          farmer.primaryCrop.toLowerCase().contains(lowerQuery) ||
          farmer.cooperativeMembership.toLowerCase().contains(lowerQuery) ||
          farmer.address.toLowerCase().contains(lowerQuery) ||
          farmer.yearsOfExperience.toString().contains(lowerQuery) ||
          farmer.farmsCount.toString().contains(lowerQuery);
    }).toList();

    notifyListeners();
  }

  void clearSearch() {
    _searchResults = List.from(_filteredFarmers);
    notifyListeners();
  }

  // Filter functionality
  void setRegionFilter(String? region) {
    _selectedRegion = region;
    _applyFilters();
  }

  void setDistrictFilter(String? district) {
    _selectedDistrict = district;
    _applyFilters();
  }

  void setMinFarmsCount(int? minFarmsCount) {
    _minFarmsCount = minFarmsCount ?? 0;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredFarmers = _farmers.where((farmer) {
      // Region filter
      if (_selectedRegion != null && farmer.regionName != _selectedRegion) {
        return false;
      }

      // District filter
      if (_selectedDistrict != null && farmer.districtName != _selectedDistrict) {
        return false;
      }

      // Farm count filter
      if (_minFarmsCount > 0 && farmer.farmsCount < _minFarmsCount) {
        return false;
      }

      return true;
    }).toList();

    // Update search results to match filtered list
    _searchResults = List.from(_filteredFarmers);

    notifyListeners();
  }

  void clearFilters() {
    _selectedRegion = null;
    _selectedDistrict = null;
    _minFarmsCount = 0;
    _filteredFarmers = List.from(_farmers);
    _searchResults = List.from(_farmers);
    notifyListeners();
  }
}