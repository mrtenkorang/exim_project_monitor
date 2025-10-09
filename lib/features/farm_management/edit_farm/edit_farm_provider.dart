// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, avoid_print
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/polygon_drawing_tool.dart';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/utils/double_value_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as gl;

import '../../../core/models/farm_model.dart';
import '../../../core/models/server_models/farmers_model/farmers_from_server.dart';
import '../../../core/services/database/database_helper.dart';
import '../../../widgets/globals/globals.dart';

/// Provider class for managing farm editing operations
/// Handles location services, polygon drawing, farm validation, and data persistence
class EditFarmProvider with ChangeNotifier {
  // ==================================================================================
  // PROPERTIES & DEPENDENCIES
  // ==================================================================================

  /// Build context for the edit farm screen - used for dialogs and navigation
  late BuildContext addFarmScreenContext;

  final _databaseHelper = DatabaseHelper();

  // Date fields
  DateTime? _harvestDate;
  DateTime? _plantingDate;
  DateTime? _dateOfVisit;

  DateTime? get harvestDate => _harvestDate;
  DateTime? get plantingDate => _plantingDate;
  DateTime? get dateOfVisit => _dateOfVisit;

  void setHarvestDate(DateTime? date) {
    _harvestDate = date;
    notifyListeners();
  }

  void setPlantingDate(DateTime? date) {
    _plantingDate = date;
    notifyListeners();
  }

  void setDateOfVisit(DateTime? date) {
    _dateOfVisit = date;
    notifyListeners();
  }

  // Farm boundary toggle
  bool _hasFarmBoundaryPolygon = false;
  bool get hasFarmBoundaryPolygon => _hasFarmBoundaryPolygon;

  void setFarmBoundaryPolygon(bool value) {
    _hasFarmBoundaryPolygon = value;
    notifyListeners();
  }

  List<FarmerFromServerModel> _farmersFromServer = [];
  FarmerFromServerModel? _selectedFarmer;
  bool _loadingFarmers = false;
  String? _farmerLoadError;

  List<FarmerFromServerModel> get farmersFromServer => _farmersFromServer;
  FarmerFromServerModel? get selectedFarmer => _selectedFarmer;
  bool get loadingFarmers => _loadingFarmers;
  String? get farmerLoadError => _farmerLoadError;

  /// Load farmers from local database (farmers from server model)
  // Future<void> loadFarmers() async {
  //   _loadingFarmers = true;
  //   _farmerLoadError = null;
  //   notifyListeners();
  //
  //   try {
  //     // Load farmers from server model stored in local database
  //     _farmersFromServer = await _databaseHelper.getAllFarmersFromServerWithRelations();
  //
  //     debugPrint('Loaded ${_farmersFromServer.length} farmers from local database');
  //
  //     _loadingFarmers = false;
  //     notifyListeners();
  //   } catch (e, stackTrace) {
  //     debugPrint('Error loading farmers from server: $e');
  //     debugPrint('Stack trace: $stackTrace');
  //     _loadingFarmers = false;
  //     _farmerLoadError = 'Failed to load farmers';
  //     notifyListeners();
  //   }
  // }

  Future<void> getFarmerById() async {
    farmer = await DatabaseHelper().getFarmerFromServerById(_selectedFarmer!.id);

    notifyListeners();
  }
  /// Set the selected farmer
  setSelectedFarmer(FarmerFromServerModel? farmer) {
    _selectedFarmer = farmer;
    notifyListeners();
  }

  /// Clear selected farmer
  void clearSelectedFarmer() {
    _selectedFarmer = null;
    notifyListeners();
  }

  // ==================================================================================
  // CONTROLLERS FOR ALL FIELDS
  // ==================================================================================

  // Basic Information
  final TextEditingController farmLocationController = TextEditingController();
  final TextEditingController projectIdController = TextEditingController();
  final TextEditingController farmSizeController = TextEditingController();
  final TextEditingController visitIdController = TextEditingController();
  final TextEditingController dateOfVisitController = TextEditingController();

