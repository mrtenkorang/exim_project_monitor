import 'package:exim_project_monitor/core/models/server_models/farmers_model/farmers_from_server.dart';
import 'package:exim_project_monitor/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'edit_farmer_from_server_controller.dart';

class EditFarmerFromServerScreen
    extends GetView<EditFarmerFromServerController> {
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
                const SizedBox(height: 8),
                _buildTextFormField(
                  controller: controller.lastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
                const SizedBox(height: 8),
                _buildTextFormField(
                  controller: controller.phoneNumberController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
                const SizedBox(height: 8),

                Obx(() {
                  return DropdownButtonFormField<String>(
                    value: controller.selectedGender.value.isNotEmpty
                        ? controller.selectedGender.value
                        : null,
                    hint: const Text('Select Gender'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
                }),

                const SizedBox(height: 8),
                _buildTextFormField(
                  controller: controller.emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                _buildTextFormField(
                  controller: controller.communityController,
                  label: 'Community',
                ),
                const SizedBox(height: 8),
                _buildTextFormField(
                  controller: controller.nationalIdController,
                  label: 'National ID',
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context: context, isDob: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: Icon(Icons.calendar_today, size: 20),
                    ),
                    child: Obx(
                      () => Text(
                        controller.dateOfBirth.value.isNotEmpty
                            ? controller.dateOfBirth.value
                            : 'Select Date of Birth',
                        style: TextStyle(
                          color: controller.dateOfBirth.value.isNotEmpty
                              ? null
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.businessNameController,
                  decoration: const InputDecoration(
                    labelText: 'Business Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 20),
                PrimaryButton(
                  onTap: ()  {
                    debugPrint("UPDATE FARMER");
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (keyboardType == TextInputType.emailAddress && value!.isNotEmpty) {
          if (!GetUtils.isEmail(value)) {
            return 'Please enter a valid email';
          }
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

  Future<void> _selectDate({
    required BuildContext context,
    bool isDob = false,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (isDob) {
        controller.dateOfBirth.value = formattedDate;
      }
    }
  }
}
