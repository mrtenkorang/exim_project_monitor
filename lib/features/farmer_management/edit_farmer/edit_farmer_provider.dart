import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../core/models/farmer_model.dart';
import '../../../core/models/picked_media.dart';
import '../../../core/services/database/database_helper.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../farm_management/polygon_drawing_tool/utils/bytes_to_size.dart';

class EditFarmerProvider extends ChangeNotifier {

  // Form controllers
  final projectIdController = TextEditingController();
  final farmerNameController = TextEditingController();
  final regionController = TextEditingController();
  final districtController = TextEditingController();
  final communityController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final farmerIdNumberController = TextEditingController();
  final farmerGenderController = TextEditingController();
  final farmerDOBController = TextEditingController();
  final farmerPhoneNumber = TextEditingController();


  final TextEditingController cropTypeController = TextEditingController();
  final TextEditingController varietyBreedController = TextEditingController();
  final TextEditingController plantingDensityController = TextEditingController();
  final TextEditingController laborHiredController = TextEditingController();
  final TextEditingController estimatedYieldController = TextEditingController();
  final TextEditingController yieldInPrevSeason = TextEditingController();


  // Selected values
  String? _selectedRegionId;
  String? _selectedDistrictId;
  String? _selectedProjectID;

  final List<Map<String, dynamic>> regions = [
    {"region_id": "1", "region": "Greater Accra"},
    {"region_id": "2", "region": "Eastern Region"},
    {"region_id": "3", "region": "Brong Ahafo"},
    {"region_id": "4", "region": "Ashanti"},
    {"region_id": "5", "region": "Western"},
    {"region_id": "6", "region": "Northern"},
  ];

  final List<Map<String, dynamic>> districts = [
    {"region_id": "1", "district_id": "1", "district": "Accra Metro"},
    {"region_id": "1", "district_id": "2", "district": "Tema Metro"},
    {"region_id": "2", "district_id": "3", "district": "East Akim"},
    {"region_id": "2", "district_id": "4", "district": "West Akim"},
    {"region_id": "3", "district_id": "5", "district": "Sunyani"},
    {"region_id": "3", "district_id": "6", "district": "Techiman"},
    {"region_id": "4", "district_id": "7", "district": "Kumasi Metro"},
    {"region_id": "4", "district_id": "8", "district": "Obuasi"},
    {"region_id": "5", "district_id": "9", "district": "Takoradi"},
    {"region_id": "5", "district_id": "10", "district": "Sekondi"},
    {"region_id": "6", "district_id": "11", "district": "Tamale Metro"},
    {"region_id": "6", "district_id": "12", "district": "Savelugu"},
  ];

  // Getters
  String? get selectedRegionId => _selectedRegionId;
  String? get selectedDistrictId => _selectedDistrictId;


  // Setters
  void setSelectedRegion(String? regionId) {
    _selectedRegionId = regionId;
    _selectedDistrictId = null; // Reset district when region changes
    notifyListeners();
  }

  void setSelectedDistrict(String? districtId) {
    _selectedDistrictId = districtId;
    notifyListeners();
  }

  // Get filtered districts based on selected region
  List<Map<String, dynamic>> getFilteredDistricts() {
    if (_selectedRegionId == null) return [];
    return districts.where((district) => district['region_id'] == _selectedRegionId).toList();
  }

  // State

  int? _farmerId;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Image handling
  final ImagePicker mediaPicker = ImagePicker();
  PickedMedia? farmerPhoto;
  DateTime? _plantingDate;
  DateTime? _harvestDate;
  DateTime? _farmerDOB;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Getters for dates
  DateTime? get plantingDate => _plantingDate;
  DateTime? get harvestDate => _harvestDate;
  DateTime? get farmerDOB => _farmerDOB;

  void setPlantingDate(DateTime? date) {
    _plantingDate = date;
    notifyListeners();
  }

  void setHarvestDate(DateTime? date) {
    _harvestDate = date;
    notifyListeners();
  }

  void setFarmerDOB(DateTime? date) {
    _farmerDOB = date;
    if (date != null) {
      farmerDOBController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } else {
      farmerDOBController.clear();
    }
    notifyListeners();
  }

