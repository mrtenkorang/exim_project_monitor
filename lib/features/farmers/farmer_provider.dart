import 'package:flutter/material.dart';

class FarmerListProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _farmers = [];

  // Getters
  List<Map<String, dynamic>> get farmers => _farmers;
  bool get isLoading => _isLoading;
  // Sample farmer data
  // Load farmers asynchronously
  Future<void> loadFarmers() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize with sample data
      _farmers = [
        {
          'id': 'f1',
          'name': 'John Doe',
          'phone': '+233 24 123 4567',
          'email': 'john.doe@example.com',
          'location': 'Eastern Region',
          'totalFarms': 3,
          'totalArea': '7.5 hectares',
          'joinDate': '2022-05-15',
          'farms': [
            {
              'id': '1',
              'name': 'Farm A',
              'area': '2.5 hectares',
              'status': 'Active',
              'cropType': 'Maize',
              'plantingDate': '2023-06-10',
            },
            {
              'id': '2',
              'name': 'Farm B',
              'area': '3.0 hectares',
              'status': 'Active',
              'cropType': 'Soybeans',
              'plantingDate': '2023-07-22',
            },
            {
              'id': '3',
              'name': 'Farm C',
              'area': '2.0 hectares',
              'status': 'Inactive',
              'cropType': 'Rice',
              'plantingDate': '2023-05-05',
              'harvestDate': '2023-09-10',
            },
          ],
        },
        {
          'id': 'f2',
          'name': 'Jane Smith',
          'phone': '+233 20 987 6543',
          'email': 'jane.smith@example.com',
          'location': 'Ashanti Region',
          'totalFarms': 2,
          'totalArea': '5.8 hectares',
          'joinDate': '2022-03-10',
          'farms': [
            {
              'id': '4',
              'name': 'Smith Farm',
              'area': '3.8 hectares',
              'status': 'Active',
              'cropType': 'Cocoa',
              'plantingDate': '2023-08-15',
            },
            {
              'id': '5',
              'name': 'Orchard View',
              'area': '2.0 hectares',
              'status': 'Active',
              'cropType': 'Oil Palm',
              'plantingDate': '2023-04-01',
            },
          ],
        },
      ];

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }}


}
