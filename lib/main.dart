import 'package:exim_project_monitor/features/home/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/models/user_model.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/screens/auth/login_screen.dart';
import 'features/farm_management/add_farm_provider.dart';
import 'features/farm_management/edit_farm/edit_farm_provider.dart';
import 'features/farm_management/history/farm_history_provider.dart';
import 'features/farmer_management/edit_farmer/edit_farmer_provider.dart';
import 'features/farmer_management/history/farmer_history_provider.dart';
import 'features/farmers/farmer_list_screen.dart';
import 'features/farmers/farmer_provider.dart';
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

  final farmerProvider = FarmerListProvider();
  final themeProvider = ThemeProvider(prefs);
  final addFarmProvider = AddFarmProvider();
  final farmHistoryProvider = FarmHistoryProvider();
  final farmerListProvider = FarmerListProvider();
  final farmerHistoryProvider = FarmerHistoryProvider();
  final homeProvider = HomeProvider();
  final editFarmerProvider = EditFarmerProvider();
  final editFarmProvider = EditFarmProvider();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => farmerProvider),
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => addFarmProvider),
        ChangeNotifierProvider(create: (_) => farmHistoryProvider),
        ChangeNotifierProvider(create: (_) => farmerListProvider),
        ChangeNotifierProvider(create: (_) => farmerHistoryProvider),
        ChangeNotifierProvider(create: (_) => homeProvider),
        ChangeNotifierProvider(create: (_) => editFarmerProvider),
        ChangeNotifierProvider(create: (_) => editFarmProvider),
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
      home: const SplashScreen(),
      // Add named routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const ScreenWrapper(),
        '/farmer-list': (context) => const FarmerListScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

