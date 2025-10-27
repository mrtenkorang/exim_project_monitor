import 'package:exim_project_monitor/core/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'farm_history_provider.dart';
import '../edit_farm/edit_farm.dart';

class FarmHistory extends StatelessWidget {
  const FarmHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FarmHistoryProvider(),
      child: const FarmHistoryView(),
    );
  }
}

class FarmHistoryView extends StatefulWidget {
  const FarmHistoryView({super.key});

  @override
  State<FarmHistoryView> createState() => _FarmHistoryViewState();
}

class _FarmHistoryViewState extends State<FarmHistoryView> {
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
    final provider = Provider.of<FarmHistoryProvider>(context, listen: false);
    provider.loadFarms();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FarmHistoryProvider>(context);
    
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
                      hintText: 'Search farms...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      provider.setSearchQuery(value);
                    },
                  )
                : const Text('Farm History'),
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
                final provider = Provider.of<FarmHistoryProvider>(context, listen: false);
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
                _FarmList(isPending: true),
                _FarmList(isPending: false),
              ],
            ),
          ),
        ),
      );
  }
}

class _FarmList extends StatelessWidget {
  final bool isPending;
  
  const _FarmList({
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FarmHistoryProvider>(context);
    final farms = isPending ? provider.pendingFarms : provider.submittedFarms;

    debugPrint('Rendering ${farms.length} ${isPending ? 'pending' : 'submitted'} farms');

    if (farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isPending ? 'No pending farms' : 'No submitted farms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isPending 
                ? 'Farms that are not yet submitted will appear here.'
                : 'Submitted farms will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadFarms(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemCount: farms.length,
        itemBuilder: (context, index) {
          debugPrint("THE FARM :::::::::::: ${farms[index].boundaryCoordinates}");
          final farm = farms[index];
          return _buildFarmCard(context, farm);
        },
      ),
    );
  }

  Future<void> _refreshFarms(FarmHistoryProvider provider) async {
    await provider.loadFarms();
  }

  Widget _buildFarmCard(BuildContext context, Farm farm) {
    final theme = Theme.of(context);
    final provider = Provider.of<FarmHistoryProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        // color: farm['status'] == 'Submitted' ? theme.colorScheme.primary.withOpacity(0.01): theme.colorScheme.secondary.withOpacity(0.1),
        // border: Border.all(
        //   color: farm["status"]== 'Submitted'?theme.colorScheme.primary:theme.colorScheme.secondary,
        //   width: 1,
        // ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          farm.location,
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
              'ID: ${farm.id}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${farm.createdAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isPending? Icons.edit:Icons.remove_red_eye, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFarmScreen(
                      farm: farm, 
                      isSynced: isPending,
                      onFarmSaved: () => _refreshFarms(provider),
                    ),
                  ),
                ).then((_) {
                  // Refresh the list when returning from the edit screen
                  _refreshFarms(provider);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmation(context, farm);
              },
            ),
          ],
        ),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => FarmDetailScreen(farmId: farm.id),
          //   ),
          // );
        },
      ),
    );
  }

  Color _getStatusColor(bool status) {
    switch (status) {
      case true:
        return Colors.orange;
      case false:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Farm farm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this farm? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('DELETE'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _deleteFarm(context, farm);
                  setState(() {});
                },
              ),
            ],
          );
          }
        );
      },
    );
  }

  Future<void> _deleteFarm(BuildContext context, Farm farm) async {
    try {
      final provider = Provider.of<FarmHistoryProvider>(context, listen: false);
      await provider.deleteFarm(farm.id!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farm deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting farm: $e')),
        );
      }
    }
  }
}
