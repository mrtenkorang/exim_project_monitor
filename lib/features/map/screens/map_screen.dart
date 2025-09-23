import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:exim_project_monitor/widgets/map/farm_boundary_drawer.dart';
import '../../farms/providers/farm_provider.dart';
import '../../farms/screens/farm_form_screen.dart';
import '../../../../core/models/farm_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/database/database_helper.dart';
import '../../../widgets/common/app_drawer.dart';
import '../../../widgets/map/map_controls.dart';
import '../../../widgets/map/map_layers_panel.dart';
import '../../../widgets/map/map_search_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  final Set<Polyline> _polylines = {};


  final GlobalKey<FarmBoundaryDrawerState> _drawerKey =
  GlobalKey<FarmBoundaryDrawerState>();

  bool _isLoading = true;
  bool _showLayersPanel = false;
  bool _showDrawingTools = false;
  LatLng? _currentLocation;
  MapType _mapType = MapType.normal;
  final Set<Polygon> _drawnPolygons = {};

  // Map camera position
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(5.55, -0.2), // Default to Ghana
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapData();
    _requestLocationPermission();

    // Load farms when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarms();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app resumes
      _loadMapData();
    }
  }

  Future<void> _loadFarms() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    await farmProvider.loadFarms();
    _updateMapWithFarms(farmProvider.farms);
  }

  void _updateMapWithFarms(List<Farm> farms) {
    setState(() {
      _markers.clear();
      _polygons.clear();

      for (final farm in farms) {
        _addFarmMarker(farm);
        _addFarmPolygon(farm);
      }
    });
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);

    try {
      // Load farms if not already loaded
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      if (farmProvider.farms.isEmpty) {
        await farmProvider.loadFarms();
        _updateMapWithFarms(farmProvider.farms);
      }

      // Add sample data if no farms exist (for testing)
      if (farmProvider.farms.isEmpty) {
        _addSampleData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading map data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addSampleData() {
    // Add sample farm markers
    final sampleFarm = Farm(
      id: 'sample-farm-1',
      name: 'Sample Farm',
      farmerName: 'John Doe',
      farmSize: 5.0,
      boundaryPoints: const [
        LatLng(5.55, -0.2),
        LatLng(5.55, -0.19),
        LatLng(5.54, -0.19),
        LatLng(5.54, -0.2),
      ],
      status: 'completed',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      assignedTo: null,
      verifiedBy: null,
      additionalData: null,
      imageUrls: null,
      zoneId: null,
      isSynced: false,
    );

    _addFarmMarker(sampleFarm);
    _addFarmPolygon(sampleFarm);
  }

  void _addFarmMarker(Farm farm) {
    final centerPoint = _calculateCenter(farm.boundaryPoints);

    final marker = Marker(
      markerId: MarkerId('farm-${farm.id}'),
      position: centerPoint,
      infoWindow: InfoWindow(
        title: farm.farmerName,
        snippet: '${farm.farmSize} acres - ${farm.status}',
        onTap: () {
          // TODO: Show farm details
        },
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _getStatusColorHue(farm.status),
      ),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  LatLng _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);

    double latSum = 0;
    double lngSum = 0;

    for (final point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

    return LatLng(latSum / points.length, lngSum / points.length);
  }

  void _addFarmPolygon(Farm farm) {
    if (farm.boundaryPoints.length < 3) return;

    final polygon = Polygon(
      polygonId: PolygonId('polygon-${farm.id}'),
      points: farm.boundaryPoints,
      strokeWidth: 2,
      strokeColor: _getStatusColor(farm.status),
      fillColor: _getStatusColor(farm.status).withOpacity(0.2),

    );

    setState(() {
      _polygons.add(polygon);
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'verified':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _getStatusColorHue(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return BitmapDescriptor.hueGreen;
      case 'in_progress':
        return BitmapDescriptor.hueOrange;
      case 'pending':
        return BitmapDescriptor.hueBlue;
      case 'verified':
        return BitmapDescriptor.hueViolet;
      case 'rejected':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  Future<void> _requestLocationPermission() async {
    // TODO: Implement location permission request
    // For now, we'll just set a default location
    setState(() {
      _currentLocation = const LatLng(5.55, -0.2);
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);

    try {
      // Set map style if available
      final style = await rootBundle.loadString('assets/map_style.json');
      controller.setMapStyle(style);
    } catch (e) {
      // If style file doesn't exist, continue without it
      print('Map style not found: $e');
    }

    // TODO: Adjust camera to show all farms or user's location
  }

  void _toggleDrawingTools() {
    setState(() {
      _showDrawingTools = !_showDrawingTools;
      if (_showLayersPanel) _showLayersPanel = false;
    });
  }

  void _toggleLayersPanel() {
    setState(() {
      _showLayersPanel = !_showLayersPanel;
      if (_showDrawingTools) _showDrawingTools = false;
    });
  }

  void _onPolygonsUpdated(Set<Polygon> polygons) {
    setState(() {
      _drawnPolygons.clear();
      _drawnPolygons.addAll(polygons);
    });
  }

  void _onMapTap(LatLng point) {
    if (_showDrawingTools && _drawerKey.currentState != null) {
      _drawerKey.currentState!.onMapTap(point);
    }
  }

  void _onMapLongPress(LatLng point) {
    if (_showDrawingTools && _drawerKey.currentState != null) {
      _drawerKey.currentState!.onMapLongPress(point);
    }
  }

  void _onMapDrag(LatLng point) {
    if (_showDrawingTools && _drawerKey.currentState != null) {
      _drawerKey.currentState!.onMapDrag(point);
    }
  }

  bool _onPolygonTap(Polygon polygon) {
    if (_showDrawingTools && _drawerKey.currentState != null) {
      return _drawerKey.currentState!.onPolygonTap(polygon);
    }
    return false;
  }

  void _onDrawerItemSelected(String item) {
    // Handle drawer item selection
    switch (item) {
      case 'profile':
      // TODO: Navigate to profile
        break;
      case 'tasks':
      // TODO: Navigate to tasks
        break;
      case 'reports':
      // TODO: Navigate to reports
        break;
      case 'settings':
      // TODO: Navigate to settings
        break;
      case 'logout':
        _logout();
        break;
    }
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _logout() async {
    final authService = context.read<AuthService>();
    await authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      mapType: _mapType,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: _onMapCreated,
      polygons: {..._polygons, ..._drawnPolygons},
      markers: _markers,
      polylines: _polylines,
      onTap: _onMapTap,
      onLongPress: _onMapLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        user: user,
        onItemSelected: _onDrawerItemSelected,
      ),
      body: Stack(
        children: [
          _buildMap(),

          // App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  // Search Bar
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: MapSearchBar(),
                  ),

                  // Map Controls
                  if (!_showLayersPanel)
                    MapControls(
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                      onLayersTap: _toggleLayersPanel,
                      onLocationTap: () {
                        // TODO: Center on user location
                      },
                      onAddTap: () {
                        // TODO: Show add menu
                      },
                    ),
                ],
              ),
            ),
          ),

          // Drawing tools panel
          if (_showDrawingTools)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: FarmBoundaryDrawer(
                key: _drawerKey,
                onPolygonsUpdated: _onPolygonsUpdated,
                currentLocation: _currentLocation,
              ),
            ),

          // Layers panel
          if (_showLayersPanel)
            Positioned(
              top: 80,
              right: 16,
              child: MapLayersPanel(
                onMapTypeChanged: (type) {
                  setState(() => _mapType = type);
                },
                onClose: () {},
                onLayerVisibilityChanged: (String layer, bool isVisible) {
                  // Handle layer visibility changes here
                },
              ),
            ),

          // Add button in map controls
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'draw_farm',
                  onPressed: _toggleDrawingTools,
                  backgroundColor: _showDrawingTools
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                  child: Icon(
                    Icons.edit,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'add_farm',
                  onPressed: () async {
                    if (_drawnPolygons.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please draw a farm boundary first'),
                        ),
                      );
                      return;
                    }

                    // Get the boundary points from the first polygon
                    final boundaryPoints = _drawnPolygons.first.points;

                    // Navigate to farm form
                    final result = await Navigator.of(context).push<Farm>(
                      MaterialPageRoute(
                        builder: (context) => FarmFormScreen(
                          boundaryPoints: boundaryPoints,
                        ),
                      ),
                    );

                    // Handle the result if farm was saved
                    if (result != null && mounted) {
                      // Clear the drawn polygons
                      setState(() {
                        _drawnPolygons.clear();
                        _showDrawingTools = false;
                      });

                      // Refresh the map data
                      _loadMapData();
                    }
                  },
                  child: const Icon(Icons.save),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}