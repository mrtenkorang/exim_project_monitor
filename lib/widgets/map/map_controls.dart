import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onLayersTap;
  final VoidCallback onLocationTap;
  final VoidCallback onAddTap;

  const MapControls({
    super.key,
    required this.onMenuTap,
    required this.onLayersTap,
    required this.onLocationTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Menu Button
          _ControlButton(
            icon: Icons.menu,
            onPressed: onMenuTap,
            tooltip: 'Menu',
          ),
          
          const Spacer(),
          
          // Add Button
          _ControlButton(
            icon: Icons.add,
            onPressed: onAddTap,
            tooltip: 'Add',
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          
          const SizedBox(width: 8),
          
          // Location Button
          _ControlButton(
            icon: Icons.my_location,
            onPressed: onLocationTap,
            tooltip: 'My Location',
          ),
          
          const SizedBox(width: 8),
          
          // Layers Button
          _ControlButton(
            icon: Icons.layers,
            onPressed: onLayersTap,
            tooltip: 'Layers',
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
