import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../../core/models/farm_model.dart';
import '../../../core/models/farmer_model.dart';
import '../../constants/URLS.dart';
import '../../constants/constants.dart';
import '../../models/district_model.dart';
import '../../models/projects_model.dart';
import '../../models/region_model.dart';
import '../../models/server_models/farmers_model/farmers_from_server.dart';
import '../../models/server_models/farms/farms.dart';
import '../../models/server_models/secondary_crops_model/secondary_crops_model.dart';
import '../../models/user_model.dart';
import '../database/database_helper.dart';

/// API service for handling all network requests related to farms and farmers
class APIService {
  final http.Client _client;

  /// Initialize with an optional http client (useful for testing)
  APIService({http.Client? client}) : _client = client ?? http.Client();

  /// Headers used for all API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add authentication token if needed
    // 'Authorization': 'Bearer $authToken',
  };

  /// Comprehensive HTTP error response handler
  Never _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    String errorMessage;
    Map<String, dynamic>? errorResponse;

    try {
      errorResponse = jsonDecode(response.body);
    } catch (e) {
      // If response body is not valid JSON, use the raw body
      errorResponse = {
        'message': response.body.isNotEmpty
            ? response.body
            : 'Unknown error occurred',
      };
    }

    // Extract error message from response
    final serverMessage =
        errorResponse?['message'] ??
        errorResponse?['error'] ??
        errorResponse?['detail'];

    switch (statusCode) {
      case 400:
        errorMessage =
            serverMessage ??
            'Bad Request: The server could not understand the request due to invalid syntax.';
        throw BadRequestException(errorMessage);
      case 401:
        errorMessage =
            serverMessage ??
            'Unauthorized: Authentication is required and has failed or not been provided.';
        throw UnauthorizedException(errorMessage);
      case 403:
        errorMessage =
            serverMessage ??
            'Forbidden: You do not have permission to access this resource.';
        throw ForbiddenException(errorMessage);
      case 404:
        errorMessage =
            serverMessage ??
            'Not Found: The requested resource could not be found on the server.';
        throw NotFoundException(errorMessage);
      case 405:
        errorMessage =
            serverMessage ??
            'Method Not Allowed: The request method is not supported for the requested resource.';
        throw MethodNotAllowedException(errorMessage);
      case 408:
        errorMessage =
            serverMessage ??
            'Request Timeout: The server timed out waiting for the request.';
        throw RequestTimeoutException(errorMessage);
      case 409:
        errorMessage =
            serverMessage ??
            'Conflict: The request could not be completed due to a conflict with the current state of the resource.';
        throw ConflictException(errorMessage);
      case 422:
        errorMessage =
            serverMessage ??
            'Unprocessable Entity: The request was well-formed but unable to be followed due to semantic errors.';
        throw UnprocessableEntityException(errorMessage);
      case 429:
        errorMessage =
            serverMessage ??
            'Too Many Requests: You have sent too many requests in a given amount of time.';
        throw RateLimitException(errorMessage);
      case 500:
        errorMessage =
            serverMessage ??
            'Internal Server Error: The server encountered an unexpected condition.';
        throw ServerException(errorMessage);
      case 502:
        errorMessage =
            serverMessage ??
            'Bad Gateway: The server received an invalid response from the upstream server.';
        throw BadGatewayException(errorMessage);
      case 503:
        errorMessage =
            serverMessage ??
            'Service Unavailable: The server is currently unavailable (overloaded or down for maintenance).';
        throw ServiceUnavailableException(errorMessage);
      case 504:
        errorMessage =
            serverMessage ??
            'Gateway Timeout: The server did not receive a timely response from the upstream server.';
        throw GatewayTimeoutException(errorMessage);
      default:
        if (statusCode >= 400 && statusCode < 500) {
          errorMessage =
              serverMessage ??
              'Client Error: An error occurred on the client side (Status code: $statusCode).';
          throw ClientException(errorMessage, statusCode);
        } else if (statusCode >= 500) {
          errorMessage =
              serverMessage ??
              'Server Error: An error occurred on the server side (Status code: $statusCode).';
          throw ServerException(errorMessage);
        } else {
          errorMessage =
              serverMessage ??
              'Unexpected error occurred (Status code: $statusCode).';
          throw ApiException(errorMessage, statusCode);
        }
    }
  }

  /// Generic method for handling API requests
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    Uri url, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = {..._headers, ...?additionalHeaders};

      final response = await switch (method) {
        'GET' => _client.get(url, headers: headers),
        'POST' => _client.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ),
        _ => throw UnsupportedMethodException(
          'HTTP method $method is not supported',
        ),
      };

      if (response.statusCode >= 400) {
        _handleErrorResponse(response);
      }

      // Handle successful responses with no content
      if (response.statusCode == 204 || response.body.isEmpty) {
        return {};
      }

      return jsonDecode(response.body);
    } on FormatException {
      debugPrint('Error: Invalid JSON format in response from $url');
      throw DataParsingException('Invalid data format received from server');
    } on http.ClientException catch (e) {
      debugPrint('Network error in $method request to $url: $e');
      throw NetworkException('Network connection failed: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error in $method request to $url: $e');
      rethrow;
    }
  }

  // ====================================
  // FARM ENDPOINTS
  // ====================================

  /// Submits a new farm to the server
  /// Returns the created farm data with server-generated ID
  Future<dynamic> submitFarm(Farm farm) async {
    final responseData = await _makeRequest(
      'POST',
      Uri.parse(URL.farms),
      body: farm.toJsonOnline(),
    );
    return responseData['status'];
  }

  /// Fetches a list of all farms from the server
  /// Optionally filter by projectId
  // Future<List<Farm>> getFarms({String? projectId}) async {
  //   final queryParams = <String, dynamic>{};
  //   if (projectId != null) {
  //     queryParams['projectId'] = projectId;
  //   }
  //
  //   final url = Uri.parse(URL.farms).replace(queryParameters: queryParams);
  //
  //   final responseData = await _makeRequest('GET', url);
  //   return (responseData['data'] as List)
  //       .map((farmJson) => Farm.fromMap(farmJson))
  //       .toList();
  // }

  /// Fetches a single farm by ID
  Future<Farm> getFarmById(String id) async {
    final responseData = await _makeRequest(
      'GET',
      Uri.parse('${URL.farms}/$id'),
    );
    return Farm.fromMap(responseData['data']);
  }

  // ====================================
  // FARMER ENDPOINTS
  // ====================================

  /// Submits a new farmer to the server
  /// Returns the created farmer data with server-generated ID
  Future<Farmer> submitFarmer(Farmer farmer) async {
    final responseData = await _makeRequest(
      'POST',
      Uri.parse(URL.farmers),
      body: farmer.toJsonOnline(),
    );
    return Farmer.fromMapOnline(responseData['data']);
  }

  /// Fetches a list of all farmers from the server
  /// Optionally filter by projectId
  Future<List<Farmer>> getFarmers({String? projectId}) async {
    final queryParams = <String, dynamic>{};
    if (projectId != null) {
      queryParams['projectId'] = projectId;
    }

    final url = Uri.parse(URL.farmers).replace(queryParameters: queryParams);

    final responseData = await _makeRequest('GET', url);
    return (responseData['data'] as List)
        .map((farmerJson) => Farmer.fromMap(farmerJson))
        .toList();
  }

  /// Fetches a single farmer by ID
  Future<Farmer> getFarmerById(String id) async {
    final responseData = await _makeRequest(
      'GET',
      Uri.parse('${URL.farmers}/$id'),
    );
    return Farmer.fromMap(responseData['data']);
  }

  /// LOGIN
  Future<User> login(LoginUser user) async {
    final responseData = await _makeRequest(
      'POST',
      Uri.parse(URL.login),
      body: user.loginMap(),
    );

    final baseData = responseData["data"]["user_profile"];
    final userData = baseData["user"];
    final districtData = baseData["district_details"];

    final userr = User(
      userID: responseData["data"]["id"],
      firstName: userData["first_name"],
      lastName: userData["last_name"],
      userName: userData["username"],
      staffId: baseData["staff_id"],
      districtName: districtData["district"],
      districtCode: districtData["district_code"],
      districtId: districtData["id"],
      regionName: districtData["region"],
      regionCode: districtData["reg_code"],
    );

    debugPrint("THE LOGIN DATA ::::::::::::::: ${userr.toJson()}");

    return User.fromJson(userr.toJson());
  }

  /// Fetch and save all districts
  Future<dynamic> fetchAndSaveDistricts() async {
    debugPrint("Fetching districts...");
    final responseData = await _makeRequest('GET', Uri.parse(URL.districts));
    final districts = (responseData['data'] as List)
        .map((districtJson) => District.fromJson(districtJson))
        .toList();

    debugPrint("Districts count: ${districts.first.toJson()}");
    await DatabaseHelper().deleteAllDistricts();
    await DatabaseHelper().bulkInsertDistricts(districts);
  }

  // fetch farmers from server
  Future<({List allFarms, List allSecondaryCrops, List farmers})> fetchFarmersFromServer() async {
    debugPrint("Fetching farmers from server...");

    try {
      final responseData = await _makeRequest('GET', Uri.parse(URL.farmers));

      // Handle the API response structure with status and msg fields
      if (responseData['status'] != 1) {
        final errorMsg = responseData['msg']?.toString() ?? 'Unknown error';
        debugPrint("Server returned error status: $errorMsg");
        throw Exception('Failed to fetch farmers: $errorMsg');
      }

      final data = responseData["data"] as List<dynamic>? ?? [];

      if (data.isEmpty) {
        debugPrint("No farmer data received from server");
        return (farmers: [], allFarms: [], allSecondaryCrops: []);
      }

      final farmers = <FarmerFromServerModel>[];
      final allFarms = <FarmFromServer>[];
      final allSecondaryCrops = <String>{}.toList(); // Use Set to avoid duplicates

      for (final farmerJson in data) {
        try {
          debugPrint("Processing farmer ID: ${farmerJson['id']}");

          final farmer = FarmerFromServerModel.fromJson(farmerJson);
          farmers.add(farmer);

          // Extract farms
          allFarms.addAll(farmer.farms);

          // Extract secondary crops and remove duplicates
          final secondaryCrops = farmer.secondaryCrops.where((crop) => crop.isNotEmpty).toList();
          allSecondaryCrops.addAll(secondaryCrops);

          // delete existing data for new one
          DatabaseHelper().deleteAllFarmersWithRelations();
          DatabaseHelper().bulkInsertFarmersWithRelations(farmers);

          debugPrint("Farmer ${farmer.firstName} ${farmer.lastName} has ${farmer.farms.length} farms and ${secondaryCrops.length} secondary crops");
        } catch (e) {
          debugPrint("Error processing farmer data ${farmerJson['id']}: $e");
          // Continue processing other farmers even if one fails
          continue;
        }
      }

      // Remove duplicate secondary crops and sort
      allSecondaryCrops
        ..toSet().toList() // Remove duplicates
        ..sort();

      debugPrint("Successfully processed ${farmers.length} farmers, "
          "${allFarms.length} farms, and ${allSecondaryCrops.length} unique secondary crops");

      return (
      farmers: farmers,
      allFarms: allFarms,
      allSecondaryCrops: allSecondaryCrops
      );
    } catch (e) {
      debugPrint("Error fetching farmers from server: $e");
      rethrow;
    }
  }
  /// Fetch and save all projects
  Future<dynamic> fetchAndSaveProjects() async {
    debugPrint("Fetching projects...");
    final responseData = await _makeRequest('GET', Uri.parse(URL.projects));
    final projects = (responseData['data'] as List)
        .map((projectJson) => Project.fromJson(projectJson))
        .toList();

    debugPrint("Projects count: ${projects.first.toJson()}");
    await DatabaseHelper().deleteAllProjects();
    await DatabaseHelper().bulkInsertProjects(projects);
  }

  /// Fetch and save all regions
  Future<dynamic> fetchAndSaveRegions() async {
    debugPrint("Fetching regions...");
    final responseData = await _makeRequest('GET', Uri.parse(URL.regions));
    final regions = (responseData['data'] as List)
        .map((regionJson) => Region.fromJson(regionJson))
        .toList();

    debugPrint("Districts count: ${regions.first.toJson()}");
    await DatabaseHelper().deleteAllRegions();
    await DatabaseHelper().bulkInsertRegions(regions);
  }

  /// Check the current app version against the server
  /// Returns a map containing version check status and data
  Future<Map<String, dynamic>> checkAppVersion() async {
    // final data = {
    //   "version": const String.fromEnvironment('VERSION_NAME', defaultValue: '1.0.0'),
    // };

    final data = {
      "version": Constants.buildNumber,
    };

    try {
      debugPrint("Checking app version with data: $data");
      
      final response = await _makeRequest(
        'POST',
        Uri.parse(URL.checkAppVersion),
        body: data,
        additionalHeaders: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint("Version check response: $response");
      
      // Return the response with success status
      return {
        'success': true,
        'status': response['status'] ?? false,
        'message': response['message'] ?? 'Version check successful',
        'data': response['data']
      };
    } catch (e) {
      debugPrint("Error in checkAppVersion: $e");
      // On error, continue with sync
      return {
        'success': false,
        'status': true, // Continue with sync on error
        'message': 'Version check error but continuing',
        'data': null,
      };
    }
  }

  /// Close the HTTP client when done
  void dispose() {
    _client.close();
  }
}




