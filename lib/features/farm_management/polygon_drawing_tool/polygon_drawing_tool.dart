// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:exim_project_monitor/core/widgets/primary_button.dart';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/utils/capitalize_string.dart';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/utils/double_value_trimmer.dart';
import 'package:exim_project_monitor/features/farm_management/polygon_drawing_tool/utils/user_current_location.dart';
import 'package:exim_project_monitor/features/farmer_management/add_farmer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart' as gl;

import '../../../widgets/custom_button.dart';
import '../../../widgets/globals/globals.dart';
import '../../../widgets/round_icon_button.dart';
import '../add_farm_provider.dart';
import 'location_in_polygon_check.dart';

typedef DrawingSaveCallback =
    Function(Polygon polygon, Set<Marker> markers, double area);

class PolygonDrawingTool extends StatefulWidget {
  final DrawingSaveCallback onSave;
  final Set<Polygon> layers;
  final Polygon? initialPolygon;
  final bool? viewInitialPolygon;
  final bool? useBackgroundLayers;
  final LatLngBounds? currentBounds;
  final CameraPosition? cameraPosition;
  final bool? allowTappingInputMethod;
  final bool? allowTracingInputMethod;
  final bool? persistMaxAccuracy;
  final bool? viewOnlyMap;
  final double? maxAccuracy;
  const PolygonDrawingTool({
    Key? key,
    required this.onSave,
    required this.layers,
    required this.useBackgroundLayers,
    this.currentBounds,
    this.cameraPosition,
    this.allowTappingInputMethod = true,
    this.allowTracingInputMethod = true,
    this.initialPolygon,
    this.viewInitialPolygon = false,
    this.persistMaxAccuracy = false,
    this.maxAccuracy,
    this.viewOnlyMap = false,
  }) : super(key: key);

  @override
  State<PolygonDrawingTool> createState() => _PolygonDrawingToolState();
}

