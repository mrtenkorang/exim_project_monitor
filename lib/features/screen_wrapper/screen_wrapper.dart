import 'package:exim_project_monitor/core/models/user_model.dart';
import 'package:exim_project_monitor/core/repositories/user_repository.dart';
import 'package:exim_project_monitor/features/home/home.dart';
import 'package:exim_project_monitor/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../settings/profile/profile_screen.dart';

class ScreenWrapper extends StatefulWidget {
  const ScreenWrapper({super.key});

  @override
  _ScreenWrapperState createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  int _selectedIndex = 0;
  bool isLoading = true;
  DateTime? _currentBackPressTime;
  final UserRepository _userRepository = UserRepository();


  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Widget> pages = [
      const HomeScreen(),
      const ProfileScreen(),
      
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: pages[_selectedIndex],
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
        _buildNavItem(Icons.person_2_outlined, Icons.person_2, 'Profile'),
        // _buildNavItem(Icons.group_outlined, Icons.group, 'Farmers'),
        // _buildNavItem(Icons.person_outline, Icons.person, 'PC List'),
        // _buildNavItem(
        //     Icons.receipt_long_outlined, Icons.receipt_long, 'Waybills'),
        // _buildNavItem(Icons.analytics_outlined, Icons.analytics, 'Reports'),
        // _buildNavItem(Icons.person_outline, Icons.person, 'Profile'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      backgroundColor: colorScheme.surface,
      elevation: 4,
      onTap: _onItemTapped,
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: theme.textTheme.labelSmall,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData outlineIcon,
      IconData filledIcon,
      String label,
      ) {
    return BottomNavigationBarItem(
      icon: Icon(outlineIcon, size: 24),
      activeIcon: Icon(filledIcon, size: 24),
      label: label,
    );
  }
}