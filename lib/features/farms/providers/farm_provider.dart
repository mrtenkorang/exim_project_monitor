import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/repositories/farm_repository.dart';
import '../repositories/farm_repository.dart';

class FarmProvider with ChangeNotifier {
  final FarmRepository _repository;
  List<Farm> _farms = [];
  bool _isLoading = false;
  String? _error;

  FarmProvider({required FarmRepository repository}) : _repository = repository;

  // Getters
  List<Farm> get farms => _farms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all farms
  Future<void> loadFarms() async {
    _setLoading(true);
    try {
      _farms = await _repository.getFarms();
      _error = null;
    } catch (e) {
      _error = 'Failed to load farms: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Add a new farm
  Future<bool> addFarm(Farm farm) async {
    _setLoading(true);
    try {
      final newFarmId = await _repository.addFarm(farm);
      // Create a new Farm object with the returned ID
      final createdFarm = Farm(
        id: newFarmId,
        name: farm.name,
        farmerName: farm.farmerName,
        farmSize: farm.farmSize,
        boundaryPoints: farm.boundaryPoints,
        status: farm.status,
        assignedTo: farm.assignedTo,
        verifiedBy: farm.verifiedBy,
        additionalData: farm.additionalData,
        imageUrls: farm.imageUrls,
        zoneId: farm.zoneId,
        isSynced: farm.isSynced,
        createdAt: farm.createdAt,
        updatedAt: farm.updatedAt,
      );
      _farms.add(createdFarm);
      notifyListeners();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to add farm: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing farm
  Future<bool> updateFarm(Farm farm) async {
    _setLoading(true);
    try {
      final index = _farms.indexWhere((f) => f.id == farm.id);
      if (index != -1) {
        await _repository.updateFarm(farm);
        _farms[index] = farm;
        notifyListeners();
        _error = null;
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update farm: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a farm
  Future<bool> deleteFarm(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteFarm(id);
      _farms.removeWhere((farm) => farm.id == id);
      notifyListeners();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to delete farm: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search farms by name or farmer name
  Future<List<Farm>> searchFarms(String query) async {
    _setLoading(true);
    try {
      final results = await _repository.searchFarms(query);
      _error = null;
      return results;
    } catch (e) {
      _error = 'Failed to search farms: $e';
      debugPrint(_error);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get a farm by ID
  Farm? getFarmById(String id) {
    try {
      return _farms.firstWhere((farm) => farm.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