  // GPS Coordinates
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // Crop Information
  final TextEditingController cropTypeController = TextEditingController();
  final TextEditingController varietyBreedController = TextEditingController();
  final TextEditingController plantingDensityController = TextEditingController();

  // Labour Information
  final TextEditingController labourHiredController = TextEditingController();
  final TextEditingController maleWorkersController = TextEditingController();
  final TextEditingController femaleWorkersController = TextEditingController();

  // Yield Information
  final TextEditingController estimatedYieldController = TextEditingController();
  final TextEditingController previousYieldController = TextEditingController();

  // Secondary Data
  final TextEditingController mainBuyersController = TextEditingController();
  final TextEditingController farmBoundaryPolygonController = TextEditingController();
  final TextEditingController landUseClassificationController = TextEditingController();
  final TextEditingController accessibilityController = TextEditingController();
  final TextEditingController proximityToProcessingFacilityController = TextEditingController();
  final TextEditingController serviceProviderController = TextEditingController();
  final TextEditingController cooperativesOrFarmerGroupsController = TextEditingController();
  final TextEditingController valueChainLinkagesController = TextEditingController();

  // Officer Information
  final TextEditingController officerNameController = TextEditingController();
  final TextEditingController officerIdController = TextEditingController();

  // Assessment
  final TextEditingController observationsController = TextEditingController();
  final TextEditingController issuesIdentifiedController = TextEditingController();
  final TextEditingController infrastructureIdentifiedController = TextEditingController();
  final TextEditingController recommendedActionsController = TextEditingController();
  final TextEditingController followUpStatusController = TextEditingController();

  String? _selectedProjectID;
  String? get selectedProjectID => _selectedProjectID;

  final List<String> projectIDs = ["Project 1", "Project 2", "Project 3"];

  void setSelectedProject(String? val) {
    _selectedProjectID = val;
    projectIdController.text = val ?? '';
    notifyListeners();
  }

  int? _farmId;
  int? get farmId => _farmId;

  FarmerFromServerModel? farmer;