class _PolygonDrawingToolState extends State<PolygonDrawingTool>
    with WidgetsBindingObserver {
  GoogleMapController? mapController;

  // isIntersect(LatLng p1) async {
  //   final intersectsWithFarm = await GlobalController()
  //       .database!
  //       .toutonOldFarmsDao
  //       .isPointInAnyFarm(p1.latitude, p1.longitude);
  //
  //   if (intersectsWithFarm != null) {
  //     return true;
  //   }
  //   return false;
  // }

  Polygon? activePolygon;
  var isLastPolygon = false.obs;
  var isFirstPolygon = false.obs;

  // var selectedFarm = AssignedFarm().obs;

  LocationData? locationData;

  // final globalController = Get.put(GlobalController());

  String? polyID;

  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(7.9527706, -1.0307118),
    zoom: 8.0,
  );

  final GlobalKey _keyGPSStatusPanel = const GlobalObjectKey(
    "_keyGPSStatusPanel",
  );
  final GlobalKey _keyAddInputButton = const GlobalObjectKey(
    "_keyAddInputButton",
  );
  final GlobalKey _keyBackspaceButton = const GlobalObjectKey(
    "_keyBackspaceButton",
  );
  final GlobalKey _keyDeleteButton = const GlobalObjectKey("_keyDeleteButton");
  final GlobalKey _keyZoomToUserButton = const GlobalObjectKey(
    "_keyZoomToUserButton",
  );
  final GlobalKey _keySelectBasemapButton = const GlobalObjectKey(
    "_keySelectBasemapButton",
  );
  final GlobalKey _keySaveButton = const GlobalObjectKey("_keySaveButton");
  final GlobalKey _keyShowTutorialButton = const GlobalObjectKey(
    "_keyShowTutorialButton",
  );

  TextStyle coachMarkTextStyleLg = const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  TextStyle coachMarkTextStyleMd = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  Map selectedFeatureInfo = {};

  bool showSelectedFeatureInfo = false;

  Set<Marker> markers = HashSet<Marker>();

  Set<Polygon> polygons = HashSet<Polygon>();

  // Completer<GoogleMapController> gMapController = Completer();

  // Globals globals = Globals();

  String? _mapStyle;

  var inputMethod = InputMethod.tapping;

  bool? pickingPoints = false;

  bool? stopLocationStream = false;

  LocationData? currentPosition;

  UserCurrentLocation? userCurrentLocation;

  MapType mapType = MapType.normal;

  bool? locationIsEnabled;

  List<Map<String, Duration>> automaticPickerIntervals = [
    {"3 seconds": const Duration(seconds: 3)},
    {"6 seconds": const Duration(seconds: 6)},
    {"10 seconds": const Duration(seconds: 10)},
    {"15 seconds": const Duration(seconds: 15)},
    {"20 seconds": const Duration(seconds: 20)},
    {"30 seconds": const Duration(seconds: 30)},
    {"1 minute": const Duration(minutes: 1)},
    {"5 minute": const Duration(minutes: 5)},
  ];

  Duration automaticPickerInterval = const Duration(seconds: 3);

  Timer? automaticPickerTimer;

  Timer? timer;
  getLocationAtIntervals(UserCurrentLocation userCurrentLocation) {
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      userCurrentLocation.getUserLocation(
        forceEnableLocation: false,
        onLocationEnabled: (isEnabled, pos) {
          if (isEnabled == true) {
            setState(() {
              currentPosition = pos;
              locationIsEnabled = isEnabled;
            });

            if (pickingPoints == true &&
                (inputMethod == InputMethod.manualRecording ||
                    inputMethod == InputMethod.automaticRecording)) {
              initialCameraPosition = CameraPosition(
                target: LatLng(
                  currentPosition!.latitude!,
                  currentPosition!.longitude!,
                ),
                zoom: 20.5,
                tilt: 12.0,
              );
              mapController?.animateCamera(
                CameraUpdate.newCameraPosition(initialCameraPosition),
              );
            }
          } else {
            setState(() {
              locationIsEnabled = isEnabled;
            });
          }
        },
      );
    });
  }

  getCurrentLocation() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      globals.showSnackBar(
        title: "Location is OFF",
        message: "Location service is not enabled. Please enable it.",
        duration: 5,
      );
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
      desiredAccuracy: gl.LocationAccuracy.high,
    );

    locationData = LocationData.fromMap({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  // getUserLocation(UserCurrentLocation userCurrentLocation) {
  //   userCurrentLocation.getUserLocation(
  //       forceEnableLocation: true,
  //       onLocationEnabled: (isEnabled, pos) {
  //         print('GETTING A  NEW USER LOCATION');
  //         // if (isEnabled == true) {
  //         //   locationData = pos!;
  //         //   update();
  //         // }
  //       });
  // }

  // =============================================================================
  // =============== START INITIALIZE LAYERS ===========
  // =============================================================================
  setupInitialLayers() {
    if (widget.useBackgroundLayers == true && widget.layers.isNotEmpty) {
      for (var polygon in widget.layers) {
        Polygon poly = Polygon(
          polygonId: polygon.polygonId,
          points: polygon.points,
          strokeColor: polygon.strokeColor,
          consumeTapEvents: true,
          fillColor: polygon.fillColor,
          strokeWidth: polygon.strokeWidth,
          onTap: polygon.onTap,
        );
        polygons.add(poly);
      }
    }

    if (widget.viewInitialPolygon == true && widget.initialPolygon != null) {
      polygons.add(widget.initialPolygon!);
    }

    setState(() {});
  }
  // =============================================================================
  // =============== END INITIALIZE LAYERS ===========
  // =============================================================================

  showGuides() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('bypassDrawingToolGuide') &&
        prefs.getBool('bypassDrawingToolGuide') == true) {
      inputMethodSelectionDialog(userCurrentLocation!);
    } else {
      Timer(const Duration(seconds: 3), () {
        setTutorialTargets();
        showTutorial();
      });
    }
  }

  @override
  void initState() {
    inputMethod = widget.allowTappingInputMethod!
        ? InputMethod.tapping
        : InputMethod.manualRecording;

    if (widget.cameraPosition != null) {
      initialCameraPosition = widget.cameraPosition!;
    }

    rootBundle.loadString('assets/map_style/silver.txt').then((string) {
      _mapStyle = string;
    });

    // if (widget.useBackgroundLayers == true && widget.layers.isNotEmpty){
    setupInitialLayers();
    // }

    polyID = DateTime.now().millisecondsSinceEpoch.remainder(100000).toString();

    // markers = Set.from([]);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userCurrentLocation = UserCurrentLocation(context: context);

      getLocationAtIntervals(userCurrentLocation!);

      getCurrentLocation();

      widget.viewOnlyMap!
          ? null
          : Timer(const Duration(seconds: 3), () {
              showGuides();
            });
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // timer!.cancel();
    if (timer != null) {
      timer!.cancel();
    }
    if (automaticPickerTimer != null) {
      automaticPickerTimer!.cancel();
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      mapController!.setMapStyle(_mapStyle);
    }
  }

  // getCurrentLocation() async {
  //   bool serviceEnabled;
  //   gl.LocationPermission permission;
  //
  //   // Test if location services are enabled.
  //   serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return;
  //   }
  //
  //   permission = await gl.Geolocator.checkPermission();
  //   if (permission == gl.LocationPermission.denied) {
  //     permission = await gl.Geolocator.requestPermission();
  //     if (permission == gl.LocationPermission.denied) {
  //       return;
  //     }
  //   }
  //
  //   if (permission == gl.LocationPermission.deniedForever) {
  //     return;
  //   }
  //
  //   gl.Position position = await gl.Geolocator.getCurrentPosition(
  //       desiredAccuracy: gl.LocationAccuracy.medium);
  //
  //   // Access latitude and longitude directly from the position
  //   // double latitude = position.latitude;
  //   // double longitude = position.longitude;
  //
  //   LocationData.fromMap({
  //     'latitude': position.latitude,
  //     'longitude': position.longitude
  //   });
  //
  // }

  var checkLatLngList = [];
  int index = 0;

  Globals globals = Globals();

  bool isLineSegmentIntersectingCircle(
    LatLng p1,
    LatLng p2,
    LatLng center,
    double radius,
  ) {
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

    double dx = p2.latitude - p1.latitude;
    double dy = p2.longitude - p1.longitude;

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
    if (discriminant < 0) {
      return false;
    }

    discriminant = sqrt(discriminant);

    double t1 = (-b - discriminant) / (2 * a);
    double t2 = (-b + discriminant) / (2 * a);

    return (t1 >= 0 && t1 <= 1) || (t2 >= 0 && t2 <= 1);
  }

  Future<void> onPolygonTap(String farmReference) async {
    Polygon polygon = polygons.firstWhere(
      (p) => p.polygonId.value == farmReference,
    );
    activePolygon = polygon;
    await updateCameraPosition(polygon);
    // await updateSelectedFarm(farmReference);
    updatePolygonNavigationStatus();
  }

  void updatePolygonNavigationStatus() {
    isFirstPolygon.value = polygons.first == activePolygon;
    isLastPolygon.value = polygons.last == activePolygon;
  }

  Future<void> updateCameraPosition(Polygon polygon) async {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          boundsFromLatLngList(polygon.points),
          140.0,
        ),
      );
    }
  }

  // Future<void> updateSelectedFarm(String farmReference) async {
  //   final f = globalController.database!.assignedFarmDao;
  //   List<AssignedFarm> farms =
  //   await f.findAssignedFarmsByFarmRef(farmReference);
  //   if (farms.isNotEmpty) {
  //     selectedFarm.value = farms.first;
  //   }
  // }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  bool isPointInCircle(LatLng point, LatLng center, double radius) {
    double distance = gl.Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      center.latitude,
      center.longitude,
    );
    return distance <= radius;
  }

  // final addFarmController = ;

  @override
  Widget build(BuildContext context) {
    var safePadding = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Material(
        child: Scaffold(
          body: ChangeNotifierProvider(
            create: (context) => AddFarmProvider(),
            child: Consumer<AddFarmProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: safePadding + 12,
                        bottom: 12,
                        left: 12,
                        right: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RoundedIconButton(
                                icon: const Icon(Icons.arrow_back),
                                size: 45,
                                backgroundColor: Colors.transparent,
                                onTap: () => Get.back(),
                              ),
                              const SizedBox(width: 12),
                              widget.viewOnlyMap!
                                  ? const Text(
                                      'View demarcated area',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const Text(
                                      'Demarcate area',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                          widget.viewOnlyMap!
                              ? const SizedBox()
                              : GestureDetector(
                                  key: _keyShowTutorialButton,
                                  onTap: () {
                                    setTutorialTargets();
                                    showTutorial();
                                  },
                                  child: const Icon(
                                    Icons.help_outline_rounded,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Container(
                      key: _keyGPSStatusPanel,
                      width: double.infinity,
                      color: locationAccuracyColor(currentPosition?.accuracy),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(6),
                      child: Builder(
                        builder: (context) {
                          var text = locationIsEnabled == true
                              ? "Location accuracy : ${currentPosition?.accuracy?.truncateToDecimalPlaces(2).toString() ?? ". . ."} ${currentPosition?.accuracy != null ? "m" : ""}"
                              : "Location is disabled";
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                              if (locationIsEnabled == false)
                                (Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: PrimaryButton(
                                    // isFullWidth: false,
                                    backgroundColor: Colors.white,
                                    // verticalPadding: 0.0,
                                    // horizontalPadding: 8.0,
                                    // borderRadius: 20,
                                    // borderColor: Colors.transparent,
                                    onTap: () {
                                      userCurrentLocation!.getUserLocation(
                                        forceEnableLocation: true,
                                        onLocationEnabled: (isEnabled, pos) {
                                          if (isEnabled == true) {
                                            setState(() {
                                              currentPosition = pos;
                                              locationIsEnabled = isEnabled;
                                            });
                                          }
                                        },
                                      );
                                    },
                                    child: const Text(
                                      'Enable',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                )),
                            ],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: initialCameraPosition,
                            mapType: mapType,
                            compassEnabled: false,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: widget.viewOnlyMap!
                                ? true
                                : false,
                            mapToolbarEnabled: false,
                            markers: markers,
                            polygons: polygons,
                            polylines: provider.polyLines,
                            onMapCreated: (GoogleMapController controller) {
                              // gMapController.complete(controller);
                              // await getCurrentLocation();

                              mapController = controller;
                              controller.setMapStyle(_mapStyle);

                              if (widget.viewInitialPolygon == false) {
                                zoomToCurrentLocation(userCurrentLocation!);
                              }

                              if (widget.viewInitialPolygon == true &&
                                  widget.initialPolygon != null) {
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    mapController!.animateCamera(
                                      CameraUpdate.newLatLngBounds(
                                        boundsFromLatLngList(
                                          widget.initialPolygon!.points,
                                        ),
                                        140.0,
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            onTap: (coordinates) {
                              setState(() {
                                showSelectedFeatureInfo = false;
                              });

                              if (pickingPoints == true &&
                                  inputMethod == InputMethod.tapping) {
                                addPoint(coordinates);
                              }
                            },
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Column(
                              children: [
                                widget.viewOnlyMap!
                                    ? const SizedBox()
                                    : controlButton(
                                        key: _keyAddInputButton,
                                        backgroundColor: Colors.black54,
                                        child: Icon(
                                          pickingPoints!
                                              ? Icons.pause
                                              : Icons.add_location_alt,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        onTap: () {
                                          if (markers.isEmpty) {
                                            inputMethodSelectionDialog(
                                              userCurrentLocation!,
                                            );
                                          } else {
                                            // if (inputMethod == InputMethod.tapping){
                                            if (pickingPoints == true) {
                                              setState(() {
                                                pickingPoints = false;
                                              });
                                              setPolygonTapEvents(
                                                consumeTap: true,
                                              );
                                            } else {
                                              setPolygonTapEvents(
                                                consumeTap: false,
                                              );
                                              setState(() {
                                                pickingPoints = true;
                                              });

                                              if (inputMethod ==
                                                  InputMethod
                                                      .automaticRecording) {
                                                handleAutomaticPickerTimer(
                                                  userCurrentLocation!,
                                                );
                                              }
                                            }
                                            // }
                                          }
                                        },
                                      ),
                                const SizedBox(height: 12),
                                widget.viewOnlyMap!
                                    ? const SizedBox()
                                    : controlButton(
                                        key: _keyBackspaceButton,
                                        backgroundColor: Colors.black54,
                                        child: const Icon(
                                          Icons.backspace_rounded,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        disabled: markers.isNotEmpty
                                            ? false
                                            : true,
                                        onTap: () {
                                          if (markers.isNotEmpty) {
                                            setState(() {
                                              markers.clear();
                                              if (polygons
                                                      .where(
                                                        (element) =>
                                                            element.polygonId ==
                                                            PolygonId(polyID!),
                                                      )
                                                      .first
                                                      .points
                                                      .length ==
                                                  1) {
                                                // polygons.clear();
                                                polygons.removeWhere(
                                                  (element) =>
                                                      element.polygonId ==
                                                      PolygonId(polyID!),
                                                );
                                              } else {
                                                polygons
                                                    .where(
                                                      (element) =>
                                                          element.polygonId ==
                                                          PolygonId(polyID!),
                                                    )
                                                    .first
                                                    .points
                                                    .removeLast();
                                                markers = polygons
                                                    .where(
                                                      (element) =>
                                                          element.polygonId ==
                                                          PolygonId(polyID!),
                                                    )
                                                    .first
                                                    .points
                                                    .map(
                                                      (e) => Marker(
                                                        markerId: MarkerId(
                                                          UniqueKey()
                                                              .toString(),
                                                        ),
                                                        position: LatLng(
                                                          e.latitude,
                                                          e.longitude,
                                                        ),
                                                      ),
                                                    )
                                                    .toSet();
                                              }
                                            });

                                            if (markers.isEmpty) {
                                              setState(() {
                                                pickingPoints = false;
                                              });
                                              setPolygonTapEvents(
                                                consumeTap: true,
                                              );
                                            }
                                          }
                                        },
                                      ),
                                const SizedBox(height: 12),
                                widget.viewOnlyMap!
                                    ? const SizedBox()
                                    : controlButton(
                                        key: _keyDeleteButton,
                                        backgroundColor: Colors.black54,
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        disabled: markers.isNotEmpty
                                            ? false
                                            : true,
                                        onTap: () {
                                          setState(() {
                                            markers.clear();
                                            // polygons.clear();
                                            polygons.removeWhere(
                                              (element) =>
                                                  element.polygonId ==
                                                  PolygonId(polyID!),
                                            );
                                            pickingPoints = false;
                                          });
                                          setPolygonTapEvents(consumeTap: true);
                                        },
                                      ),
                                const SizedBox(height: 12),
                                controlButton(
                                  key: _keyZoomToUserButton,
                                  backgroundColor: Colors.black54,
                                  child: const Icon(
                                    PhosphorIcons.crosshair,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  // child: const Icon(Icons.api_rounded, color: Colors.white, size: 25,),
                                  onTap: () => zoomToCurrentLocation(
                                    userCurrentLocation!,
                                    force: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                widget.viewOnlyMap!
                                    ? const SizedBox()
                                    : controlButton(
                                        key: _keySelectBasemapButton,
                                        backgroundColor: Colors.black54,
                                        child: const Icon(
                                          Icons.map_rounded,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        onTap: () => selectBasemapStyle(),
                                      ),
                                const SizedBox(height: 12),
                                widget.viewOnlyMap!
                                    ? const SizedBox()
                                    : controlButton(
                                        key: _keySaveButton,
                                        backgroundColor: Colors.black54,
                                        child: const Icon(
                                          Icons.save,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        onTap: () {
                                          if (markers.length < 3) {
                                            onSaveErrorDialog();
                                          } else {
                                            if (timer != null) {
                                              timer!.cancel();
                                            }
                                            if (automaticPickerTimer != null) {
                                              automaticPickerTimer!.cancel();
                                            }
                                            var area = calculatePolygonArea(
                                              polygons.first.points,
                                            );
                                            Polygon drawnPoly = polygons
                                                .where(
                                                  (element) =>
                                                      element.polygonId ==
                                                      PolygonId(polyID!),
                                                )
                                                .first;
                                            Navigator.of(context).pop();
                                            widget.onSave(
                                              drawnPoly,
                                              markers,
                                              area,
                                            );
                                          }
                                        },
                                      ),
                              ],
                            ),
                          ),
                          // Positioned(
                          //   top: 5,
                          //   left: 10,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Row(
                          //         children: [
                          //           Container(
                          //             height: 10,
                          //             width: 10,
                          //             color: Theme.of(context).colorScheme.primary,
                          //           ),
                          //           const SizedBox(
                          //             width: 10,
                          //           ),
                          //           const Text(
                          //             "Don't Map",
                          //             style: TextStyle(fontWeight: FontWeight.bold),
                          //           )
                          //         ],
                          //       ),
                          //       // Row(
                          //       //   children: [
                          //       //     Container(
                          //       //       height: 10,
                          //       //       width: 10,
                          //       //       color: Colors.green,
                          //       //     ),
                          //       //     const SizedBox(width: 10,),
                          //       //     const Text("Re-map Farms")
                          //       //   ],
                          //       // ),
                          //       Row(
                          //         children: [
                          //           Container(
                          //             height: 10,
                          //             width: 10,
                          //             color: Colors.orange,
                          //           ),
                          //           const SizedBox(
                          //             width: 10,
                          //           ),
                          //           const Text("Forest reserve")
                          //         ],
                          //       )
                          //     ],
                          //   ),
                          // ),
                          if (showSelectedFeatureInfo == true)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: clickedFeatureInfoWindow(
                                selectedFeatureInfo,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 12,
                      ),
                      color: Colors.blueGrey.shade100,
                      child: Column(
                        children: [
                          if (pickingPoints == true &&
                              inputMethod == InputMethod.manualRecording)
                            widget.viewOnlyMap!
                                ? const SizedBox()
                                : PrimaryButton(
                                    // isFullWidth: true,
                                    backgroundColor:
                                        (double.parse(
                                              currentPosition?.accuracy
                                                      .toString() ??
                                                  '100.0',
                                            ) >=
                                            30)
                                        ? Colors.black12
                                        : Theme.of(context).colorScheme.primary,

                                    // verticalPadding: 0.0,
                                    // horizontalPadding: 8.0,
                                    onTap: () {
                                      debugPrint(
                                        "Record point :::::::: ${currentPosition?.accuracy}",
                                      );
                                      debugPrint(
                                        "Record point :::::::: ${widget.persistMaxAccuracy}",
                                      );
                                      userCurrentLocation!.getUserLocation(
                                        forceEnableLocation: true,
                                        onLocationEnabled: (isEnabled, currentPosition) {
                                          if (isEnabled == true) {
                                            if (widget.persistMaxAccuracy ==
                                                true) {
                                              if (double.parse(
                                                    currentPosition!.accuracy
                                                        .toString(),
                                                  ) <=
                                                  30) {
                                                if (isLocationInsidePolygon(
                                                  LatLng(
                                                    currentPosition.latitude!,
                                                    currentPosition.longitude!,
                                                  ),
                                                  provider.polygonsForCheck,
                                                )) {
                                                  globals.showSnackBar(
                                                    title: "Invalid Point",
                                                    message:
                                                        "The point captured interferes with another farm, causing overlap, please adjust yourself and re-capture the point",
                                                    backgroundColor: Colors.red,
                                                  );
                                                } else {
                                                  checkLatLngList.add(
                                                    currentPosition,
                                                  );
                                                  if (checkLatLngList.length >=
                                                      2) {
                                                    LatLng firstPoint = LatLng(
                                                      checkLatLngList
                                                          .first
                                                          .latitude,
                                                      checkLatLngList
                                                          .first
                                                          .longitude,
                                                    );

                                                    LatLng
                                                    previousPoint = LatLng(
                                                      checkLatLngList[checkLatLngList
                                                                  .length -
                                                              2]
                                                          .latitude,
                                                      checkLatLngList[checkLatLngList
                                                                  .length -
                                                              2]
                                                          .longitude,
                                                    );

                                                    LatLng recentPoint = LatLng(
                                                      checkLatLngList
                                                          .last
                                                          .latitude,
                                                      checkLatLngList
                                                          .last
                                                          .longitude,
                                                    );

                                                    if (gl.Geolocator.distanceBetween(
                                                          recentPoint.latitude,
                                                          recentPoint.longitude,
                                                          previousPoint
                                                              .latitude,
                                                          previousPoint
                                                              .longitude,
                                                        ) <=
                                                        1) {
                                                      globals.showSnackBar(
                                                        title: "Invalid Point",
                                                        message:
                                                            "The point captured is too close to another point, multiple point at one place, please adjust yourself and re-capture the point",
                                                        backgroundColor:
                                                            Colors.red,
                                                      );
                                                      return;
                                                    }

                                                    bool
                                                    isLineBetweenRecentPointAndPreviousPointPassThroughPolygon =
                                                        doesLineBetweenPointsPassThroughPolygon(
                                                          recentPoint,
                                                          previousPoint,
                                                          provider
                                                              .polygonsForCheck,
                                                        );

                                                    bool
                                                    isLineBetweenRecentPointAndFirstPointPassThroughPolygon =
                                                        doesLineBetweenPointsPassThroughPolygon(
                                                          firstPoint,
                                                          recentPoint,
                                                          provider
                                                              .polygonsForCheck,
                                                        );

                                                    if (isLineBetweenRecentPointAndPreviousPointPassThroughPolygon ||
                                                        isLineBetweenRecentPointAndFirstPointPassThroughPolygon) {
                                                      checkLatLngList
                                                          .removeLast();
                                                      globals.showSnackBar(
                                                        title: "Invalid Line",
                                                        message:
                                                            "The line drawn interferes with another farm, causing overlap, please adjust yourself and re-capture the point",
                                                        backgroundColor:
                                                            Colors.red,
                                                      );
                                                    } else {
                                                      // add the second and the rest of the points
                                                      addPoint(
                                                        LatLng(
                                                          currentPosition
                                                              .latitude!,
                                                          currentPosition
                                                              .longitude!,
                                                        ),
                                                      );
                                                      index++;
                                                    }
                                                  } else {
                                                    // add the first point
                                                    addPoint(
                                                      LatLng(
                                                        currentPosition
                                                            .latitude!,
                                                        currentPosition
                                                            .longitude!,
                                                      ),
                                                    );
                                                  }
                                                }
                                              } else {
                                                Get.snackbar(
                                                  "Cannot record point",
                                                  "The accuracy must be ${3} or below",
                                                  messageText: const Text(
                                                    "The accuracy must be ${3} or below",
                                                  ),
                                                  colorText: Colors.white,
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                        horizontal: 10,
                                                      ),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(
                                                    seconds: 3,
                                                  ),
                                                );
                                              }
                                            } else {
                                              addPoint(
                                                LatLng(
                                                  currentPosition!.latitude!,
                                                  currentPosition.longitude!,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Record point',
                                      style: TextStyle(
                                        color:
                                            (double.parse(
                                                  currentPosition?.accuracy
                                                          .toString() ??
                                                      '100.0',
                                                ) <=
                                                widget.maxAccuracy!)
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer
                                            : Colors.black,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                          if (pickingPoints == true &&
                              (inputMethod == InputMethod.tapping ||
                                  inputMethod ==
                                      InputMethod.automaticRecording))
                            Builder(
                              builder: (context) {
                                var duration = automaticPickerIntervals.where(
                                  (element) =>
                                      element.values.first ==
                                      automaticPickerInterval,
                                );
                                String text =
                                    inputMethod ==
                                        InputMethod.automaticRecording
                                    ? "Recording points every ${duration.first.keys.first}"
                                    : "Tap the map to place points";

                                return Column(
                                  children: [
                                    Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                );
                              },
                            ),
                          widget.viewOnlyMap!
                              ? const SizedBox()
                              : Text(
                                  "Points captured : ${markers.length.toString()}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          markers.length >= 3
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Text(
                                    "Estimated Area in Hectares : ${calculatePolygonArea(polygons.where((element) => element.polygonId == PolygonId(polyID!)).first.points).truncateToDecimalPlaces(6).toString()}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================================
  // START SET LOCATION ACCURACY COLOR
  // ==============================================================================

  Color locationAccuracyColor(double? accuracy) {
    if (accuracy == null) {
      return Colors.red;
    } else if (accuracy <= 3) {
      return Colors.green;
    } else if (accuracy <= 6) {
      return Colors.amber;
    } else if (accuracy > 6) {
      return Colors.red;
    }
    return Colors.grey;
  }

  // ==============================================================================
  // END SET LOCATION ACCURACY COLOR
  // ==============================================================================

  // ==============================================================================
  // START CONTROL BUTTON
  // ==============================================================================
  Widget controlButton({
    Key? key,
    Color? backgroundColor,
    Widget? child,
    Function? onTap,
    bool disabled = false,
  }) {
    return AbsorbPointer(
      key: key,
      absorbing: disabled,
      child: Container(
        decoration: BoxDecoration(
          color: disabled ? Colors.grey : backgroundColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 8.0),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: disabled ? Colors.grey : backgroundColor,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: () => disabled ? null : onTap!(),
              customBorder: const CircleBorder(),
              child: Center(child: child),
              // splashColor: Colors. red,
            ),
          ),
        ),
      ),
    );
  }
  // ==============================================================================
  // END CONTROL BUTTON
  // ==============================================================================

  // ==============================================================================
  // START CLICKED FEATURE WIDGET
  // ==============================================================================

  Widget clickedFeatureInfoWindow(features) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 8.0),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showSelectedFeatureInfo = false;
                  });
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black45,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.entries.map<Widget>((entry) {
                  var w = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.toString().capitalizeFirstOfEach,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value.toString().capitalizeFirstOfEach,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 15),
                    ],
                  );
                  return w;
                }).toList(),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================================
  // END CLICKED FEATURE WIDGET
  // ==============================================================================

  // ==============================================================================
  // START SAVE ERROR DIALOG
  // ==============================================================================
  onSaveErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invalid polygon',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                const Text(
                  "A valid polygon requires at least 3 points",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: CustomButton(
                    isFullWidth: false,
                    backgroundColor: const Color(0XFF002424),
                    verticalPadding: 0.0,
                    horizontalPadding: 8.0,
                    // borderRadius: 20,
                    // borderColor: Colors.transparent,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Okay',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        // .show(context, dialogTransitionType: DialogTransitionType.Shrink);
      },
    ).then((val) {
      setState(() {});
    });
  }
  // ==============================================================================
  // END SAVE ERROR DIALOG
  // ==============================================================================

  // ==============================================================================
  // START BASEMAP TYPE SELECTION DIALOG
  // ==============================================================================
  selectBasemapStyle() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        MapType selected = mapType;
        return AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select basemap style',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // mapType = MapType.normal;
                          selected = MapType.normal;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Radio<MapType>(
                            value: MapType.normal,
                            groupValue: selected,
                            onChanged: (value) {
                              setState(() {
                                // mapType = MapType.normal;
                                selected = MapType.normal;
                              });
                            },
                            activeColor: Colors.blueAccent,
                          ),
                          const Text('Normal', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // mapType = MapType.hybrid;
                          selected = MapType.hybrid;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Radio<MapType>(
                            value: MapType.hybrid,
                            groupValue: selected,
                            onChanged: (value) {
                              setState(() {
                                // mapType = MapType.hybrid;
                                selected = MapType.hybrid;
                              });
                            },
                            activeColor: Colors.blueAccent,
                          ),
                          const Text('Hybrid', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // mapType = MapType.satellite;
                          selected = MapType.satellite;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Radio<MapType>(
                            value: MapType.satellite,
                            groupValue: selected,
                            onChanged: (value) {
                              setState(() {
                                // mapType = MapType.satellite;
                                selected = MapType.satellite;
                              });
                            },
                            activeColor: Colors.blueAccent,
                          ),
                          const Text(
                            'Satellite',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          isFullWidth: false,
                          backgroundColor: Colors.transparent,
                          verticalPadding: 0.0,
                          horizontalPadding: 8.0,
                          // borderRadius: 20,
                          // borderColor: Colors.transparent,
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black, fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 15),
                        CustomButton(
                          isFullWidth: false,
                          backgroundColor: const Color(0XFF002424),
                          verticalPadding: 0.0,
                          horizontalPadding: 8.0,
                          // borderRadius: 20,
                          // borderColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              mapType = selected;
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Okay',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
        // .show(context, dialogTransitionType: DialogTransitionType.Shrink);
      },
    ).then((val) {
      setState(() {});
    });
  }
  // ==============================================================================
  // END BASEMAP TYPE SELECTION DIALOG
  // ==============================================================================

  // ==============================================================================
  // START INPUT METHOD SELECTION DIALOG
  // ==============================================================================
  inputMethodSelectionDialog(UserCurrentLocation userCurrentLocation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var selected = inputMethod;
        Duration automaticDurationVal = automaticPickerInterval;
        return AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Select input method',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    if (widget.allowTappingInputMethod!)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            inputMethod = InputMethod.tapping;
                            selected = InputMethod.tapping;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Radio<String>(
                              value: InputMethod.tapping,
                              groupValue: selected,
                              onChanged: (value) {
                                setState(() {
                                  inputMethod = InputMethod.tapping;
                                  selected = InputMethod.tapping;
                                });
                              },
                              activeColor: const Color(0XFF002424),
                              // activeColor: Colors.blueAccent,
                            ),
                            const Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Draw polygon',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    "Tap map to draw",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.allowTappingInputMethod!)
                      const SizedBox(height: 5),
                    if (widget.allowTappingInputMethod!)
                      const Divider(height: 5),
                    if (widget.allowTappingInputMethod!)
                      const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          inputMethod = InputMethod.manualRecording;
                          selected = InputMethod.manualRecording;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: InputMethod.manualRecording,
                            groupValue: selected,
                            onChanged: (value) {
                              setState(() {
                                inputMethod = InputMethod.manualRecording;
                                selected = InputMethod.manualRecording;
                              });
                            },
                            activeColor: const Color(0XFF002424),
                          ),
                          const Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pick boundary vertices',
                                  style: TextStyle(fontSize: 13),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "Walk around area and drop markers at vertices",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.allowTracingInputMethod!)
                      const SizedBox(height: 5),
                    if (widget.allowTracingInputMethod!)
                      const Divider(height: 5),
                    if (widget.allowTracingInputMethod!)
                      const SizedBox(height: 5),
                    if (widget.allowTracingInputMethod!)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            inputMethod = InputMethod.automaticRecording;
                            selected = InputMethod.automaticRecording;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Radio<String>(
                              value: InputMethod.automaticRecording,
                              groupValue: selected,
                              onChanged: (value) {
                                setState(() {
                                  inputMethod = InputMethod.automaticRecording;
                                  selected = InputMethod.automaticRecording;
                                });
                              },
                              activeColor: const Color(0XFF002424),
                            ),
                            const Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trace boundaries',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    "Automatically draw area by walking around it's boundary",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (selected == InputMethod.automaticRecording)
                      (ListTile(
                        leading: const Text('Recording interval'),
                        trailing: DropdownButton(
                          elevation: 2,
                          autofocus: true,
                          borderRadius: BorderRadius.circular(20),
                          value: automaticDurationVal,
                          onChanged: (newValue) {
                            setState(() {
                              var hr = newValue!.toString().split(":")[0];
                              var min = newValue.toString().split(":")[1];
                              var sec = newValue
                                  .toString()
                                  .split(":")[2]
                                  .split(".")[0];
                              automaticPickerInterval = Duration(
                                hours: int.parse(hr),
                                minutes: int.parse(min),
                                seconds: int.parse(sec),
                              );
                              automaticDurationVal = automaticPickerInterval;
                            });
                          },
                          items: automaticPickerIntervals.map((interval) {
                            return DropdownMenuItem(
                              value: interval.values.first,
                              child: Text(interval.keys.first),
                            );
                          }).toList(),
                        ),
                      )),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          isFullWidth: false,
                          backgroundColor: Colors.transparent,
                          // borderColor: Colors.transparent,
                          // borderRadius: 20,
                          verticalPadding: 0.0,
                          horizontalPadding: 8.0,
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black, fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 15),
                        CustomButton(
                          isFullWidth: false,
                          backgroundColor: const Color(0XFF002424),
                          verticalPadding: 0.0,
                          horizontalPadding: 8.0,
                          // borderRadius: 20,
                          // borderColor: Colors.transparent,
                          onTap: () {
                            if (inputMethod == InputMethod.tapping) {
                              setState(() {
                                pickingPoints = true;
                              });
                              Navigator.of(context).pop();
                            } else {
                              userCurrentLocation.getUserLocation(
                                forceEnableLocation: true,
                                onLocationEnabled:
                                    (isEnabled, currentPosition) {
                                      if (isEnabled == true) {
                                        setState(() {
                                          pickingPoints = true;
                                        });
                                        Navigator.of(context).pop();
                                        zoomToCurrentLocation(
                                          userCurrentLocation,
                                        );
                                      }
                                    },
                              );
                            }
                          },
                          child: const Text(
                            'Start',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        );
        // .show(context, dialogTransitionType: DialogTransitionType.Shrink);
      },
    ).then((val) {
      if (inputMethod == InputMethod.tapping && pickingPoints == true) {
        setPolygonTapEvents(consumeTap: false);
      }

      if (inputMethod == InputMethod.automaticRecording &&
          pickingPoints == true) {
        handleAutomaticPickerTimer(userCurrentLocation);
      }
      setState(() {});
    });
  }
  // ==============================================================================
  // END INPUT METHOD SELECTION DIALOG
  // ==============================================================================

  // ==============================================================================
  // START ZOOM TO CURRENT LOCATION
  // ==============================================================================
  zoomToCurrentLocation(
    UserCurrentLocation userCurrentLocation, {
    bool? force = false,
  }) {
    userCurrentLocation.getUserLocation(
      forceEnableLocation: force,
      onLocationEnabled: (isEnabled, currentPosition) {
        if (isEnabled == true) {
          initialCameraPosition = CameraPosition(
            target: LatLng(
              currentPosition!.latitude!,
              currentPosition.longitude!,
            ),
            zoom: 18.0,
            tilt: 20.0,
          );
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(initialCameraPosition),
          );
        }
      },
    );
  }
  // ==============================================================================
  // END ZOOM TO CURRENT LOCATION
  // ==============================================================================

  // ==============================================================================
  // START HANDLE TAPPING INPUT METHOD
  // ==============================================================================

  addPoint(LatLng latLng) {
    if (markers.isEmpty) {
      setState(() {
        // Add first marker
        markers.add(
          Marker(
            markerId: MarkerId(UniqueKey().toString()),
            position: LatLng(latLng.latitude, latLng.longitude),
          ),
        );

        // Create polygon with one point
        polygons.add(
          Polygon(
            polygonId: PolygonId(polyID!),
            points: markers.map((e) => e.position).toList(),
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.5),
            strokeWidth: 3,
          ),
        );
      });
    } else {
      // // Last point added to the polygon
      // LatLng lastPoint = markers.last.position;
      //
      // // Get current polygon points
      // List<LatLng> polygonPoints = polygons
      //     .where((element) => element.polygonId == PolygonId(polyID!))
      //     .first
      //     .points;
      //
      // bool intersects = false;
      //
      // // Check intersection between new line (lastPoint -> latLng) and all polygon edges
      // for (int i = 0; i < polygonPoints.length - 1; i++) {
      //   LatLng edgeStart = polygonPoints[i];
      //   LatLng edgeEnd = polygonPoints[i + 1];
      //
      //   if (doLineSegmentsIntersect(
      //     lastPoint,   // One endpoint of the new line
      //     latLng,      // Other endpoint of the new line
      //     edgeStart,   // One endpoint of the current polygon edge
      //     edgeEnd,     // Other endpoint of the current polygon edge
      //
      //   )) {
      //     intersects = true;
      //     break;
      //   }
      // }
      //
      // // Additional check: check the last edge (from last point to the first point)
      // // if (!intersects && polygonPoints.length > 2) {
      // //   LatLng firstPoint = polygonPoints.first;
      // //   if (doLineSegmentsIntersect(
      // //     polygonPoints.last,  // Last point in the polygon
      // //     edgeStart,   // One endpoint of the current polygon edge
      // //     edgeEnd,     // Other endpoint of the current polygon edge
      // //     lastPoint,   // One endpoint of the new line
      // //     latLng,              // New point to add
      // //   )) {
      // //     intersects = true;
      // //   }
      // // }

      // if (!intersects) {
      setState(() {
        // Add the new marker and update the polygon
        markers.add(
          Marker(
            markerId: MarkerId(UniqueKey().toString()),
            position: LatLng(latLng.latitude, latLng.longitude),
          ),
        );

        // Update polygon with new point
        polygons
            .where((element) => element.polygonId == PolygonId(polyID!))
            .first
            .points
            .add(latLng);
      });
      // } else {
      //   // Show an error message if the new line intersects with existing edges
      //   globals.showSnackBar(
      //     title: "Intersection Detected",
      //     message: 'Cannot add point, please adjust and re-capture',
      //     backgroundColor: Colors.red,
      //   );
      // }
    }
  }

  // ==============================================================================
  // END HANDLE TAPPING INPUT METHOD
  // ==============================================================================

  // ==============================================================================
  // START HANDLE AUTOMATIC PICKER TIMER
  // ==============================================================================
  handleAutomaticPickerTimer(UserCurrentLocation userCurrentLocation) {
    automaticPickerTimer = Timer.periodic(automaticPickerInterval, (Timer t) {
      if (pickingPoints == false) {
        automaticPickerTimer!.cancel();
      } else {
        userCurrentLocation.getUserLocation(
          forceEnableLocation: false,
          onLocationEnabled: (isEnabled, currentPosition) {
            if (isEnabled == true) {
              addPoint(
                LatLng(currentPosition!.latitude!, currentPosition.longitude!),
              );
            }
          },
        );
      }
    });
  }
  // ==============================================================================
  // END HANDLE AUTOMATIC PICKER TIMER
  // ==============================================================================

  // ==============================================================================
  // START CALCULATE POLYGON AREA
  // ==============================================================================
  static double calculatePolygonArea(List coordList) {
    double area = 0;

    List<LatLng> coordinates = coordList
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
    coordinates.add(coordinates.first);

    if (coordinates.length > 2) {
      for (var i = 0; i < coordinates.length - 1; i++) {
        var p1 = coordinates[i];
        var p2 = coordinates[i + 1];
        area +=
            convertToRadian(p2.longitude - p1.longitude) *
            (2 +
                math.sin(convertToRadian(p1.latitude)) +
                math.sin(convertToRadian(p2.latitude)));
      }

      area = area * 6378137 * 6378137 / 2;
    }

    var areaAcres = area.abs() * 0.000247105; //sq meters to Acres
    return areaAcres / 2.471; //to hectares
  }

  static double convertToRadian(double input) {
    return input * math.pi / 180;
  }
  // ==============================================================================
  // END CALCULATE POLYGON AREA
  // ==============================================================================

  // =============================================================================
  // =============== START DISABLE | ENABLE CONSUME POLYGON TAP EVENTS ===========
  // =============================================================================
  setPolygonTapEvents({bool? consumeTap}) {
    Set<Polygon> newPolygons = HashSet<Polygon>();
    for (var polygon in polygons) {
      newPolygons.add(
        Polygon(
          polygonId: polygon.polygonId,
          points: polygon.points,
          strokeColor: polygon.strokeColor,
          consumeTapEvents: consumeTap!,
          fillColor: polygon.fillColor,
          strokeWidth: polygon.strokeWidth,
          // tag: polygon.tag,
          // properties: polygon.properties,
          onTap: polygon.onTap,
        ),
      );
    }
    setState(() {
      polygons = newPolygons;
      if (consumeTap == false) {
        showSelectedFeatureInfo = false;
      }
    });
  }
  // =============================================================================
  // =============== END DISABLE | ENABLE CONSUME POLYGON TAP EVENTS =============
  // =============================================================================

  void setTutorialTargets() {
    targets = [
      TargetFocus(
        identify: "Target 1",
        keyTarget: _keyGPSStatusPanel,
        shape: ShapeLightFocus.RRect,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "View current GPS status of your device.",
                    style: coachMarkTextStyleMd,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Background color red means one of 3 things;",
                    style: coachMarkTextStyleMd,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "It's either location is turned off or GPS accuracy is bad",
                    style: coachMarkTextStyleMd,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Background color amber means GPS accuracy is moderate",
                    style: coachMarkTextStyleMd,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Background color green means GPS accuracy is good",
                    style: coachMarkTextStyleMd,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "In the case where location is turned off, turn it on by pressing the enable button when prompted",
                    style: coachMarkTextStyleMd,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.finish(),
                        child: const Text(
                          'Exit guide',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.next(),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 2",
        keyTarget: _keyAddInputButton,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Select input method, continue or pause input",
                    style: coachMarkTextStyleLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.finish(),
                        child: const Text(
                          'Exit guide',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.next(),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 3",
        keyTarget: _keyBackspaceButton,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Remove the last picked point",
                    style: coachMarkTextStyleLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.finish(),
                        child: const Text(
                          'Exit guide',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.next(),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 4",
        keyTarget: _keyDeleteButton,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Remove all points and drawn area",
                    style: coachMarkTextStyleLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.finish(),
                        child: const Text(
                          'Exit guide',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.next(),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 5",
        keyTarget: _keyZoomToUserButton,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Zoom to your current location",
                    style: coachMarkTextStyleLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.finish(),
                        child: const Text(
                          'Exit guide',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.next(),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 6",
        keyTarget: _keySelectBasemapButton,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Change basemap",
                    style: coachMarkTextStyleLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.finish(),
                        child: const Text(
                          'Exit guide',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.next(),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 7",
        keyTarget: _keySaveButton,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Save drawn area for analysis",
                    style: coachMarkTextStyleLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.finish(),
                        child: const Text(
                          'Exit guide',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.next(),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 8",
        keyTarget: _keyShowTutorialButton,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Relaunch this tutorial",
                    style: coachMarkTextStyleLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () {
                          tutorialCoachMark!.skip();
                          showTutorial();
                        },
                        child: const Text(
                          'Restart guide',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                      CustomButton(
                        isFullWidth: false,
                        backgroundColor: Colors.white,
                        verticalPadding: 0.0,
                        horizontalPadding: 8.0,
                        // borderRadius: 20,
                        // borderColor: Colors.transparent,
                        onTap: () => tutorialCoachMark!.finish(),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.black, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets, // List<TargetFocus>
      // colorShadow: Colors.red,
      hideSkip: true,
      // alignSkip: Alignment.bottomRight,
      // textSkip: "SKIP",
      paddingFocus: 5,
      // opacityShadow: 0.8,
      onClickTarget: (target) {
        // print(target);
      },
      onClickOverlay: (target) {
        // print(target);
      },
      onSkip: () {
        // print("skip");
        return true;
      },
      onFinish: () async {
        Timer(const Duration(milliseconds: 500), () {
          inputMethodSelectionDialog(userCurrentLocation!);
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('bypassDrawingToolGuide', true);
      },
    )..show(context: context);
  }

  // =================================================================================
  // =================== START CALCULATE BOUNDS FROM POLYGON LATLNG ================
  // =================================================================================
  // LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  //   assert(list.isNotEmpty);
  //   double? x0, x1, y0, y1;
  //   for (LatLng latLng in list) {
  //     if (x0 == null) {
  //       x0 = x1 = latLng.latitude;
  //       y0 = y1 = latLng.longitude;
  //     } else {
  //       if (latLng.latitude > x1!) x1 = latLng.latitude;
  //       if (latLng.latitude < x0) x0 = latLng.latitude;
  //       if (latLng.longitude > y1!) y1 = latLng.longitude;
  //       if (latLng.longitude < y0!) y0 = latLng.longitude;
  //     }
  //   }
  //   return LatLngBounds(
  //       northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  // }
  // =================================================================================
  // =================== END CALCULATE BOUNDS FROM POLYGON LATLNG ================
  // =================================================================================
}

class InputMethod {
  static String tapping = "0";
  static String manualRecording = "1";
  static String automaticRecording = "2";
}
