import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:exim_project_monitor/core/models/farm_model.dart';

class MapUtils {
  // Calculate bounds for a list of LatLng points
  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
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

  // Calculate center point of a polygon
  static LatLng getPolygonCenter(List<LatLng> points) {
    double x = 0, y = 0, z = 0;
    for (var point in points) {
      final lat = point.latitude * pi / 180;
      final lng = point.longitude * pi / 180;
      x += cos(lat) * cos(lng);
      y += cos(lat) * sin(lng);
      z += sin(lat);
    }

    final total = points.length;
    x = x / total;
    y = y / total;
    z = z / total;

    final centralLng = atan2(y, x);
    final centralSquareRoot = sqrt(x * x + y * y);
    final centralLat = atan2(z, centralSquareRoot);

    return LatLng(
      centralLat * 180 / pi,
      centralLng * 180 / pi,
    );
  }

  // Calculate area of a polygon in square meters
  static double calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    double area = 0.0;
    final p1 = points[0];
    
    for (int i = 1; i < points.length - 1; i++) {
      final p2 = points[i];
      final p3 = points[i + 1];
      area += _calculateTriangleArea(p1, p2, p3);
    }
    
    return area.abs();
  }

  static double _calculateTriangleArea(LatLng a, LatLng b, LatLng c) {
    return ((b.latitude - a.latitude) * (c.longitude - a.longitude) - 
            (c.latitude - a.latitude) * (b.longitude - a.longitude)) / 2;
  }

  // Convert square meters to acres
  static double squareMetersToAcres(double squareMeters) {
    return squareMeters * 0.000247105;
  }

  // Calculate distance between two points in meters
  static double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6378137.0; // WGS84 Earth's radius in meters
    
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Check if a point is inside a polygon
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool isInside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * 
          (point.latitude - polygon[i].latitude) / 
          (polygon[j].latitude - polygon[i].latitude) + polygon[i].longitude)) {
        isInside = !isInside;
      }
    }
    return isInside;
  }
}