  Future<void> initFarmData(Farm farm) async {
    try {
      await setSelectedFarmer(farmer);
      // Load farmers first
      await getFarmerById();

      _farmId = farm.id;
      // Set the project ID and update the selected project
      projectIdController.text = farm.projectId;
      _selectedProjectID = farm.projectId;

      // Parse dates from the farm object
      if (farm.dateOfVisit.isNotEmpty) {
        try {
          _dateOfVisit = DateTime.parse(farm.dateOfVisit);
          dateOfVisitController.text = "${_dateOfVisit!.year}-${_dateOfVisit!.month.toString().padLeft(2, '0')}-${_dateOfVisit!.day.toString().padLeft(2, '0')}";
        } catch (e) {
          debugPrint('Error parsing visit date: $e');
          dateOfVisitController.text = farm.dateOfVisit;
          _dateOfVisit = null;
        }
      } else {
        _dateOfVisit = null;
      }

      // Parse planting date
      if (farm.plantingDate.isNotEmpty) {
        try {
          _plantingDate = DateTime.parse(farm.plantingDate);
        } catch (e) {
          debugPrint('Error parsing planting date: $e');
          _plantingDate = null;
        }
      } else {
        _plantingDate = null;
      }

      // Parse harvest date
      if (farm.harvestDate.isNotEmpty) {
        try {
          _harvestDate = DateTime.parse(farm.harvestDate);
        } catch (e) {
          debugPrint('Error parsing harvest date: $e');
          _harvestDate = null;
        }
      } else {
        _harvestDate = null;
      }

      // Set GPS coordinates
      latitudeController.text = farm.latitude.toString();
      longitudeController.text = farm.longitude.toString();

      // Set crop information
      cropTypeController.text = farm.cropType;
      varietyBreedController.text = farm.varietyBreed;
      plantingDensityController.text = farm.plantingDensity;

      // Set labour information
      labourHiredController.text = farm.labourHired.toString();
      maleWorkersController.text = farm.maleWorkers.toString();
      femaleWorkersController.text = farm.femaleWorkers.toString();

      // Set yield information
      estimatedYieldController.text = farm.estimatedYield;
      previousYieldController.text = farm.previousYield;

      // Set other fields
      farmLocationController.text = farm.location;
      farmSizeController.text = farm.farmSize;
      visitIdController.text = farm.visitId;
      mainBuyersController.text = farm.mainBuyers;
      landUseClassificationController.text = farm.landUseClassification;
      accessibilityController.text = farm.accessibility;
      proximityToProcessingFacilityController.text = farm.proximityToProcessingFacility;
      serviceProviderController.text = farm.serviceProvider;
      cooperativesOrFarmerGroupsController.text = farm.cooperativesOrFarmerGroups;
      valueChainLinkagesController.text = farm.valueChainLinkages;
      officerNameController.text = farm.officerName;
      officerIdController.text = farm.officerId;
      observationsController.text = farm.observations;
      issuesIdentifiedController.text = farm.issuesIdentified;
      infrastructureIdentifiedController.text = farm.infrastructureIdentified;
      recommendedActionsController.text = farm.recommendedActions;
      followUpStatusController.text = farm.followUpStatus;

      // Set farm boundary polygon status
      _hasFarmBoundaryPolygon = farm.hasBoundaryPolygon;


      
      // Set the selected farmer based on farmerId
      if (farm.farmerId != null && farm.farmerId != 0) {
        try {
          _selectedFarmer = _farmersFromServer.firstWhere(
            (farmer) => farmer.id == farm.farmerId,
          );
          debugPrint('Selected farmer: ${_selectedFarmer?.firstName} ${_selectedFarmer?.lastName}');
        } catch (e) {
          debugPrint('Farmer with ID ${farm.farmerId} not found in local database');
          _selectedFarmer = null;
        }
      }

      // Notify listeners to update the UI with the new data
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing farm data: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    farmLocationController.dispose();
    projectIdController.dispose();
    farmSizeController.dispose();
    visitIdController.dispose();
    dateOfVisitController.dispose();
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
  // INITIALIZATION & LIFECYCLE
  // ==================================================================================

  /// Initialize the provider with required context
  Future<void> initialize(BuildContext context) async {
    addFarmScreenContext = context;

    // Get current location first - critical for loading nearby farms
    await getCurrentLocation();

    // Show loading indicator while fetching farm data
    Globals().startWait(addFarmScreenContext);

    // Load existing farms in the area for overlap detection
    // await loadFarms(locationData!);

    // Hide loading indicator
    Globals().endWait(addFarmScreenContext);
  }

  /// Saves the farm data to the local database
  Future<bool> saveFarm() async {
    debugPrint('Saving farm...');
    if (!_validateForm()) return false;

    debugPrint('Form is valid. Saving farm...');
    try {
      // If polygon exists, close it by adding the first point
      if (polygon != null) {
        polygon!.points.add(polygon!.points.first);
      }

      // Convert polygon to coordinate format if exists
      Uint8List? boundaryPolygon;
      if (polygon != null && polygon!.points.isNotEmpty) {
        var boundaryCoordinates = polygon!.points
            .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
            .toList();
        boundaryPolygon = Uint8List.fromList(utf8.encode(jsonEncode(boundaryCoordinates)));
      }

      final farm = Farm(
        id: _farmId,
        farmerId: selectedFarmer?.id,
        projectId: projectIdController.text.trim(),
        visitId: visitIdController.text.trim(),
        dateOfVisit: _dateOfVisit?.toIso8601String() ?? '',
        mainBuyers: mainBuyersController.text.trim(),
        farmBoundaryPolygon: boundaryPolygon,
        landUseClassification: landUseClassificationController.text.trim(),
        accessibility: accessibilityController.text.trim(),
        proximityToProcessingFacility: proximityToProcessingFacilityController.text.trim(),
        serviceProvider: serviceProviderController.text.trim(),
        cooperativesOrFarmerGroups: cooperativesOrFarmerGroupsController.text.trim(),
        valueChainLinkages: valueChainLinkagesController.text.trim(),
        officerName: officerNameController.text.trim(),
        officerId: officerIdController.text.trim(),
        observations: observationsController.text.trim(),
        issuesIdentified: issuesIdentifiedController.text.trim(),
        infrastructureIdentified: infrastructureIdentifiedController.text.trim(),
        recommendedActions: recommendedActionsController.text.trim(),
        followUpStatus: followUpStatusController.text.trim(),
        farmSize: farmSizeController.text.trim(),
        location: farmLocationController.text.trim(),
        isSynced: false, // Mark as not synced since it's updated
        updatedAt: DateTime.now(),

        // New fields
        latitude: double.tryParse(latitudeController.text) ?? 0.0,
        longitude: double.tryParse(longitudeController.text) ?? 0.0,
        cropType: cropTypeController.text.trim(),
        varietyBreed: varietyBreedController.text.trim(),
        plantingDate: _plantingDate?.toIso8601String() ?? '',
        plantingDensity: plantingDensityController.text.trim(),
        labourHired: int.tryParse(labourHiredController.text) ?? 0,
        maleWorkers: int.tryParse(maleWorkersController.text) ?? 0,
        femaleWorkers: int.tryParse(femaleWorkersController.text) ?? 0,
        estimatedYield: estimatedYieldController.text.trim(),
        previousYield: previousYieldController.text.trim(),
        harvestDate: _harvestDate?.toIso8601String() ?? '',
      );

      debugPrint('Updating farm with ID: ${farm.id}');

      // Update the farm in the database
      final id = await _databaseHelper.updateFarm(farm);

      if (id>=0) {
        debugPrint('Farm updated successfully');

        // Show success message
        if (addFarmScreenContext.mounted) {
          ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
            const SnackBar(content: Text('Farm updated successfully')),
          );

          // Navigate back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (addFarmScreenContext.mounted) {
              Navigator.of(addFarmScreenContext).pop(true); // Return success
            }
          });
        }
        return true;
      } else {
        throw Exception('Failed to update farm in database');
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating farm: $e');
      debugPrint('Stack trace: $stackTrace');

      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          SnackBar(content: Text('Error updating farm: ${e.toString()}')),
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

  /// Submits the farm data to the server
  Future<bool> submitFarm() async {
    // First save locally
    final saved = await saveFarm();
    if (!saved) return false;

    try {
      // TODO: Implement actual server submission logic here
      // For now, we'll just simulate a successful submission
      await Future.delayed(const Duration(seconds: 1));

      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          const SnackBar(content: Text('Farm submitted successfully')),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error submitting farm: $e');
      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
            SnackBar(content: Text('Error submitting farm: $e')));
      }
      return false;
    }
  }

  bool _validateForm() {
    // Basic validation - you can add more specific validation as needed
    if (projectIdController.text.isEmpty) {
      ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
        const SnackBar(content: Text('Project ID is required')),
      );
      return false;
    }

    if (visitIdController.text.isEmpty) {
      ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
        const SnackBar(content: Text('Visit ID is required')),
      );
      return false;
    }

    if (farmSizeController.text.isEmpty) {
      ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
        const SnackBar(content: Text('Farm size is required')),
      );
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
                          color: Theme.of(addFarmScreenContext).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '${area.truncateToDecimalPlaces(6).toString()} ha',
                        style: TextStyle(
                          color: Theme.of(addFarmScreenContext).colorScheme.onSurface,
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
}

class MaximumAccuracy {
  static const double max = 10;
  static const double min = 1;
}