// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, avoid_print
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:exim_project_monitor/core/cache_service/cache_service.dart';
import 'package:exim_project_monitor/core/models/custom_user.dart';
import 'package:exim_project_monitor/core/models/server_models/farmers_model/farmers_from_server.dart';
import 'package:exim_project_monitor/core/models/user_model.dart';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/polygon_drawing_tool.dart';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/utils/double_value_trimmer.dart';
import 'package:exim_project_monitor/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import '../../core/models/farm_model.dart';
import '../../core/models/farmer_model.dart';
import '../../core/services/database/database_helper.dart';
import '../../core/services/api/api.dart';
import '../../widgets/globals/globals.dart';
import 'package:geolocator/geolocator.dart' as gl;

/// Provider class for managing farm addition operations
/// Handles location services, polygon drawing, farm validation, and data persistence
class AddFarmProvider with ChangeNotifier {
  // ==================================================================================
  // PROPERTIES & DEPENDENCIES
  // ==================================================================================

  /// Build context for the add farm screen - used for dialogs and navigation
  late BuildContext addFarmScreenContext;
  /// Loading state for farm submission
  bool _isLoading = false;

  /// Loading state getter
  bool get isLoading => _isLoading;

  final _databaseHelper = DatabaseHelper();
  final _apiService = APIService();

  // Date properties
  DateTime? _harvestDate;
  DateTime? _plantingDate;
  DateTime? _visitDate;
  bool _hasFarmBoundaryPolygon = false;

  // Farmer selection properties
  List<Farmer> _farmers = [];
  List<FarmerFromServerModel> _farmersFromServer = [];
  FarmerFromServerModel? _selectedFarmer;
  bool _loadingFarmers = false;
  String? _farmerLoadError;

  // Getters
  DateTime? get harvestDate => _harvestDate;
  DateTime? get plantingDate => _plantingDate;
  DateTime? get visitDate => _visitDate;
  bool get hasFarmBoundaryPolygon => _hasFarmBoundaryPolygon;
  List<Farmer> get farmers => _farmers;
  List<FarmerFromServerModel> get farmersFromServer => _farmersFromServer;
  FarmerFromServerModel? get selectedFarmer => _selectedFarmer;
  bool get loadingFarmers => _loadingFarmers;
  String? get farmerLoadError => _farmerLoadError;

  // Setters
  void setHarvestDate(DateTime? date) {
    _harvestDate = date;
    notifyListeners();
  }

  void setPlantingDate(DateTime? date) {
    _plantingDate = date;
    notifyListeners();
  }

  void setVisitDate(DateTime? date) {
    _visitDate = date;
    notifyListeners();
  }

  void setFarmBoundaryPolygon(bool value) {
    _hasFarmBoundaryPolygon = value;
    farmBoundaryPolygonController.text = value ? 'Yes' : 'No';
    notifyListeners();
  }

  // load farmer from server from local db
  // loadFarmFromServer() async {
  //
  //   final farmers = await _databaseHelper.getAllFarmersFromServer();
  //   _farmersFromServer = farmers;
  //   notifyListeners();
  // }

  /// Load farmers from local database (farmers from server model)
  Future<void> loadFarmers() async {
    _loadingFarmers = true;
    _farmerLoadError = null;
    notifyListeners();

    try {
      // Load farmers from server model stored in local database
      _farmersFromServer = await _databaseHelper.getAllFarmersFromServerWithRelations();

      debugPrint('Loaded ${_farmersFromServer.length} farmers from local database');

      _loadingFarmers = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error loading farmers from server: $e');
      debugPrint('Stack trace: $stackTrace');
      _loadingFarmers = false;
      _farmerLoadError = 'Failed to load farmers';
      notifyListeners();
    }
  }

  /// Set the selected farmer
  void setSelectedFarmer(FarmerFromServerModel? farmer) {
    _selectedFarmer = farmer;
    notifyListeners();
  }

  /// Clear selected farmer
  void clearSelectedFarmer() {
    _selectedFarmer = null;
    notifyListeners();
  }

