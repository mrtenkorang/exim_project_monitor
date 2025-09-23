import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLayersPanel extends StatelessWidget {
  final VoidCallback onClose;
  final Function(MapType) onMapTypeChanged;
  final Function(String, bool) onLayerVisibilityChanged;

  const MapLayersPanel({
    super.key,
    required this.onClose,
    required this.onMapTypeChanged,
    required this.onLayerVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.layers),
                const SizedBox(width: 8),
                Text(
                  'Map Layers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Map Type Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map Type',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMapTypeGrid(),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Map Layers
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Layers',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                _buildLayerItem(
                  context,
                  'Satellite Imagery',
                  Icons.satellite,
                  'satellite',
                  value: true,
                ),
                _buildLayerItem(
                  context,
                  'Terrain',
                  Icons.terrain,
                  'terrain',
                  value: true,
                ),
                _buildLayerItem(
                  context,
                  'Traffic',
                  Icons.traffic,
                  'traffic',
                  value: false,
                ),
                _buildLayerItem(
                  context,
                  'Farm Boundaries',
                  Icons.crop_square,
                  'farms',
                  value: true,
                ),
                _buildLayerItem(
                  context,
                  'Soil Data',
                  Icons.landscape,
                  'soil',
                  value: false,
                ),
                _buildLayerItem(
                  context,
                  'Water Sources',
                  Icons.water_drop,
                  'water',
                  value: true,
                ),
              ],
            ),
          ),
          
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: onClose,
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapTypeGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _MapTypeItem(
          icon: Icons.map,
          label: 'Standard',
          type: MapType.normal,
          onTap: () => onMapTypeChanged(MapType.normal),
        ),
        _MapTypeItem(
          icon: Icons.satellite,
          label: 'Satellite',
          type: MapType.satellite,
          onTap: () => onMapTypeChanged(MapType.satellite),
        ),
        _MapTypeItem(
          icon: Icons.terrain,
          label: 'Terrain',
          type: MapType.terrain,
          onTap: () => onMapTypeChanged(MapType.terrain),
        ),
        _MapTypeItem(
          icon: Icons.map,
          label: 'Hybrid',
          type: MapType.hybrid,
          onTap: () => onMapTypeChanged(MapType.hybrid),
        ),
      ],
    );
  }
  
  Widget _buildLayerItem(
    BuildContext context,
    String title,
    IconData icon,
    String layerId, {
    required bool value,
  }) {
    final theme = Theme.of(context);
    
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      value: value,
      onChanged: (bool newValue) {
        onLayerVisibilityChanged(layerId, newValue);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      dense: true,
      activeColor: theme.colorScheme.primary,
    );
  }
}

class _MapTypeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final MapType type;
  final VoidCallback onTap;

  const _MapTypeItem({
    required this.icon,
    required this.label,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
