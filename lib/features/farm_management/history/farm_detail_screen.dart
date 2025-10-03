// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'farm_history_provider.dart';
//
// class FarmDetailScreen extends StatefulWidget {
//   const FarmDetailScreen({super.key, required this.farmId});
//
//   final String farmId;
//
//   @override
//   State<FarmDetailScreen> createState() => _FarmDetailScreenState();
// }
//
// class _FarmDetailScreenState extends State<FarmDetailScreen> {
//   late final TextEditingController _nameController;
//   late final TextEditingController _areaController;
//   late final TextEditingController _farmerNameController;
//   late final TextEditingController _locationController;
//   late Map<String, dynamic> _farm;
//   bool _isEditing = false;
//   bool _isLoading = false;
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     final provider = Provider.of<FarmHistoryProvider>(context, listen: false);
//     _farm = provider.getFarmById(widget.farmId) ?? {};
//
//     // Initialize controllers with current values
//     _nameController = TextEditingController(text: _farm['name'] ?? '');
//     _areaController = TextEditingController(text: _farm['area'] ?? '');
//     _farmerNameController = TextEditingController(
//       text: _farm['farmerName'] ?? '',
//     );
//     _locationController = TextEditingController(text: _farm['location'] ?? '');
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _areaController.dispose();
//     _farmerNameController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       final provider = Provider.of<FarmHistoryProvider>(context, listen: false);
//
//       // Update farm data
//       provider.updateFarmData(
//         farmId: _farm['id'],
//         name: _nameController.text.trim(),
//         area: _areaController.text.trim(),
//         farmerName: _farmerNameController.text.trim(),
//         location: _locationController.text.trim(),
//       );
//
//       // If status is Pending, show option to submit
//       if (_farm['status'] == 'Pending') {
//         final shouldSubmit = await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Submit for Approval'),
//             content: const Text(
//               'Do you want to submit this farm for approval?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('SAVE DRAFT'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('SUBMIT'),
//               ),
//             ],
//           ),
//         );
//
//         if (shouldSubmit == true) {
//           final success = await provider.submitFarmForApproval(_farm['id']);
//           if (mounted) {
//             if (success) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Farm submitted for approval')),
//               );
//               Navigator.pop(context);
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Failed to submit farm')),
//               );
//             }
//           }
//           return;
//         }
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Changes saved successfully')),
//         );
//         setState(() => _isEditing = false);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('An error occurred. Please try again.')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FarmHistoryProvider>(
//       builder: (context, provider, _) {
//         _farm = provider.getFarmById(widget.farmId) ?? _farm;
//         if (_farm.isEmpty) {
//           return const Scaffold(body: Center(child: Text('Farm not found')));
//         }
//
//         final polygon =
//             (_farm['polygon'] as List<dynamic>?)?.cast<LatLng>() ?? [];
//
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(_farm['name'] ?? 'Farm Details'),
//             actions: [
//               if (_farm['status'] == 'Pending')
//                 IconButton(
//                   icon: Icon(_isEditing ? Icons.close : Icons.edit),
//                   onPressed: () {
//                     setState(() {
//                       _isEditing = !_isEditing;
//                       if (!_isEditing) {
//                         // Reset form if canceling edit
//                         _nameController.text = _farm['name'] ?? '';
//                         _areaController.text = _farm['area'] ?? '';
//                         _farmerNameController.text = _farm['farmerName'] ?? '';
//                         _locationController.text = _farm['location'] ?? '';
//                       }
//                     });
//                   },
//                 ),
//             ],
//           ),
//           body: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Farm Details Card
//                         Card(
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildEditableField(
//                                   'Farm Name',
//                                   _nameController,
//                                   isEditable: _isEditing,
//                                   isRequired: true,
//                                 ),
//                                 _buildDivider(),
//                                 _buildEditableField(
//                                   'Farmer Name',
//                                   _farmerNameController,
//                                   isEditable: _isEditing,
//                                   isRequired: true,
//                                 ),
//                                 _buildDivider(),
//                                 _buildEditableField(
//                                   'Location',
//                                   _locationController,
//                                   isEditable: _isEditing,
//                                   isRequired: true,
//                                 ),
//                                 _buildDivider(),
//                                 _buildEditableField(
//                                   'Area',
//                                   _areaController,
//                                   isEditable: _isEditing,
//                                   isRequired: true,
//                                   keyboardType: TextInputType.number,
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.allow(
//                                       RegExp(r'[0-9.]'),
//                                     ),
//                                   ],
//                                   suffixText: 'hactares',
//                                 ),
//                                 _buildDivider(),
//                                 _buildDetailRow(
//                                   'Status',
//                                   _farm['status'] ?? 'N/A',
//                                 ),
//                                 _buildDivider(),
//                                 _buildDetailRow(
//                                   'Date Added',
//                                   _farm['date'] ?? 'N/A',
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         // Map Section
//                         const Text(
//                           'Farm Location',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Container(
//                           height: 300,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: GoogleMap(
//                               initialCameraPosition: CameraPosition(
//                                 target: _calculateCenter(polygon),
//                                 zoom: 15,
//                               ),
//                               polygons: {
//                                 Polygon(
//                                   polygonId: PolygonId(widget.farmId),
//                                   points: polygon,
//                                   fillColor: Colors.blue.withOpacity(0.2),
//                                   strokeColor: Colors.blue,
//                                   strokeWidth: 2,
//                                 ),
//                               },
//                               myLocationEnabled: true,
//                               myLocationButtonEnabled: true,
//                               zoomControlsEnabled: false,
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         // Action Buttons
//                         if (_isEditing) ...[
//                           const SizedBox(height: 16),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: _submitForm,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Theme.of(context).primaryColor,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                               ),
//                               child: _isLoading
//                                   ? const SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                   : const Text(
//                                       'SAVE CHANGES',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                         ] else if (_farm['status'] == 'Pending') ...[
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () => _submitForm(),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                               ),
//                               child: const Text(
//                                 'SUBMIT',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                         ],
//
//                         SizedBox(
//                           width: double.infinity,
//                           child: OutlinedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => FullScreenMap(
//                                     farmName: _farm['name'],
//                                     polygon: polygon,
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               side: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                             child: Text(
//                               'VIEW FULL MAP',
//                               style: TextStyle(
//                                 color: Theme.of(context).primaryColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDivider() {
//     return Divider(
//       height: 1,
//       thickness: 1,
//       color: Colors.grey.withOpacity(0.2),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEditableField(
//     String label,
//     TextEditingController controller, {
//     bool isEditable = false,
//     bool isRequired = false,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     String? suffixText,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label + (isRequired ? ' *' : ''),
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: isEditable
//                 ? TextFormField(
//                     controller: controller,
//                     keyboardType: keyboardType,
//                     inputFormatters: inputFormatters,
//                     decoration: InputDecoration(
//                       isDense: true,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 12,
//                       ),
//                       suffixText: suffixText,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(
//                           color: Colors.grey[300]!,
//                           width: 1,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(
//                           color: Colors.grey[300]!,
//                           width: 1,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(
//                           color: Theme.of(context).primaryColor,
//                           width: 1.5,
//                         ),
//                       ),
//                     ),
//                     style: const TextStyle(fontSize: 14),
//                     validator: (value) {
//                       if (isRequired &&
//                           (value == null || value.trim().isEmpty)) {
//                         return 'This field is required';
//                       }
//                       return null;
//                     },
//                   )
//                 : Text(
//                     controller.text.isNotEmpty ? controller.text : 'N/A',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     textAlign: TextAlign.end,
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper method to calculate center of polygon for camera position
//   LatLng _calculateCenter(List<LatLng> points) {
//     if (points.isEmpty) return const LatLng(0, 0);
//
//     double lat = 0, lng = 0;
//     for (var point in points) {
//       lat += point.latitude;
//       lng += point.longitude;
//     }
//
//     return LatLng(lat / points.length, lng / points.length);
//   }
//
//   // Helper method to calculate bounds for polygon
//   LatLngBounds _calculateBounds(List<LatLng> points) {
//     double? minLat, maxLat, minLng, maxLng;
//
//     for (var point in points) {
//       minLat = (minLat == null || point.latitude < minLat)
//           ? point.latitude
//           : minLat;
//       maxLat = (maxLat == null || point.latitude > maxLat)
//           ? point.latitude
//           : maxLat;
//       minLng = (minLng == null || point.longitude < minLng)
//           ? point.longitude
//           : minLng;
//       maxLng = (maxLng == null || point.longitude > maxLng)
//           ? point.longitude
//           : maxLng;
//     }
//
//     return LatLngBounds(
//       northeast: LatLng(maxLat ?? 0, maxLng ?? 0),
//       southwest: LatLng(minLat ?? 0, minLng ?? 0),
//     );
//   }
// }
//
// class FullScreenMap extends StatefulWidget {
//   final String farmName;
//   final List<LatLng> polygon;
//
//   const FullScreenMap({Key? key, required this.farmName, required this.polygon})
//     : super(key: key);
//
//   @override
//   _FullScreenMapState createState() => _FullScreenMapState();
// }
//
// class _FullScreenMapState extends State<FullScreenMap> {
//   late GoogleMapController _mapController;
//   bool _isLoading = true;
//   late LatLngBounds _bounds;
//
//   @override
//   void initState() {
//     super.initState();
//     _bounds = _calculateBounds(widget.polygon);
//     _loadMap();
//   }
//
//   Future<void> _loadMap() async {
//     // Small delay to ensure the map is properly initialized
//     await Future.delayed(const Duration(milliseconds: 300));
//     if (mounted) {
//       setState(() => _isLoading = false);
//       _fitBounds();
//     }
//   }
//
//   void _fitBounds() {
//     _mapController.animateCamera(CameraUpdate.newLatLngBounds(_bounds, 100.0));
//   }
//
//   LatLngBounds _calculateBounds(List<LatLng> points) {
//     double? minLat, maxLat, minLng, maxLng;
//
//     for (var point in points) {
//       minLat = (minLat == null || point.latitude < minLat)
//           ? point.latitude
//           : minLat;
//       maxLat = (maxLat == null || point.latitude > maxLat)
//           ? point.latitude
//           : maxLat;
//       minLng = (minLng == null || point.longitude < minLng)
//           ? point.longitude
//           : minLng;
//       maxLng = (maxLng == null || point.longitude > maxLng)
//           ? point.longitude
//           : maxLng;
//     }
//
//     // Add some padding to the bounds
//     final latPadding = (maxLat! - minLat!) * 0.1;
//     final lngPadding = (maxLng! - minLng!) * 0.1;
//
//     return LatLngBounds(
//       northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
//       southwest: LatLng(minLat - latPadding, minLng - lngPadding),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.farmName} - Farm Location'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.my_location),
//             onPressed: _fitBounds,
//             tooltip: 'Fit to bounds',
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(
//                 (widget.polygon.first.latitude + widget.polygon[1].latitude) /
//                     2,
//                 (widget.polygon.first.longitude + widget.polygon[1].longitude) /
//                     2,
//               ),
//               zoom: 15,
//             ),
//             onMapCreated: (controller) {
//               _mapController = controller;
//               // Small delay to ensure the map is fully loaded
//               Future.delayed(const Duration(milliseconds: 500), _fitBounds);
//             },
//             polygons: {
//               Polygon(
//                 polygonId: const PolygonId('full_screen_polygon'),
//                 points: widget.polygon,
//                 fillColor: Colors.blue.withOpacity(0.3),
//                 strokeColor: Colors.blue,
//                 strokeWidth: 3,
//               ),
//             },
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             zoomControlsEnabled: false,
//             mapToolbarEnabled: true,
//             compassEnabled: true,
//             rotateGesturesEnabled: true,
//             tiltGesturesEnabled: true,
//             zoomGesturesEnabled: true,
//             scrollGesturesEnabled: true,
//           ),
//
//           if (_isLoading) const Center(child: CircularProgressIndicator()),
//
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: _fitBounds,
//               child: const Icon(Icons.zoom_out_map),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _mapController.dispose();
//     super.dispose();
//   }
// }
