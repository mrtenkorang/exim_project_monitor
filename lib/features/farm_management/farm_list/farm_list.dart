import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exim_project_monitor/features/farm_management/farm_list/farm_list_provider.dart';
import 'package:exim_project_monitor/features/farmer_management/farmers_list/farm_map_screen.dart';

class FarmList extends StatefulWidget {
  const FarmList({super.key});

  @override
  State<FarmList> createState() => _FarmListState();
}

class _FarmListState extends State<FarmList> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmProvider = Provider.of<FarmListProvider>(context, listen: false);
      farmProvider.loadFarmers();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    final provider = Provider.of<FarmListProvider>(context, listen: false);

    if (query.isEmpty) {
      provider.clearSearch();
      setState(() {
        _isSearching = false;
      });
    } else {
      provider.searchFarms(query);
      setState(() {
        _isSearching = true;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final provider = Provider.of<FarmListProvider>(context, listen: false);
    provider.clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  void _showFilterDialog(BuildContext context) {
    final provider = Provider.of<FarmListProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Farms'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Filter
              const Text('Status:'),
              DropdownButtonFormField<String>(
                value: provider.selectedStatus,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Status')),
                  ...provider.availableStatuses.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                ],
                onChanged: (value) {
                  provider.setStatusFilter(value);
                },
              ),
              const SizedBox(height: 16),

              // Crop Type Filter
              // const Text('Crop Type:'),
              // DropdownButtonFormField<String>(
              //   value: provider.selectedCropType,
              //   items: [
              //     const DropdownMenuItem(value: null, child: Text('All Crops')),
              //     ...provider.availableCropTypes.map((crop) {
              //       return DropdownMenuItem(value: crop, child: Text(crop));
              //     }).toList(),
              //   ],
              //   onChanged: (value) {
              //     provider.setCropTypeFilter(value);
              //   },
              // ),
              // const SizedBox(height: 16),

              // Area Size Filter
              const Text('Minimum Area (ha):'),
              DropdownButtonFormField<double>(
                value: provider.minArea,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Any Size')),
                  DropdownMenuItem(value: 1, child: Text('1+ ha')),
                  DropdownMenuItem(value: 5, child: Text('5+ ha')),
                  DropdownMenuItem(value: 10, child: Text('10+ ha')),
                  DropdownMenuItem(value: 20, child: Text('20+ ha')),
                ],
                onChanged: (value) {
                  provider.setMinArea(value ?? 0);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('CLEAR ALL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('APPLY'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search farms...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
        )
            : const Text('Farms'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<FarmListProvider>(
        builder: (context, provider, _) {
          final displayFarms = _isSearching ? provider.searchResults : provider.filteredFarms;

          if (provider.isLoading && provider.farms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (displayFarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSearching ? Icons.search_off : Icons.agriculture_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? 'No farms found' : 'No farms available',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  if (_isSearching) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Try different search terms',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _clearSearch,
                      child: const Text('Clear Search'),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter/Search Info
              if (provider.hasActiveFilters || _isSearching)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Text(
                        _isSearching
                            ? '${displayFarms.length} results for "${_searchController.text}"'
                            : '${displayFarms.length} farms (filtered)',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          if (_isSearching) {
                            _clearSearch();
                          } else {
                            provider.clearFilters();
                          }
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),

              // Farms List
              Expanded(
                child: ListView.builder(
                  itemCount: displayFarms.length,
                  itemBuilder: (context, index) {
                    final farm = displayFarms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(farm.status).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.agriculture,
                            size: 24,
                            color: _getStatusColor(farm.status),
                          ),
                        ),
                        title: Text(
                          farm.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Code: ${farm.farmCode}'),
                            // Text('Crop: ${farm.cropType}'),
                            Text('Area: ${farm.areaHectares} ha'),
                            Text('Farmer: ${farm.farmerName}'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(farm.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getStatusColor(farm.status)),
                                  ),
                                  child: Text(
                                    farm.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(farm.status),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (farm.soilType.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.orange),
                                    ),
                                    child: Text(
                                      farm.soilType,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmMapScreen(farm: farm),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}