  // Helper method to parse date string to DateTime
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.tryParse(dateString);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  Future<void> initializeFromFarmerData(Farmer farmer) async {
    try {
      _farmerId = farmer.id;
      
          // Set basic information
      farmerNameController.text = farmer.name ?? '';
      phoneNumberController.text = farmer.phoneNumber ?? '';
      farmerGenderController.text = farmer.gender ?? '';
      farmerIdNumberController.text = farmer.idNumber ?? '';
      
      // Handle date of birth
      _farmerDOB = _parseDate(farmer.dateOfBirth);
      if (_farmerDOB != null) {
        farmerDOBController.text = "${_farmerDOB!.year}-${_farmerDOB!.month.toString().padLeft(2, '0')}-${_farmerDOB!.day.toString().padLeft(2, '0')}";
      } else {
        farmerDOBController.text = farmer.dateOfBirth ?? '';
      }
      
      // Set location information
      communityController.text = farmer.community ?? '';
      
      // Set region and district
      if (farmer.regionName.isNotEmpty) {
        regionController.text = farmer.regionName;
        final region = regions.firstWhere(
          (r) => r['region'] == farmer.regionName,
          orElse: () => {'region_id': null},
        );
        if (region['region_id'] != null) {
          _selectedRegionId = region['region_id'].toString();
        }
      }

      if (farmer.districtName.isNotEmpty) {
        districtController.text = farmer.districtName;
        if (_selectedRegionId != null) {
          final district = districts.firstWhere(
            (d) => d['district'] == farmer.districtName && d['region_id'] == _selectedRegionId,
            orElse: () => {'district_id': null},
          );
          if (district['district_id'] != null) {
            _selectedDistrictId = district['district_id'].toString();
          }
        }
      }
      
      // Set crop information
      cropTypeController.text = farmer.cropType ?? '';
      varietyBreedController.text = farmer.varietyBreed ?? '';
      plantingDensityController.text = farmer.plantingDensity.toString() ?? '';
      laborHiredController.text = farmer.laborHired.toString() ?? '';
      estimatedYieldController.text = farmer.estimatedYield.toString() ?? '';
      yieldInPrevSeason.text = farmer.previousYield.toString() ?? '';

      // Set dates
      _plantingDate = farmer.plantingDate;
      _harvestDate = farmer.harvestDate;

          // Set region and district
      if (farmer.regionName.isNotEmpty) {
        regionController.text = farmer.regionName;
        final region = regions.firstWhere(
          (r) => r['region'] == farmer.regionName,
          orElse: () => {'region_id': null},
        );
        if (region['region_id'] != null) {
          _selectedRegionId = region['region_id'].toString();
        }
      }

      if (farmer.districtName.isNotEmpty) {
        districtController.text = farmer.districtName;
        if (_selectedRegionId != null) {
          final district = districts.firstWhere(
            (d) => d['district'] == farmer.districtName && d['region_id'] == _selectedRegionId,
            orElse: () => {'district_id': null},
          );
          if (district['district_id'] != null) {
            _selectedDistrictId = district['district_id'].toString();
          }
        }
      }

      // Handle photo
      if (farmer.photoPath != null && farmer.photoPath!.isNotEmpty) {
        // Check if it's a base64 string or a file path
        if (farmer.photoPath!.startsWith('data:image/')) {
          // It's a base64 string
          farmerPhoto = PickedMedia(
            name: 'farmer_${farmer.id}_photo',
            type: 'image',
            base64String: farmer.photoPath!,
          );
        } else {
          // It's a file path
          final file = io.File(farmer.photoPath!);
          if (await file.exists()) {
            final base64String = await PickedMedia.fileToBase64(file);
            farmerPhoto = PickedMedia(
              name: path.basename(farmer.photoPath!),
              path: farmer.photoPath!,
              base64String: base64String,
              type: 'image',
              file: file,
            );
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing farmer data: $e');
      rethrow;
    }
  }


  Future<void> pickMedia({int? source}) async {
    try {
      final XFile? mediaFile = await mediaPicker.pickImage(
        source: source == 0 ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (mediaFile != null) {
        final file = io.File(mediaFile.path);
        final fileSize = await file.length();

        farmerPhoto = PickedMedia(
          name: path.basename(mediaFile.path),
          path: mediaFile.path,
          type: 'image',
          file: file,
        );

        notifyListeners();
        debugPrint('Selected image size: ${bytesToSize(fileSize)}');
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }

  // Clear form
  void clearForm() {
    _farmerId = null;
    farmerNameController.clear();
    phoneNumberController.clear();
    businessNameController.clear();
    farmerIdNumberController.clear();
    farmerGenderController.clear();
    farmerDOBController.clear();
    projectIdController.clear();
    farmerPhoto = null;
    _errorMessage = null;
    formKey.currentState?.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    projectIdController.dispose();
    farmerNameController.dispose();
    phoneNumberController.dispose();
    businessNameController.dispose();
    farmerIdNumberController.dispose();
    farmerGenderController.dispose();
    farmerDOBController.dispose();
    farmerPhoneNumber.dispose();
    super.dispose();
  }

  DatabaseHelper dbHelper = DatabaseHelper();

  saveFarmerOffline(BuildContext context) async {

    try {
      Farmer farmer = Farmer(
        idNumber: farmerIdNumberController.text,
        name: farmerNameController.text,
        phoneNumber: phoneNumberController.text,
        gender: farmerGenderController.text,
        dateOfBirth: farmerDOBController.text,
        photoPath: farmerPhoto?.path,
        regionName: regionController.text,
        districtName: districtController.text,
        community: communityController.text,
        cropType: cropTypeController.text,
        varietyBreed: varietyBreedController.text,
        plantingDate: _plantingDate,
        plantingDensity: plantingDensityController.text,
        laborHired: laborHiredController.text,
        estimatedYield: estimatedYieldController.text,
        previousYield: yieldInPrevSeason.text,
        harvestDate: _harvestDate,
        createdAt: DateTime.now(),
        isSynced: false,
      );

      _isLoading = true;
      notifyListeners();

      final result = await dbHelper.insertFarmer(farmer);
      if (result > 0) {
        CustomSnackbar.show(
          context,
          message: 'Farmer added successfully!',
          type: SnackbarType.success,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error adding farmer: $e\n$stackTrace');
      CustomSnackbar.show(
        context,
        message: 'Error adding farmer: $e',
        type: SnackbarType.error,
      );

    }

  }
}