  User? userInfo;

  Future<void> loadUserInfo() async {
    final cacheService = await CacheService.getInstance();
    userInfo = await cacheService.getUserInfo();

    debugPrint("USER INFO: ${userInfo?.toJson()}");
    notifyListeners();
  }

  // ==================================================================================
  // FORM CONTROLLERS
  // ==================================================================================

  // Original Controllers
  final TextEditingController farmLocationController = TextEditingController();
  // final TextEditingController projectIdController = TextEditingController();
  final TextEditingController farmSizeController = TextEditingController();
  final TextEditingController visitIdController = TextEditingController();
  final TextEditingController dateOfVisitController = TextEditingController();
  final TextEditingController mainBuyersController = TextEditingController();
  final TextEditingController farmBoundaryPolygonController =
      TextEditingController();
  final TextEditingController landUseClassificationController =
      TextEditingController();
  final TextEditingController accessibilityController = TextEditingController();
  final TextEditingController proximityToProcessingFacilityController =
      TextEditingController();
  final TextEditingController serviceProviderController =
      TextEditingController();
  final TextEditingController cooperativesOrFarmerGroupsController =
      TextEditingController();
  final TextEditingController valueChainLinkagesController =
      TextEditingController();
  final TextEditingController officerNameController = TextEditingController();
  final TextEditingController officerIdController = TextEditingController();
  final TextEditingController observationsController = TextEditingController();
  final TextEditingController issuesIdentifiedController =
      TextEditingController();
  final TextEditingController infrastructureIdentifiedController =
      TextEditingController();
  final TextEditingController recommendedActionsController =
      TextEditingController();
  final TextEditingController followUpStatusController =
      TextEditingController();

  // New Controllers for Added Fields
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController cropTypeController = TextEditingController();
  final TextEditingController varietyBreedController = TextEditingController();
  final TextEditingController plantingDensityController =
      TextEditingController();
  final TextEditingController labourHiredController = TextEditingController();
  final TextEditingController maleWorkersController = TextEditingController();
  final TextEditingController femaleWorkersController = TextEditingController();
  final TextEditingController estimatedYieldController =
      TextEditingController();
  final TextEditingController previousYieldController = TextEditingController();

  @override
  void dispose() {
    // Dispose all original controllers
    farmLocationController.dispose();
    // projectIdController.dispose();
    farmSizeController.dispose();
    visitIdController.dispose();
    dateOfVisitController.dispose();
    mainBuyersController.dispose();
    farmBoundaryPolygonController.dispose();
    landUseClassificationController.dispose();
    accessibilityController.dispose();
    proximityToProcessingFacilityController.dispose();
    serviceProviderController.dispose();
    cooperativesOrFarmerGroupsController.dispose();
    valueChainLinkagesController.dispose();
    officerNameController.dispose();
    officerIdController.dispose();
    observationsController.dispose();
    issuesIdentifiedController.dispose();
    infrastructureIdentifiedController.dispose();
    recommendedActionsController.dispose();
    followUpStatusController.dispose();

    // Dispose new controllers
    latitudeController.dispose();
    longitudeController.dispose();
    cropTypeController.dispose();
    varietyBreedController.dispose();
    plantingDensityController.dispose();
    labourHiredController.dispose();
    maleWorkersController.dispose();
    femaleWorkersController.dispose();
    estimatedYieldController.dispose();
    previousYieldController.dispose();

    super.dispose();
  }

  final addFarmFormKey = GlobalKey<FormState>();

  // Services
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  // ==================================================================================
  // FORM CONTROLLERS & DATA MODELS
  // ==================================================================================

  /// Text controller for farm area input field
  TextEditingController? farmAreaTC = TextEditingController();

  /// Variable to store ID type selection
  var idType;

  /// Current device location data
  LocationData? locationData;

  /// Observable flag to track initial loading state
  bool _isInitialLoad = false;
  bool get isInitialLoad => _isInitialLoad;
  set isInitialLoad(bool value) {
    _isInitialLoad = value;
    notifyListeners();
  }

