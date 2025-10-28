import 'package:exim_project_monitor/core/models/server_models/farmers_model/farmers_from_server.dart';
import 'package:exim_project_monitor/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'edit_farmer_from_server_controller.dart';

class EditFarmerFromServerScreen extends GetView<EditFarmerFromServerController> {
  final FarmerFromServerModel farmer;

  const EditFarmerFromServerScreen({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    Get.put(EditFarmerFromServerController(farmer: farmer));
    controller.editFarmerFromServerScreenContext = context;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Farmer Details')),
      body: Obx(() {
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (controller.successMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.successMessage.value,
              style: const TextStyle(color: Colors.green),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextFormField(
                  controller: controller.firstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
                const SizedBox(height: 14),
                _buildTextFormField(
                  controller: controller.lastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
                const SizedBox(height: 14),
                _buildTextFormField(
                  controller: controller.phoneNumberController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
                const SizedBox(height: 14),
                _buildGenderDropdown(),
                const SizedBox(height: 14),
                _buildDistrictSearchDropdown(context),
                const SizedBox(height: 14),
                _buildTextFormField(
                  controller: controller.communityController,
                  label: 'Community',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: controller.nationalIdController,
                  decoration: const InputDecoration(
                    labelText: 'National ID (GHA-XXXXXXXXX-X)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    // prefixText: 'GHA-',
                    counterText: '',
                  ),
                  // keyboardType: TextInputType.number,
                  maxLength: 15,
                  buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) {
                        return const TextEditingValue(
                          text: 'GHA-',
                          selection: TextSelection.collapsed(offset: 4),
                        );
                      }
                      
                      String newText = newValue.text;
                      
                      // Add GHA- prefix if not present
                      if (!newText.startsWith('GHA-')) {
                        newText = 'GHA-$newText';
                      }
                      
                      // Add hyphen after 13 characters if not present
                      if (newText.length == 14 && !newText.endsWith('-')) {
                        newText = '${newText.substring(0, 13)}-${newText.substring(13)}';
                      }
                      
                      // Limit to 15 characters (GHA-123456789-1)
                      if (newText.length > 15) {
                        newText = newText.substring(0, 15);
                      }
                      
                      return TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(offset: newText.length),
                      );
                    }),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final regex = RegExp(r'^GHA-\d{9}-\d$');
                    if (!regex.hasMatch(value)) {
                      return 'Please enter a valid National ID (GHA-123456789-1)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildDateOfBirthField(context),
                const SizedBox(height: 14),
                _buildTextFormField(
                  controller: controller.businessNameController,
                  label: 'Business Name',
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  onTap: () {
                    controller.updateFarmer();
                  },
                  child: const Text("Update Farmer"),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (keyboardType == TextInputType.phone && value!.isNotEmpty) {
          if (!GetUtils.isPhoneNumber(value)) {
            return 'Please enter a valid phone number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.selectedGender.value.isNotEmpty ? controller.selectedGender.value : null,
        hint: const Text('Select Gender'),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          labelText: 'Gender',
        ),
        onChanged: (value) {
          if (value != null) {
            controller.selectedGender.value = value;
          }
        },
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a gender';
          }
          return null;
        },
      );
    });
  }

  Widget _buildDistrictSearchDropdown(BuildContext context) {
    debugPrint("SELECTED DISTRICT :::::::::::: ${controller.selectedDistrict.value}");
    return Obx(() {
      return InkWell(
        onTap: () {
          _showDistrictSearchDialog(context);
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'District',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: Icon(Icons.search),
          ),
          child: Text(
            controller.selectedDistrict.value.isNotEmpty
                ? controller.selectedDistrict.value
                : 'Select District',
            style: TextStyle(
              color: controller.selectedDistrict.value.isNotEmpty ? Colors.black : Colors.grey,
            ),
          ),
        ),
      );
    });
  }

  void _showDistrictSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DistrictSearchDialog(
          districts: controller.districts,
          selectedDistrict: controller.selectedDistrict.value,
          onDistrictSelected: (String district) {
            controller.selectedDistrict.value = district;
            Get.back();
          },
        );
      },
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context: context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: Icon(Icons.calendar_today, size: 20),
        ),
        child: Obx(() => Text(
          controller.dateOfBirth.value.isNotEmpty ? controller.dateOfBirth.value : 'Select Date of Birth',
          style: TextStyle(color: controller.dateOfBirth.value.isNotEmpty ? null : Colors.grey),
        )),
      ),
    );
  }

  Future<void> _selectDate({required BuildContext context}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      controller.dateOfBirth.value = formattedDate;
    }
  }
}

class DistrictSearchDialog extends StatefulWidget {
  final List<dynamic> districts;
  final String selectedDistrict;
  final Function(String) onDistrictSelected;

  const DistrictSearchDialog({
    super.key,
    required this.districts,
    required this.selectedDistrict,
    required this.onDistrictSelected,
  });

  @override
  State<DistrictSearchDialog> createState() => _DistrictSearchDialogState();
}

class _DistrictSearchDialogState extends State<DistrictSearchDialog> {
  late List<dynamic> filteredDistricts;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDistricts = widget.districts;
  }

  void filterDistricts(String query) {
    setState(() {
      filteredDistricts = widget.districts.where((district) {
        final districtName = district.district.toLowerCase();
        return districtName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search District',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterDistricts,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDistricts.length,
              itemBuilder: (context, index) {
                final district = filteredDistricts[index];
                return ListTile(
                  title: Text(district.district),
                  onTap: () {
                    widget.onDistrictSelected(district.district);
                  },
                  selected: district.district == widget.selectedDistrict,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}