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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${farmer.firstName} ${farmer.lastName}"),

          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.onSurface,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.agriculture), text: 'Farms'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard(
            context,
            title: 'Contact Information',
            children: [
              _buildDetailRow(
                Icons.phone,
                'Phone',
                farmer.phoneNumber,
                onTap: () => _makePhoneCall(farmer.phoneNumber),
              ),
              _buildDetailRow(
                Icons.email,
                'Email',
                farmer.email,
                onTap: () => _sendEmail(farmer.email),
              ),
              _buildDetailRow(Icons.location_on, 'Location', farmer.community),
            ],
          ),
          const SizedBox(height: 16),
          if(farmer.farms.isNotEmpty)
          _buildDetailCard(
            context,
            title: 'Farm Statistics',
            children: [
              _buildStatRow('Total Farms', '${farmer.farmsCount}'),
              _buildStatRow(
                'Total Area',
                farmer.farms.first.areaHectares.toString(),
              ),
              // _buildStatRow('Member Since', farmer['joinDate']),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            context,
            title: 'Actions',
            children: [
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Send Message'),
                onTap: () => _sendSMS(farmer.phoneNumber),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add_location_alt),
                title: const Text('Add New Farm'),
                onTap: () {
                  // TODO: Implement add new farm
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmsTab(BuildContext context, FarmerFromServerModel farmer) {
    if (farmer.farms.isEmpty) {
      return const Center(child: Text('No farms found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: farmer.farms.length,
      itemBuilder: (context, index) {
        final farm = farmer.farms[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.agriculture, size: 32),
            title: Text(
              farm.farmCode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Crop: ${farmer.cropType}'),
                Text('Area: ${farm.areaHectares}'),
                Text('Status: ${farm.status}'),
                Text('Planted: ${farmer.plantingDate}'),
                Text('Harvested: ${farmer.harvestDate}'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return FarmMapScreen(farm: farm);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onTap,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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

  void _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
