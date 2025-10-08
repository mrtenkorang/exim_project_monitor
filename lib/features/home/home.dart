import 'package:exim_project_monitor/core/cache_service/cache_service.dart';
import 'package:exim_project_monitor/core/models/user_model.dart';
import 'package:exim_project_monitor/core/services/api/api.dart';
import 'package:exim_project_monitor/core/services/cache_service.dart';
import 'package:exim_project_monitor/features/farm_management/add_farm.dart';
import 'package:exim_project_monitor/features/farmer_management/add_farmer.dart';
import 'package:exim_project_monitor/features/farmer_management/history/farmer_history.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../farm_management/farm_list/farm_list.dart';
import '../farm_management/history/farm_history.dart';
import '../farmer_management/farmers_list/farmer_list_screen.dart';
import '../settings/profile/profile_screen.dart';
import 'home_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final homeController = Get.put(HomeController());

  User? userInfo;
  bool _isLoading = true;

  //load user info from cache
  _loadUserInfo() async {
    final cacheService = await CacheService.getInstance();
    userInfo = await cacheService.getUserInfo();

    debugPrint("USER INFO: ${userInfo?.toJson()}");

    //update the state
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load greeting
    Provider.of<HomeProvider>(context, listen: false).getUserNameGreeting();
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loading indicator while fetching user info
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.primaryColor,
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: Container(),
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: _buildTopSection(""),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (userInfo!.firstName!.isEmpty &&
                                    userInfo!.lastName!.isEmpty)
                                  Row(
                                    children: [
                                      Text(
                                        "${userInfo!.userName}",
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: theme.colorScheme.surface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
Spacer(),
                                      GestureDetector(
                                        onTap: () async {
                                          final api = APIService();
                                          await api.fetchFarmersFromServer();
                                        },
                                        child: Icon(Icons.sync, color: theme.secondaryHeaderColor),
                                      )
                                    ],
                                  ),
                                Text(
                                  "${userInfo?.firstName} ${userInfo?.lastName}",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.surface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${userInfo?.districtName}",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.surface,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildEvacuationSection(
                    imgPath: "assets/img/farmer.png",
                    context,
                    title: "Farmer Management",
                    color: theme.primaryColor,
                    onAdd: () async {
                      final result = await Get.to(
                            () => const AddFarmerScreen(),
                      );
                      _handleResult(result);
                    },
                    onList: () async {
                      final result = await Get.to(
                            () => const FarmerListScreen(),
                      );
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
                      final result = await Get.to(() => const FarmList());
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
    if (result != null &&
        result is Map<String, dynamic> &&
        result["refreshState"] == true) {
      setState(() {});
    }
  }

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
                  child: Image.asset(imgPath, width: 20, height: 20),
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
                _buildOptionContainer(
                  context,
                  "Add New",
                  Icons.add_circle_outline,
                  isPrimary,
                  onAdd,
                ),
                _buildOptionContainer(
                  context,
                  "History",
                  Icons.history,
                  isPrimary,
                  onHistory,
                ),
                _buildOptionContainer(
                  context,
                  "List",
                  Icons.list_alt,
                  isPrimary,
                  onList,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(String profileImage) {
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
                    image: profileImage.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(profileImage),
                      fit: BoxFit.cover,
                    )
                        : null,
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