import 'package:exim_project_monitor/widgets/common/section_header.dart';
import 'package:flutter/material.dart';
import 'package:exim_project_monitor/core/models/user_model.dart';
import 'package:exim_project_monitor/core/widgets/info_card.dart';
import 'package:exim_project_monitor/core/widgets/primary_button.dart';
import '../../../core/cache_service/cache_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final CacheService cacheService = await CacheService.getInstance();
    final user = await cacheService.getUserInfo();
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;




    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,

      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_user!.firstName ?? ''} ${_user!.lastName ?? ''}'.trim(),
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (_user?.userName != null) ...[  
                          const SizedBox(height: 4),
                          Text(
                            '${_user!.userName}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information Section
                  const SectionHeader(
                    title: 'Personal Information',
                    // icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.badge_outlined,
                    title: 'Staff ID',
                    value: _user!.staffId ?? 'Not provided',
                  ),

                  const SizedBox(height: 14),

                  // Location Information
                  const SectionHeader(
                    title: 'Location',
                    // icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.place_outlined,
                    title: 'Region',
                    value: _user!.regionName ?? 'Not specified',
                    // subtitle: _user!.regionCode != null ? 'Code: ${_user!.regionCode}' : null,
                  ),
                  const SizedBox(height: 8),
                  InfoCard(
                    icon: Icons.map_outlined,
                    title: 'District',
                    value: _user!.districtName ?? 'Not specified',
                    // subtitle: _user!.districtCode != null ? 'Code: ${_user!.districtCode}' : null,
                  ),
                  const SizedBox(height: 24),


                  // Logout Button
                  PrimaryButton(
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      ) ?? false;
                      
                      if (shouldLogout && context.mounted) {
                        final cacheService = await CacheService.getInstance();
                        await cacheService.logout(context);
                      }
                    },
                    backgroundColor: colorScheme.errorContainer,
                    child: const Text("Log out"),
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

  // Helper method to format date if needed
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