  // ==================================================================================
  // MAP & POLYGON RELATED PROPERTIES
  // ==================================================================================

  /// Set of markers to display on the map
  Set<Marker>? markers;

  /// Current polygon being drawn/edited
  Polygon? polygon;

  /// Collection of polygons for overlap checking (primary set)
  Set<Polygon> polygonsForCheck = HashSet<Polygon>();

  /// Collection of polygons for secondary checking operations
  Set<Polygon> polygonsForCheck2 = HashSet<Polygon>();

  /// Collection of forest reserve polygons for environmental validation
  Set<Polygon> polygonsForForestReserveCheck = HashSet<Polygon>();

  /// Collection of polylines for map display
  Set<Polyline> polyLines = HashSet<Polyline>();

  /// Custom marker icon for map display
  BitmapDescriptor? mapMarker;

  /// Currently active polygon for editing operations
  Polygon? activePolygon;

  // Flags for polygon navigation state
  bool _isLastPolygon = false;
  bool _isFirstPolygon = false;
  bool _emptyData = false;
  bool _loadingPolygons = false;

  bool get isLastPolygon => _isLastPolygon;
  bool get isFirstPolygon => _isFirstPolygon;
  bool get emptyData => _emptyData;
  bool get loadingPolygons => _loadingPolygons;

  set isLastPolygon(bool value) {
    _isLastPolygon = value;
    notifyListeners();
  }

  set isFirstPolygon(bool value) {
    _isFirstPolygon = value;
    notifyListeners();
  }

  set emptyData(bool value) {
    _emptyData = value;
    notifyListeners();
  }

  set loadingPolygons(bool value) {
    _loadingPolygons = value;
    notifyListeners();
  }

  // ==================================================================================
  // LOCATION PERMISSION & COORDINATES ACCESS
  // ==================================================================================

  /// Requests location permission and returns the status
  Future<gl.LocationPermission> requestLocationPermission() async {
    try {
      gl.LocationPermission permission = await gl.Geolocator.checkPermission();

      if (permission == gl.LocationPermission.denied) {
        permission = await gl.Geolocator.requestPermission();
      }

      return permission;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return gl.LocationPermission.denied;
    }
  }

  /// Checks if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      gl.LocationPermission permission = await gl.Geolocator.checkPermission();
      return permission == gl.LocationPermission.whileInUse ||
          permission == gl.LocationPermission.always;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Gets current coordinates and updates the controllers
  Future<bool> getCurrentCoordinates() async {
    try {
      // Check and request permission
      final permission = await requestLocationPermission();

      if (permission != gl.LocationPermission.whileInUse &&
          permission != gl.LocationPermission.always) {
        debugPrint('Location permission not granted');
        if (addFarmScreenContext.mounted) {
          CustomSnackbar.show(
            addFarmScreenContext,
            message: "Location permission required",
            type: SnackbarType.error,
          );
        }
        return false;
      }

      // Check if location services are enabled
      bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        if (addFarmScreenContext.mounted) {
          if (addFarmScreenContext.mounted) {
            CustomSnackbar.show(
              addFarmScreenContext,
              message: "Enable location to continue",
              type: SnackbarType.error,
            );
          }
        }
        return false;
      }

      // Show loading indicator
      // if (addFarmScreenContext.mounted) {
      //   Globals().startWait(addFarmScreenContext);
      // }

      // Get current position
      gl.Position position = await gl.Geolocator.getCurrentPosition(
        desiredAccuracy: gl.LocationAccuracy.best,
      );

      // Update controllers with coordinates
      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);

      // Update location data
      locationData = LocationData.fromMap({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      });

      debugPrint(
        'Coordinates obtained: ${position.latitude}, ${position.longitude}',
      );

      // Hide loading indicator
      // if (addFarmScreenContext.mounted) {
      //   Globals().endWait(addFarmScreenContext);
      // }

      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          const SnackBar(content: Text('Coordinates obtained successfully')),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error getting current coordinates: $e');

