import 'package:dropdown_search/dropdown_search.dart';
import 'package:exim_project_monitor/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/farm_model.dart';
import '../../../core/models/server_models/farmers_model/farmers_from_server.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../widgets/date_field.dart';
import 'edit_farm_provider.dart';

class EditFarmScreen extends StatefulWidget {
  const EditFarmScreen({super.key, required this.farm, required this.isSynced});

  final Farm farm;
  final bool isSynced;

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
      _editFarmProvider.loadUserInfo();
      _editFarmProvider.initFarmData(widget.farm);
      _editFarmProvider.addFarmScreenContext = context;
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // GPS Coordinates Section
                    // _buildSectionHeader("GPS Coordinates"),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildTitleAndField(
                    //           "Latitude",
                    //           farmProvider.latitudeController,
                    //           keyboardType: TextInputType.none,
                    //           enabled: false
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     Expanded(
                    //       child: _buildTitleAndField(
                    //           "Longitude",
                    //           farmProvider.longitudeController,
                    //           keyboardType: TextInputType.none,
                    //           enabled: false
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // Farmer Selection Section
                    _buildSectionHeader("Farmer Information"),
                    _buildFarmerDropdown(farmProvider),

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
                      initialDate: farmProvider.plantingDate != null
                          ? DateTime.tryParse(farmProvider.plantingDate!.toString())
                          : null,
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
                      initialDate: farmProvider.harvestDate != null
                          ? DateTime.tryParse(farmProvider.harvestDate!.toString())
                          : null,
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
                    // _buildFarmBoundaryToggle(farmProvider),
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
                      initialDate: farmProvider.dateOfVisit != null
                          ? DateTime.tryParse(farmProvider.dateOfVisit.toString())
                          : null,
                      onDateSelected: (date) {
                        farmProvider.setDateOfVisit(date);
                      },
                    ),

                    // _buildTitleAndField(
                    //   "Officer Name",
                    //   farmProvider.officerNameController,
                    // ),
                    // _buildTitleAndField(
                    //   "Officer ID",
                    //   farmProvider.officerIdController,
                    // ),

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
                    if(widget.isSynced)
                    const SizedBox(height: 20),
                    if(widget.isSynced)
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

  Widget _buildFarmBoundaryToggle(EditFarmProvider farmProvider) {
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

  Widget _buildFarmerDropdown(EditFarmProvider farmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Farmer",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<FarmerFromServerModel>(
          items: (filter, infiniteScrollProps) async {
            // Return the farmers list, optionally filtered
            if (filter.isEmpty) {
              return farmProvider.farmersFromServer;
            }
            final searchLower = filter.toLowerCase();
            return farmProvider.farmersFromServer.where((farmer) {
              return farmer.firstName.toLowerCase().contains(searchLower) ||
                  farmer.lastName.toLowerCase().contains(searchLower) ||
                  farmer.phoneNumber.toLowerCase().contains(searchLower) ||
                  farmer.community.toLowerCase().contains(searchLower) ||
                  farmer.districtName.toLowerCase().contains(searchLower);
            }).toList();
          },
          selectedItem: farmProvider.selectedFarmer,
          itemAsString: (FarmerFromServerModel farmer) =>
          '${farmer.firstName} ${farmer.lastName} - ${farmer.phoneNumber}',
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: "Search and select farmer",
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2
                ),
              ),
              suffixIcon: farmProvider.loadingFarmers
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : const Icon(Icons.arrow_drop_down),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchDelay: const Duration(milliseconds: 300),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Search by name, phone, or location",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            itemBuilder: (context, farmer, isSelected, onTap) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  selected: isSelected,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      farmer.firstName.isNotEmpty ? farmer.firstName[0].toUpperCase() : 'F',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '${farmer.firstName} ${farmer.lastName}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer.phoneNumber,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${farmer.community}, ${farmer.districtName}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: isSelected
                      ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              );
            },
            emptyBuilder: (context, searchEntry) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      farmProvider.farmerLoadError ?? 'No farmers found',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (searchEntry.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search terms',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    // if (farmProvider.farmerLoadError != null) ...[
                    //   // const SizedBox(height: 16),
                    //   // ElevatedButton.icon(
                    //   //   onPressed: () => farmProvider.loadFarmFromServer(),
                    //   //   icon: const Icon(Icons.refresh, size: 18),
                    //   //   label: const Text('Retry Loading'),
                    //   //   style: ElevatedButton.styleFrom(
                    //   //     backgroundColor: Theme.of(context).colorScheme.primary,
                    //   //     foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    //   //   ),
                    //   // ),
                    // ],
                  ],
                ),
              );
            },
            loadingBuilder: (context, searchEntry) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading farmers...'),
                  ],
                ),
              );
            },
            containerBuilder: (context, popupWidget) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: popupWidget,
              );
            },
          ),
          onChanged: (FarmerFromServerModel? farmer) {
            farmProvider.setSelectedFarmer(farmer);
          },
          compareFn: (item1, item2) => item1.id == item2.id,
        ),

        // Selected Farmer Display
        if (farmProvider.selectedFarmer != null) ...[
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    farmProvider.selectedFarmer!.firstName.isNotEmpty
                        ? farmProvider.selectedFarmer!.firstName[0].toUpperCase()
                        : 'F',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${farmProvider.selectedFarmer!.firstName} ${farmProvider.selectedFarmer!.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📞 ${farmProvider.selectedFarmer!.phoneNumber}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '📍 ${farmProvider.selectedFarmer!.community}, ${farmProvider.selectedFarmer!.districtName}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => farmProvider.clearSelectedFarmer(),
                  tooltip: 'Clear selection',
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
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
              farmProvider.submitFarm();
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
          fillColor: enabled ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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