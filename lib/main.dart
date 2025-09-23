import 'package:exim_project_monitor/features/onboarding/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:exim_project_monitor/core/models/user_model.dart';
import 'package:exim_project_monitor/core/services/auth_service.dart';
import 'package:exim_project_monitor/core/services/service_locator.dart';
import 'package:exim_project_monitor/features/auth/screens/login_screen.dart';
import 'package:exim_project_monitor/features/farms/providers/farm_provider.dart';
import 'package:exim_project_monitor/features/map/screens/map_screen.dart';
import 'package:exim_project_monitor/theme/app_theme.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/theme_provider.dart';
import 'core/repositories/farm_repository.dart';
import 'core/repositories/user_repository.dart';
import 'features/farm_management/add_farm_provider.dart';
import 'features/home/home.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/screen_wrapper/screen_wrapper.dart';
import 'features/settings/profile/profile_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await setupLocator();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  
  // Create auth service
  final authService = AuthService(locator<UserRepository>(), prefs);
  
  // Initialize auth state
  await authService.initAuthState();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize FarmProvider
  final farmProvider = FarmProvider(repository: locator<FarmRepository>());
  
  // Load initial farm data
  await farmProvider.loadFarms();
  
  // Create theme provider
  final themeProvider = ThemeProvider(prefs);
  final addFarmProvider = AddFarmProvider();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<FarmProvider>.value(value: farmProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<AddFarmProvider>.value(value: addFarmProvider),
      ],
      child: const EximProjectMonitorApp(),
    ),
  );
}

class EximProjectMonitorApp extends StatelessWidget {
  const EximProjectMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Exim Project Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: authService.isLoggedIn 
          ? const SplashScreen()
          : const SplashScreen(),
      // Add named routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const ScreenWrapper(),
        '/map': (context) => const MapScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

// Auth wrapper to handle authentication state changes
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<User?>(
      stream: Stream.fromFuture(Future.value(authService.currentUser)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final user = snapshot.data;
        
        if (user == null) {
          return const HomeScreen();
        }
        
        // Here you can add role-based routing if needed
        return const HomeScreen();
      },
    );
  }
}
