import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exim_project_monitor/core/models/user_model.dart';
import 'package:exim_project_monitor/core/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    var user;
    
    // If user is null, create a default user
    user ??= User(
      id: 1,
      email: 'guest@example.com',
      fullName: 'Guest User',
      role: 'guest',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(), userId: 1,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName ?? 'Guest User',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...{
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                },
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Account Section
            _buildSectionHeader('Account', context),
            _buildListTile(
              context,
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                // TODO: Implement edit profile
              },
            ),
            _buildListTile(
              context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                // TODO: Implement change password
              },
            ),
            const SizedBox(height: 24),
            
            // Preferences Section
            _buildSectionHeader('Preferences', context),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return _buildListTile(
                  context,
                  icon: themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  title: 'Theme',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: colorScheme.primary,
                  ),
                );
              },
            ),
            _buildListTile(
              context,
              icon: Icons.notifications_none,
              title: 'Notifications',
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Support Section
            _buildSectionHeader('Support', context),
            _buildListTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                // TODO: Implement help & support
              },
            ),
            _buildListTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
            _buildListTile(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {
                // TODO: Show terms of service
              },
            ),
            const SizedBox(height: 24),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: FilledButton.icon(
                onPressed: () {
                  // TODO: Implement logout
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
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
            const SizedBox(height: 16),
            
            // App Version
            Center(
              child: Text(
                'v1.0.0',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.1),
          width: 1,
        ),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
