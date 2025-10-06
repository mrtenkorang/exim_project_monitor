import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../core/constants/constants.dart';
import '../../../core/models/district_model.dart';
import '../../../core/models/farmer_model.dart';
import '../../../core/models/picked_media.dart';
import '../../../core/models/region_model.dart';
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
  String? _selectedRegionCode;
  String? _selectedDistrictId;
  String? _selectedProjectID;


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


  List<Region> regions = [];

  List<District> districts = [];

  // Fetch Districts from local database
  Future<void> fetchDistricts() async {
    try {
      final districts = await DatabaseHelper().getAllDistricts();
      this.districts = districts;

      debugPrint('Districts count: ${districts.first.toJson()}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  // Fetch Regions from local database
  Future<void> fetchRegions() async {
    try {
      final regions = await DatabaseHelper().getAllRegions();
      this.regions = regions;

      debugPrint('Regions count: ${regions.first.toJson()}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching regions: $e');
    }
  }

  List<String> projectIDs = [];

  /// Fetch projects from local database
  Future<void> fetchProjects() async {
    try {
      final projects = await DatabaseHelper().getAllProjects();

      projects.forEach((project) {
        projectIDs.add(project.code);
      });
      // projectIDs = projects;

      debugPrint('Projects count: ${projects.first.toJson()}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    }
  }

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
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> initializeFromFarmerData(Farmer farmer) async {
    try {
      _farmerId = farmer.id;
      
      // Set basic information
      farmerNameController.text = farmer.name;
      phoneNumberController.text = farmer.phoneNumber;
      farmerGenderController.text = farmer.gender;
      farmerIdNumberController.text = farmer.idNumber;
      businessNameController.text = farmer.businessName;
      projectIdController.text = farmer.projectId;

      setSelectedProject(farmer.projectId);
      
      // Handle date of birth
      _farmerDOB = _parseDate(farmer.dateOfBirth);
      if (_farmerDOB != null) {
        farmerDOBController.text = _formatDate(_farmerDOB!);
      } else {
        farmerDOBController.text = farmer.dateOfBirth;
      }
      
      // Set location information
      communityController.text = farmer.community;
      
      debugPrint('Initializing with region: ${farmer.regionName}, district: ${farmer.districtName}');
      
      // Ensure regions and districts are loaded first
      await fetchRegions();
      await fetchDistricts();
      await fetchProjects();

      debugPrint('Total regions loaded: ${regions.length}');
      debugPrint('Total districts loaded: ${districts.length}');
      
      // Set region and district
      if (farmer.regionName.isNotEmpty) {
        debugPrint('Looking for region: ${farmer.regionName}');
        
        // First try to find the region by name or code
        var region = regions.firstWhere(
          (r) => r.region.toLowerCase() == farmer.regionName.toLowerCase() || 
                 r.regCode.toLowerCase() == farmer.regionName.toLowerCase(),
          orElse: () => Region(id: 0, region: '', regCode: '', createdAt: '', updatedAt: ''),
        );
        
        if (region.region.isNotEmpty) {
          debugPrint('Found region: ${region.region} (${region.regCode})');
          _selectedRegionId = region.regCode;
          _selectedRegionCode = region.regCode;
          regionController.text = region.region;
          
          // Now set the district after region is set
          if (farmer.districtName.isNotEmpty) {
            debugPrint('Looking for district: ${farmer.districtName} in region: ${region.regCode}');
            
            // Find the district by name within the selected region (case insensitive)
            final district = districts.firstWhere(
              (d) => (d.district.toLowerCase() == farmer.districtName.toLowerCase() ||
                     (d.districtCode.toLowerCase()) == farmer.districtName.toLowerCase()) &&
                    d.regCode == _selectedRegionId,
              orElse: () => District(id: 0, district: '', districtCode: '', regCode: '', region: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
            );
            
            if (district.district.isNotEmpty) {
              _selectedDistrictId = district.id.toString();
              districtController.text = district.district;
              debugPrint('✓ District set to: ${district.district} (ID: ${district.id})');
            } else {
              debugPrint('✗ District not found: ${farmer.districtName} for region: ${region.region}');
              // Try to find any district that matches the name regardless of region
              final anyDistrict = districts.firstWhere(
                (d) => d.district.toLowerCase() == farmer.districtName.toLowerCase() ||
                       (d.districtCode.toLowerCase() ?? '') == farmer.districtName.toLowerCase(),
                orElse: () => District(id: 0, district: '', districtCode: '', regCode: '', region: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
              );
              
              if (anyDistrict.district.isNotEmpty) {
                debugPrint('Found district in different region: ${anyDistrict.district} (Region: ${anyDistrict.regCode})');
                districtController.text = anyDistrict.district;
              }
            }
          }
        } else {
          debugPrint('✗ Region not found: ${farmer.regionName}');
          debugPrint('Available regions: ${regions.map((r) => '${r.region} (${r.regCode})').toList()}');
        }
      }
      
      // Set project ID if available
      if (farmer.projectId.isNotEmpty) {
        if (projectIDs.contains(farmer.projectId)) {
          _selectedProjectID = farmer.projectId;
        }
      }

      // Handle photo
      // if (farmer.photoPath != null && farmer.photoPath!.isNotEmpty) {
      //   // Check if it's a base64 string or a file path
      //   if (farmer.photoPath!.startsWith('data:image/')) {
      //     // It's a base64 string
      //     farmerPhoto = PickedMedia(
      //       name: 'farmer_${farmer.id}_photo',
      //       type: 'image',
      //       base64String: farmer.photoPath!,
      //     );
      //   } else {
      //     // It's a file path
      //     final file = io.File(farmer.photoPath!);
      //     if (await file.exists()) {
      //       final base64String = await PickedMedia.fileToBase64(file);
      //       farmerPhoto = PickedMedia(
      //         name: path.basename(farmer.photoPath!),
      //         path: farmer.photoPath!,
      //         base64String: base64String,
      //         type: 'image',
      //         file: file,
      //       );
      //     }
      //   }

      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing farmer data: $e');
      rethrow;
    }
  }


  String? get selectedProjectID => _selectedProjectID;

  /// Form key for validation of the add farm form
  ///
  void setSelectedProject(String? val) {
    _selectedProjectID = val;
    projectIdController.text = val ?? '';
    notifyListeners();
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

    debugPrint("Started save offline");
    try {
      Farmer farmer = Farmer(
        idNumber: farmerIdNumberController.text,
        name: farmerNameController.text,
        phoneNumber: phoneNumberController.text,
        gender: farmerGenderController.text,
        dateOfBirth: farmerDOBController.text,
        // photoPath: farmerPhoto?.path,
        regionName: regionController.text,
        districtName: districtController.text,
        community: communityController.text,
        projectId: projectIdController.text,
        businessName: businessNameController.text,
        // cropType: cropTypeController.text,
        // varietyBreed: varietyBreedController.text,
        // plantingDate: _plantingDate,
        // plantingDensity: plantingDensityController.text,
        // laborHired: laborHiredController.text,
        // estimatedYield: estimatedYieldController.text,
        // previousYield: yieldInPrevSeason.text,
        // harvestDate: _harvestDate,
        createdAt: DateTime.now(),
        isSynced: SyncStatus.notSynced,
      );

      _isLoading = true;
      notifyListeners();

      final result = await dbHelper.updateFarmer(farmer);

      debugPrint("Result: $result");

      if (result >= 0) {
        Navigator.of(context).pop();
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