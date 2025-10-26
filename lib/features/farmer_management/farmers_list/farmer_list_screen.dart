import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'farmer_provider.dart';
import 'farmer_detail_screen.dart';

class FarmerListScreen extends StatefulWidget {
  const FarmerListScreen({super.key});

  @override
  State<FarmerListScreen> createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends State<FarmerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmerProvider = Provider.of<FarmerListProvider>(context, listen: false);
      farmerProvider.loadFarmers();
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
    final provider = Provider.of<FarmerListProvider>(context, listen: false);

    if (query.isEmpty) {
      provider.clearSearch();
      setState(() {
        _isSearching = false;
      });
    } else {
      provider.searchFarmers(query);
      setState(() {
        _isSearching = true;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final provider = Provider.of<FarmerListProvider>(context, listen: false);
    provider.clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  void _showFilterDialog(BuildContext context) {
    final provider = Provider.of<FarmerListProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Farmers'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Region Filter
              const Text('Region:'),
              DropdownButtonFormField<String>(
                value: provider.selectedRegion,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Regions')),
                  ...provider.availableRegions.map((region) {
                    return DropdownMenuItem(value: region, child: Text(region));
                  }),
                ],
                onChanged: (value) {
                  provider.setRegionFilter(value);
                },
              ),
              const SizedBox(height: 16),

              // District Filter
              const Text('District:'),
              SizedBox(
                width: double.infinity, // Take full width of parent
                child: DropdownButtonFormField<String>(
                  isExpanded: true, // Allow the dropdown to expand
                  value: provider.selectedDistrict,
                  items: [
                    const DropdownMenuItem(
                      value: null, 
                      child: Text('All Districts', overflow: TextOverflow.ellipsis),
                    ),
                    ...provider.availableDistricts.map((district) {
                      return DropdownMenuItem(
                        value: district, 
                        child: Text(
                          district,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    provider.setDistrictFilter(value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Farm Count Filter
              const Text('Minimum Farms:'),
              DropdownButtonFormField<int>(
                value: provider.minFarmsCount,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Any')),
                  DropdownMenuItem(value: 1, child: Text('1+ Farms')),
                  DropdownMenuItem(value: 5, child: Text('5+ Farms')),
                  DropdownMenuItem(value: 10, child: Text('10+ Farms')),
                ],
                onChanged: (value) {
                  provider.setMinFarmsCount(value ?? 0);
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
            hintText: 'Search farmers...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
        )
            : const Text('Farmers'),
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
      body: Consumer<FarmerListProvider>(
        builder: (context, provider, _) {
          final displayFarmers = _isSearching ? provider.searchResults : provider.filteredFarmers;

          if (provider.isLoading && provider.farmers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (displayFarmers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSearching ? Icons.search_off : Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? 'No farmers found' : 'No farmers available',
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
                            ? '${displayFarmers.length} results for "${_searchController.text}"'
                            : '${displayFarmers.length} farmers (filtered)',
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

              // Farmers List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()
                  ),
                  itemCount: displayFarmers.length,
                  itemBuilder: (context, index) {
                    double totalArea = 0;
                    for (var farm in displayFarmers[index].farms) {
                      totalArea += farm.areaHectares;
                    }
                    final farmer = displayFarmers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.1),
                        contentPadding: const EdgeInsets.all(8),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            farmer.firstName.isNotEmpty ? farmer.firstName[0] : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          '${farmer.firstName} ${farmer.lastName}'.trim(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('📱 ${farmer.phoneNumber}'),
                            const SizedBox(height: 2),
                            Text('📍 ${farmer.community}'),
                            if (farmer.regionName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text('🏙️ ${farmer.regionName}'),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                                  label: Text(
                                    '${farmer.farmsCount} Farms',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
                                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                  label: Text(
                                    farmer.farms.isNotEmpty
                                        ? '${totalArea.toStringAsFixed(2)} ha'
                                        : 'N/A',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmerDetailScreen(
                                farmerId: farmer.id.toString(),
                                farmer: farmer,
                              ),
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
}