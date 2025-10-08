import 'dart:async';
import 'package:exim_project_monitor/core/models/server_models/farmers_model/farmers_from_server.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

class FarmMapScreen extends StatefulWidget {
  final FarmFromServer farm;
  final List<LatLng>? polygonPoints;

  const FarmMapScreen({
    Key? key,
    required this.farm,
    this.polygonPoints,
  }) : super(key: key);

  @override
  _FarmMapScreenState createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};
  CameraPosition? _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _setUpMap();
  }

  void _setUpMap() {
    // Get boundary coordinates from the farm
    final boundaryCoordinates = widget.farm.boundaryCoordinates;

    if (boundaryCoordinates != null && boundaryCoordinates.isNotEmpty) {
      // Convert boundary coordinates to Google Maps LatLng
      final polygonPoints = boundaryCoordinates.map((coord) {
        // Coordinates are in [longitude, latitude] format
        return LatLng(coord[1], coord[0]);
      }).toList();

      // Create polygon
      _polygons.add(
        Polygon(
          polygonId: PolygonId('farm_${widget.farm.id}_polygon'),
          points: polygonPoints,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeWidth: 3,
          strokeColor: Colors.blue,
          geodesic: true,
        ),
      );

      // Calculate center for camera position
      final center = _calculateCenter(polygonPoints);
      _initialCameraPosition = CameraPosition(
        target: center,
        zoom: 15.0,
      );

      // Add marker at the farm location
      // _markers.add(
      //   Marker(
      //     markerId: MarkerId('farm_${widget.farm.id}_marker'),
      //     position: LatLng(widget.farm.latitude, widget.farm.longitude),
      //     infoWindow: InfoWindow(
      //       title: widget.farm.name,
      //       snippet: 'Farm Area: ${widget.farm.areaHectares} ha',
      //     ),
      //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      //   ),
      // );

      // Also add markers for each boundary point
      // for (int i = 0; i < polygonPoints.length; i++) {
      //   _markers.add(
      //     Marker(
      //       markerId: MarkerId('boundary_${widget.farm.id}_$i'),
      //       position: polygonPoints[i],
      //       infoWindow: InfoWindow(
      //         title: 'Boundary Point ${i + 1}',
      //         snippet: 'Lat: ${polygonPoints[i].latitude.toStringAsFixed(6)}, Lng: ${polygonPoints[i].longitude.toStringAsFixed(6)}',
      //       ),
      //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      //       anchor: const Offset(0.5, 0.5),
      //     ),
      //   );
      // }
    } else {
      // If no boundary coordinates, use farm's lat/long
      _initialCameraPosition = CameraPosition(
        target: LatLng(widget.farm.latitude, widget.farm.longitude),
        zoom: 15.0,
      );

      _markers.add(
        Marker(
          markerId: MarkerId('farm_${widget.farm.id}_marker'),
          position: LatLng(widget.farm.latitude, widget.farm.longitude),
          infoWindow: InfoWindow(
            title: widget.farm.name,
            snippet: 'Farm Area: ${widget.farm.areaHectares} ha',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
  }

  LatLng _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) {
      return const LatLng(5.6037, -0.1870); // Default to Accra
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);

    // Add a delay to ensure the map is fully loaded
    await Future.delayed(const Duration(milliseconds: 500));

    // If we have polygons, adjust camera to show them
    if (_polygons.isNotEmpty) {
      final polygon = _polygons.first;
      final points = polygon.points;

      if (points.length >= 2) {
        // Calculate bounds
        double minLat = points.first.latitude;
        double maxLat = points.first.latitude;
        double minLng = points.first.longitude;
        double maxLng = points.first.longitude;

        for (var point in points) {
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
          if (point.longitude < minLng) minLng = point.longitude;
          if (point.longitude > maxLng) maxLng = point.longitude;
        }

        final bounds = LatLngBounds(
          northeast: LatLng(maxLat, maxLng),
          southwest: LatLng(minLat, minLng),
        );

        final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);

        // Use try-catch as newLatLngBounds might fail if map isn't ready
        try {
          await controller.animateCamera(cameraUpdate);
        } catch (e) {
          // Fallback: just move to center
          await controller.animateCamera(
            CameraUpdate.newLatLng(_initialCameraPosition!.target),
          );
        }
      }
    }
  }

  Future<void> _zoomToFarm() async {
    final controller = await _controller.future;

    if (_polygons.isNotEmpty) {
      final points = _polygons.first.points;

      if (points.length >= 2) {
        double minLat = points.first.latitude;
        double maxLat = points.first.latitude;
        double minLng = points.first.longitude;
        double maxLng = points.first.longitude;

        for (var point in points) {
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
          if (point.longitude < minLng) minLng = point.longitude;
          if (point.longitude > maxLng) maxLng = point.longitude;
        }

        final bounds = LatLngBounds(
          northeast: LatLng(maxLat, maxLng),
          southwest: LatLng(minLat, minLng),
        );

        final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);

        try {
          await controller.animateCamera(cameraUpdate);
        } catch (e) {
          await controller.animateCamera(
            CameraUpdate.newLatLng(_initialCameraPosition!.target),
          );
        }
      }
    } else {
      await controller.animateCamera(
        CameraUpdate.newLatLng(_initialCameraPosition!.target),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use default position if no boundary coordinates
    final initialPosition = _initialCameraPosition ?? const CameraPosition(
      target: LatLng(5.6037, -0.1870),
      zoom: 14.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.farm.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _zoomToFarm,
            tooltip: 'Zoom to Farm',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => _buildFarmDetails(context),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            onMapCreated: _onMapCreated,
            polygons: _polygons,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: false,
            mapType: MapType.hybrid,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomIn());
                  },
                  mini: true,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () async {
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomOut());
                  },
                  mini: true,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          if (_polygons.isEmpty)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[800]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No boundary coordinates available for this farm. Showing farm location only.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFarmDetails(BuildContext context) {
    final farm = widget.farm;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              farm.name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              farm.farmCode,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Farm Details
            _buildDetailRow(
              context,
              icon: Icons.agriculture_rounded,
              label: 'Farm Area',
              value: '${farm.areaHectares} hectares',
            ),
            _buildDetailRow(
              context,
              icon: Icons.terrain_rounded,
              label: 'Soil Type',
              value: farm.soilType.isNotEmpty ? farm.soilType : 'Not specified',
            ),
            _buildDetailRow(
              context,
              icon: Icons.water_drop_rounded,
              label: 'Irrigation',
              value: farm.irrigationType.isNotEmpty ? farm.irrigationType : 'Not specified',
            ),
            _buildDetailRow(
              context,
              icon: Icons.landscape_rounded,
              label: 'Irrigation Coverage',
              value: '${farm.irrigationCoverage}%',
            ),
            _buildDetailRow(
              context,
              icon: Icons.circle_rounded,
              label: 'Status',
              value: farm.status,
              statusColor: _getStatusColor(farm.status),
            ),

            // Project Information
            const SizedBox(height: 16),
            Text(
              'Project Information',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              icon: Icons.business_center_rounded,
              label: 'Project',
              value: farm.projectName.isNotEmpty ? farm.projectName : 'Not assigned',
            ),

            // Location Information
            const SizedBox(height: 16),
            Text(
              'Location',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              icon: Icons.location_on_rounded,
              label: 'Coordinates',
              value: 'Lat: ${farm.latitude.toStringAsFixed(6)}, Lng: ${farm.longitude.toStringAsFixed(6)}',
            ),
            _buildDetailRow(
              context,
              icon: Icons.landscape_rounded,
              label: 'Altitude',
              value: '${farm.altitude} meters',
            ),
            _buildDetailRow(
              context,
              icon: Icons.landscape_rounded,
              label: 'Slope',
              value: '${farm.slope}°',
            ),

            // Boundary Information
            if (farm.boundaryCoordinates != null && farm.boundaryCoordinates!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Boundary Information',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                icon: Icons.polyline_rounded,
                label: 'Boundary Points',
                value: '${farm.boundaryCoordinates!.length} points',
              ),
              _buildDetailRow(
                context,
                icon: Icons.check_circle_rounded,
                label: 'Boundary Polygon',
                value: farm.hasFarmBoundaryPolygon ? 'Available' : 'Not available',
              ),
            ],

            // Additional Information
            if (farm.observation.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Observation',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Text(
                  farm.observation,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        Color? statusColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: statusColor ?? Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor ?? Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}