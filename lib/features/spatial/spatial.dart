import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class EarthEngineMap extends StatefulWidget {
  const EarthEngineMap({super.key});

  @override
  State<EarthEngineMap> createState() => _EarthEngineMapState();
}

class _EarthEngineMapState extends State<EarthEngineMap> {
  late GoogleMapController _mapController;
  bool _isLoading = true;
  String _statusMessage = "Loading map...";

  static const String tileUrl =
      "https://earthengine.googleapis.com/v1/projects/earthengine-legacy/maps/67a5f40eb20fe8966189afeda8fab183-7c3eb24ad0390e3871fe47955cd0327f/tiles/{z}/{x}/{y}";

  TileOverlay _buildTileOverlay() {
    return TileOverlay(
      tileOverlayId: const TileOverlayId("earthengine"),
      tileProvider: CustomUrlTileProvider(
        urlTemplate: tileUrl,
        onTileLoaded: (success, url) {
          if (mounted) {
            setState(() {
              if (success) {
                _statusMessage = "Tiles loading successfully";
              } else {
                _statusMessage = "Failed to load tiles from: $url";
              }
            });
          }
        },
      ),
      transparency: 0.0, // Make sure tiles are fully opaque
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Earth Engine Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _statusMessage = "Refreshing map...";
              });
              // Rebuild the tile overlay
              // _mapController.clearTileCache();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(5.6037, -0.1870), // Ghana coordinates
              zoom: 8,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              setState(() {
                _isLoading = false;
                _statusMessage = "Map loaded. Loading tiles...";
              });
            },
            tileOverlays: {
              _buildTileOverlay(),
            },
            // Add these properties to help with debugging
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
          ),
          // Status overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          // Debug info
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomUrlTileProvider extends TileProvider {
  final String urlTemplate;
  final Function(bool success, String url)? onTileLoaded;

  CustomUrlTileProvider({
    required this.urlTemplate,
    this.onTileLoaded,
  });

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    try {
      final String url = urlTemplate
          .replaceAll("{x}", x.toString())
          .replaceAll("{y}", y.toString())
          .replaceAll("{z}", zoom.toString());

      developer.log('Requesting tile: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Flutter App',
          'Accept': 'image/*',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tile request timeout');
        },
      );

      developer.log('Tile response: ${response.statusCode} for $url');

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        onTileLoaded?.call(true, url);
        return Tile(256, 256, response.bodyBytes);
      } else {
        developer.log('Tile failed: Status ${response.statusCode}, Body length: ${response.bodyBytes.length}');
        onTileLoaded?.call(false, url);
        return _getErrorTile();
      }
    } catch (e) {
      developer.log('Tile error: $e');
      onTileLoaded?.call(false, 'Error: $e');
      return _getErrorTile();
    }
  }

  // Create a simple error tile to help visualize what's happening
  Tile _getErrorTile() {
    // Create a simple red tile to indicate error
    final bytes = Uint8List(4 * 256 * 256); // RGBA format
    for (int i = 0; i < bytes.length; i += 4) {
      bytes[i] = 255;     // Red
      bytes[i + 1] = 0;   // Green
      bytes[i + 2] = 0;   // Blue
      bytes[i + 3] = 50;  // Alpha (semi-transparent)
    }
    return Tile(256, 256, bytes);
  }
}

// Alternative implementation using a different approach
class EarthEngineMapAlternative extends StatefulWidget {
  const EarthEngineMapAlternative({super.key});

  @override
  State<EarthEngineMapAlternative> createState() => _EarthEngineMapAlternativeState();
}

class _EarthEngineMapAlternativeState extends State<EarthEngineMapAlternative> {
  late GoogleMapController _mapController;

  // Try a different Earth Engine URL format or use a test URL
  static const String testTileUrl =
      "https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}"; // Google Satellite for testing

  // Your original Earth Engine URL
  static const String earthEngineTileUrl =
      "https://earthengine.googleapis.com/v1/projects/earthengine-legacy/maps/67a5f40eb20fe8966189afeda8fab183-7c3eb24ad0390e3871fe47955cd0327f/tiles/{z}/{x}/{y}";

  bool _useTestTiles = false;

  TileOverlay _buildTileOverlay() {
    return TileOverlay(
      tileOverlayId: const TileOverlayId("overlay"),
      tileProvider: NetworkTileProvider(
        template: _useTestTiles ? testTileUrl : earthEngineTileUrl,
      ),
      transparency: 0.3, // Make Earth Engine overlay semi-transparent
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_useTestTiles ? "Test Tiles" : "Earth Engine"),
        actions: [
          IconButton(
            icon: Icon(_useTestTiles ? Icons.satellite : Icons.terrain),
            onPressed: () {
              setState(() {
                _useTestTiles = !_useTestTiles;
              });
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(5.6037, -0.1870),
          zoom: 8,
        ),
        onMapCreated: (controller) => _mapController = controller,
        tileOverlays: {_buildTileOverlay()},
      ),
    );
  }
}

// Simple network tile provider
class NetworkTileProvider extends TileProvider {
  final String template;

  NetworkTileProvider({required this.template});

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final url = template
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString())
        .replaceAll('{z}', zoom.toString());

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return Tile(256, 256, response.bodyBytes);
      }
    } catch (e) {
      developer.log('Network tile error: $e');
    }

    return Tile(256, 256, Uint8List(0));
  }
}