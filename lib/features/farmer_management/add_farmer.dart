import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../widgets/date_field.dart';
import '../../widgets/image_field_card.dart';
import 'add_farmer_provider.dart';

class AddFarmerScreen extends StatefulWidget {
  const AddFarmerScreen({super.key});

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AddFarmerProvider>(context, listen: false);
      provider.fetchRegions();
      provider.fetchDistricts();
      provider.fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Farmer')),
      body: Consumer<AddFarmerProvider>(
        builder: (context, farmerProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // ImageFieldCard(
                  //   onTap: () => farmerProvider.pickMedia(source: 1),
                  //   image: farmerProvider.farmerPhoto?.file,
                  // ),
                  _buildProjectIDDropdown(farmerProvider),
                  // const SizedBox(height: 10),
                  _buildRegionDropdown(farmerProvider),
                  const SizedBox(height: 10),
                  _buildDistrictDropdown(farmerProvider),
                  const SizedBox(height: 10),
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
                    keyboardType: TextInputType.number,
                  ),
                  _buildTitleAndField(
                    "Business Name",
                    farmerProvider.businessNameController,
                  ),
                  _buildTitleAndField(
                    "Farmer's phone number",
                    farmerProvider.phoneNumberController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTitleAndField(
                    "Gender",
                    farmerProvider.farmerGenderController,
                  ),
                  DateField(
                    label: "Farmer's date of birth (DOB)",
                    onDateSelected: (date) {
                      farmerProvider.setFarmerDOB(date);
                      debugPrint('Selected date: $date');
                    },
                  ),
                  const SizedBox(height: 10),
                  // _buildTitleAndField(
                  //   "Crop Type",
                  //   farmerProvider.cropTypeController,
                  // ),
                  // _buildTitleAndField(
                  //   "Variety / Breed",
                  //   farmerProvider.varietyBreedController,
                  // ),
                  // DateField(
                  //   label: 'Planting date',
                  //   onDateSelected: (date) {
                  //     farmerProvider.setPlantingDate(date);
                  //     debugPrint('Selected date: $date');
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                  // _buildTitleAndField(
                  //   "Planting Density / Spacing",
                  //   farmerProvider.plantingDensityController,
                  // ),
                  // _buildTitleAndField(
                  //   "Labour Hired (number of workers, males and females)",
                  //   farmerProvider.laborHiredController,
                  //   keyboardType: TextInputType.number,
                  // ),
                  // _buildTitleAndField(
                  //   "Estimated Yield",
                  //   farmerProvider.estimatedYieldController,
                  // ),
                  // _buildTitleAndField(
                  //   "Yields in previous seasons",
                  //   farmerProvider.yieldInPrevSeason,
                  // ),
                  // DateField(
                  //   label: 'Harvest date',
                  //   onDateSelected: (date) {
                  //     farmerProvider.setHarvestDate(date);
                  //     debugPrint('Selected date: $date');
                  //   },
                  // ),
                  const SizedBox(height: 20),
                  _buildActionButtons(farmerProvider),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectIDDropdown(AddFarmerProvider farmerProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Project ID"),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.surface,
            value: farmerProvider.projectIDs.contains(farmerProvider.selectedProjectID)
                ? farmerProvider.selectedProjectID
                : null,
            onChanged: (String? newValue) {
              farmerProvider.setSelectedProject(newValue);
            },
            items: farmerProvider.projectIDs.map<DropdownMenuItem<String>>((String region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text('Select project id', style: TextStyle(color: Colors.grey),),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRegionDropdown(AddFarmerProvider farmProvider) {
    debugPrint("THE REGIONS COUNT: ${farmProvider.regions.length}");
    if (farmProvider.regions.isNotEmpty) {
      debugPrint("FIRST REGION: ${farmProvider.regions.first.toJson()}");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Region',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: farmProvider.selectedRegionId,
              onChanged: (String? newValue) {
                farmProvider.setSelectedRegion(newValue);
                debugPrint("SELECTED REGION CODE: $newValue");
              },
              items: farmProvider.regions.map<DropdownMenuItem<String>>((region) {
                return DropdownMenuItem<String>(
                  value: region.regCode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        region.region,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Code: ${region.regCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              isExpanded: true,
              hint: farmProvider.regions.isEmpty
                  ? const Text('Loading regions...')
                  : const Text('Select a region'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown(AddFarmerProvider farmProvider) {
    // Filter districts using the selected region code (which is now the value)
    final filteredDistricts = farmProvider.districts
        .where((district) => district.regCode == farmProvider.selectedRegionId)
        .toList();

    final isEnabled = farmProvider.selectedRegionId != null && farmProvider.districts.isNotEmpty;

    // debugPrint("ALL DISTRICTS COUNT: ${farmProvider.districts.length}");
    // debugPrint("FILTERED DISTRICTS COUNT: ${filteredDistricts.length}");
    // debugPrint("SELECTED REGION ID (CODE): ${farmProvider.selectedRegionId}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'District',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isEnabled ? null : Colors.grey.shade100,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: farmProvider.selectedDistrictId,
              onChanged: isEnabled
                  ? (String? newValue) {
                farmProvider.setSelectedDistrict(newValue);
              }
                  : null,
              items: filteredDistricts.map<DropdownMenuItem<String>>((district) {
                return DropdownMenuItem<String>(
                  value: district.districtCode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        district.district,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            district.district,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            district.districtCode,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              isExpanded: true,
              hint: farmProvider.districts.isEmpty
                  ? const Text('Loading districts...')
                  : Text(
                isEnabled ? 'Select a district' : 'Select a region first',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AddFarmerProvider farmProvider) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            borderColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            onTap: () {
              farmProvider.saveFarmerOffline(context);
            },
            child: farmProvider.isLoadingOffline
                ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onSurface,
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.save,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTap: () {
              farmProvider.submitFarmer(context);
            },
            child: farmProvider.isLoading
                ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Submit",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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