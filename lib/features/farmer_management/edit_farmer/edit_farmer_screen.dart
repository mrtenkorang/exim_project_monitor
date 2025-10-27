import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/farmer_model.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/image_field_card.dart';
import 'edit_farmer_provider.dart';

class EditFarmerScreen extends StatefulWidget {
  const EditFarmerScreen({
    super.key,
    required this.farmer,
    required this.isSynced,
    this.onFarmerSaved,
  });

  final Farmer farmer;
  final bool isSynced;
  final VoidCallback? onFarmerSaved;

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
      appBar: AppBar(
        title: widget.isSynced
            ? const Text('View Farmer')
            : const Text('Edit Farmer'),
      ),
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
                    _buildGenderDropdown(farmerProvider),
                    // _buildTitleAndField(
                    //   "Gender",
                    //   farmerProvider.farmerGenderController,
                    // ),
                    DateField(
                      label: "Farmer's date of birth (DOB)",
                      initialDate: farmerProvider.farmerDOB,
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
                    if (widget.isSynced) const SizedBox(height: 20),
                    if (!widget.isSynced) _buildActionButtons(farmerProvider, widget.onFarmerSaved),
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

  Widget _buildProjectIDDropdown(EditFarmerProvider farmerProvider) {
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
            value:
                farmerProvider.projectIDs.contains(
                  farmerProvider.selectedProjectID,
                )
                ? farmerProvider.selectedProjectID
                : null,
            onChanged: (String? newValue) {
              farmerProvider.setSelectedProject(newValue);
            },
            items: farmerProvider.projectIDs.map<DropdownMenuItem<String>>((
              String region,
            ) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text(
              'Select project id',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRegionDropdown(EditFarmerProvider farmProvider) {
    debugPrint("THE REGIONS COUNT: ${farmProvider.regions.length}");
    if (farmProvider.regions.isNotEmpty) {
      debugPrint("FIRST REGION: ${farmProvider.regions.first.toJson()}");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Region',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: farmProvider.selectedRegionId,
              onChanged: (String? newValue) {
                farmProvider.setSelectedRegion(newValue);
                debugPrint("SELECTED REGION CODE: $newValue");
              },
              items: farmProvider.regions.map<DropdownMenuItem<String>>((
                  region,
                  ) {
                return DropdownMenuItem<String>(
                  value: region.regCode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        region.region,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Code: ${region.regCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              isExpanded: true,
              hint: farmProvider.regions.isEmpty
                  ? Text(
                'Loading regions...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              )
                  : Text(
                'Select a region',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown(EditFarmerProvider farmProvider) {
    // Filter districts using the selected region code (which is now the value)
    final filteredDistricts = farmProvider.districts
        .where((district) => district.regCode == farmProvider.selectedRegionId)
        .toList();

    final isEnabled =
        farmProvider.selectedRegionId != null &&
            farmProvider.districts.isNotEmpty;

    debugPrint("ALL DISTRICTS COUNT: ${farmProvider.districts.length}");
    debugPrint("FILTERED DISTRICTS COUNT: ${filteredDistricts.length}");
    debugPrint("SELECTED REGION ID (CODE): ${farmProvider.selectedRegionId}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'District',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isEnabled ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isEnabled ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: farmProvider.selectedDistrictId,
              onChanged: isEnabled
                  ? (String? newValue) {
                farmProvider.setSelectedDistrict(newValue);
              }
                  : null,
              items: filteredDistricts.map<DropdownMenuItem<String>>((
                  district,
                  ) {
                return DropdownMenuItem<String>(
                  value: district.id.toString(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        district.district,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            district.district,
                            style: TextStyle(
                              fontSize: 9,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            district.districtCode,
                            style: TextStyle(
                              fontSize: 8,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                  ? Text(
                'Loading districts...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              )
                  : Text(
                isEnabled ? 'Select a district' : 'Select a region first',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(EditFarmerProvider farmProvider, VoidCallback? onFarmerSaved) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            borderColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withOpacity(0.3),
            onTap: () async {
              await farmProvider.saveFarmerOffline(context);
              if (onFarmerSaved != null) {
                onFarmerSaved!();
              }
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
              farmProvider.submitFarmer(context);
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

  Widget _buildGenderDropdown(EditFarmerProvider farmerProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender"),
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
            value: farmerProvider.genders.contains(farmerProvider.selectedGender)
                ? farmerProvider.selectedGender
                : null,
            onChanged: (String? newValue) {
              farmerProvider.setSelectedGender(newValue);
            },
            items: farmerProvider.genders.map<DropdownMenuItem<String>>((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text('Select gender', style: TextStyle(color: Colors.grey),),
          ),
        ),
        const SizedBox(height: 10),
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
