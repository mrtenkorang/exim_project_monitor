import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/farm_model.dart';
import '../providers/farm_provider.dart';

class FarmFormScreen extends StatefulWidget {
  final List<LatLng> boundaryPoints;
  final Farm? farm;
  final bool isEditingBoundary;
  
  const FarmFormScreen({
    super.key,
    required this.boundaryPoints,
    this.farm,
    this.isEditingBoundary = false,
  });

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _farmerNameController;
  late TextEditingController _sizeController;
  late String _status;
  
  // Form field focus nodes
  final _nameFocusNode = FocusNode();
  final _farmerFocusNode = FocusNode();
  final _sizeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farm?.name ?? '');
    _farmerNameController = TextEditingController(
      text: widget.farm?.farmerName ?? '',
    );
    _sizeController = TextEditingController(
      text: widget.farm?.farmSize.toString() ?? '',
    );
    _status = widget.farm?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmerNameController.dispose();
    _sizeController.dispose();
    _nameFocusNode.dispose();
    _farmerFocusNode.dispose();
    _sizeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm == null ? 'Add New Farm' : 'Edit Farm'),
        actions: [
          if (widget.farm != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteFarm,
              tooltip: 'Delete Farm',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Farm Preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // TODO: Show a static map preview with the farm boundary
                      Center(child: Text('Farm Boundary Preview')),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Boundary'),
                          onPressed: () {
                            // Return to map with the current boundary
                            Navigator.of(context).pop(widget.boundaryPoints);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Farm Name
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Farm Name',
                  hintText: 'Enter farm name',
                  prefixIcon: Icon(Icons.agriculture),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a farm name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  _nameFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_farmerFocusNode);
                },
              ),
              const SizedBox(height: 16),
              
              // Farmer Name
              TextFormField(
                controller: _farmerNameController,
                focusNode: _farmerFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Farmer Name',
                  hintText: 'Enter farmer\'s name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the farmer\'s name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  _farmerFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_sizeFocusNode);
                },
              ),
              const SizedBox(height: 16),
              
              // Farm Size
              TextFormField(
                controller: _sizeController,
                focusNode: _sizeFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Farm Size (acres)',
                  hintText: 'Enter farm size in acres',
                  prefixIcon: Icon(Icons.square_foot),
                  suffixText: 'acres',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the farm size';
                  }
                  final size = double.tryParse(value);
                  if (size == null || size <= 0) {
                    return 'Please enter a valid size';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _sizeFocusNode.unfocus();
                  _submitForm();
                },
              ),
              const SizedBox(height: 20),
              
              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'harvested', child: Text('Harvested')),
                  DropdownMenuItem(value: 'abandoned', child: Text('Abandoned')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              
              // Save Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Farm',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Create or update farm
    final farm = Farm(
      id: widget.farm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      farmerName: _farmerNameController.text.trim(),
      farmSize: double.parse(_sizeController.text),
      boundaryPoints: widget.boundaryPoints,
      status: _status,
      createdAt: widget.farm?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Save farm using provider
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final success = widget.farm == null
          ? await farmProvider.addFarm(farm)
          : await farmProvider.updateFarm(farm);
      
      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();
      
      if (success) {
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farm ${widget.farm == null ? 'added' : 'updated'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen with the saved farm
        if (!mounted) return;
        Navigator.of(context).pop(farm);
      } else {
        // Show error message from provider
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(farmProvider.error ?? 'An unknown error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving farm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFarm() async {
    if (widget.farm == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm'),
        content: const Text('Are you sure you want to delete this farm? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Delete farm using provider
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final success = await farmProvider.deleteFarm(widget.farm!.id);
      
      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();
      
      if (success) {
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farm deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen with deletion flag
        if (!mounted) return;
        Navigator.of(context).pop(true); // true indicates deletion
      } else {
        // Show error message from provider
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(farmProvider.error ?? 'Failed to delete farm'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting farm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }  
  }
}
