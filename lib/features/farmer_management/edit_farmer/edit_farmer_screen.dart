import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/farmer_model.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/image_field_card.dart';
import 'edit_farmer_provider.dart';

class EditFarmerScreen extends StatefulWidget {
  const EditFarmerScreen({super.key, required this.farmer});

  final Farmer farmer;

  @override
  State<EditFarmerScreen> createState() => _EditFarmerScreenState();
}

class _EditFarmerScreenState extends State<EditFarmerScreen> {
  late final EditFarmerProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = EditFarmerProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.initializeFromFarmerData(widget.farmer);
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Farmer')),
      body: ChangeNotifierProvider.value(
        value: _provider,
        child: Consumer<EditFarmerProvider>(
          builder: (context, farmerProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // _buildRegionDropdown(
                    //     farmerProvider
                    // ),

                    ImageFieldCard(
                      onTap: () => farmerProvider.pickMedia(source: 1),
                      image: farmerProvider.farmerPhoto?.file,
                      base64Image: farmerProvider.farmerPhoto?.base64String,
                    ),

                    const SizedBox(height: 10),
                    _buildRegionDropdown(farmerProvider),
                    _buildDistrictDropdown(farmerProvider),
                    _buildTitleAndField(
                      "Community",
                      farmerProvider.communityController,
                    ),
                    _buildTitleAndField(
                      "Farmer name",
                      farmerProvider.farmerNameController,
                    ),
                    _buildTitleAndField(
                      "Farmer Id / Ghana card number",
                      farmerProvider.farmerIdNumberController,
                    ),
                    _buildTitleAndField(
                      "Farmer's phone number",
                      farmerProvider.phoneNumberController,
                    ),
                    _buildTitleAndField(
                      "Gender",
                      farmerProvider.farmerGenderController,
                    ),
                    DateField(
                      label: "Farmer's date of birth (DOB)",
                      initialDate: farmerProvider.farmerDOB,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onDateSelected: (date) {
                        farmerProvider.setFarmerDOB(date);
                      },
                    ),

                    _buildTitleAndField(
                      "Crop Type",
                      farmerProvider.cropTypeController,
                    ),
                    _buildTitleAndField(
                      "Variety / Breed",
                      farmerProvider.varietyBreedController,
                    ),
                    DateField(
                      label: 'Planting date',
                      initialDate: farmerProvider.plantingDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onDateSelected: (date) {
                        farmerProvider.setPlantingDate(date);
                      },
                    ),
                    _buildTitleAndField(
                      "Planting Density / Spacing",
                      farmerProvider.plantingDensityController,
                    ),
                    _buildTitleAndField(
                      "Labour Hired (number of workers, males and females)",
                      farmerProvider.laborHiredController,
                    ),
                    _buildTitleAndField(
                      "Estimated Yield",
                      farmerProvider.estimatedYieldController,
                    ),
                    _buildTitleAndField(
                      "Yields in previous seasons",
                      farmerProvider.yieldInPrevSeason,
                    ),
                    DateField(
                      label: 'Harvest date',
                      initialDate: farmerProvider.harvestDate,
                      firstDate: farmerProvider.plantingDate ?? DateTime.now(),
                      lastDate: DateTime(2100),
                      onDateSelected: (date) {
                        farmerProvider.setHarvestDate(date);
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildActionButtons(farmerProvider),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildRegionDropdown(EditFarmerProvider farmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Region"),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.surface,
            value: farmProvider.selectedRegionId,
            onChanged: (String? newValue) {
              farmProvider.setSelectedRegion(newValue);
            },
            items: farmProvider.regions.map<DropdownMenuItem<String>>((
                Map<String, dynamic> region,
                ) {
              return DropdownMenuItem<String>(
                value: region['region_id']?.toString(),
                child: Text(region['region']?.toString() ?? ''),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text('Select a region'),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDistrictDropdown(EditFarmerProvider farmProvider) {
    final filteredDistricts = farmProvider.getFilteredDistricts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select District"),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.surface,
            value: farmProvider.selectedDistrictId,
            onChanged: farmProvider.selectedRegionId != null
                ? (String? newValue) {
              farmProvider.setSelectedDistrict(newValue);
            }
                : null, // Disable if no region selected
            items: filteredDistricts.map<DropdownMenuItem<String>>((
                Map<String, dynamic> district,
                ) {
              return DropdownMenuItem<String>(
                value: district['district_id']?.toString(),
                child: Text(district['district']?.toString() ?? ''),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(
              farmProvider.selectedRegionId != null
                  ? 'Select a district'
                  : 'Select a region first',
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildActionButtons(EditFarmerProvider farmProvider) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            borderColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withOpacity(0.3),
            onTap: () {
              farmProvider.saveFarmerOffline(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.save,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                Text(
                  "Save",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PrimaryButton(
            borderColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.3),
            onTap: () {
              // farmProvider.submitFarm();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                Text(
                  "Submit",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndField(
      String title,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        bool enabled = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 5),
        CustomTextField(
          enabled: enabled,
          keyboardType: keyboardType,
          label: "",
          controller: controller,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
