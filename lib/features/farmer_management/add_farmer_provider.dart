import 'dart:io' as io;
import 'package:exim_project_monitor/core/models/projects_model.dart';
import 'package:exim_project_monitor/core/models/region_model.dart';
import 'package:exim_project_monitor/core/services/api/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../core/constants/constants.dart';
import '../../core/models/district_model.dart';
import '../../core/models/farmer_model.dart';
import '../../core/models/picked_media.dart';
import '../../core/services/database/database_helper.dart';
import '../../widgets/custom_snackbar.dart';
import '../farm_management/polygon_drawing_tool/utils/bytes_to_size.dart';

class AddFarmerProvider extends ChangeNotifier {
  // Form controllers
  final farmerNameController = TextEditingController();
  final regionController = TextEditingController();
  final districtController = TextEditingController();
  final communityController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final farmerGenderController = TextEditingController();
  final farmerDOBController = TextEditingController();
  final farmerIdNumberController = TextEditingController();

  final TextEditingController cropTypeController = TextEditingController();
  final TextEditingController varietyBreedController = TextEditingController();
  final TextEditingController plantingDensityController =
      TextEditingController();
  final TextEditingController laborHiredController = TextEditingController();
  final TextEditingController estimatedYieldController =
      TextEditingController();
  final TextEditingController yieldInPrevSeason = TextEditingController();
  final TextEditingController projectIdController = TextEditingController();

  // Selected values
  String? _selectedRegionId;
  String? _selectedRegionCode;
  String? _selectedDistrictId;
  List<Region> regions = [];

  List<District> districts = [];

  // Fetch Districts from local database
  Future<void> fetchDistricts() async {
    try {
      final districts = await DatabaseHelper().getAllDistricts();
      this.districts.clear();
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
      this.regions.clear();
      this.regions = regions;

      debugPrint('Regions count: ${regions.first.toJson()}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching regions: $e');
    }
  }

  // Getters
  String? get selectedRegionId => _selectedRegionId;
  String? get selectedRegionCode => _selectedRegionCode;
  String? get selectedDistrictId => _selectedDistrictId;

  String? _selectedProjectID;
  String? _selectedGender;
  String? get selectedProjectID => _selectedProjectID;
  String? get selectedGender => _selectedGender;

  List<String> projectIDs = [];
  List<String> genders = ["Male", "Female"];

