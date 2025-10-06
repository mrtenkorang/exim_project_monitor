import 'package:exim_project_monitor/features/screen_wrapper/screen_wrapper.dart';
import 'package:exim_project_monitor/features/sync/sync_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/screens/auth/login_screen.dart';
import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Add a delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isFirstLaunch 
            ? const SyncPage()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Image.asset("assets/img/eximbankghana.jpg"),
            // const SizedBox(height: 20),
            // // App name
            // Text(
            //   'EXIM Monitor',
            //   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            //     color: Theme.of(context).primaryColor
            //   )
            // ),
            // const SizedBox(height: 10),
            // // Loading indicator
            //  CircularProgressIndicator(
            //   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            // ),
          ],
        ),
      ),
    );
  }
}
