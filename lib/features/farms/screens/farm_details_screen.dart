import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/farm_model.dart';
import '../../map/utils/map_utils.dart';
import '../../map/widgets/map_preview.dart';
import '../providers/farm_provider.dart';
import 'farm_form_screen.dart';

class FarmDetailsScreen extends StatelessWidget {
  final Farm farm;

  const FarmDetailsScreen({
    super.key,
    required this.farm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(farm.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farm Map Preview
            if (farm.boundaryPoints.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MapPreview(
                    boundaryPoints: farm.boundaryPoints,
                    interactive: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Farm Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      context,
                      icon: Icons.person,
                      label: 'Farmer',
                      value: farm.farmerName,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: Icons.agriculture,
                      label: 'Farm Size',
                      value: '${farm.farmSize.toStringAsFixed(2)} acres',
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: _getStatusIcon(farm.status),
                      label: 'Status',
                      value: farm.status,
                      valueColor: _getStatusColor(context, farm.status),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: DateFormat.yMMMd().add_jm().format(farm.createdAt),
                    ),
                    if (farm.updatedAt != null) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        icon: Icons.update,
                        label: 'Last Updated',
                        value: DateFormat.yMMMd().add_jm().format(farm.updatedAt!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Farm Boundary Details
            if (farm.boundaryPoints.isNotEmpty) ...[
              Text(
                'Boundary Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildBoundaryDetail(
                        context,
                        'Boundary Points',
                        '${farm.boundaryPoints.length} points',
                      ),
                      const Divider(),
                      _buildBoundaryDetail(
                        context,
                        'Approx. Area',
                        '${farm.farmSize.toStringAsFixed(2)} acres',
                      ),
                      // Add more boundary details as needed
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text('DIRECTIONS'),
                    onPressed: () => _openDirections(farm.boundaryPoints.isNotEmpty 
                        ? farm.boundaryPoints.first 
                        : null),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.edit_location_alt),
                    label: const Text('EDIT BOUNDARY'),
                    onPressed: () => _navigateToEditScreen(context, editBoundary: true),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Delete Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'DELETE FARM',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => _confirmDelete(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.hintColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: valueColor ?? theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBoundaryDetail(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'inactive':
        return Icons.pause_circle;
      case 'harvested':
        return Icons.agriculture;
      case 'abandoned':
        return Icons.not_interested;
      default:
        return Icons.help_outline;
    }
  }
  
  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'harvested':
        return Colors.blue;
      case 'abandoned':
        return Colors.red;
      default:
        return theme.textTheme.bodyLarge?.color ?? Colors.grey;
    }
  }
  
  void _navigateToEditScreen(BuildContext context, {bool editBoundary = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmFormScreen(
          farm: farm,
          boundaryPoints: farm.boundaryPoints,
          isEditingBoundary: editBoundary,
        ),
      ),
    );
  }
  
  void _openDirections(LatLng? location) async {
    if (location == null) return;
    
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}&travelmode=driving';
    
    // Use url_launcher to open the URL
    // final url = Uri.parse(googleMapsUrl);
    // if (await canLaunchUrl(url)) {
    //   await launchUrl(url);
    // }
    
    // For now, just log the URL
    debugPrint('Opening directions to: $googleMapsUrl');
  }
  
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm'),
        content: const Text('Are you sure you want to delete this farm? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final success = await farmProvider.deleteFarm(farm.id);
      
      if (success && context.mounted) {
        Navigator.of(context).pop(true); // Return to previous screen with success
      }
    }
  }
}
