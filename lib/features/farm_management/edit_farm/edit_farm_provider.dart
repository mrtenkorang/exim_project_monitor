// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, avoid_print
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/polygon_drawing_tool.dart';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/utils/double_value_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as gl;

import '../../../core/models/farm_model.dart';
import '../../../core/services/database/database_helper.dart';
import '../../../widgets/globals/globals.dart';

/// Provider class for managing farm addition operations
/// Handles location services, polygon drawing, farm validation, and data persistence
class EditFarmProvider with ChangeNotifier {
  // Database instance
  // ==================================================================================
  // PROPERTIES & DEPENDENCIES
  // ==================================================================================

  /// Build context for the add farm screen - used for dialogs and navigation
  late BuildContext addFarmScreenContext;

  final _databaseHelper = DatabaseHelper();
  DateTime? _harvestDate;

  DateTime? get harvestDate => _harvestDate;

  void setHarvestDate(DateTime? date) {
    _harvestDate = date;
    notifyListeners();
  }

  // Controllers
  final TextEditingController farmLocationController = TextEditingController();
  final TextEditingController projectIdController = TextEditingController();
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

  String? _selectedProjectID;
  String? get selectedProjectID => _selectedProjectID;

  final List<String> projectIDs = ["Project 1", "Project 2", "Project 3"];

  /// Form key for validation of the add farm form
  ///
  void setSelectedProject(String? val) {
    _selectedProjectID = val;
    projectIdController.text = val ?? '';
    notifyListeners();
  }

