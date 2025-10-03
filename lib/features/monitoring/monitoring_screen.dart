// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/widgets/custom_text_field.dart';
// import '../../core/widgets/primary_button.dart';
// import 'monitoring_provider.dart';
// import '../../../widgets/image_field_card.dart';
//
// class MonitoringScreen extends StatefulWidget {
//   const MonitoringScreen({super.key});
//
//   @override
//   State<MonitoringScreen> createState() => _MonitoringScreenState();
// }
//
// class _MonitoringScreenState extends State<MonitoringScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final List<String> farmDetails = [
//     "Main Buyers",
//     "Farm Boundary Polygon (Yes/No)",
//     "Land Use Classification",
//     "Accessibility (distance to road/market)",
//     "Proximity to Processing facility",
//     "Service Provider",
//     "Cooperatives or Farmer Groups Affiliated",
//     "Value Chain Linkages",
//     "Visit ID / Reference Number",
//     "Date of Visit",
//     "Officer Name & ID",
//     "Observations",
//     "Issues Identified",
//     "Infrastructure Identified",
//     "Recommended Actions",
//     "Follow-Up Status",
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => MonitoringProvider(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Monitoring'),
//           centerTitle: true,
//           elevation: 0,
//         ),
//         body: Consumer<MonitoringProvider>(
//           builder: (context, monitoringProvider, child) {
//             return Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const SizedBox(height: 20),
//                     _buildFormFields(monitoringProvider),
//                     const SizedBox(height: 20),
//                     _buildActionButtons(monitoringProvider),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFormFields(MonitoringProvider provider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         _buildTitleAndField(
//           farmDetails[0],
//           provider.mainBuyersController,
//         ),
//         _buildTitleAndField(
//           farmDetails[1],
//           provider.farmBoundaryPolygonController,
//         ),
//         _buildTitleAndField(
//           farmDetails[2],
//           provider.landUseClassificationController,
//         ),
//         _buildTitleAndField(
//           farmDetails[3],
//           provider.accessibilityController,
//         ),
//         _buildTitleAndField(
//           farmDetails[4],
//           provider.proximityToProcessingFacilityController,
//         ),
//         _buildTitleAndField(
//           farmDetails[5],
//           provider.serviceProviderController,
//         ),
//         _buildTitleAndField(
//           farmDetails[6],
//           provider.cooperativesAffiliatedController,
//         ),
//         _buildTitleAndField(
//           farmDetails[7],
//           provider.valueChainLinkagesController,
//         ),
//         _buildTitleAndField(
//           farmDetails[8],
//           provider.visitIdController,
//         ),
//         _buildTitleAndField(
//           farmDetails[9],
//           provider.dateOfVisitController,
//           onTap: () => _selectDate(context, provider.dateOfVisitController),
//           readOnly: true,
//         ),
//         _buildTitleAndField(
//           farmDetails[10],
//           provider.officerNameIdController,
//         ),
//         _buildTitleAndField(
//           farmDetails[11],
//           provider.observationsController,
//           maxLines: 3,
//         ),
//         _buildTitleAndField(
//           farmDetails[12],
//           provider.issuesIdentifiedController,
//           maxLines: 3,
//         ),
//         _buildTitleAndField(
//           farmDetails[13],
//           provider.infrastructureIdentifiedController,
//         ),
//         _buildTitleAndField(
//           farmDetails[14],
//           provider.recommendedActionsController,
//           maxLines: 3,
//         ),
//         _buildTitleAndField(
//           farmDetails[15],
//           provider.followUpStatusController,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons(MonitoringProvider monitoringProvider) {
//     return Row(
//       children: [
//         Expanded(
//           child: PrimaryButton(
//             borderColor: Theme.of(context).colorScheme.secondary,
//             backgroundColor: Theme.of(
//               context,
//             ).colorScheme.secondary.withOpacity(0.3),
//             onTap: () {
//               // farmProvider.saveFarm();
//             },
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.save,
//                   color: Theme.of(context).colorScheme.onSurface,
//                 ),
//                 Text(
//                   "Save",
//                   style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                     color: Theme.of(context).colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: PrimaryButton(
//             borderColor: Theme.of(context).colorScheme.primary,
//             backgroundColor: Theme.of(
//               context,
//             ).colorScheme.primary.withOpacity(0.3),
//             onTap: () {
//               // farmProvider.submitFarm();
//             },
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface), Text("Submit", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                   color: Theme.of(context).colorScheme.onSurface
//               ),)],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTitleAndField(
//     String title,
//     TextEditingController controller, {
//       bool enabled = true,
//         TextInputType keyboardType = TextInputType.text,
//     int maxLines = 1,
//     bool readOnly = false,
//     VoidCallback? onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w500,
//                   color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
//                 ),
//           ),
//           const SizedBox(height: 4),
//           CustomTextField(
//             enabled: enabled,
//             keyboardType: keyboardType,
//             label: "",
//             controller: controller,
//           ),
//
//         ],
//       ),
//     );
//   }
//
//
//   Future<void> _selectDate(
//       BuildContext context, TextEditingController controller) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       controller.text = "${picked.day}/${picked.month}/${picked.year}";
//     }
//   }
// }
