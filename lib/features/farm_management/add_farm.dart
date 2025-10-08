import 'package:exim_project_monitor/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/primary_button.dart';
import '../../widgets/date_field.dart';
import 'add_farm_provider.dart';

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // init provider
    final provider = Provider.of<AddFarmProvider>(context, listen: false);
    provider.addFarmScreenContext = context;
    provider.autoFillCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Farm")),
      body: Consumer<AddFarmProvider>(
        builder: (context, farmProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                    // GPS Coordinates Section
                    _buildSectionHeader("GPS Coordinates"),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTitleAndField(
                            "Latitude",
                            farmProvider.latitudeController,
                            keyboardType: TextInputType.none,
                            enabled: false
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTitleAndField(
                            "Longitude",
                            farmProvider.longitudeController,
                            keyboardType: TextInputType.none,
                            enabled: false
                          ),
                        ),
                      ],
                    ),

                    // Farm Basic Information Section
                    _buildSectionHeader("Farm Basic Information"),
                    _buildTitleAndField(
                      "Farm Size (hectares) - computed after mapping",
                      farmProvider.farmSizeController,
                      keyboardType: TextInputType.none,
                      enabled: false
                    ),
                    _buildTitleAndField(
                      "Crop Type",
                      farmProvider.cropTypeController,
                    ),
                    _buildTitleAndField(
                      "Variety / Breed",
                      farmProvider.varietyBreedController,
                    ),
                    DateField(
                      label: 'Date of Planting',
                      onDateSelected: (date) {
                        farmProvider.setPlantingDate(date);
                      },
                    ),
                    _buildTitleAndField(
                      "Planting Density / Spacing",
                      farmProvider.plantingDensityController,
                    ),

                    // Labour Information Section
                    _buildSectionHeader("Labour Information"),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTitleAndField(
                            "Total Labour Hired",
                            farmProvider.labourHiredController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTitleAndField(
                            "Male Workers",
                            farmProvider.maleWorkersController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTitleAndField(
                            "Female Workers",
                            farmProvider.femaleWorkersController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    // Yield Information Section
                    _buildSectionHeader("Yield Information"),
                    _buildTitleAndField(
                      "Estimated Yield",
                      farmProvider.estimatedYieldController,
                    ),
                    _buildTitleAndField(
                      "Yields in Previous Seasons",
                      farmProvider.previousYieldController,
                      maxLines: 2,
                    ),
                    DateField(
                      label: 'Harvest Date',
                      onDateSelected: (date) {
                        farmProvider.setHarvestDate(date);
                      },
                    ),

                    // Secondary Data Section
                    _buildSectionHeader("Secondary Data"),
                    _buildTitleAndField(
                      "Main Buyers",
                      farmProvider.mainBuyersController,
                    ),
                    _buildFarmBoundaryToggle(farmProvider),
                    _buildTitleAndField(
                      "Land Use Classification",
                      farmProvider.landUseClassificationController,
                    ),
                    _buildTitleAndField(
                      "Accessibility (distance to road/market)",
                      farmProvider.accessibilityController,
                    ),
                    _buildTitleAndField(
                      "Proximity to Processing Facility",
                      farmProvider.proximityToProcessingFacilityController,
                    ),
                    _buildTitleAndField(
                      "Service Provider",
                      farmProvider.serviceProviderController,
                    ),
                    _buildTitleAndField(
                      "Cooperatives or Farmer Groups Affiliated",
                      farmProvider.cooperativesOrFarmerGroupsController,
                    ),
                    _buildTitleAndField(
                      "Value Chain Linkages",
                      farmProvider.valueChainLinkagesController,
                    ),

                    // Visit Information Section
                    _buildSectionHeader("Visit Information"),
                    _buildTitleAndField(
                      "Visit ID / Reference Number",
                      farmProvider.visitIdController,
                    ),
                    DateField(
                      label: 'Date of Visit',
                      onDateSelected: (date) {
                        farmProvider.setVisitDate(date);
                      },
                    ),
                    _buildTitleAndField(
                      "Officer Name",
                      farmProvider.officerNameController,
                    ),
                    _buildTitleAndField(
                      "Officer ID",
                      farmProvider.officerIdController,
                    ),

                    // Assessment Section
                    _buildSectionHeader("Assessment"),
                    _buildTitleAndField(
                      "Observations",
                      farmProvider.observationsController,
                      maxLines: 3,
                    ),
                    _buildTitleAndField(
                      "Issues Identified",
                      farmProvider.issuesIdentifiedController,
                      maxLines: 3,
                    ),
                    _buildTitleAndField(
                      "Infrastructure Identified",
                      farmProvider.infrastructureIdentifiedController,
                      maxLines: 2,
                    ),
                    _buildTitleAndField(
                      "Recommended Actions",
                      farmProvider.recommendedActionsController,
                      maxLines: 3,
                    ),
                    _buildTitleAndField(
                      "Follow-Up Status",
                      farmProvider.followUpStatusController,
                    ),

                    const SizedBox(height: 20),
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

    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildFarmBoundaryToggle(AddFarmProvider farmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Farm Boundary Polygon"),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Yes'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: farmProvider.hasFarmBoundaryPolygon,
                  onChanged: (bool? value) {
                    farmProvider.setFarmBoundaryPolygon(value ?? false);
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('No'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: farmProvider.hasFarmBoundaryPolygon,
                  onChanged: (bool? value) {
                    farmProvider.setFarmBoundaryPolygon(value ?? false);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMapFarmButton(AddFarmProvider farmProvider) {
    return PrimaryButton(
      borderColor: farmProvider.farmSizeController.text.isNotEmpty
          ? Colors.green
          : Theme.of(context).colorScheme.primary,
      backgroundColor: farmProvider.farmSizeController.text.isNotEmpty
          ? Colors.green.withOpacity(0.15)
          : Theme.of(context).colorScheme.primary.withOpacity(0.15),
      child: Row(
        children: [
          Icon(Icons.map, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 10),
          Text(
            "Map farm",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
            onTap: () async{
              await farmProvider.saveFarm();
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
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        bool enabled = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 5),
        CustomTextField(
          fillColor: enabled? null : Colors.grey.shade200,
          maxLines: maxLines,
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