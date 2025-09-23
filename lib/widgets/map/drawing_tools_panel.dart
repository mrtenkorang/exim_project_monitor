import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DrawingToolsPanel extends StatefulWidget {
  final Function(Set<Polygon>) onPolygonsUpdated;
  final LatLng? currentLocation;
  final Function() onClose;

  const DrawingToolsPanel({
    super.key,
    required this.onPolygonsUpdated,
    this.currentLocation,
    required this.onClose,
  });

  @override
  State<DrawingToolsPanel> createState() => _DrawingToolsPanelState();
}

class _DrawingToolsPanelState extends State<DrawingToolsPanel> {
  final Set<Polygon> _polygons = {};
  List<LatLng> _currentPoints = [];
  int _polygonId = 0;
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Draw Farm Boundary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolButton(
                icon: Icons.edit,
                label: _isDrawing ? 'Finish' : 'Draw',
                onPressed: _toggleDrawing,
                isActive: _isDrawing,
              ),
              _buildToolButton(
                icon: Icons.undo,
                label: 'Undo',
                onPressed: _undoLastPoint,
                isEnabled: _currentPoints.isNotEmpty,
              ),
              _buildToolButton(
                icon: Icons.clear,
                label: 'Clear',
                onPressed: _clearDrawing,
                isEnabled: _currentPoints.isNotEmpty,
              ),
            ],
          ),
          if (_currentPoints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Points: ${_currentPoints.length}'),
            ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
    bool isEnabled = true,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : isEnabled
                  ? null
                  : Colors.grey,
          onPressed: isEnabled ? onPressed : null,
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : isEnabled
                    ? null
                    : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _toggleDrawing() {
    setState(() {
      _isDrawing = !_isDrawing;
      if (!_isDrawing && _currentPoints.length >= 3) {
        _completePolygon();
      } else if (!_isDrawing) {
        _currentPoints.clear();
      }
    });
  }

  void _undoLastPoint() {
    if (_currentPoints.isNotEmpty) {
      setState(() {
        _currentPoints.removeLast();
      });
    }
  }

  void _clearDrawing() {
    setState(() {
      _currentPoints.clear();
      _isDrawing = false;
    });
  }

  void _completePolygon() {
    if (_currentPoints.length < 3) return;

    final polygon = Polygon(
      polygonId: PolygonId('polygon_${_polygonId++}'),
      points: List<LatLng>.from(_currentPoints),
      strokeWidth: 2,
      strokeColor: Theme.of(context).colorScheme.primary,
      fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
    );

    setState(() {
      _polygons.add(polygon);
      _currentPoints.clear();
      _isDrawing = false;
    });

    widget.onPolygonsUpdated(_polygons);
  }

  // Call this when a point is added to the current drawing
  void addPoint(LatLng point) {
    if (!_isDrawing) return;

    setState(() {
      _currentPoints.add(point);
    });
  }

  // Get the current drawing state
  Set<Polygon> get polygons => _polygons;
  List<LatLng> get currentPoints => _currentPoints;
  bool get isDrawing => _isDrawing;
}
