// import 'package:exim_project_monitor/features/farm_management/add_farm.dart';
// import 'package:exim_project_monitor/features/farmer_management/add_farmer.dart';
// import 'package:exim_project_monitor/features/farmer_management/history/farmer_history.dart';
// import 'package:exim_project_monitor/features/home/home_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../farm_management/history/farm_history.dart';
// import '../monitoring/monitoring_screen.dart';
// import '../settings/profile/profile_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<HomeProvider>(context, listen: false);
//       provider.getGreeting();
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => HomeProvider()
//         ..getGreeting()
//         ..getUserNameGreeting(),
//       child: Scaffold(
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildTopSection(),
//                 const SizedBox(height: 14),
//                 _buildActionButtons(),
//                 // const SizedBox(height: 16),
//                 // _buildMonitoringSection(),
//                 const SizedBox(height: 12),
//                 Expanded(child: _buildTabsSection()),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMonitoringSection() {
//     return GestureDetector(
//       onTap: _showMonitoringOptions,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.primaryContainer,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.monitor_heart_outlined, size: 24,),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Monitoring',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'View and manage monitoring activities',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       fontWeight: FontWeight.bold
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16,
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTopSection() {
//     return Consumer<HomeProvider>(
//       builder: (context, provider, child) {
//         final theme = Theme.of(context);
//         final colorScheme = theme.colorScheme;
//
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       provider.userNameGreeting,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w500,
//                         color: colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       provider.greeting,
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ProfileScreen(),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: colorScheme.primaryContainer,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: colorScheme.outline.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.person_rounded,
//                     color: colorScheme.onPrimaryContainer,
//                     size: 24,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTabsSection() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: TabBar(
//             controller: _tabController,
//             indicator: BoxDecoration(
//               color: colorScheme.primary,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             indicatorSize: TabBarIndicatorSize.tab,
//             indicatorPadding: const EdgeInsets.all(4),
//             dividerColor: Colors.transparent,
//             labelColor: colorScheme.onPrimary,
//             unselectedLabelColor: colorScheme.onSurfaceVariant,
//             labelStyle: theme.textTheme.titleSmall?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//             unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
//               fontWeight: FontWeight.w500,
//             ),
//             tabs: const [
//               Tab(text: 'Farms Overview'),
//               Tab(text: 'Farmers Overview'),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: colorScheme.surfaceVariant.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: colorScheme.outlineVariant.withOpacity(0.5),
//               ),
//             ),
//             child: TabBarView(
//               controller: _tabController,
//               children: [_buildFarmsOverview(), _buildFarmersOverview()],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFarmsOverview() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.agriculture_rounded,
//                 color: colorScheme.primary,
//                 size: 28,
//               ),
//               // const SizedBox(width: 12),
//               Text(
//                 'Farms Overview',
//                 style: theme.textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 34),
//           Expanded(
//             child: GridView.count(
//               crossAxisCount: 2,
//               crossAxisSpacing: 18,
//               mainAxisSpacing: 18,
//               childAspectRatio: 1.1,
//               children: [
//                 _buildMetricCard(
//                   title: 'Pending Farms',
//                   value: '20',
//                   icon: Icons.pending_actions_rounded,
//                   color: colorScheme.primary,
//                   backgroundColor: colorScheme.tertiaryContainer,
//                 ),
//                 _buildMetricCard(
//                   title: 'Submitted Farms',
//                   value: '45',
//                   icon: Icons.check_circle_rounded,
//                   color: colorScheme.secondary,
//                   backgroundColor: colorScheme.primaryContainer,
//                 ),
//                 _buildMetricCard(
//                   title: 'Total Farms',
//                   value: '65',
//                   icon: Icons.landscape_rounded,
//                   color: colorScheme.secondary,
//                   backgroundColor: colorScheme.secondaryContainer,
//                 ),
//                 _buildMetricCard(
//                   title: 'Active Farms',
//                   value: '58',
//                   icon: Icons.trending_up_rounded,
//                   color: Colors.green,
//                   backgroundColor: Colors.green.withOpacity(0.1),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFarmersOverview() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.people_rounded, color: colorScheme.primary, size: 28),
//               const SizedBox(width: 12),
//               Text(
//                 'Farmers Overview',
//                 style: theme.textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 34),
//           Expanded(
//             child: GridView.count(
//               crossAxisCount: 2,
//               crossAxisSpacing: 24,
//               mainAxisSpacing: 24,
//               childAspectRatio: 1.1,
//               children: [
//                 _buildMetricCard(
//                   title: 'Active Farmers',
//                   value: '142',
//                   icon: Icons.person_rounded,
//                   color: colorScheme.secondary,
//                   backgroundColor: colorScheme.primaryContainer,
//                 ),
//                 _buildMetricCard(
//                   title: 'New Farmers',
//                   value: '18',
//                   icon: Icons.person_add_rounded,
//                   color: colorScheme.primary,
//                   backgroundColor: colorScheme.tertiaryContainer,
//                 ),
//                 _buildMetricCard(
//                   title: 'Verified Farmers',
//                   value: '128',
//                   icon: Icons.verified_user_rounded,
//                   color: Colors.green,
//                   backgroundColor: Colors.green.withOpacity(0.1),
//                 ),
//                 _buildMetricCard(
//                   title: 'Total Farmers',
//                   value: '160',
//                   icon: Icons.groups_rounded,
//                   color: colorScheme.secondary,
//                   backgroundColor: colorScheme.secondaryContainer,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMetricCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//     required Color backgroundColor,
//   }) {
//     final theme = Theme.of(context);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(16),
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: color.withOpacity(0.1),
//         //     blurRadius: 8,
//         //     offset: const Offset(0, 2),
//         //   ),
//         // ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: color, size: 20),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.more_vert_rounded,
//                   color: theme.colorScheme.onSurfaceVariant,
//                   size: 16,
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Text(
//               value,
//               style: theme.textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurface,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showManagementOptions({required bool isFarmManagement}) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final title = isFarmManagement ? 'Farm Management' : 'Farmer Management';
//
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: colorScheme.onSurface.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               title,
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 24),
//             _buildOptionTile(
//               icon: Icons.add_circle_outline_rounded,
//               title: 'Create New ${isFarmManagement ? 'Farm' : 'Farmer'}',
//               subtitle:
//                   'Add a new ${isFarmManagement ? 'farm' : 'farmer'} record',
//               color: colorScheme.primary,
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return isFarmManagement
//                           ? const AddFarmScreen()
//                           : const AddFarmerScreen();
//                     },
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildOptionTile(
//               icon: Icons.history_rounded,
//               title: 'View History',
//               subtitle:
//                   'View all ${isFarmManagement ? 'farms' : 'farmers'} records',
//               color: colorScheme.secondary,
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return isFarmManagement
//                           ? const FarmHistory()
//                           : const FarmerHistory();
//                     },
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildOptionTile(
//               icon: Icons.download,
//               title: 'Export Data',
//               subtitle:
//                   'Download ${isFarmManagement ? 'farms' : 'farmers'} data',
//               color: colorScheme.tertiary,
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Show analytics
//               },
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: FilledButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: FilledButton.styleFrom(
//                   backgroundColor: colorScheme.surfaceVariant,
//                   foregroundColor: colorScheme.onSurfaceVariant,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Close'),
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showMonitoringOptions() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: colorScheme.onSurface.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Monitoring',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 24),
//             _buildOptionTile(
//               icon: Icons.visibility_outlined,
//               title: 'Create New Monitoring Data',
//               subtitle: 'Create new monitoring data',
//               color: colorScheme.primary,
//               onTap: () {
//                 Navigator.pop(context);
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(
//                 //     builder: (context) {
//                 //       return const MonitoringScreen();
//                 //     },
//                 //   ),
//                 // );
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildOptionTile(
//               icon: Icons.analytics_outlined,
//               title: 'View Monitoring Data',
//               subtitle: 'View all monitoring activities and data',
//               color: colorScheme.secondary,
//               onTap: () {
//                 Navigator.pop(context);
//
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildOptionTile(
//               icon: Icons.download_outlined,
//               title: 'Export Data',
//               subtitle: 'Download monitoring data in various formats',
//               color: colorScheme.tertiary,
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Implement data export
//               },
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: FilledButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: FilledButton.styleFrom(
//                   backgroundColor: colorScheme.surfaceVariant,
//                   foregroundColor: colorScheme.onSurfaceVariant,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Close'),
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOptionTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     final theme = Theme.of(context);
//
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: color.withOpacity(0.1), width: 1),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right_rounded,
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             height: 120,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   colorScheme.primary,
//                   colorScheme.primary.withOpacity(0.8),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () => _showManagementOptions(isFarmManagement: true),
//                 borderRadius: BorderRadius.circular(16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.add_circle_rounded,
//                         color: colorScheme.onPrimary,
//                         size: 24,
//                       ),
//                       const Spacer(),
//                       Text(
//                         'Farm Management',
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(
//                               color: colorScheme.onPrimary,
//                               fontWeight: FontWeight.bold,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Container(
//             height: 120,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   colorScheme.secondary,
//                   colorScheme.secondary.withOpacity(0.8),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () => _showManagementOptions(isFarmManagement: false),
//                 borderRadius: BorderRadius.circular(16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.people_alt_rounded,
//                         color: colorScheme.onSecondary,
//                         size: 24,
//                       ),
//                       const Spacer(),
//                       Text(
//                         'Farmer Management',
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(
//                               color: colorScheme.onSecondary,
//                               fontWeight: FontWeight.bold,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:exim_project_monitor/features/farm_management/add_farm.dart';
import 'package:exim_project_monitor/features/farmer_management/add_farmer.dart';
import 'package:exim_project_monitor/features/farmer_management/history/farmer_history.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../core/models/custom_user.dart';
import '../farm_management/history/farm_history.dart';
import '../farmers/farmer_list_screen.dart';
import '../settings/profile/profile_screen.dart';
import 'home_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.userInfo});
  final CmUser? userInfo;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        // backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color:
                    theme.primaryColor,
                    // gradient: LinearGradient(
                    //   colors: [
                    //
                    //     // theme.scaffoldBackgroundColor,
                    //   ],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.surface,
                            child: Text(
                              widget.userInfo!.firstName![0] + widget.userInfo!.lastName![0],
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${widget.userInfo!.firstName} ${widget.userInfo!.lastName}",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.surface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.userInfo!.district!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.surface.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: 60,
                              height: 60,
                              child: _buildTopSection()),
                          // CircleAvatar(
                          //   backgroundColor: theme.colorScheme.surface,
                          //   child: IconButton(
                          //     icon: Icon(Icons.refresh, color: theme.primaryColor),
                          //     // onPressed: () => Get.to(() => SyncPage()),
                          //     onPressed: (){},
                          //     tooltip: 'Refresh',
                          //   ),
                          // ),
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     TextButton(
                      //       onPressed: () => Get.to(() => DashboardScreen()),
                      //       child: Container(
                      //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      //         decoration: BoxDecoration(
                      //           color: theme.colorScheme.surface,
                      //           borderRadius: BorderRadius.circular(20),
                      //         ),
                      //         child: Text(
                      //           "View Dashboard",
                      //           style: theme.textTheme.labelLarge?.copyWith(
                      //             color: theme.primaryColor,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // _buildPcFundingSection(context),
                  // const SizedBox(height: 16),
                  _buildEvacuationSection(
                    imgPath: "assets/img/farmer.png",
                    context,
                    title: "Farmer Management",
                    color: theme.primaryColor,
                    onAdd: () async {
                      final result = await Get.to(() => const AddFarmerScreen());
                      _handleResult(result);
                    },
                    onList: () async {
                      final result = await Get.to(() => const FarmerListScreen());
                      _handleResult(result);
                    },
                    onHistory: () async {
                      final result = await Get.to(() => const FarmerHistory());
                      _handleResult(result);
                    },
                    onSync: () async {
                      // var res = await homeController.submitAllPendingPrimaryEvacData();
                      // if (res) setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEvacuationSection(
                    imgPath: "assets/img/farm.png",
                    context,
                    title: "Farm Management",
                    color: theme.colorScheme.primary,
                    onAdd: () async {
                      final result = await Get.to(() => const AddFarmScreen());
                      _handleResult(result);
                    },
                    onList: () async {
                      // final result = await Get.to(() => FarmListScreen());
                      // _handleResult(result);
                    },
                    onHistory: () async {
                      final result = await Get.to(() => const FarmHistory());
                      _handleResult(result);
                    },
                    onSync: () async {
                      // var res = await homeController.submitAllPendingSecondaryEvacData();
                      // if (res) setState(() {});
                    },
                  ),
                  const SizedBox(height: 5),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleResult(dynamic result) {
    if (result != null && result is Map<String, dynamic> && result["refreshState"] == true) {
      setState(() {});
    }
  }

  // Widget _buildPcFundingSection(BuildContext context) {
  //   final theme = Theme.of(context);
  //
  //   return Card(
  //     shadowColor: Colors.transparent,
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.attach_money, color: theme.primaryColor),
  //               const SizedBox(width: 8),
  //               Text("PC Funding", style: theme.textTheme.titleMedium),
  //               const Spacer(),
  //               Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(Icons.sync, size: 16, color: theme.primaryColor),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     "Sync",
  //                     style: theme.textTheme.labelLarge?.copyWith(
  //                       color: theme.primaryColor,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           GridView.count(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             crossAxisCount: 3,
  //             crossAxisSpacing: 10,
  //             mainAxisSpacing: 10,
  //             childAspectRatio: 1.5,
  //             children: [
  //               _buildOptionContainer(
  //                 context,
  //                 "Add funds",
  //                 Icons.add_circle_outline,
  //                 true,
  //                     () async {
  //                   final result = await Get.to(() => AddFunding());
  //                   _handleResult(result);
  //                 },
  //               ),
  //               _buildOptionContainer(
  //                 context,
  //                 "History",
  //                 Icons.history,
  //                 true,
  //                     () => Get.to(() => FundsHistory()),
  //               ),
  //               _buildOptionContainer(
  //                 context,
  //                 "Funded PCs",
  //                 Icons.list_alt,
  //                 true,
  //                     () => Get.to(() => FundedPcs()),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildOptionContainer(
      BuildContext context,
      String title,
      IconData icon,
      bool isPrimary,
      VoidCallback onTap,
      ) {
    final theme = Theme.of(context);
    final color = isPrimary ? theme.primaryColor : theme.colorScheme.secondary;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvacuationSection(
      BuildContext context, {
        required String title,
        required Color color,
        required VoidCallback onAdd,
        required VoidCallback onList,
        required VoidCallback onHistory,
        required VoidCallback onSync,
        required String imgPath,
      }) {
    final theme = Theme.of(context);
    final isPrimary = color == theme.secondaryHeaderColor;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(imgPath, width: 20, height: 20)
                ),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.sync, size: 20, color: color),
                  onPressed: onSync,
                  tooltip: 'Sync Data',
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildOptionContainer(context, "Add New", Icons.add_circle_outline, isPrimary, onAdd),
                _buildOptionContainer(context, "History", Icons.history, isPrimary, onHistory),
                _buildOptionContainer(context, "List", Icons.list_alt, isPrimary, onList),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  provider.greeting,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
