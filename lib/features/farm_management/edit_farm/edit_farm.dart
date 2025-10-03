import 'package:exim_project_monitor/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/farm_model.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../widgets/date_field.dart';
import 'edit_farm_provider.dart';

class EditFarmScreen extends StatefulWidget {
  const EditFarmScreen({super.key, required this.farm});

  final Farm farm;

  @override
  State<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends State<EditFarmScreen> {
  late final EditFarmProvider _editFarmProvider;

  @override
  void initState() {
    super.initState();
    _editFarmProvider = EditFarmProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFarmProvider.initFarmData(widget.farm);
    });
  }

  @override
  void dispose() {
    _editFarmProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Farm")),
      body: ChangeNotifierProvider.value(
        value: _editFarmProvider,
        child: Consumer<EditFarmProvider>(
          builder: (context, farmProvider, child) {
            farmProvider.addFarmScreenContext = context;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildProjectIDDropdown(farmProvider),
                    _buildTitleAndField(
                      "Visit ID / Reference Number",
                      farmProvider.visitIdController,
                    ),
                    DateField(
                      label: 'Harvest date',
                      initialDate: farmProvider.harvestDate != null
                          ? DateTime.tryParse(farmProvider.harvestDate.toString())
                          : null,
                      onDateSelected: (date) {
                        farmProvider.setHarvestDate(date);
                        debugPrint('Selected date: $date');
                      },
                    ),
                    _buildTitleAndField(
                      "Main Buyers",
                      farmProvider.mainBuyersController,
                    ),
                    _buildTitleAndField(
                      "Farm Boundary Polygon (Yes/No)",
                      farmProvider.farmBoundaryPolygonController,
                    ),
                    _buildTitleAndField(
                      "Land Use Classification",
                      farmProvider.landUseClassificationController,
                    ),
                    _buildTitleAndField(
                      "Accessibility (distance to road/market)",
                      farmProvider.accessibilityController,
                    ),
                    _buildTitleAndField(
                      "Proximity to Processing facility",
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
                    _buildTitleAndField(
                      "Officer Name",
                      farmProvider.officerNameController,
                    ),
                    _buildTitleAndField(
                      "Officer ID",
                      farmProvider.officerIdController,
                    ),
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

                    const SizedBox(height: 10),
                    _buildTitleAndField(
                      enabled: false,
                      keyboardType: TextInputType.number,
                      "Farm Size",
                      farmProvider.farmSizeController,
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



  Widget _buildMapFarmButton(EditFarmProvider farmProvider) {
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

  Widget _buildActionButtons(EditFarmProvider farmProvider) {
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


  Widget _buildProjectIDDropdown(EditFarmProvider farmProvider) {
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
            value: farmProvider.projectIDs.contains(farmProvider.selectedProjectID)
                ? farmProvider.selectedProjectID
                : null,
            onChanged: (String? newValue) {
              farmProvider.setSelectedProject(newValue);
            },
            items: farmProvider.projectIDs.map<DropdownMenuItem<String>>((String region) {
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
}
