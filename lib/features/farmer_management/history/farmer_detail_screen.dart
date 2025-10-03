// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../core/models/farmer_model.dart';
// import 'farmer_history_provider.dart';
//
// class FarmerDetailScreen extends StatefulWidget {
//   const FarmerDetailScreen({super.key, required this.farmerId});
//
//   final String farmerId;
//
//   @override
//   State<FarmerDetailScreen> createState() => _FarmerDetailScreenState();
// }
//
// class _FarmerDetailScreenState extends State<FarmerDetailScreen> {
//   late final TextEditingController _nameController;
//   late final TextEditingController _phoneController;
//   late final TextEditingController _locationController;
//
//   late Farmer _farmer;
//   bool _isEditing = false;
//   bool _isLoading = false;
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     final provider = Provider.of<FarmerHistoryProvider>(context, listen: false);
//     _farmer = provider.getFarmerById(widget.farmerId)!;
//
//     // Initialize controllers with current values
//     _nameController = TextEditingController(text: _farmer.name);
//     _phoneController = TextEditingController(text: _farmer.phoneNumber);
//     _locationController = TextEditingController(text: _farmer.community);
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
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
//       final provider = Provider.of<FarmerHistoryProvider>(context, listen: false);
//
//
//
//       // If status is Pending, show option to submit
//       if (!_farmer.isSynced) {
//         final shouldSubmit = await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Submit for Approval'),
//             content: const Text(
//               'Do you want to submit this farmer for approval?',
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
//         // if (shouldSubmit == true) {
//         //   final success = await provider.submitFarmerForApproval(_farmer['id']);
//         //   if (mounted) {
//         //     if (success) {
//         //       ScaffoldMessenger.of(context).showSnackBar(
//         //         const SnackBar(content: Text('Farmer submitted for approval')),
//         //       );
//         //       Navigator.pop(context);
//         //     } else {
//         //       ScaffoldMessenger.of(context).showSnackBar(
//         //         const SnackBar(content: Text('Failed to submit farmer')),
//         //       );
//         //     }
//         //   }
//         //   return;
//         // }
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
//   void _toggleEditMode() {
//     setState(() {
//       _isEditing = !_isEditing;
//       if (!_isEditing) {
//         // Reset form if canceling edit
//         _nameController.text = _farmer.name;
//         _phoneController.text = _farmer.phoneNumber;
//         _locationController.text = _farmer.community;
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FarmerHistoryProvider>(
//       builder: (context, provider, _) {
//         _farmer = provider.getFarmerById(widget.farmerId) ?? _farmer;
//
//         // Show error if farmer not found
//         if (_farmer.id == null) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Farmer Details')),
//             body: const Center(
//               child: Text(
//                 'Farmer not found',
//                 style: TextStyle(fontSize: 16, color: Colors.red),
//               ),
//             ),
//           );
//         }
//
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(_farmer.name ?? 'Farmer Details'),
//             actions: [
//               if (!_farmer.isSynced)
//                 IconButton(
//                   icon: _isEditing ? const Icon(Icons.close) : const Icon(Icons.edit),
//                   onPressed: _toggleEditMode,
//                   tooltip: _isEditing ? 'Cancel Edit' : 'Edit Farmer',
//                 ),
//             ],
//           ),
//           body: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Personal Information Card
//                   Card(
//                     elevation: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Personal Information',
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           _buildEditableField(
//                             'Full Name',
//                             _nameController,
//                             isEditable: _isEditing,
//                             isRequired: true,
//                           ),
//                           _buildDivider(),
//                           _buildEditableField(
//                             'Phone Number',
//                             _phoneController,
//                             isEditable: _isEditing,
//                             keyboardType: TextInputType.phone,
//                             isRequired: true,
//                           ),
//                           _buildDivider(),
//                           _buildEditableField(
//                             'Location',
//                             _locationController,
//                             isEditable: _isEditing,
//                             isRequired: true,
//                           ),
//                           _buildDivider(),
//                           _buildReadOnlyField(
//                             'Status',
//                             _farmer.isSynced.toString(),
//                             status: _farmer.isSynced,
//                           ),
//                           ...[
//                           _buildDivider(),
//                           _buildReadOnlyField(
//                             'Created Date',
//                             _farmer.createdAt.toString(),
//                           ),
//                         ],
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   if (_isEditing) ...[
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: _submitForm,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                         ),
//                         child: const Text('Save Changes'),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildEditableField(
//       String label,
//       TextEditingController controller, {
//         bool isEditable = false,
//         bool isRequired = false,
//         TextInputType keyboardType = TextInputType.text,
//       }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (isRequired)
//               Text(
//                 ' *',
//                 style: GoogleFonts.poppins(
//                   color: Colors.red,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         isEditable
//             ? TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           enabled: isEditable,
//           decoration: InputDecoration(
//             isDense: true,
//             contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey.shade400),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey.shade400),
//             ),
//           ),
//           validator: (value) {
//             if (isRequired && (value == null || value.isEmpty)) {
//               return 'This field is required';
//             }
//
//             // Phone number validation
//             if (label == 'Phone Number' && value != null && value.isNotEmpty) {
//               final phoneRegex = RegExp(r'^[0-9]{10,15}$');
//               if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
//                 return 'Please enter a valid phone number';
//               }
//             }
//
//             return null;
//           },
//         )
//             : Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.grey.shade50,
//           ),
//           width: double.infinity,
//           child: Text(
//             controller.text.isNotEmpty ? controller.text : 'Not provided',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: controller.text.isNotEmpty ? Colors.black87 : Colors.grey,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildReadOnlyField(String label, String value, {bool status = false}) {
//     Color statusColor = Colors.black87;
//
//     // Set color based on status
//     switch (status) {
//       case true:
//         statusColor = Colors.blue;
//         break;
//       case false:
//         statusColor = Colors.green;
//         break;
//
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.grey.shade50,
//           ),
//           width: double.infinity,
//           child: Text(
//             value.isNotEmpty ? value : 'Not provided',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: value.isNotEmpty ? statusColor : Colors.grey,
//               fontWeight: status ? FontWeight.w500 : FontWeight.normal,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDivider() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(vertical: 12),
//       child: Divider(height: 1, thickness: 1),
//     );
//   }
// }