import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/server_models/farmers_model/farmers_from_server.dart';
import 'farm_map_screen.dart';
import 'farmer_provider.dart';

class FarmerDetailScreen extends StatelessWidget {
  final String farmerId;
  final FarmerFromServerModel farmer;

  const FarmerDetailScreen({
    super.key,
    required this.farmerId,
    required this.farmer,
  });

  @override
  Widget build(BuildContext context) {
    final farmer = this.farmer;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${farmer.firstName} ${farmer.lastName}",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimary,
            ),
          ),
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          bottom: TabBar(
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
            indicatorColor: colorScheme.onPrimary,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: textTheme.labelLarge,
            tabs: const [
              Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
              Tab(icon: Icon(Icons.agriculture_outlined), text: 'Farms'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProfileTab(context, farmer),
            _buildFarmsTab(context, farmer),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, FarmerFromServerModel farmer) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Card
          _buildDetailCard(
            context,
            title: 'Personal Information',
            icon: Icons.person_outlined,
            children: [
              _buildDetailRow(
                context,
                Icons.badge_outlined,
                'ID',
                farmer.nationalId.isNotEmpty ? farmer.nationalId : 'Not provided',
              ),
              _buildDetailRow(
                context,
                Icons.cake_outlined,
                'Date of Birth',
                farmer.dateOfBirth.isNotEmpty ? farmer.dateOfBirth : 'Not provided',
              ),
              _buildDetailRow(
                context,
                Icons.people_outlined,
                'Gender',
                farmer.gender.isNotEmpty ? farmer.gender : 'Not provided',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact Information Card
          _buildDetailCard(
            context,
            title: 'Contact Information',
            icon: Icons.contact_phone_outlined,
            children: [
              _buildDetailRow(
                context,
                Icons.phone_iphone_outlined,
                'Phone',
                farmer.phoneNumber,
                onTap: () => _makePhoneCall(farmer.phoneNumber),
                isInteractive: true,
              ),
              _buildDetailRow(
                context,
                Icons.email_outlined,
                'Email',
                farmer.email.isNotEmpty ? farmer.email : 'Not provided',
                onTap: farmer.email.isNotEmpty ? () => _sendEmail(farmer.email) : null,
                isInteractive: farmer.email.isNotEmpty,
              ),
              _buildDetailRow(
                context,
                Icons.location_on_outlined,
                'Community',
                farmer.community.isNotEmpty ? farmer.community : 'Not provided',
              ),
              _buildDetailRow(
                context,
                Icons.business_outlined,
                'District',
                farmer.districtName.isNotEmpty ? farmer.districtName : 'Not provided',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Farm Information Card
          if (farmer.farms.isNotEmpty)
            _buildDetailCard(
              context,
              title: 'Farm Statistics',
              icon: Icons.analytics_outlined,
              children: [
                _buildStatRow(
                  context,
                  'Total Farms',
                  '${farmer.farms.length}',
                  colorScheme.primary,
                ),
                _buildStatRow(
                  context,
                  'Total Area (Hectares)',
                  _calculateTotalArea(farmer.farms).toStringAsFixed(2),
                  colorScheme.secondary,
                ),
                _buildStatRow(
                  context,
                  'Average Farm Size',
                  _calculateAverageArea(farmer.farms).toStringAsFixed(2),
                  colorScheme.tertiary,
                ),
              ],
            ),
          if (farmer.farms.isNotEmpty) const SizedBox(height: 16),

          // Business Information Card
          _buildDetailCard(
            context,
            title: 'Business Information',
            icon: Icons.business_center_outlined,
            children: [
              _buildDetailRow(
                context,
                Icons.business_outlined,
                'Business Name',
                farmer.businessName.isNotEmpty ? farmer.businessName : 'Not provided',
              ),
              _buildDetailRow(
                context,
                Icons.psychology_outlined,
                'Primary Crop',
                farmer.primaryCrop.isNotEmpty ? farmer.primaryCrop : 'Not provided',
              ),
              _buildDetailRow(
                context,
                Icons.work_history_outlined,
                'Years of Experience',
                '${farmer.yearsOfExperience} years',
              ),
              _buildDetailRow(
                context,
                Icons.group_outlined,
                'Cooperative Membership',
                farmer.cooperativeMembership.isNotEmpty ? farmer.cooperativeMembership : 'Not a member',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions Card
          _buildDetailCard(
            context,
            title: 'Quick Actions',
            icon: Icons.quickreply_outlined,
            children: [
              _buildActionTile(
                context,
                Icons.message_outlined,
                'Send SMS',
                'Send text message to farmer',
                    () => _sendSMS(farmer.phoneNumber),
              ),
              _buildActionTile(
                context,
                Icons.message_outlined,
                'Make a call',
                'Call farmer',
                    () => _makePhoneCall(farmer.phoneNumber),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFarmsTab(BuildContext context, FarmerFromServerModel farmer) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (farmer.farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No Farms Registered',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This farmer has no farms yet',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // TODO: Implement add new farm
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add First Farm'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: farmer.farms.length,
      itemBuilder: (context, index) {
        final farm = farmer.farms[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmMapScreen(farm: farm),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.agriculture_outlined,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.name.isNotEmpty ? farm.name : 'Farm ${index + 1}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFarmInfoRow(
                          context,
                          Icons.code_outlined,
                          'Code: ${farm.farmCode}',
                        ),
                        _buildFarmInfoRow(
                          context,
                          Icons.square_foot_outlined,
                          'Area: ${farm.areaHectares} hectares',
                        ),
                        _buildFarmInfoRow(
                          context,
                          Icons.landscape_outlined,
                          'Soil: ${farm.soilType.isNotEmpty ? farm.soilType : 'Not specified'}',
                        ),
                        _buildFarmInfoRow(
                          context,
                          Icons.water_drop_outlined,
                          'Irrigation: ${farm.irrigationType.isNotEmpty ? farm.irrigationType : 'Not specified'}',
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(farm.status, colorScheme),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            farm.status.isNotEmpty ? farm.status : 'Unknown',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_outlined,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(
      BuildContext context, {
        required String title,
        required List<Widget> children,
        IconData? icon,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      IconData icon,
      String label,
      String value, {
        VoidCallback? onTap,
        bool isInteractive = false,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isInteractive && onTap != null
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontWeight: isInteractive && onTap != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context,
      String label,
      String value,
      Color color,
      ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_outlined,
        color: colorScheme.onSurface.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildFarmInfoRow(
      BuildContext context,
      IconData icon,
      String text,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 24,
      thickness: 1,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'active':
        return colorScheme.primary;
      case 'pending':
        return colorScheme.secondary;
      case 'inactive':
        return colorScheme.error;
      default:
        return colorScheme.onSurface.withOpacity(0.2);
    }
  }

  double _calculateTotalArea(List<FarmFromServer> farms) {
    return farms.fold(0, (sum, farm) => sum + (farm.areaHectares ?? 0));
  }

  double _calculateAverageArea(List<FarmFromServer> farms) {
    if (farms.isEmpty) return 0;
    return _calculateTotalArea(farms) / farms.length;
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // void _makePhoneCall(String phoneNumber) async {
  //   final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  //   if (await canLaunchUrl(launchUri)) {
  //     await launchUrl(launchUri);
  //   }
  // }

  void _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}