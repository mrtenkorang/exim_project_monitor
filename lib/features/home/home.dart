import 'package:exim_project_monitor/core/cache_service/cache_service.dart';
import 'package:exim_project_monitor/core/models/user_model.dart';
import 'package:exim_project_monitor/core/services/api/api.dart';
import 'package:exim_project_monitor/features/farm_management/add_farm.dart';
import 'package:exim_project_monitor/features/farmer_management/add_farmer.dart';
import 'package:exim_project_monitor/features/farmer_management/history/farmer_history.dart';
import 'package:exim_project_monitor/features/sync/sync_page.dart';
import 'package:exim_project_monitor/widgets/custom_snackbar.dart';
import 'package:exim_project_monitor/widgets/globals/globals.dart';
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
    final homeProvider = Provider.of<HomeProvider>(context);
    homeProvider.homeContext = context;

    // Show loading indicator while fetching user info
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        drawer: _buildDrawer(context),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenWidth < 360;
            final isLargeScreen = screenWidth > 600;

            return CustomScrollView(
              slivers: [
                // App Bar Section
                SliverAppBar(
                  automaticallyImplyLeading: false,

                  expandedHeight: isSmallScreen ? 100 : 120,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(color: theme.primaryColor),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 20,
                        vertical: isSmallScreen ? 12 : 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(
                                builder: (context) => IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    color: theme.colorScheme.surface,
                                  ),
                                  onPressed: () => Scaffold.of(context).openDrawer(),
                                ),
                              ),
                              // Profile Icon
                              // Container(
                              //   width: isSmallScreen ? 50 : 60,
                              //   height: isSmallScreen ? 50 : 60,
                              //   padding: const EdgeInsets.all(8),
                              //   decoration: BoxDecoration(
                              //     color: theme.colorScheme.primaryContainer,
                              //     shape: BoxShape.circle,
                              //     border: Border.all(
                              //       color: theme.colorScheme.outline.withOpacity(0.3),
                              //       width: 1,
                              //     ),
                              //   ),
                              //   child: Icon(
                              //     Icons.person_rounded,
                              //     color: theme.colorScheme.onPrimaryContainer,
                              //     size: isSmallScreen ? 20 : 24,
                              //   ),
                              // ),

                              SizedBox(width: isSmallScreen ? 8 : 12),
                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // User Name Row
                                    Row(
                                      children: [
                                        if (userInfo!.firstName!.isEmpty &&
                                            userInfo!.lastName!.isEmpty)
                                          Expanded(
                                            child: Text(
                                              "${userInfo!.userName}",
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                color: theme.colorScheme.surface,
                                                fontSize: isSmallScreen ? 16 : 18,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          )
                                        else
                                          Expanded(
                                            child: Text(
                                              "${userInfo?.firstName} ${userInfo?.lastName}",
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                color: theme.colorScheme.surface,
                                                fontSize: isSmallScreen ? 16 : 18,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        // Sync Button
                                        GestureDetector(
                                          onTap: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const SyncPage(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surface.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.sync,
                                              color: theme.secondaryHeaderColor,
                                              size: isSmallScreen ? 18 : 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isSmallScreen ? 2 : 4),
                                    // District Name
                                    Text(
                                      "${userInfo?.districtName}",
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.surface,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: isSmallScreen ? 2 : 4),
                                    // Greeting
                                    Consumer<HomeProvider>(
                                      builder: (context, provider, child) {
                                        return Text(
                                          provider.greeting,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.surface.withOpacity(0.9),
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content Section
                SliverPadding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Farmer Management Section
                      _buildManagementSection(
                        context,
                        title: "Farmer Management",
                        imgPath: "assets/img/farmer.png",
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
                          final res = await homeProvider.syncPendingFarmers();
                          debugPrint("Sync result: $res");
                          if (res) {
                            Globals().endWait(context);
                            CustomSnackbar.show(
                              context,
                              message: "Synced successfully",
                              type: SnackbarType.success,
                            );
                          } else {
                            Globals().endWait(context);
                            CustomSnackbar.show(
                              context,
                              message: "Sync failed",
                              type: SnackbarType.error,
                            );
                          }
                        },
                        isSmallScreen: isSmallScreen,
                        isLargeScreen: isLargeScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Farm Management Section
                      _buildManagementSection(
                        context,
                        title: "Farm Management",
                        imgPath: "assets/img/farm.png",
                        color: theme.colorScheme.primary,
                        onAdd: () async {
                          final result = await Get.to(() => const AddFarmScreen());
                          _handleResult(result);
                        },
                        onList: () async {
                          final result = await Get.to(() => const FarmList());
                        },
                        onHistory: () async {
                          final result = await Get.to(() => const FarmHistory());
                          _handleResult(result);
                        },
                        onSync: () async {
                          final res = await homeProvider.syncPendingFarms();
                          debugPrint("Sync result: $res");
                          if (res) {
                            Globals().endWait(context);
                            CustomSnackbar.show(
                              context,
                              message: "Synced successfully",
                              type: SnackbarType.success,
                            );
                          } else {
                            Globals().endWait(context);
                            CustomSnackbar.show(
                              context,
                              message: "Sync failed",
                              type: SnackbarType.error,
                            );
                          }
                        },
                        isSmallScreen: isSmallScreen,
                        isLargeScreen: isLargeScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Monitoring Section (Coming Soon)
                      _buildManagementSection(
                        context,
                        title: "Monitoring (coming soon)",
                        imgPath: "assets/img/farm.png",
                        color: theme.colorScheme.primary.withOpacity(0.6),
                        onAdd: () async {
                          // Coming soon
                          CustomSnackbar.show(
                            context,
                            message: "Feature coming soon",
                            type: SnackbarType.info,
                          );
                        },
                        onList: () async {
                          // Coming soon
                          CustomSnackbar.show(
                            context,
                            message: "Feature coming soon",
                            type: SnackbarType.info,
                          );
                        },
                        onHistory: () async {
                          // Coming soon
                          CustomSnackbar.show(
                            context,
                            message: "Feature coming soon",
                            type: SnackbarType.info,
                          );
                        },
                        onSync: () async {
                          // Coming soon
                          CustomSnackbar.show(
                            context,
                            message: "Feature coming soon",
                            type: SnackbarType.info,
                          );
                        },
                        isSmallScreen: isSmallScreen,
                        isLargeScreen: isLargeScreen,
                        isDisabled: true,
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Build the side drawer
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userInfo?.firstName?.isNotEmpty == true && userInfo?.lastName?.isNotEmpty == true
                      ? "${userInfo?.firstName} ${userInfo?.lastName}"
                      : "${userInfo?.userName}",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.surface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${userInfo?.districtName}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

              ],
            ),
          ),

          // Drawer Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: "Profile",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.sync,
                  title: "Sync Data",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SyncPage(),
                      ),
                    );
                  },
                ),

                // Divider


                // Divider before logout
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: "Logout",
                  isLogout: true,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutConfirmation(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build individual drawer menu item
  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        bool isLogout = false,
      }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : theme.primaryColor,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isLogout ? Colors.red : null,
          fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isLogout ? null : Icon(
        Icons.chevron_right,
        color: theme.primaryColor.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performLogout(context);
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Perform logout operation
  void _performLogout(BuildContext context) async {
    try {
      // Show loading
      Globals().startWait(context);

      final cacheService = await CacheService.getInstance();
      await cacheService.logout(context);

      await Future.delayed(const Duration(seconds: 1));

      Globals().endWait(context);

      CustomSnackbar.show(
        context,
        message: "Logged out successfully",
        type: SnackbarType.success,
      );

      // Example: Navigate to login screen
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginScreen()),
      //   (route) => false,
      // );

    } catch (e) {
      Globals().endWait(context);
      CustomSnackbar.show(
        context,
        message: "Logout failed: $e",
        type: SnackbarType.error,
      );
    }
  }

  void _handleResult(dynamic result) {
    if (result != null &&
        result is Map<String, dynamic> &&
        result["refreshState"] == true) {
      setState(() {});
    }
  }

  Widget _buildOptionContainer(
      BuildContext context, {
        required String title,
        required IconData icon,
        required bool isPrimary,
        required VoidCallback onTap,
        required bool isSmallScreen,
        required bool isLargeScreen,
        bool isDisabled = false,
      }) {
    final theme = Theme.of(context);
    final color = isPrimary ? theme.primaryColor : theme.colorScheme.secondary;
    const disabledColor = Colors.grey;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isDisabled ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled
              ? disabledColor.withOpacity(0.1)
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDisabled
                ? disabledColor.withOpacity(0.3)
                : color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                icon,
                color: isDisabled ? disabledColor : color,
                size: isSmallScreen ? 20 : isLargeScreen ? 28 : 24
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDisabled ? disabledColor : null,
                  fontSize: isSmallScreen ? 10 : isLargeScreen ? 14 : 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(
      BuildContext context, {
        required String title,
        required Color color,
        required VoidCallback onAdd,
        required VoidCallback onList,
        required VoidCallback onHistory,
        required VoidCallback onSync,
        required String imgPath,
        required bool isSmallScreen,
        required bool isLargeScreen,
        bool isDisabled = false,
      }) {
    final theme = Theme.of(context);
    final isPrimary = color == theme.secondaryHeaderColor;
    const disabledColor = Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: isDisabled
            ? disabledColor.withOpacity(0.05)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDisabled
              ? disabledColor.withOpacity(0.2)
              : color.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 16 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? disabledColor.withOpacity(0.1)
                        : color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    imgPath,
                    width: isSmallScreen ? 16 : 20,
                    height: isSmallScreen ? 16 : 20,
                    color: isDisabled ? disabledColor : null,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDisabled ? disabledColor : null,
                      fontSize: isSmallScreen ? 16 : isLargeScreen ? 20 : 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isDisabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: disabledColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Soon",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: disabledColor,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Options Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: isSmallScreen ? 6 : 10,
              mainAxisSpacing: isSmallScreen ? 6 : 10,
              childAspectRatio: isSmallScreen ? 1.3 : 1.5,
              children: [
                _buildOptionContainer(
                  context,
                  title: "Add New",
                  icon: Icons.add_circle_outline,
                  isPrimary: isPrimary,
                  onTap: onAdd,
                  isSmallScreen: isSmallScreen,
                  isLargeScreen: isLargeScreen,
                  isDisabled: isDisabled,
                ),
                _buildOptionContainer(
                  context,
                  title: "History",
                  icon: Icons.history,
                  isPrimary: isPrimary,
                  onTap: onHistory,
                  isSmallScreen: isSmallScreen,
                  isLargeScreen: isLargeScreen,
                  isDisabled: isDisabled,
                ),
                _buildOptionContainer(
                  context,
                  title: "List",
                  icon: Icons.list_alt,
                  isPrimary: isPrimary,
                  onTap: onList,
                  isSmallScreen: isSmallScreen,
                  isLargeScreen: isLargeScreen,
                  isDisabled: isDisabled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}