import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'farmer_provider.dart';

class FarmerDetailScreen extends StatelessWidget {
  final String farmerId;
  final Map<String, dynamic> farmer;

  const FarmerDetailScreen({
    super.key,
    required this.farmerId, required this.farmer,
  });

  @override
  Widget build(BuildContext context) {
    final farmer = this.farmer;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(farmer['name']),

          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.agriculture), text: 'Farms'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProfileTab(context, farmer),
            _buildFarmsTab(context, farmer['farms'] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, Map<String, dynamic> farmer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard(
            context,
            title: 'Contact Information',
            children: [
              _buildDetailRow(Icons.phone, 'Phone', farmer['phone'],
                  onTap: () => _makePhoneCall(farmer['phone'])),
              _buildDetailRow(Icons.email, 'Email', farmer['email'],
                  onTap: () => _sendEmail(farmer['email'])),
              _buildDetailRow(
                  Icons.location_on, 'Location', farmer['location']),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            context,
            title: 'Farm Statistics',
            children: [
              _buildStatRow('Total Farms', '${farmer['totalFarms']}'),
              _buildStatRow('Total Area', farmer['totalArea']),
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
                onTap: () => _sendSMS(farmer['phone']),
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

  Widget _buildFarmsTab(BuildContext context, List<dynamic> farms) {
    if (farms.isEmpty) {
      return const Center(child: Text('No farms found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: farms.length,
      itemBuilder: (context, index) {
        final farm = farms[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.agriculture, size: 32),
            title: Text(
              farm['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Crop: ${farm['cropType']}'),
                Text('Area: ${farm['area']}'),
                Text('Status: ${farm['status']}'),
                Text('Planted: ${farm['plantingDate']}'),
                if (farm['harvestDate'] != null)
                  Text('Harvested: ${farm['harvestDate']}'),
              ],
            ),
            onTap: () {
              // TODO: Navigate to farm details
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                  ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
