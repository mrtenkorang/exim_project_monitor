import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final User? user;
  final Function(String) onItemSelected;

  const AppDrawer({
    super.key,
    required this.user,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Account Header
            _buildUserHeader(theme, colorScheme, textTheme),

            // Navigation Items
            Expanded(
              child: _buildNavigationItems(),
            ),

            // Footer with Logout Button
            _buildFooter(context, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        user?.fullName ?? 'Guest User',
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        user?.email ?? 'No email provided',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimary.withOpacity(0.8),
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: Text(
          _getInitials(user?.fullName),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  String _getInitials(String? displayName) {
    if (displayName == null || displayName.isEmpty) return '?';

    final nameParts = displayName.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return '${nameParts[0][0]}${nameParts.last[0]}'.toUpperCase();
    }
  }

  Widget _buildNavigationItems() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Home/Dashboard
        _DrawerItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () => onItemSelected('dashboard'),
        ),

        // Farms
        _DrawerItem(
          icon: Icons.agriculture,
          title: 'Farms',
          onTap: () => onItemSelected('farms'),
        ),

        // Tasks
        _DrawerItem(
          icon: Icons.task,
          title: 'Tasks',
          badgeCount: 3, // TODO: Get actual count from database
          onTap: () => onItemSelected('tasks'),
        ),

        // Data Collection
        _DrawerItem(
          icon: Icons.assignment,
          title: 'Data Collection',
          onTap: () => onItemSelected('data_collection'),
        ),

        // Reports
        _DrawerItem(
          icon: Icons.analytics,
          title: 'Reports',
          onTap: () => onItemSelected('reports'),
        ),

        const Divider(),

        // Settings
        _DrawerItem(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () => onItemSelected('settings'),
        ),

        // Help & Support
        _DrawerItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () => onItemSelected('help'),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('LOGOUT'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // App Version
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          child: Text(
            'Version 1.0.0',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onItemSelected('logout');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? badgeCount;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      trailing: badgeCount != null
          ? Badge.count(
        count: badgeCount!,
        backgroundColor: colorScheme.primary,
        textColor: colorScheme.onPrimary,
      )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      visualDensity: VisualDensity.comfortable,
    );
  }
}