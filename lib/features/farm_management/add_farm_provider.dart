// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, avoid_print
import 'dart:collection';
import 'dart:math';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/polygon_drawing_tool.dart';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/utils/double_value_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
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

  final List<Map<String, dynamic>> regions = [
    {"region_id": "1", "region": "Greater Accra"},
    {"region_id": "2", "region": "Eastern Region"},
    {"region_id": "3", "region": "Brong Ahafo"},
    {"region_id": "4", "region": "Ashanti"},
    {"region_id": "5", "region": "Western"},
    {"region_id": "6", "region": "Northern"},
  ];

  final List<Map<String, dynamic>> districts = [
    {"region_id": "1", "district_id": "1", "district": "Accra Metro"},
    {"region_id": "1", "district_id": "2", "district": "Tema Metro"},
    {"region_id": "2", "district_id": "3", "district": "East Akim"},
    {"region_id": "2", "district_id": "4", "district": "West Akim"},
    {"region_id": "3", "district_id": "5", "district": "Sunyani"},
    {"region_id": "3", "district_id": "6", "district": "Techiman"},
    {"region_id": "4", "district_id": "7", "district": "Kumasi Metro"},
    {"region_id": "4", "district_id": "8", "district": "Obuasi"},
    {"region_id": "5", "district_id": "9", "district": "Takoradi"},
    {"region_id": "5", "district_id": "10", "district": "Sekondi"},
    {"region_id": "6", "district_id": "11", "district": "Tamale Metro"},
    {"region_id": "6", "district_id": "12", "district": "Savelugu"},
  ];

  // Controllers
  final TextEditingController farmLocationController = TextEditingController();
  final TextEditingController cropTypeController = TextEditingController();
  final TextEditingController varietyBreedController = TextEditingController();
  final TextEditingController plantingDensityController = TextEditingController();
  final TextEditingController farmInputsReceivedController = TextEditingController();
  final TextEditingController inputsQuantityController = TextEditingController();
  final TextEditingController laborHiredController = TextEditingController();
  final TextEditingController estimatedYieldController = TextEditingController();
  final TextEditingController actualYieldController = TextEditingController();
  final TextEditingController farmSizeController = TextEditingController();

  // Selected values
  String? _selectedRegionId;
  String? _selectedDistrictId;
  DateTime? _plantingDate;
  DateTime? _harvestDate;

  // Getters
  String? get selectedRegionId => _selectedRegionId;
  String? get selectedDistrictId => _selectedDistrictId;
  DateTime? get plantingDate => _plantingDate;
  DateTime? get harvestDate => _harvestDate;

  // Setters
  void setSelectedRegion(String? regionId) {
    _selectedRegionId = regionId;
    _selectedDistrictId = null; // Reset district when region changes
    notifyListeners();
  }

  void setSelectedDistrict(String? districtId) {
    _selectedDistrictId = districtId;
    notifyListeners();
  }

  void setPlantingDate(DateTime? date) {
    _plantingDate = date;
    notifyListeners();
  }

  void setHarvestDate(DateTime? date) {
    _harvestDate = date;
    notifyListeners();
  }

  // Get filtered districts based on selected region
  List<Map<String, dynamic>> getFilteredDistricts() {
    if (_selectedRegionId == null) return [];
    return districts.where((district) => district['region_id'] == _selectedRegionId).toList();
  }

  @override
  void dispose() {
    farmLocationController.dispose();
    cropTypeController.dispose();
    varietyBreedController.dispose();
    plantingDensityController.dispose();
    farmInputsReceivedController.dispose();
    inputsQuantityController.dispose();
    laborHiredController.dispose();
    estimatedYieldController.dispose();
    actualYieldController.dispose();
    super.dispose();
  }

  /// Form key for validation of the add farm form
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

  /// Text controller for COCOBOD ID input field
  TextEditingController? cocobodIDController = TextEditingController(text: "");

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


  void saveFarm() {
    // TODO: Implement save functionality
    if (_validateForm()) {
      // Save farm data locally
      ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
        const SnackBar(content: Text('Farm saved successfully')),
      );
    }
  }

  void submitFarm() {
    // TODO: Implement submit functionality
    if (_validateForm()) {
      // Submit farm data to server
      ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
        const SnackBar(content: Text('Farm submitted successfully')),
      );
    }
  }

  bool _validateForm() {
    if (selectedRegionId == null) {
      ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
        const SnackBar(content: Text('Please select a region')),
      );
      return false;
    }

    if (selectedDistrictId == null) {
      ScaffoldMessenger.of(addFarmScreenContext).showSnackBar(
        const SnackBar(content: Text('Please select a district')),
      );
      return false;
    }

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
        desiredAccuracy: gl.LocationAccuracy.best);

    locationData = LocationData.fromMap({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy
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
      LatLng p1, LatLng p2, LatLng center, double radius) {
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
    double b = 2 *
        (dx * (p1.latitude - center.latitude) +
            dy * (p1.longitude - center.longitude));
    double c = (p1.latitude - center.latitude) *
        (p1.latitude - center.latitude) +
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
              farmSizeController.text = area.truncateToDecimalPlaces(6).toString();
              notifyListeners();

              Globals().showOkayDialog(
                context: addFarmScreenContext,
                title: 'Measurement Result',
                image: 'assets/images/cocoa_monitor/ruler-combined.png',
                content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Farm size in hectares',
                        style: TextStyle(color: Theme.of(addFarmScreenContext).colorScheme.onSurface),
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