      // Hide loading indicator
      if (addFarmScreenContext.mounted) {
        Globals().endWait(addFarmScreenContext);
      }

      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
      return false;
    }
  }

  /// Auto-fill coordinates when the user focuses on coordinate fields
  void autoFillCoordinates() async {
    if (latitudeController.text.isEmpty || longitudeController.text.isEmpty) {
      final success = await getCurrentCoordinates();

      if (success) {
        debugPrint(
          "Coordinates auto-filled: ${latitudeController.text}, ${longitudeController.text}",
        );
      } else {
        debugPrint("Failed to auto-fill coordinates");
      }
    }
  }

  // ==================================================================================
  // INITIALIZATION & LIFECYCLE
  // ==================================================================================

  /// Initialize the provider with required context
  Future<void> initialize(BuildContext context) async {
    addFarmScreenContext = context;

    // Get current location first - critical for loading nearby farms
    await getCurrentLocation();

    // Show loading indicator while fetching farm data
    Globals().startWait(addFarmScreenContext);

    // Load farmers
    await loadFarmers();

    // Hide loading indicator
    Globals().endWait(addFarmScreenContext);
  }

  // ==================================================================================
  // FARM OPERATIONS
  // ==================================================================================

  /// Saves the farm data to the local database
  Future<bool> saveFarm() async {
    debugPrint('Saving farm...');
    if (!_validateForm()) return false;

    debugPrint('Form is valid. Saving farm...');
    try {
      // Show loading indicator
      if (addFarmScreenContext.mounted) {
        Globals().startWait(addFarmScreenContext);
      }

      polygon!.points.add(polygon!.points.first);

      // Convert polygon to coordinate format
      var boundaryCoordinates = polygon!.points
          .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList();

      final farm = Farm(
        farmerId: selectedFarmer?.id,
        visitId: visitIdController.text.trim(),
        dateOfVisit: _visitDate?.toString() ?? '',
        mainBuyers: mainBuyersController.text.trim(),
        farmBoundaryPolygon: Uint8List.fromList(
          utf8.encode(jsonEncode(boundaryCoordinates)),
        ),
        landUseClassification: landUseClassificationController.text.trim(),
        accessibility: accessibilityController.text.trim(),
        proximityToProcessingFacility: proximityToProcessingFacilityController
            .text
            .trim(),
        serviceProvider: serviceProviderController.text.trim(),
        cooperativesOrFarmerGroups: cooperativesOrFarmerGroupsController.text
            .trim(),
        valueChainLinkages: valueChainLinkagesController.text.trim(),
        officerName: officerNameController.text.trim(),
        officerId: userInfo?.userID.toString() ?? "",
        observations: observationsController.text.trim(),
        issuesIdentified: issuesIdentifiedController.text.trim(),
        infrastructureIdentified: infrastructureIdentifiedController.text
            .trim(),
        recommendedActions: recommendedActionsController.text.trim(),
        followUpStatus: followUpStatusController.text.trim(),
        farmSize: farmSizeController.text.trim(),
        location: farmLocationController.text.trim(),
        isSynced: false,
        latitude: double.tryParse(latitudeController.text) ?? 0.0,
        longitude: double.tryParse(longitudeController.text) ?? 0.0,
        cropType: cropTypeController.text.trim(),
        varietyBreed: varietyBreedController.text.trim(),
        plantingDate: _plantingDate?.toString() ?? '',
        plantingDensity: plantingDensityController.text.trim(),
        labourHired: int.tryParse(labourHiredController.text) ?? 0,
        maleWorkers: int.tryParse(maleWorkersController.text) ?? 0,
        femaleWorkers: int.tryParse(femaleWorkersController.text) ?? 0,
        estimatedYield: estimatedYieldController.text.trim(),
        previousYield: previousYieldController.text.trim(),
        harvestDate: _harvestDate?.toString() ?? '',
      );

      debugPrint('Saving farm with polygon data: ${farm.farmBoundaryPolygon}');

      // Insert the farm into the database
      final id = await _databaseHelper.insertFarm(farm);
      debugPrint('Farm saved with ID: $id');

      // Hide loading indicator
      if (addFarmScreenContext.mounted) {
        Globals().endWait(addFarmScreenContext);
      }

      // Show success message
      if (addFarmScreenContext.mounted) {
        CustomSnackbar.show(
          addFarmScreenContext,
          message: "Farm saved successfully",
          type: SnackbarType.success,
        );

        // clear the form
        clearForm();

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (addFarmScreenContext.mounted) {
            Navigator.of(addFarmScreenContext).pop(true); // Return success
          }
        });
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('Error saving farm: $e');
      debugPrint('Stack trace: $stackTrace');

      // Hide loading indicator
      if (addFarmScreenContext.mounted) {
        Globals().endWait(addFarmScreenContext);
      }

      if (addFarmScreenContext.mounted) {
        CustomSnackbar.show(
          addFarmScreenContext,
          message: "An unknown error occurred",
          type: SnackbarType.error,
        );
      }

      return false;
    }
  }

  /// Saves the farm data to the local database and syncs with the server if online
  Future<bool> submitFarm() async {

    debugPrint('Form is valid. Saving farm...');
    try {
      // Show loading indicator
      if (addFarmScreenContext.mounted) {
        Globals().startWait(addFarmScreenContext);
      }

      polygon!.points.add(polygon!.points.first);

      // Convert polygon to coordinate format
      var boundaryCoordinates = polygon!.points
          .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList();

      final farm = Farm(
        // id: _farmId,
        farmerId: selectedFarmer?.id,
        visitId: visitIdController.text.trim(),
        dateOfVisit: _visitDate?.toString() ?? '',
        mainBuyers: mainBuyersController.text.trim(),
        farmBoundaryPolygon: Uint8List.fromList(
          utf8.encode(jsonEncode(boundaryCoordinates)),
        ),
        landUseClassification: landUseClassificationController.text.trim(),
        accessibility: accessibilityController.text.trim(),
        proximityToProcessingFacility: proximityToProcessingFacilityController
            .text
            .trim(),
        serviceProvider: serviceProviderController.text.trim(),
        cooperativesOrFarmerGroups: cooperativesOrFarmerGroupsController.text
            .trim(),
        valueChainLinkages: valueChainLinkagesController.text.trim(),
        officerName: officerNameController.text.trim(),
        officerId: userInfo?.userID.toString() ?? "",
        observations: observationsController.text.trim(),
        issuesIdentified: issuesIdentifiedController.text.trim(),
        infrastructureIdentified: infrastructureIdentifiedController.text
            .trim(),
        recommendedActions: recommendedActionsController.text.trim(),
        followUpStatus: followUpStatusController.text.trim(),
        farmSize: farmSizeController.text.trim(),
        location: farmLocationController.text.trim(),
        isSynced: true,
        latitude: double.tryParse(latitudeController.text) ?? 0.0,
        longitude: double.tryParse(longitudeController.text) ?? 0.0,
        cropType: cropTypeController.text.trim(),
        varietyBreed: varietyBreedController.text.trim(),
        plantingDate: _plantingDate?.toString() ?? '',
        plantingDensity: plantingDensityController.text.trim(),
        labourHired: int.tryParse(labourHiredController.text) ?? 0,
        maleWorkers: int.tryParse(maleWorkersController.text) ?? 0,
        femaleWorkers: int.tryParse(femaleWorkersController.text) ?? 0,
        estimatedYield: estimatedYieldController.text.trim(),
        previousYield: previousYieldController.text.trim(),
        harvestDate: _harvestDate?.toString() ?? '',
      );

      debugPrint('Submitting farm with polygon data: ${farm.toJsonOnline()}');

      // Insert the farm into the database
      dynamic farmResponse = await _apiService.submitFarm(farm);

      // Hide loading indicator
      if (addFarmScreenContext.mounted) {
        Globals().endWait(addFarmScreenContext);
      }

      // Show success message
      if (addFarmScreenContext.mounted && farmResponse != null && farmResponse == 1) {
        final id = await _databaseHelper.insertFarm(farm);
        debugPrint('Farm submitted with ID: $id');
        CustomSnackbar.show(
          addFarmScreenContext,
          message: "Farm submitted successfully",
          type: SnackbarType.success,
        );

        // Clear the form
        clearForm();
        
        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (addFarmScreenContext.mounted) {
            Navigator.of(addFarmScreenContext).pop(true);
          }
        });
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('Error submitting farm: $e');
      debugPrint('Stack trace: $stackTrace');

      // Hide loading indicator
      if (addFarmScreenContext.mounted) {
        Globals().endWait(addFarmScreenContext);
      }

      if (addFarmScreenContext.mounted) {
        CustomSnackbar.show(
          addFarmScreenContext,
          message: "An unknown error occurred",
          type: SnackbarType.error,
        );
      }

      return false;
    }
  }

  // Get all farms from database
  Future<List<Farm>> getAllFarms() async {
    return await _databaseHelper.getAllFarms();
  }

  // Get farm by ID
  Future<Farm?> getFarmById(int id) async {
    return await _databaseHelper.getFarm(id);
  }

  // Update farm in database
  Future<bool> updateFarm(Farm farm) async {
    try {
      await _databaseHelper.updateFarm(farm);
      return true;
    } catch (e) {
      debugPrint('Error updating farm: $e');
      return false;
    }
  }

  // Delete farm from database
  Future<bool> deleteFarm(int id) async {
    try {
      await _databaseHelper.deleteFarm(id);
      return true;
    } catch (e) {
      debugPrint('Error deleting farm: $e');
      return false;
    }
  }

  // ==================================================================================
  // VALIDATION
  // ==================================================================================

  bool _validateForm() {
    // Basic validation
    if (farmSizeController.text.isEmpty) {
      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(
          addFarmScreenContext,
        ).showSnackBar(const SnackBar(content: Text('Farm size is required')));
      }
      return false;
    }

    if (latitudeController.text.isEmpty || longitudeController.text.isEmpty) {
      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          const SnackBar(content: Text('GPS coordinates are required')),
        );
      }
      return false;
    }

    if (cropTypeController.text.isEmpty) {
      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(
          addFarmScreenContext,
        ).showSnackBar(const SnackBar(content: Text('Crop type is required')));
      }
      return false;
    }

    return true;
  }

  // ==================================================================================
  // LOCATION SERVICES
  // ==================================================================================

  /// Retrieves the device's current geographic location with comprehensive error handling.
  getCurrentLocation() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        return;
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      return;
    }

    gl.Position position = await gl.Geolocator.getCurrentPosition(
      desiredAccuracy: gl.LocationAccuracy.best,
    );

    locationData = LocationData.fromMap({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
    });
  }

  // ==================================================================================
  // GEOMETRIC CALCULATIONS
  // ==================================================================================

  bool isPointInCircle(LatLng point, LatLng center, double radius) {
    double distance = gl.Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      center.latitude,
      center.longitude,
    );
    return distance <= radius;
  }

  bool isLineSegmentIntersectingCircle(
    LatLng p1,
    LatLng p2,
    LatLng center,
    double radius,
  ) {
    // Quick check: if either endpoint is inside circle, intersection exists
    double distP1 = gl.Geolocator.distanceBetween(
      p1.latitude,
      p1.longitude,
      center.latitude,
      center.longitude,
    );
    double distP2 = gl.Geolocator.distanceBetween(
      p2.latitude,
      p2.longitude,
      center.latitude,
      center.longitude,
    );

    if (distP1 <= radius || distP2 <= radius) {
      return true;
    }

    // Use quadratic formula to find intersection points
    double dx = p2.latitude - p1.latitude;
    double dy = p2.longitude - p1.longitude;

    // Coefficients for quadratic equation
    double a = dx * dx + dy * dy;
    double b =
        2 *
        (dx * (p1.latitude - center.latitude) +
            dy * (p1.longitude - center.longitude));
    double c =
        (p1.latitude - center.latitude) * (p1.latitude - center.latitude) +
        (p1.longitude - center.longitude) * (p1.longitude - center.longitude) -
        radius * radius;

    double discriminant = b * b - 4 * a * c;

    // No intersection if discriminant is negative
    if (discriminant < 0) {
      return false;
    }

    discriminant = sqrt(discriminant);

    // Calculate intersection parameters
    double t1 = (-b - discriminant) / (2 * a);
    double t2 = (-b + discriminant) / (2 * a);

    // Check if intersection points are within the line segment
    return (t1 >= 0 && t1 <= 1) || (t2 >= 0 && t2 <= 1);
  }

  // ==================================================================================
  // POLYGON DRAWING INTERFACE
  // ==================================================================================

  usePolygonDrawingTool(BuildContext context) {
    Set<Polygon> polys = HashSet<Polygon>();
    if (polygon != null) polys.add(polygon!);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PolygonDrawingTool(
          layers: polys,
          initialPolygon: polygon,
          viewInitialPolygon: polygon != null,
          useBackgroundLayers: false,
          allowTappingInputMethod: false,
          allowTracingInputMethod: false,
          maxAccuracy: MaximumAccuracy.max,
          persistMaxAccuracy: true,
          onSave: (poly, mkr, area) {
            if (mkr.isNotEmpty) {
              polygon = poly;
              markers = mkr;
              farmSizeController.text = area
                  .truncateToDecimalPlaces(6)
                  .toString();
              notifyListeners();

              Globals().showOkayDialog(
                context: addFarmScreenContext,
                title: 'Measurement Result',
                image: 'assets/img/ruler-combined.png',
                content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Farm size in hectares',
                        style: TextStyle(
                          color: Theme.of(
                            addFarmScreenContext,
                          ).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '${area.truncateToDecimalPlaces(6).toString()} ha',
                        style: TextStyle(
                          color: Theme.of(
                            addFarmScreenContext,
                          ).colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ==================================================================================
  // UTILITY METHODS
  // ==================================================================================

  /// Clears all form fields
  void clearForm() {
    farmLocationController.clear();
    farmSizeController.clear();
    visitIdController.clear();
    dateOfVisitController.clear();
    mainBuyersController.clear();
    farmBoundaryPolygonController.clear();
    landUseClassificationController.clear();
    accessibilityController.clear();
    proximityToProcessingFacilityController.clear();
    serviceProviderController.clear();
    cooperativesOrFarmerGroupsController.clear();
    valueChainLinkagesController.clear();
    officerNameController.clear();
    officerIdController.clear();
    observationsController.clear();
    issuesIdentifiedController.clear();
    infrastructureIdentifiedController.clear();
    recommendedActionsController.clear();
    followUpStatusController.clear();

    // Clear new fields
    latitudeController.clear();
    longitudeController.clear();
    cropTypeController.clear();
    varietyBreedController.clear();
    plantingDensityController.clear();
    labourHiredController.clear();
    maleWorkersController.clear();
    femaleWorkersController.clear();
    estimatedYieldController.clear();
    previousYieldController.clear();

    // Clear dates
    _harvestDate = null;
    _plantingDate = null;
    _visitDate = null;
    _hasFarmBoundaryPolygon = false;
    _selectedFarmer = null;


    // Clear polygon
    polygon = null;
    markers = null;

    notifyListeners();
  }

  /// Validates if all required fields are filled
  bool isFormValid() {
    return farmSizeController.text.isNotEmpty &&
        latitudeController.text.isNotEmpty &&
        longitudeController.text.isNotEmpty &&
        cropTypeController.text.isNotEmpty;
  }

  /// Gets a summary of the farm data for preview
  Map<String, dynamic> getFarmSummary() {
    return {
      'farmSize': farmSizeController.text,
      'cropType': cropTypeController.text,
      'coordinates': '${latitudeController.text}, ${longitudeController.text}',
      'plantingDate': _plantingDate?.toString(),
      'harvestDate': _harvestDate?.toString(),
      'hasBoundary': _hasFarmBoundaryPolygon,
    };
  }
}

class MaximumAccuracy {
  static const double max = 10;
  static const double min = 1;
}
