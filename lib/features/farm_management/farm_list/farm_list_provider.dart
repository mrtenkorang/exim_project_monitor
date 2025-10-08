import 'package:exim_project_monitor/core/models/server_models/farmers_model/farmers_from_server.dart';
import 'package:exim_project_monitor/core/services/database/database_helper.dart';
import 'package:flutter/material.dart';

class FarmListProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<FarmerFromServerModel> _farmers = [];
  List<FarmFromServer> _farms = [];
  List<FarmFromServer> _filteredFarms = [];
  List<FarmFromServer> _searchResults = [];
  String? _error;

  // Filter states
  String? _selectedStatus;
  String? _selectedCropType;
  double _minArea = 0;

  // Getters
  List<FarmerFromServerModel> get farmers => _farmers;
  List<FarmFromServer> get farms => _farms;
  List<FarmFromServer> get filteredFarms => _filteredFarms;
  List<FarmFromServer> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter getters
  String? get selectedStatus => _selectedStatus;
  String? get selectedCropType => _selectedCropType;
  double get minArea => _minArea;

  // Available options for filters
  List<String> get availableStatuses {
    final statuses = _farms.map((farm) => farm.status).toSet().toList();
    statuses.sort();
    return statuses;
  }

  // List<String> get availableCropTypes {
  //   final cropTypes = _farms.map((farm) => farm.cropType).where((crop) => crop.isNotEmpty).toSet().toList();
  //   cropTypes.sort();
  //   return cropTypes;
  // }

  bool get hasActiveFilters {
    return _selectedStatus != null || _selectedCropType != null || _minArea > 0;
  }

  // Clear any existing error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load farmers and extract farms
  Future<void> loadFarmers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _farmers = await DatabaseHelper().getAllFarmersFromServerWithRelations();

      // Extract all farms from all farmers
      _farms = [];
      for (final farmer in _farmers) {
        _farms.addAll(farmer.farms);
      }

      _filteredFarms = List.from(_farms);

      if (_farms.isNotEmpty) {
        debugPrint("Farms loaded: ${_farms.length} farms from ${_farmers.length} farmers");
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
  void searchFarms(String query) {
    final lowerQuery = query.toLowerCase();

    _searchResults = _filteredFarms.where((farm) {
      return farm.name.toLowerCase().contains(lowerQuery) ||
          farm.farmCode.toLowerCase().contains(lowerQuery) ||
          // farm.cropType.toLowerCase().contains(lowerQuery) ||
          farm.farmerName.toLowerCase().contains(lowerQuery) ||
          farm.status.toLowerCase().contains(lowerQuery) ||
          farm.soilType.toLowerCase().contains(lowerQuery) ||
          farm.irrigationType.toLowerCase().contains(lowerQuery) ||
          farm.projectName.toLowerCase().contains(lowerQuery) ||
          farm.areaHectares.toString().contains(lowerQuery) ||
          farm.irrigationCoverage.toString().contains(lowerQuery);
    }).toList();

    notifyListeners();
  }

  void clearSearch() {
    _searchResults = List.from(_filteredFarms);
    notifyListeners();
  }

  // Filter functionality
  void setStatusFilter(String? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void setCropTypeFilter(String? cropType) {
    _selectedCropType = cropType;
    _applyFilters();
  }

  void setMinArea(double? minArea) {
    _minArea = minArea ?? 0;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredFarms = _farms.where((farm) {
      // Status filter
      if (_selectedStatus != null && farm.status != _selectedStatus) {
        return false;
      }

      // Crop type filter
      // if (_selectedCropType != null && farm.cropType != _selectedCropType) {
      //   return false;
      // }

      // Area filter
      if (_minArea > 0 && farm.areaHectares < _minArea) {
        return false;
      }

      return true;
    }).toList();

    // Update search results to match filtered list
    _searchResults = List.from(_filteredFarms);

    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _selectedCropType = null;
    _minArea = 0;
    _filteredFarms = List.from(_farms);
    _searchResults = List.from(_farms);
    notifyListeners();
  }
}