import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../widgets/image_field_card.dart';
import 'add_farmer_provider.dart';

class AddFarmerScreen extends StatefulWidget {
  const AddFarmerScreen({super.key});

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Farmer')),
      body: ChangeNotifierProvider(
        create: (context) => AddFarmerProvider(),
        child: Consumer<AddFarmerProvider>(
          builder: (context, farmerProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildRegionDropdown(
                      farmerProvider
                    ),
                    ImageFieldCard(
                       onTap: () => farmerProvider
                          .pickMedia(source: 1),
                      image:
                      farmerProvider.farmerPhoto?.file,
                    ),
                    const SizedBox(height: 10,),
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
                      farmerProvider.farmerPhoneNumber,
                    ),
                    _buildTitleAndField(
                      "Gender",
                      farmerProvider.farmerGenderController,
                    ),
                    _buildTitleAndField(
                      "Farmer's date of birth (DOB)",
                      farmerProvider.farmerDOBController,
                    ),
                
                    const SizedBox(height: 20),
                    _buildActionButtons(farmerProvider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }




  Widget _buildRegionDropdown(AddFarmerProvider farmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Project ID"),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.surface,
            value: farmProvider.selectedProjectID,
            onChanged: (String? newValue) {
              farmProvider.setSelectedProject(newValue?? "");
            },
            items: farmProvider.projectIDs.map<DropdownMenuItem<String>>((String region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text('Select project id'),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildActionButtons(AddFarmerProvider farmProvider) {
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
