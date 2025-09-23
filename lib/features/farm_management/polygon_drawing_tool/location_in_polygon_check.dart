import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

bool isLocationInsidePolygon(LatLng point, Set<Polygon> polygons) {
  if (polygons.isEmpty) {
    return false;
  }

  for (Polygon polygon in polygons) {
    if (_isPointInPolygon(point, polygon.points)) {
      return true;
    }
  }
  return false;
}

bool _isPointInPolygon(LatLng point, List<LatLng> vertices) {
  int intersectCount = 0;
  double precision = 1e-9;
  int vertexCount = vertices.length;

  for (int i = 0; i < vertexCount; i++) {
    LatLng vertex1 = vertices[i];
    LatLng vertex2 = vertices[(i + 1) % vertexCount];

    // Check if the point is on the edge of the polygon
    if (isPointOnSegment(point, vertex1, vertex2, precision)) {
      return true;
    }

    // Ray-casting algorithm to count intersections
    if ((vertex1.longitude > point.longitude) != (vertex2.longitude > point.longitude) &&
        point.latitude < (vertex2.latitude - vertex1.latitude) * (point.longitude - vertex1.longitude) / (vertex2.longitude - vertex1.longitude) + vertex1.latitude) {
      intersectCount++;
    }
  }
  return (intersectCount % 2 == 1); // Odd count means inside polygon
}

bool isPointOnSegment(LatLng point, LatLng segStart, LatLng segEnd, double precision) {
  double minX = math.min(segStart.latitude, segEnd.latitude);
  double maxX = math.max(segStart.latitude, segEnd.latitude);
  double minY = math.min(segStart.longitude, segEnd.longitude);
  double maxY = math.max(segStart.longitude, segEnd.longitude);

  // Check if point is within the bounding box of the segment
  if (point.latitude >= minX && point.latitude <= maxX && point.longitude >= minY && point.longitude <= maxY) {
    // Calculate the distance from the point to the segment
    double distance = calculateDistanceToSegment(point, segStart, segEnd);
    return distance < precision;
  }
  return false;
}

double calculateDistanceToSegment(LatLng point, LatLng segStart, LatLng segEnd) {
  double x0 = point.latitude;
  double y0 = point.longitude;
  double x1 = segStart.latitude;
  double y1 = segStart.longitude;
  double x2 = segEnd.latitude;
  double y2 = segEnd.longitude;

  double numerator = (y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1;
  double denominator = math.sqrt(math.pow(y2 - y1, 2) + math.pow(x2 - x1, 2));

  return numerator.abs() / denominator;
}


bool doesLineBetweenPointsPassThroughPolygon(LatLng p1, LatLng p2, Set<Polygon> polygons) {
  for (Polygon polygon in polygons) {
    List<LatLng> vertices = polygon.points;
    int vertexCount = vertices.length;

    for (int i = 0; i < vertexCount; i++) {
      LatLng vertex1 = vertices[i];
      LatLng vertex2 = vertices[(i + 1) % vertexCount];

      // print("VERTEX 2 ---------------- $vertex2");

      if (doLineSegmentsIntersect(p1, p2, vertex1, vertex2)) {
        return true;
      }
    }
  }
  return false;
}

bool doLineSegmentsIntersect(LatLng p1, LatLng p2, LatLng q1, LatLng q2) {
  double orientation(LatLng a, LatLng b, LatLng c) {
    double value = (b.latitude - a.latitude) * (c.longitude - b.longitude) - (b.longitude - a.longitude) * (c.latitude - b.latitude);
    if (value == 0) return 0; // Collinear
    return (value > 0) ? 1 : 2; // Clockwise or Counterclockwise
  }

  bool onSegment(LatLng p, LatLng q, LatLng r) {
    if (q.latitude <= math.max(p.latitude, r.latitude) && q.latitude >= math.min(p.latitude, r.latitude) &&
        q.longitude <= math.max(p.longitude, r.longitude) && q.longitude >= math.min(p.longitude, r.longitude)) {
      return true;
    }
    return false;
  }

  double o1 = orientation(p1, p2, q1);
  double o2 = orientation(p1, p2, q2);
  double o3 = orientation(q1, q2, p1);
  double o4 = orientation(q1, q2, p2);

  // General case
  if (o1 != o2 && o3 != o4) {
    return true;
  }

  // Special cases
  // p1, p2, q1 are collinear and q1 lies on segment p1p2
  if (o1 == 0 && onSegment(p1, q1, p2)) return true;
  // p1, p2, q2 are collinear and q2 lies on segment p1p2
  if (o2 == 0 && onSegment(p1, q2, p2)) return true;
  // q1, q2, p1 are collinear and p1 lies on segment q1q2
  if (o3 == 0 && onSegment(q1, p1, q2)) return true;
  // q1, q2, p2 are collinear and p2 lies on segment q1q2
  if (o4 == 0 && onSegment(q1, p2, q2)) return true;

  return false;
}