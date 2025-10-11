import 'package:exim_project_monitor/features/auth/screens/auth/login_provider.dart';
import 'package:exim_project_monitor/features/home/home_provider.dart';
import 'package:exim_project_monitor/features/sync/background_sync/background_sync.dart';
import 'package:exim_project_monitor/features/sync/background_sync/sync_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/models/user_model.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/screens/auth/login_screen.dart';
import 'features/farm_management/add_farm_provider.dart';
import 'features/farm_management/edit_farm/edit_farm_provider.dart';
import 'features/farm_management/farm_list/farm_list_provider.dart';
import 'features/farm_management/history/farm_history_provider.dart';
import 'features/farmer_management/add_farmer_provider.dart';
import 'features/farmer_management/edit_farmer/edit_farmer_provider.dart';
import 'features/farmer_management/farmers_list/farmer_list_screen.dart';
import 'features/farmer_management/farmers_list/farmer_provider.dart';
import 'features/farmer_management/history/farmer_history_provider.dart';
import 'features/home/home.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/screen_wrapper/screen_wrapper.dart';
import 'features/settings/profile/profile_screen.dart';
import 'theme/app_theme.dart';
import 'package:get/get.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize providers
  final themeProvider = ThemeProvider(prefs);
  final addFarmProvider = AddFarmProvider();
  final farmListProvider = FarmListProvider();
  final farmHistoryProvider = FarmHistoryProvider();
  final farmerListProvider = FarmerListProvider();
  final farmerHistoryProvider = FarmerHistoryProvider();
  final homeProvider = HomeProvider();
  final editFarmerProvider = EditFarmerProvider();
  final editFarmProvider = EditFarmProvider();
  final loginProvider = LoginProvider();
  final addFarmerProvider = AddFarmerProvider();

  // Initialize sync services
  final backgroundSyncService = BackgroundSyncService(() {
    // This callback will be set properly after SyncManager is created
    debugPrint('Background sync triggered - callback not set yet');
    return Future<void>.value();
  });

  final syncManager = SyncManager(backgroundSyncService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => addFarmProvider),
        ChangeNotifierProvider(create: (_) => farmListProvider),
        ChangeNotifierProvider(create: (_) => farmHistoryProvider),
        ChangeNotifierProvider(create: (_) => farmerListProvider),
        ChangeNotifierProvider(create: (_) => farmerHistoryProvider),
        ChangeNotifierProvider(create: (_) => homeProvider),
        ChangeNotifierProvider(create: (_) => editFarmerProvider),
        ChangeNotifierProvider(create: (_) => editFarmProvider),
        ChangeNotifierProvider(create: (_) => loginProvider),
        ChangeNotifierProvider(create: (_) => addFarmerProvider),
        ChangeNotifierProvider(create: (_) => syncManager), // Add SyncManager
      ],
      child: const EximProjectMonitorApp(),
    ),
  );
}

class EximProjectMonitorApp extends StatelessWidget {
  const EximProjectMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GetMaterialApp(
      title: 'Exim Project Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AppStartupWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const ScreenWrapper(),
        '/farmer-list': (context) => const FarmerListScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

// Wrapper widget to handle app initialization
class AppStartupWrapper extends StatefulWidget {
  const AppStartupWrapper({super.key});

  @override
  State<AppStartupWrapper> createState() => _AppStartupWrapperState();
}

class _AppStartupWrapperState extends State<AppStartupWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final syncManager = Provider.of<SyncManager>(context, listen: false);

      // Initialize sync manager (this sets up background services)
      await syncManager.initialize();

      // Check for pending sync on app startup
      if (await syncManager.hasPendingSync()) {
        // Trigger sync in background without blocking UI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          syncManager.syncAllData();
        });
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('App initialization error: $e');
      setState(() {
        _isInitialized = true; // Continue anyway
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing app...'),
            ],
          ),
        ),
      );
    }

    return const SplashScreen();
  }
}