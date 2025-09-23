import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DrawingMode {
  none,
  polygon,
  rectangle,
  circle,
  freehand,
  edit,
  delete,
}

class FarmBoundaryDrawer extends StatefulWidget {
  final ValueChanged<Set<Polygon>> onPolygonsUpdated;
  final LatLng? currentLocation;

  const FarmBoundaryDrawer({
    super.key,
    required this.onPolygonsUpdated,
    this.currentLocation,
  });

  @override
  State<FarmBoundaryDrawer> createState() => FarmBoundaryDrawerState();
}

class FarmBoundaryDrawerState extends State<FarmBoundaryDrawer> {
  DrawingMode _drawingMode = DrawingMode.none;
  Set<Polygon> _polygons = {};
  List<LatLng> _currentPoints = [];
  int _polygonIdCounter = 1;
  String? _selectedPolygonId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drawing mode selection
          _buildModeSelector(theme),
          const SizedBox(height: 8),
          // Action buttons
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildModeSelector(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildModeButton(
            icon: Icons.edit,
            label: 'Edit',
            mode: DrawingMode.edit,
            isSelected: _drawingMode == DrawingMode.edit,
          ),
          _buildModeButton(
            icon: Icons.polyline,
            label: 'Polygon',
            mode: DrawingMode.polygon,
            isSelected: _drawingMode == DrawingMode.polygon,
          ),
          _buildModeButton(
            icon: Icons.crop_square,
            label: 'Rectangle',
            mode: DrawingMode.rectangle,
            isSelected: _drawingMode == DrawingMode.rectangle,
          ),
          _buildModeButton(
            icon: Icons.circle,
            label: 'Circle',
            mode: DrawingMode.circle,
            isSelected: _drawingMode == DrawingMode.circle,
          ),
          _buildModeButton(
            icon: Icons.brush,
            label: 'Freehand',
            mode: DrawingMode.freehand,
            isSelected: _drawingMode == DrawingMode.freehand,
          ),
          _buildModeButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            mode: DrawingMode.delete,
            isSelected: _drawingMode == DrawingMode.delete,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required DrawingMode mode,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon),
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            onPressed: () => _onDrawingModeChanged(mode),
            tooltip: label,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Save button
        ElevatedButton.icon(
          onPressed: _saveDrawing,
          icon: const Icon(Icons.save, size: 18),
          label: const Text('Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),

        // Cancel button
        TextButton(
          onPressed: _cancelDrawing,
          child: const Text('Cancel'),
        ),

        // Clear all button
        IconButton(
          icon: const Icon(Icons.clear_all, size: 20),
          onPressed: _clearAll,
          tooltip: 'Clear All',
        ),
      ],
    );
  }

  void _onDrawingModeChanged(DrawingMode mode) {
    setState(() {
      if (_drawingMode == mode) {
        _drawingMode = DrawingMode.none;
      } else {
        _drawingMode = mode;
      }
      _currentPoints.clear();
    });
  }

  void _saveDrawing() {
    if (_currentPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 3 points are required to create a polygon')),
      );
      return;
    }

    final polygonId = 'polygon_${_polygonIdCounter++}';
    final polygon = Polygon(
      polygonId: PolygonId(polygonId),
      points: List<LatLng>.from(_currentPoints),
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.2),
    );

    setState(() {
      _polygons.add(polygon);
      _currentPoints.clear();
      _drawingMode = DrawingMode.none;
    });

    widget.onPolygonsUpdated(_polygons);
  }

  void _cancelDrawing() {
    setState(() {
      _currentPoints.clear();
      _drawingMode = DrawingMode.none;
    });
  }

  void _clearAll() {
    setState(() {
      _polygons.clear();
      _currentPoints.clear();
      _drawingMode = DrawingMode.none;
      widget.onPolygonsUpdated(_polygons);
    });
  }

  // Call this when the user taps on the map
  void onMapTap(LatLng point) {
    if (_drawingMode == DrawingMode.none || _drawingMode == DrawingMode.edit) {
      return;
    }

    setState(() {
      _currentPoints.add(point);
    });

    // For rectangle mode, we need exactly 2 points
    if (_drawingMode == DrawingMode.rectangle && _currentPoints.length == 2) {
      _completeRectangle();
    }
  }

  // Call this when the user long-presses on the map (for freehand drawing)
  void onMapLongPress(LatLng point) {
    if (_drawingMode != DrawingMode.freehand) {
      return;
    }

    setState(() {
      _currentPoints.add(point);
    });
  }

  // Call this when the user drags on the map (for freehand drawing)
  void onMapDrag(LatLng point) {
    if (_drawingMode != DrawingMode.freehand) {
      return;
    }

    setState(() {
      _currentPoints.add(point);
    });
  }

  void _completeRectangle() {
    if (_currentPoints.length != 2) return;

    final start = _currentPoints[0];
    final end = _currentPoints[1];

    final rectanglePoints = [
      start,
      LatLng(start.latitude, end.longitude),
      end,
      LatLng(end.latitude, start.longitude),
      start, // Close the polygon
    ];

    final polygonId = 'rectangle_${_polygonIdCounter++}';
    final rectangle = Polygon(
      polygonId: PolygonId(polygonId),
      points: rectanglePoints,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.2),
    );

    setState(() {
      _polygons.add(rectangle);
      _currentPoints.clear();
      _drawingMode = DrawingMode.none;
    });

    widget.onPolygonsUpdated(_polygons);
  }

  // Call this when the user taps on a polygon
  bool onPolygonTap(Polygon polygon) {
    if (_drawingMode == DrawingMode.edit) {
      setState(() {
        _selectedPolygonId = polygon.polygonId.value;
      });
      // TODO: Show edit dialog or enable vertex editing
      return true;
    } else if (_drawingMode == DrawingMode.delete) {
      setState(() {
        _polygons.removeWhere((p) => p.polygonId == polygon.polygonId);
      });
      widget.onPolygonsUpdated(_polygons);
      return true;
    }
    return false;
  }

  // Get the current drawing state
  Set<Polygon> get polygons => _polygons;
  List<LatLng> get currentPoints => _currentPoints;
  DrawingMode get drawingMode => _drawingMode;
  bool get isDrawing => _drawingMode != DrawingMode.none;
}