  /// Fetch projects from local database
  Future<void> fetchProjects() async {
    try {
      final projects = await DatabaseHelper().getAllProjects();

      projectIDs.clear();

      for (var project in projects) {
        projectIDs.add(project.code);
      }
      // projectIDs = projects;

      debugPrint('Projects count: ${projects.first.toJson()}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    }
  }

  /// Form key for validation of the add farm form
  ///
  void setSelectedProject(String? val) {
    _selectedProjectID = val;
    projectIdController.text = val ?? '';
    notifyListeners();
  }

  void setSelectedGender(String? val) {
    _selectedGender = val;
    farmerGenderController.text = val ?? '';
    notifyListeners();
  }

  // Setters
  void setSelectedRegion(String? regionId) {
    regionController.text = regionId ?? '';
    _selectedRegionId = regionId;
    notifyListeners();
  }

  void setSelectedRegionCode(String? regionId) {
    _selectedRegionCode = regionId;
    notifyListeners();
  }

  void setSelectedDistrict(String? districtId) {
    districtController.text = districtId ?? '';
    _selectedDistrictId = districtId;
    notifyListeners();
  }

  // Get filtered districts based on selected region
  // List<Map<String, dynamic>> getFilteredDistricts() {
  //   if (_selectedRegionId == null) return [];
  //   return districts.where((district) => district.regionId == _selectedRegionId).toList();
  // }

  // State

  int? _farmerId;
  bool _isLoading = false;
  bool _isLoadingOFFLINE = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingOffline => _isLoadingOFFLINE;
  String? get errorMessage => _errorMessage;

  // Image handling
  final ImagePicker mediaPicker = ImagePicker();
  PickedMedia? farmerPhoto;
  DateTime? _plantingDate;
  DateTime? _harvestDate;

  DateTime? get plantingDate => _plantingDate;
  DateTime? get harvestDate => _harvestDate;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void setPlantingDate(DateTime? date) {
    _plantingDate = date;
    notifyListeners();
  }

  void setFarmerDOB(DateTime? date) {
    farmerDOBController.text = date.toString();
    // notifyListeners();
  }

  void setHarvestDate(DateTime? date) {
    _harvestDate = date;
    notifyListeners();
  }

  // Media handling
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
        final base64String = await PickedMedia.fileToBase64(file);

        farmerPhoto = PickedMedia(
          name: path.basename(mediaFile.path),
          path: mediaFile.path,
          type: 'image',
          file: file,
          base64String: base64String,
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
    communityController.clear();
    farmerDOBController.clear();
    projectIdController.clear();
    farmerPhoto = null;
    _errorMessage = null;
    formKey.currentState?.reset();

    _farmerId = null;
    _selectedRegionId = null;
    _selectedRegionCode = null;
    _selectedDistrictId = null;
    _selectedProjectID = null;

    notifyListeners();
  }

  @override
  void dispose() {
    farmerNameController.dispose();
    phoneNumberController.dispose();
    businessNameController.dispose();
    farmerGenderController.dispose();
    farmerDOBController.dispose();
    super.dispose();
  }

  DatabaseHelper dbHelper = DatabaseHelper();

  saveFarmerOffline(BuildContext context) async {
    try {
      // Convert image to base64 if available
      String? photoBase64;
      if (farmerPhoto?.file != null) {
        photoBase64 = await PickedMedia.fileToBase64(farmerPhoto!.file!);
      } else if (farmerPhoto?.base64String != null) {
        photoBase64 = farmerPhoto!.base64String;
      }

      Farmer farmer = Farmer(
        name: farmerNameController.text,
        idNumber: farmerIdNumberController.text,
        phoneNumber: phoneNumberController.text,
        // photoPath: photoBase64,
        gender: farmerGenderController.text,
        dateOfBirth: farmerDOBController.text,
        regionName: regionController.text,
        districtName: districtController.text,
        community: communityController.text,
        businessName: businessNameController.text,
        projectId: selectedProjectID ?? '',
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

      final data = farmer.toMap();
      debugPrint("THE DATA: $data");

      _isLoadingOFFLINE = true;
      notifyListeners();

      final farmerData = farmer.toMap();

      final result = await dbHelper.insertFarmer(farmerData);
      if (result >= 0) {
        clearForm();
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: 'Farmer saved successfully!',
          type: SnackbarType.success,
        );
      }

      _isLoadingOFFLINE = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoadingOFFLINE = false;
      notifyListeners();
      debugPrint('Error adding farmer: $e\n$stackTrace');
      CustomSnackbar.show(
        context,
        message: 'Error adding farmer: $e',
        type: SnackbarType.error,
      );
    }
  }

  submitFarmer(BuildContext context) async {


    try {

      //get project from local db
      Project? project = await dbHelper.getProjectByCode(selectedProjectID!);
      if (project == null) {
        throw Exception('Project not found');
      }
      // Get district name using district code
      final districtName = districts
          .firstWhere((district) => district.districtCode == selectedDistrictId)
          .district;

      // Convert image to base64 if available
      String? photoBase64;
      if (farmerPhoto?.file != null) {
        photoBase64 = await PickedMedia.fileToBase64(farmerPhoto!.file!);
      } else if (farmerPhoto?.base64String != null) {
        photoBase64 = farmerPhoto!.base64String;
      }

      Farmer farmer = Farmer(
        name: farmerNameController.text,
        idNumber: farmerIdNumberController.text,
        phoneNumber: phoneNumberController.text,
        // photoPath: photoBase64,
        gender: farmerGenderController.text,
        dateOfBirth: farmerDOBController.text,
        regionName: regionController.text,
        districtName: districtName,
        community: communityController.text,
        projectId: project.id.toString(),
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
        isSynced: SyncStatus.synced,
      );

      /// init api service
      final apiService = APIService();

      /// show loading
      _isLoading = true;
      notifyListeners();

      await apiService
          .submitFarmer(farmer)
          .then((response) async {
            // debugPrint("THE RESPONSE: $response");
            _isLoading = false;
            notifyListeners();

            // debugPrint("THE RESPONSE: $response");

            final data = farmer.toMap();
            data['districtName'] = districtController.text;
            final result = await dbHelper.insertFarmer(data);

            if (result >= 0) {
              clearForm();
              debugPrint("THE DB ID :::::::::: $result");

              Navigator.pop(context);
              CustomSnackbar.show(
                context,
                message: 'Farmer submitted successfully!',
                type: SnackbarType.success,
              );
            }
          })
          .catchError((error, stackTrace) {
            _isLoading = false;
            notifyListeners();
            debugPrint('Error adding farmer via API: $error');
            debugPrint('Error adding farmer via API: $stackTrace');
            CustomSnackbar.show(
              context,
              message: 'Error adding farmer: $error',
              type: SnackbarType.error,
            );
          });

      final data = farmer.toJsonOnline();
      debugPrint("THE DATA: $data");
      //
      // _isLoading = true;
      // notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error adding farmer: $e\n$stackTrace');
      CustomSnackbar.show(
        context,
        message: 'Error adding farmer: $e',
        type: SnackbarType.error,
      );
    }
  }
}
