import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:exim_project_monitor/core/services/database/database_helper.dart';
import 'package:exim_project_monitor/core/models/farm_model.dart';
import 'package:sqflite/sqflite.dart';

class ExportService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  static const String _exportFolderName = 'FarmDataExports';

  /// Gets or creates the export directory
  Future<Directory> _getExportDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory exportDir = Directory(
      '${appDocDir.path}/$_exportFolderName',
    );

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    return exportDir;
  }

  /// Gets list of all exported files
  Future<List<FileSystemEntity>> getExportedFiles() async {
    final exportDir = await _getExportDirectory();
    return exportDir.list().toList();
  }

  /// Deletes a specific exported file
  Future<void> deleteExportedFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Clears all exported files
  Future<void> clearAllExports() async {
    final exportDir = await _getExportDirectory();
    if (await exportDir.exists()) {
      await exportDir.delete(recursive: true);
      await exportDir.create(recursive: true);
    }
  }

  /// Exports all farm data to an Excel file using simple XML format and saves to folder
  Future<File> exportFarmsToExcel({bool shareFile = true}) async {
    try {
      // Get all farms from database
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> farmMaps = await db.query('farms');

      if (farmMaps.isEmpty) {
        throw Exception('No farm data available to export');
      }

      // Prepare headers
      final headers = [
        'Farmer',
        'Farm Name',
        'Project',
        'Main Buyers',
        'Land Use Classification',
        'Accessibility',
        'Proximity to Processing Plants',
        'Service Provider',
        'Farmer Groups Affiliated',
        'Value Chain Linkages',
        'Visit ID',
        'Visit Date',
        'Officer',
        'Observation',
        'Issues Identified',
        'Infrastructure Identified',
        'Recommended Actions',
        'Follow Up Actions',
        'Area (Hectares)',
        'Soil Type',
        'Irrigation Type',
        'Irrigation Coverage',
        'Boundary Coordinates',
        'Latitude',
        'Longitude',
        'Altitude',
        'Slope',
        'Status',
        'Last Visit Date',
        'Validation Status',
        'Crop Type',
        'Variety',
        'Planting Date',
        'Labours Hired',
        'Male Labors',
        'Female Labors',
        'Planting Density',
        'Total Trees',
        'Tree Density',
        'Estimated Yield',
        'Yield in Pre Season',
        'Harvest Date',
      ];

      // Create Excel XML content
      final excelContent = StringBuffer();

      // Excel XML header
      excelContent.writeln('<?xml version="1.0"?>');
      excelContent.writeln('<?mso-application progid="Excel.Sheet"?>');
      excelContent.writeln(
        '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"',
      );
      excelContent.writeln(
        ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">',
      );
      excelContent.writeln(' <Worksheet ss:Name="Farms">');
      excelContent.writeln('  <Table>');

      // Add headers row
      excelContent.writeln('   <Row>');
      for (var header in headers) {
        excelContent.writeln(
          '    <Cell><Data ss:Type="String">$header</Data></Cell>',
        );
      }
      excelContent.writeln('   </Row>');

      // Add data rows
      for (var farmMap in farmMaps) {
        final farm = Farm.fromMap(farmMap);
        final data = farm.toJson();

        excelContent.writeln('   <Row>');

        // Map data to headers with proper field mapping
        final fieldMappings = {
          'Farmer': 'farmer_id',
          'Farm Name': 'name',
          'Project': 'project',
          'Main Buyers': 'mainBuyers',
          'Land Use Classification': 'landUseClassification',
          'Accessibility': 'accessibility',
          'Proximity to Processing Plants': 'proximityToFacility',
          'Service Provider': 'serviceProvider',
          'Farmer Groups Affiliated': 'cooperativesOrFarmerGroups',
          'Value Chain Linkages': 'valueChainLinkages',
          'Visit ID': 'visitId',
          'Visit Date': 'dateOfVisit',
          'Officer': 'officerId',
          'Observation': 'observations',
          'Issues Identified': 'issuesIdentified',
          'Infrastructure Identified': 'infrastructureIdentified',
          'Recommended Actions': 'recommendedActions',
          'Follow Up Actions': 'followUpStatus',
          'Area (Hectares)': 'farmSize',
          'Soil Type': 'soilType',
          'Irrigation Type': 'irrigationType',
          'Irrigation Coverage': 'irrigationCoverage',
          'Boundary Coordinates': 'farmBoundaryPolygon',
          'Latitude': 'latitude',
          'Longitude': 'longitude',
          'Altitude': 'altitude',
          'Slope': 'slope',
          'Status': 'status',
          'Last Visit Date': 'lastVisitDate',
          'Validation Status': 'validationStatus',
          'Crop Type': 'cropType',
          'Variety': 'varietyBreed',
          'Planting Date': 'plantingDate',
          'Labours Hired': 'labourHired',
          'Male Labors': 'maleWorkers',
          'Female Labors': 'femaleWorkers',
          'Planting Density': 'plantingDensity',
          'Total Trees': 'totalTrees',
          'Tree Density': 'treeDensity',
          'Estimated Yield': 'estimatedYield',
          'Yield in Pre Season': 'previousYield',
          'Harvest Date': 'harvestDate',
        };

        for (var header in headers) {
          final fieldName = fieldMappings[header] ?? '';
          var value = data[fieldName]?.toString() ?? '';

          // Handle special cases
          if (header == 'Boundary Coordinates' && value.contains('[')) {
            try {
              final coords = jsonDecode(value) as List;
              value = coords
                  .map((c) => '${c['latitude']},${c['longitude']}')
                  .join('; ');
            } catch (e) {
              value = 'Error parsing coordinates';
            }
          }

          // Format dates if needed
          if ((header.endsWith('Date') || header.endsWith('date')) &&
              value.isNotEmpty) {
            try {
              final date = DateTime.tryParse(value);
              if (date != null) {
                value =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              }
            } catch (e) {
              // If date parsing fails, keep the original value
            }
          }

          // Escape XML special characters
          value = value
              .replaceAll('&', '&amp;')
              .replaceAll('<', '&lt;')
              .replaceAll('>', '&gt;')
              .replaceAll('"', '&quot;')
              .replaceAll("'", '&apos;');

          excelContent.writeln(
            '    <Cell><Data ss:Type="String">$value</Data></Cell>',
          );
        }

        excelContent.writeln('   </Row>');
      }

      // Close XML tags
      excelContent.writeln('  </Table>');
      excelContent.writeln(' </Worksheet>');
      excelContent.writeln('</Workbook>');

      // Save the Excel file to export folder
      final exportDir = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'farms_export_$timestamp.xls';
      final filePath = '${exportDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(excelContent.toString());

      // Share the file if requested
      if (shareFile) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exported Farm Data (Excel)',
          subject: 'Farm Data Export',
        );
      }

      return file;
    } catch (e) {
      throw Exception('Failed to export farm data to Excel: $e');
    }
  }

  /// Exports all farm data to a CSV file and saves to folder
  Future<File> exportFarmsToCSV({bool shareFile = true}) async {
    try {
      // Get all farms from database
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> farmMaps = await db.query('farms');

      if (farmMaps.isEmpty) {
        throw Exception('No farm data available to export');
      }

      // Define headers and their corresponding field names
      final headers = [
        'Farmer',
        'Farm Name',
        'Project',
        'Main Buyers',
        'Land Use Classification',
        'Accessibility',
        'Proximity to Processing Plants',
        'Service Provider',
        'Farmer Groups Affiliated',
        'Value Chain Linkages',
        'Visit ID',
        'Visit Date',
        'Officer',
        'Observation',
        'Issues Identified',
        'Infrastructure Identified',
        'Recommended Actions',
        'Follow Up Actions',
        'Area (Hectares)',
        'Soil Type',
        'Irrigation Type',
        'Irrigation Coverage',
        'Boundary Coordinates',
        'Latitude',
        'Longitude',
        'Altitude',
        'Slope',
        'Status',
        'Last Visit Date',
        'Validation Status',
        'Crop Type',
        'Variety',
        'Planting Date',
        'Labours Hired',
        'Male Labors',
        'Female Labors',
        'Planting Density',
        'Total Trees',
        'Tree Density',
        'Estimated Yield',
        'Yield in Pre Season',
        'Harvest Date',
      ];

      // Field mappings (same as in Excel export)
      final fieldMappings = {
        'Farmer': 'farmer_id',
        'Farm Name': 'name',
        'Project': 'project',
        'Main Buyers': 'mainBuyers',
        'Land Use Classification': 'landUseClassification',
        'Accessibility': 'accessibility',
        'Proximity to Processing Plants': 'proximityToFacility',
        'Service Provider': 'serviceProvider',
        'Farmer Groups Affiliated': 'cooperativesOrFarmerGroups',
        'Value Chain Linkages': 'valueChainLinkages',
        'Visit ID': 'visitId',
        'Visit Date': 'dateOfVisit',
        'Officer': 'officerId',
        'Observation': 'observations',
        'Issues Identified': 'issuesIdentified',
        'Infrastructure Identified': 'infrastructureIdentified',
        'Recommended Actions': 'recommendedActions',
        'Follow Up Actions': 'followUpStatus',
        'Area (Hectares)': 'farmSize',
        'Soil Type': 'soilType',
        'Irrigation Type': 'irrigationType',
        'Irrigation Coverage': 'irrigationCoverage',
        'Boundary Coordinates': 'farmBoundaryPolygon',
        'Latitude': 'latitude',
        'Longitude': 'longitude',
        'Altitude': 'altitude',
        'Slope': 'slope',
        'Status': 'status',
        'Last Visit Date': 'lastVisitDate',
        'Validation Status': 'validationStatus',
        'Crop Type': 'cropType',
        'Variety': 'varietyBreed',
        'Planting Date': 'plantingDate',
        'Labours Hired': 'labourHired',
        'Male Labors': 'maleWorkers',
        'Female Labors': 'femaleWorkers',
        'Planting Density': 'plantingDensity',
        'Total Trees': 'totalTrees',
        'Tree Density': 'treeDensity',
        'Estimated Yield': 'estimatedYield',
        'Yield in Pre Season': 'previousYield',
        'Harvest Date': 'harvestDate',
      };

      // Create CSV content
      final csvContent = StringBuffer();

      // Add headers
      csvContent.writeln(headers.map((h) => _escapeCsvField(h)).join(','));

      // Add data rows
      for (var farmMap in farmMaps) {
        final farm = Farm.fromMap(farmMap);
        final data = farm.toJson();

        final row = headers
            .map((header) {
              final fieldName = fieldMappings[header] ?? '';
              var value = data[fieldName]?.toString() ?? '';

              // Handle special cases
              if (header == 'Boundary Coordinates' && value.contains('[')) {
                try {
                  final coords = jsonDecode(value) as List;
                  value = coords
                      .map((c) => '${c['latitude']},${c['longitude']}')
                      .join('; ');
                } catch (e) {
                  value = 'Error parsing coordinates';
                }
              }

              // Format dates if needed
              if ((header.endsWith('Date') || header.endsWith('date')) &&
                  value.isNotEmpty) {
                try {
                  final date = DateTime.tryParse(value);
                  if (date != null) {
                    value =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                } catch (e) {
                  // If date parsing fails, keep the original value
                }
              }

              return _escapeCsvField(value);
            })
            .join(',');

        csvContent.writeln(row);
      }

      // Save the CSV file to export folder
      final exportDir = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'farms_export_$timestamp.csv';
      final filePath = '${exportDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvContent.toString());

      // Share the file if requested
      if (shareFile) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exported Farm Data (CSV)',
          subject: 'Farm Data Export',
        );
      }

      return file;
    } catch (e) {
      throw Exception('Failed to export farm data to CSV: $e');
    }
  }

  /// Exports all farm data to a JSON file and saves to folder
  Future<File> exportFarmsToJSON({bool shareFile = true}) async {
    try {
      // Get all farms from database
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> farmMaps = await db.query('farms');

      if (farmMaps.isEmpty) {
        throw Exception('No farm data available to export');
      }

      // Convert to Farm objects and then to JSON
      final farms = farmMaps.map((map) => Farm.fromMap(map)).toList();
      final List<Map<String, dynamic>> jsonData = farms
          .map((farm) => farm.toJson())
          .toList();

      // Convert to formatted JSON string
      final jsonString = _formatJson(jsonData);

      // Save the JSON file to export folder
      final exportDir = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'farms_export_$timestamp.json';
      final filePath = '${exportDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share the file if requested
      if (shareFile) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exported Farm Data (JSON)',
          subject: 'Farm Data Export',
        );
      }

      return file;
    } catch (e) {
      throw Exception('Failed to export farm data to JSON: $e');
    }
  }

  /// Helper method to escape CSV fields
  String _escapeCsvField(String field) {
    if (field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r')) {
      // Escape quotes and wrap in quotes
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    return field;
  }

  /// Helper method to format JSON with proper indentation
  String _formatJson(List<Map<String, dynamic>> data) {
    final buffer = StringBuffer();
    buffer.writeln('[');

    for (var i = 0; i < data.length; i++) {
      buffer.writeln('  {');

      final entries = data[i].entries.toList();
      for (var j = 0; j < entries.length; j++) {
        final entry = entries[j];
        final value = entry.value?.toString() ?? '';
        final comma = j < entries.length - 1 ? ',' : '';
        buffer.writeln('    "${entry.key}": "$value"$comma');
      }

      final comma = i < data.length - 1 ? ',' : '';
      buffer.writeln('  }$comma');
    }

    buffer.writeln(']');
    return buffer.toString();
  }

  /// Generic export method that supports multiple formats
  Future<File> exportFarms({
    required String format,
    bool shareFile = true,
  }) async {
    switch (format.toLowerCase()) {
      case 'excel':
        return await exportFarmsToExcel(shareFile: shareFile);
      case 'csv':
        return await exportFarmsToCSV(shareFile: shareFile);
      case 'json':
        return await exportFarmsToJSON(shareFile: shareFile);
      default:
        throw Exception('Unsupported export format: $format');
    }
  }

  /// Get available export formats
  List<String> getAvailableFormats() {
    return ['Excel', 'CSV', 'JSON'];
  }

  /// Get file extension for each format
  String getFileExtension(String format) {
    switch (format.toLowerCase()) {
      case 'excel':
        return 'xls';
      case 'csv':
        return 'csv';
      case 'json':
        return 'json';
      default:
        return 'txt';
    }
  }

  /// Gets the total size of all exported files
  Future<int> getTotalExportSize() async {
    final exportDir = await _getExportDirectory();
    if (!await exportDir.exists()) return 0;

    final files = await exportDir.list().toList();
    int totalSize = 0;

    for (var file in files) {
      if (file is File) {
        totalSize += await file.length();
      }
    }

    return totalSize;
  }
}
