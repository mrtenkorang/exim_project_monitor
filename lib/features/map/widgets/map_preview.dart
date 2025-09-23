import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPreview extends StatefulWidget {
  final List<LatLng> boundaryPoints;
  final bool interactive;
  final double? height;
  final double? width;
  final LatLng? center;
  final double? zoom;

  const MapPreview({
    super.key,
    required this.boundaryPoints,
    this.interactive = false,
    this.height,
    this.width,
    this.center,
    this.zoom,
  });

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  late GoogleMapController _mapController;
  final Set<Polygon> _polygons = {};
  LatLngBounds? _bounds;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    if (widget.boundaryPoints.isEmpty) {
      _isLoading = false;
      return;
    }

    // Create polygon from boundary points
    _polygons.add(
      Polygon(
        polygonId: const PolygonId('farm_boundary'),
        points: widget.boundaryPoints,
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.15),
      ),
    );

    // Calculate bounds to fit the polygon
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final point in widget.boundaryPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.boundaryPoints.isEmpty) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.map, size: 48, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.center ?? LatLng(
              (_bounds!.northeast.latitude + _bounds!.southwest.latitude) / 2,
              (_bounds!.northeast.longitude + _bounds!.southwest.longitude) / 2,
            ),
            zoom: widget.zoom ?? _getZoomLevel(),
          ),
          mapType: MapType.hybrid,
          zoomControlsEnabled: widget.interactive,
          zoomGesturesEnabled: widget.interactive,
          scrollGesturesEnabled: widget.interactive,
          rotateGesturesEnabled: widget.interactive,
          tiltGesturesEnabled: false,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            _fitToBounds();
          },
          polygons: _polygons,
        ),
      ),
    );
  }

  double _getZoomLevel() {
    if (_bounds == null) return 12.0;
    
    // Simple zoom level calculation based on bounds
    final latDiff = _bounds!.northeast.latitude - _bounds!.southwest.latitude;
    final lngDiff = _bounds!.northeast.longitude - _bounds!.southwest.longitude;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    if (maxDiff > 0.1) return 10.0;
    if (maxDiff > 0.05) return 12.0;
    if (maxDiff > 0.01) return 14.0;
    return 16.0;
  }

  Future<void> _fitToBounds() async {
    if (_bounds == null || !mounted) return;
    
    // Add padding to the bounds
    final padding = 0.02; // 2% padding
    final bounds = LatLngBounds(
      southwest: LatLng(
        _bounds!.southwest.latitude - padding,
        _bounds!.southwest.longitude - padding,
      ),
      northeast: LatLng(
        _bounds!.northeast.latitude + padding,
        _bounds!.northeast.longitude + padding,
      ),
    );

    // Animate camera to fit the bounds
    await _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50), // 50 pixels padding
    );
  }
}