  void initFarmData(Farm farm) {
    try {
      // Set the project ID and update the selected project
      projectIdController.text = farm.projectId ?? '';
      _selectedProjectID = farm.projectId;
      
      // Parse the date from the farm object
      if (farm.dateOfVisit.isNotEmpty) {
        try {
          _harvestDate = DateTime.parse(farm.dateOfVisit);
          // Format the date to match what the DateField expects (YYYY-MM-DD)
          dateOfVisitController.text = "${_harvestDate!.year}-${_harvestDate!.month.toString().padLeft(2, '0')}-${_harvestDate!.day.toString().padLeft(2, '0')}";
        } catch (e) {
          debugPrint('Error parsing date: $e');
          dateOfVisitController.text = farm.dateOfVisit; // Fallback to raw string if parsing fails
          _harvestDate = null; // Reset harvest date if parsing fails
        }
      } else {
        _harvestDate = null; // Reset if no date is provided
      }
      
      // Set other fields
      farmLocationController.text = farm.location ?? '';
      farmSizeController.text = farm.farmSize ?? '';
      visitIdController.text = farm.visitId ?? '';
      mainBuyersController.text = farm.mainBuyers ?? '';
      farmBoundaryPolygonController.text = farm.farmBoundaryPolygon ?? '';
      landUseClassificationController.text = farm.landUseClassification ?? '';
      accessibilityController.text = farm.accessibility ?? '';
      proximityToProcessingFacilityController.text = farm.proximityToProcessingFacility ?? '';
      serviceProviderController.text = farm.serviceProvider ?? '';
      cooperativesOrFarmerGroupsController.text = farm.cooperativesOrFarmerGroups ?? '';
      valueChainLinkagesController.text = farm.valueChainLinkages ?? '';
      officerNameController.text = farm.officerName ?? '';
      officerIdController.text = farm.officerId ?? '';
      observationsController.text = farm.observations ?? '';
      issuesIdentifiedController.text = farm.issuesIdentified ?? '';
      infrastructureIdentifiedController.text = farm.infrastructureIdentified ?? '';
      recommendedActionsController.text = farm.recommendedActions ?? '';
      followUpStatusController.text = farm.followUpStatus ?? '';
      
      // Notify listeners to update the UI with the new data
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing farm data: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    farmLocationController.dispose();
    projectIdController.dispose();
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
    super.dispose();
  }

  final addFarmFormKey = GlobalKey<FormState>();

  // Services
  // Globals globals = Globals();
  // FarmerApiInterface farmerApiInterface = FarmerApiInterface();
  // GeneralCocoaRehabApiInterface generalCocoaRehabApiInterface =
  // GeneralCocoaRehabApiInterface();

  /// Date formatter for consistent date formatting across the app
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
  // DATA MODELS
  // ==================================================================================

  /// Society information for the farm being added
  // Society? society = Society();
  //
  // /// Farmer information retrieved from server
  // FarmerFromServer? farmerFromServer = FarmerFromServer();
  //
  // /// Currently selected farm from assigned farms list
  // AssignedFarm? _selectedFarm = AssignedFarm();
  // AssignedFarm? get selectedFarm => _selectedFarm;
  // set selectedFarm(AssignedFarm? value) {
  //   _selectedFarm = value;
  //   notifyListeners();
  // }

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
      // Get polygon data from the controller or use empty array if not set
      String polygonData = farmBoundaryPolygonController.text.trim();
      if (polygonData.isEmpty) {
        polygonData = '[]'; // Default to empty array if no polygon data
      }

      final farm = Farm(
        projectId: projectIdController.text.trim(),
        visitId: visitIdController.text.trim(),
        dateOfVisit: _harvestDate.toString(),
        mainBuyers: mainBuyersController.text.trim(),
        farmBoundaryPolygon: polygonData,
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
        officerId: officerIdController.text.trim(),
        observations: observationsController.text.trim(),
        issuesIdentified: issuesIdentifiedController.text.trim(),
        infrastructureIdentified: infrastructureIdentifiedController.text
            .trim(),
        recommendedActions: recommendedActionsController.text.trim(),
        followUpStatus: followUpStatusController.text.trim(),
        farmSize: farmSizeController.text.trim(),
        location: farmLocationController.text.trim(),
        isSynced: true,
      );

      debugPrint('Saving farm with polygon data: ${farm.farmBoundaryPolygon}');

      // Insert the farm into the database
      final id = await _databaseHelper.insertFarm(farm);
      debugPrint('Farm saved with ID: $id');

      // Show success message
      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          const SnackBar(content: Text('Farm saved successfully')),
        );

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

      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          SnackBar(content: Text('Error saving farm: ${e.toString()}')),
        );
      }

      return false;
    }
  }

  /// Saves the farm data to the local database and syncs with the server if online
  Future<bool> saveFarmToDatabase() async {
    debugPrint('Saving farm to database...');
    if (!_validateForm()) {
      debugPrint('Form validation failed');
      if (addFarmScreenContext.mounted) {
        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
      }
      return false;
    }

    try {
      // Show loading indicator
      if (addFarmScreenContext.mounted) {
        Globals().startWait(addFarmScreenContext);
      }

      // Get polygon data from the controller or use empty array if not set
      String polygonData = farmBoundaryPolygonController.text.trim();
      if (polygonData.isEmpty) {
        polygonData = '[]'; // Default to empty array if no polygon data
      }

      debugPrint('Creating farm object with polygon data...');
      final farm = Farm(
        projectId: projectIdController.text.trim(),
        visitId: visitIdController.text.trim(),
        dateOfVisit: _harvestDate.toString(),
        mainBuyers: mainBuyersController.text.trim(),
        farmBoundaryPolygon: polygonData,
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
        officerId: officerIdController.text.trim(),
        observations: observationsController.text.trim(),
        issuesIdentified: issuesIdentifiedController.text.trim(),
        infrastructureIdentified: infrastructureIdentifiedController.text
            .trim(),
        recommendedActions: recommendedActionsController.text.trim(),
        followUpStatus: followUpStatusController.text.trim(),
        farmSize: farmSizeController.text.trim(),
        location: farmLocationController.text.trim(),
        isSynced: false,
      );

      debugPrint('Saving farm with polygon data: ${farm.farmBoundaryPolygon}');

      // Save to local database
      final id = await _databaseHelper.insertFarm(farm);
      debugPrint('Farm saved with ID: $id');

      // TODO: Add server sync logic here when online

      // Show success message
      if (addFarmScreenContext.mounted) {
        Globals().endWait(addFarmScreenContext);

        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          const SnackBar(content: Text('Farm saved successfully')),
        );

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

      if (addFarmScreenContext.mounted) {
        Globals().endWait(addFarmScreenContext);

        ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
          SnackBar(content: Text('Error saving farm: ${e.toString()}')),
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
        ScaffoldMessenger.of(
          addFarmScreenContext,
        ).showSnackBar(SnackBar(content: Text('Error submitting farm: $e')));
      }
      return false;
    }
  }

  bool _validateForm() {
    // Add more validation as needed

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
  // FARM DATA LOADING & PROCESSING
  // ==================================================================================

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
// FARM SUBMISSION OPERATIONS
// ==================================================================================

// handleAddFarm() async {
//   final globalProvider = Provider.of<GlobalProvider>(addFarmScreenContext, listen: false);
//   final homeProvider = Provider.of<HomeProvider>(addFarmScreenContext, listen: false);
//
//   polygon!.points.add(polygon!.points.first);
//
//   var boundaryCoordinates = polygon!.points
//       .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
//       .toList();
//
//   globals.startWait(addFarmScreenContext);
//
//   try {
//     DateTime now = DateTime.now();
//     String formattedReportingDate = DateFormat('yyyy-MM-dd').format(now);
//
//     Farm farmData = Farm(
//       uid: const Uuid().v4(),
//       agent: globalProvider.userInfo.value.userId!,
//       cocobod_id: cocobodIDController?.text.trim(),
//       farmboundary:
//       Uint8List.fromList(utf8.encode(jsonEncode(boundaryCoordinates))),
//       farmer: farmerFromServer!.farmerId,
//       farmArea: double.parse(farmAreaTC!.text.trim()),
//       registrationDate: formattedReportingDate,
//       status: SubmissionStatus.submitted,
//       societyCode: society?.societyCode,
//     );
//
//     Map<String, dynamic> data = farmData.toJson();
//     data.remove('status');
//     data.remove('societyCode');
//
//     debugPrint("FARM DATA :::::: ${data.toString()}");
//
//     var postResult = await farmerApiInterface.saveFarm(farmData, data);
//
//     if (postResult['status'] == RequestStatus.True ||
//         postResult['status'] == RequestStatus.Exist ||
//         postResult['status'] == RequestStatus.NoInternet) {
//       await generalCocoaRehabApiInterface.loadAssignedFarms();
//
//       globals.endWait(addFarmScreenContext);
//       Navigator.of(addFarmScreenContext).pop();
//
//       globals.showSecondaryDialog(
//         context: homeProvider.homeScreenContext,
//         content: Text(
//           postResult['msg'],
//           style: const TextStyle(fontSize: 13),
//           textAlign: TextAlign.center,
//         ),
//         status: AlertDialogStatus.success,
//         okayTap: () => Navigator.of(homeProvider.homeScreenContext).pop(),
//       );
//     } else if (postResult['status'] == RequestStatus.False) {
//       globals.endWait(addFarmScreenContext);
//
//       globals.showSecondaryDialog(
//         context: addFarmScreenContext,
//         content: Text(
//           postResult['msg'],
//           style: const TextStyle(fontSize: 13),
//           textAlign: TextAlign.center,
//         ),
//         // status: AlertDialogStatus.error,
//       );
//     }
//   } catch (e) {
//     globals.endWait(addFarmScreenContext);
//     print("Error submitting farm: $e");
//
//     globals.showSecondaryDialog(
//       context: addFarmScreenContext,
//       content: const Text(
//         'An error occurred while submitting the farm. Please try again.',
//         style: TextStyle(fontSize: 13),
//         textAlign: TextAlign.center,
//       ),
//       // status: AlertDialogStatus.error,
//     );
//   }
// }

// ==================================================================================
// OFFLINE FARM STORAGE
// ==================================================================================

// handleSaveOfflineFarm() async {
//   final globalProvider = Provider.of<GlobalProvider>(addFarmScreenContext, listen: false);
//   final homeProvider = Provider.of<HomeProvider>(addFarmScreenContext, listen: false);
//
//   polygon!.points.add(polygon!.points.first);
//
//   var boundaryCoordinates = polygon!.points
//       .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
//       .toList();
//
//   globals.startWait(addFarmScreenContext);
//
//   try {
//     DateTime now = DateTime.now();
//     String formattedReportingDate = DateFormat('yyyy-MM-dd').format(now);
//
//     Farm farmData = Farm(
//       // uid: const Uuid().v4(),
//       // agent: globalProvider.userInfo.value.userId!,
//       // cocobod_id: cocobodIDController?.text.trim(),
//       // farmboundary:
//       // Uint8List.fromList(utf8.encode(jsonEncode(boundaryCoordinates))),
//       // farmer: farmerFromServer!.farmerId,
//       // farmArea: double.parse(farmAreaTC!.text.trim()),
//       // registrationDate: formattedReportingDate,
//       // status: SubmissionStatus.pending,
//       // societyCode: society?.societyCode,
//     );
//
//     Map<String, dynamic> data = farmData.toJson();
//     data.remove('status');
//     data.remove('societyCode');
//
//     final farmDao = globalProvider.database!.farmDao;
//     await farmDao.insertFarm(farmData);
//
//     globals.endWait(addFarmScreenContext);
//
//     Navigator.of(addFarmScreenContext).pop(result: {'farm': farmData, 'submitted': false});
//
//     globals.showSecondaryDialog(
//       context: homeProvider.homeScreenContext,
//       content: const Text(
//         'Farm Record saved',
//         style: TextStyle(fontSize: 13),
//         textAlign: TextAlign.center,
//       ),
//       // status: AlertDialogStatus.success,
//       okayTap: () => Navigator.of(homeProvider.homeScreenContext).pop(),
//     );
//   } catch (e) {
//     globals.endWait(addFarmScreenContext);
//     print("Error saving offline farm: $e");
//
//     globals.showSecondaryDialog(
//       context: addFarmScreenContext,
//       content: const Text(
//         'An error occurred while saving the farm. Please try again.',
//         style: TextStyle(fontSize: 13),
//         textAlign: TextAlign.center,
//       ),
//       status: AlertDialogStatus.error,
//     );
//   }
// }

// ==================================================================================
// CLEANUP
// ==================================================================================
}

class MaximumAccuracy {
  static const double max = 10;
  static const double min = 1;
}
