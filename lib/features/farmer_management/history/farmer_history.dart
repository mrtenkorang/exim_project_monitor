import 'package:exim_project_monitor/features/farmer_management/edit_farmer/edit_farmer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/models/farmer_model.dart';
import 'farmer_history_provider.dart';
import 'farmer_detail_screen.dart';
import '../add_farmer.dart';

class FarmerHistory extends StatefulWidget {
  const FarmerHistory({super.key});

  @override
  State<FarmerHistory> createState() => _FarmerHistoryState();
}

class _FarmerHistoryState extends State<FarmerHistory> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FarmerHistoryProvider(),
      child: const FarmerHistoryView(),
    );
  }
}

class FarmerHistoryView extends StatefulWidget {
  const FarmerHistoryView({super.key});

  @override
  State<FarmerHistoryView> createState() => _FarmerHistoryViewState();
}

class _FarmerHistoryViewState extends State<FarmerHistoryView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FarmerHistoryProvider>(context, listen: false);
    provider.loadFarmers();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FarmerHistoryProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: _isSearching
              ? TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search farmers...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              provider.setSearchQuery(value);
            },
          )
              : const Text('Farmer History'),
          actions: [
            if (!_isSearching)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    provider.setSearchQuery('');
                  });
                },
              ),
          ],
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.onSurface,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Submitted'),
            ],
            onTap: (index) {
              final provider = Provider.of<FarmerHistoryProvider>(context, listen: false);
              provider.changeTab(index);
            },
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                provider.setSearchQuery('');
              });
              return false;
            }
            return true;
          },
          child: const TabBarView(
            children: [
              FarmerList(isPending: true),
              FarmerList(isPending: false),
            ],
          ),
        ),
      ),
    );
  }
}

class FarmerList extends StatelessWidget {
  final bool isPending;

  const FarmerList({
    super.key,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FarmerHistoryProvider>(context);
    final farmers = isPending ? provider.pendingFarmers : provider.submittedFarmers;

    if (farmers.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'No pending farmers' : 'No submitted farmers',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        final farmer = farmers[index];
        return _buildFarmerCard(context, farmer);
      },
    );
  }

  Widget _buildFarmerCard(BuildContext context, Farmer farmer) {
    debugPrint(farmer.toMap().toString());
    final theme = Theme.of(context);
    final provider = Provider.of<FarmerHistoryProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              farmer.name ?? 'Unnamed Farmer',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Phone: ${farmer.phoneNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Location: ${farmer.community}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${farmer.isSynced}',
                  style: TextStyle(
                    color: _getStatusColor(farmer.isSynced, context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditFarmerScreen(farmer: farmer),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteDialog(context, provider, farmer);
                  },
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => FarmerDetailScreen(farmerId: farmer.id!),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(bool status, BuildContext context) {
    switch (status) {
      case true:
        return Theme.of(context).colorScheme.primary;
      case false:
        return Theme.of(context).colorScheme.error;
      }
  }

  void _showDeleteDialog(BuildContext context, FarmerHistoryProvider provider, Farmer farmer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Farmer'),
          content: const Text('Are you sure you want to delete this farmer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // provider.deleteFarmer(farmer['id']);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Farmer deleted successfully')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}