import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'farmer_provider.dart';
import 'farmer_detail_screen.dart';

class FarmerListScreen extends StatelessWidget {
  const FarmerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmerProvider = Provider.of<FarmerListProvider>(context);
    final farmers = farmerProvider.farmers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: farmers.isEmpty
          ? const Center(child: Text('No farmers found'))
          : ListView.builder(
              itemCount: farmers.length,
              itemBuilder: (context, index) {
                final farmer = farmers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        farmer['name'][0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      farmer['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('📱 ${farmer['phone']}'),
                        const SizedBox(height: 2),
                        Text('📍 ${farmer['location']}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                              label: Text(
                                '${farmer['totalFarms']} Farms',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
                              label: Text(
                                farmer['totalArea'],
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
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
                            farmerId: farmer['id'],
                            farmer: farmer,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
