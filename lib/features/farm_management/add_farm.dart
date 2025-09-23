import 'package:exim_project_monitor/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/primary_button.dart';
import '../../widgets/date_field.dart';
import '../farms/providers/farm_provider.dart';
import 'add_farm_provider.dart';

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Add Farm")),
      body: ChangeNotifierProvider(
        create: (context) => AddFarmProvider(),
        child: Consumer<AddFarmProvider>(
          builder: (context, farmProvider, child) {
            farmProvider.addFarmScreenContext = context;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildRegionDropdown(farmProvider),
                    _buildDistrictDropdown(farmProvider),
                    _buildTitleAndField("Location", farmProvider.farmLocationController),
                    _buildTitleAndField("Crop type", farmProvider.cropTypeController),
                    _buildTitleAndField(
                      "Variety / Breed ",
                      farmProvider.varietyBreedController,
                    ),
                    DateField(
                      label: 'Planting date',
                      onDateSelected: (date) {
                        farmProvider.setPlantingDate(date);
                        debugPrint('Selected date: $date');
                      },
                    ),
                    _buildTitleAndField(
                      "Planting density/ spacing",
                      farmProvider.plantingDensityController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTitleAndField(
                      "Farm inputs received",
                      farmProvider.farmInputsReceivedController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTitleAndField(
                      "Inputs quantity",
                      farmProvider.inputsQuantityController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTitleAndField(
                      "Labor hired",
                      farmProvider.laborHiredController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTitleAndField(
                      "Estimated yield",
                      farmProvider.estimatedYieldController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTitleAndField(
                      "Actual yield",
                      farmProvider.actualYieldController,
                      keyboardType: TextInputType.number,
                    ),
                    DateField(
                      label: 'Harvest date',
                      onDateSelected: (date) {
                        farmProvider.setHarvestDate(date);
                        debugPrint('Selected date: $date');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTitleAndField(
                      enabled: false,
                      keyboardType: TextInputType.number,
                      "Farm Size",
                      farmProvider.actualYieldController,
                    ),
                    const SizedBox(height: 10),
                    _buildMapFarmButton(farmProvider),
                    const SizedBox(height: 20),
                    _buildActionButtons(farmProvider),
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

  Widget _buildRegionDropdown(AddFarmProvider farmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Region"),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).colorScheme.onSurface),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.surface,
            value: farmProvider.selectedRegionId,
            onChanged: (String? newValue) {
              farmProvider.setSelectedRegion(newValue);
            },
            items: farmProvider.regions.map<DropdownMenuItem<String>>((Map<String, dynamic> region) {
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

  Widget _buildDistrictDropdown(AddFarmProvider farmProvider) {
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
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.surface,
            value: farmProvider.selectedDistrictId,
            onChanged: farmProvider.selectedRegionId != null
                ? (String? newValue) {
              farmProvider.setSelectedDistrict(newValue);
            }
                : null, // Disable if no region selected
            items: filteredDistricts.map<DropdownMenuItem<String>>((Map<String, dynamic> district) {
              return DropdownMenuItem<String>(
                value: district['district_id']?.toString(),
                child: Text(district['district']?.toString() ?? ''),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(farmProvider.selectedRegionId != null
                ? 'Select a district'
                : 'Select a region first'),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMapFarmButton(AddFarmProvider farmProvider) {
    return PrimaryButton(
      borderColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      child: Row(
        children: [
          Icon(Icons.map, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 10),
          Text(
            "Map farm",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSurface),
        ],
      ),
      onTap: () {
        farmProvider.usePolygonDrawingTool(context);
      },
    );
  }

  Widget _buildActionButtons(AddFarmProvider farmProvider) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            borderColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withOpacity(0.3),
            onTap: () {
              // farmProvider.saveFarm();
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
              children: [Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface), Text("Submit", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface
              ),)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndField(String title, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 5),
        CustomTextField(
          enabled: enabled,
            keyboardType: keyboardType,
            label: "", controller: controller),
        const SizedBox(height: 10),
      ],
    );
  }


}