// ====================================
// CUSTOM EXCEPTION CLASSES
// ====================================

/// Base class for all API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// 400 Bad Request
class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message, 400);
}

/// 401 Unauthorized
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

/// 403 Forbidden
class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

/// 404 Not Found
class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

/// 405 Method Not Allowed
class MethodNotAllowedException extends ApiException {
  MethodNotAllowedException(String message) : super(message, 405);
}

/// 408 Request Timeout
class RequestTimeoutException extends ApiException {
  RequestTimeoutException(String message) : super(message, 408);
}

/// 409 Conflict
class ConflictException extends ApiException {
  ConflictException(String message) : super(message, 409);
}

/// 422 Unprocessable Entity
class UnprocessableEntityException extends ApiException {
  UnprocessableEntityException(String message) : super(message, 422);
}

/// 429 Rate Limit
class RateLimitException extends ApiException {
  RateLimitException(String message) : super(message, 429);
}

/// 500 Internal Server Error
class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
}

/// 502 Bad Gateway
class BadGatewayException extends ApiException {
  BadGatewayException(String message) : super(message, 502);
}

/// 503 Service Unavailable
class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException(String message) : super(message, 503);
}

/// 504 Gateway Timeout
class GatewayTimeoutException extends ApiException {
  GatewayTimeoutException(String message) : super(message, 504);
}

/// Client-side exceptions (400-499)
class ClientException extends ApiException {
  ClientException(super.message, int super.statusCode);
}

/// Network connectivity issues
class NetworkException extends ApiException {
  NetworkException(super.message);
}

/// Data parsing errors
class DataParsingException extends ApiException {
  DataParsingException(super.message);
}

/// Unsupported HTTP method
class UnsupportedMethodException extends ApiException {
  UnsupportedMethodException(super.message);
}
