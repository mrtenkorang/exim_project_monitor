import 'package:exim_project_monitor/core/models/district_model.dart';
import 'package:exim_project_monitor/core/models/farmer_model.dart';
import 'package:exim_project_monitor/core/services/database/database_helper.dart';
import 'package:exim_project_monitor/widgets/globals/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/models/server_models/farmers_model/farmers_from_server.dart';
import '../../../../../core/services/api/api.dart';

class EditFarmerFromServerController extends GetxController {
  final APIService _apiService = APIService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final formKey = GlobalKey<FormState>();
  BuildContext? editFarmerFromServerScreenContext;

  final FarmerFromServerModel farmer;

  EditFarmerFromServerController({required this.farmer});

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final nationalIdController = TextEditingController();
  final bankAccountNumberController = TextEditingController();
  final bankNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final communityController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  var selectedGender = ''.obs;
  var selectedRegion = ''.obs;
  var selectedDistrict = ''.obs;
  var selectedPrimaryCrop = ''.obs;
  var selectedCropType = ''.obs;
  var selectedVariety = ''.obs;

  var selectedSecondaryCrops = <String>[].obs;
  var extensionServices = false.obs;

  var dateOfBirth = ''.obs;
  var plantingDate = ''.obs;
  var harvestDate = ''.obs;

  var yearsOfExperience = 0.obs;
  var labourHired = 0.obs;
  var estimatedYield = 0.0.obs;
  var yieldInPreSeason = 0.0.obs;

  final districts = <District>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFormWithFarmerData();
    fetchDistricts();
  }

  Future<void> fetchDistricts() async {
    try {
      final districtsList = await _databaseHelper.getAllDistricts();
      districts.assignAll(districtsList);
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  void _initializeFormWithFarmerData() {
    firstNameController.text = farmer.firstName;
    lastNameController.text = farmer.lastName;
    phoneNumberController.text = farmer.phoneNumber;
    emailController.text = farmer.email;
    addressController.text = farmer.address;
    nationalIdController.text = farmer.nationalId;
    bankAccountNumberController.text = farmer.bankAccountNumber;
    bankNameController.text = farmer.bankName;
    businessNameController.text = farmer.businessName;
    communityController.text = farmer.community;

    selectedGender.value = farmer.gender;
    selectedPrimaryCrop.value = farmer.primaryCrop;
    selectedCropType.value = farmer.cropType;
    selectedVariety.value = farmer.variety;
    selectedSecondaryCrops.value = List<String>.from(farmer.secondaryCrops);
    extensionServices.value = farmer.extensionServices;
    selectedRegion.value = farmer.regionName;
    selectedDistrict.value = farmer.districtName;

    dateOfBirth.value = farmer.dateOfBirth;
    plantingDate.value = farmer.plantingDate;
    harvestDate.value = farmer.harvestDate;

    yearsOfExperience.value = farmer.yearsOfExperience;
    labourHired.value = farmer.labourHired;
    estimatedYield.value = double.tryParse(farmer.estimatedYield) ?? 0.0;
    yieldInPreSeason.value = double.tryParse(farmer.yieldInPreSeason) ?? 0.0;
  }

  Future<bool> updateFarmer() async {
    try {
      if (!formKey.currentState!.validate()) return false;

      isLoading.value = true;
      errorMessage.value = '';

      final updatedFarmer = Farmer(
          id: farmer.id,
          projectId: "",
          name: "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
          idNumber: nationalIdController.text.trim(),
          phoneNumber: phoneNumberController.text.trim(),
          gender: selectedGender.value,
          dateOfBirth: dateOfBirth.value,
          regionName: selectedRegion.value,
          districtName: selectedDistrict.value,
          community: communityController.text.trim(),
          businessName: businessNameController.text.trim(),
          isSynced: 0
      );

      final Map<String, dynamic> farmerMap = updatedFarmer.toJsonOnline();
      debugPrint("THE FARMER DATA ::::::::: $farmerMap");

      Globals().startWait(editFarmerFromServerScreenContext!);
      Farmer farmerResponse = await _apiService.updateFarmer(updatedFarmer);
      Globals().endWait(editFarmerFromServerScreenContext!);

      if (farmerResponse.id.toString().isNotEmpty) {
        Get.back();
        Get.back();
        Globals().showSnackBar(
          title: 'Success',
          message: 'Farmer updated successfully',
          backgroundColor: Colors.green,
        );
        successMessage.value = 'Farmer updated successfully';
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to update farmer: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    nationalIdController.dispose();
    bankAccountNumberController.dispose();
    bankNameController.dispose();
    businessNameController.dispose();
    communityController.dispose();
    super.onClose();
  }
}