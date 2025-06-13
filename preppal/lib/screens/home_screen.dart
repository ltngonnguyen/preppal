import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/community_tab.dart';
import 'tabs/profile_tab.dart';
import 'settings_screen.dart'; // Import the SettingsScreen

class HomeScreen extends StatefulWidget {
 const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default to Home/Dashboard tab.

  // Widgets for each tab in the bottom navigation bar.
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardTab(), // Index 0: Home
    const AlertsTab(),    // Index 1: Alerts
    const CommunityTab(), // Index 2: Community
    const ProfileTab(),   // Index 3: Profile
  ];

  // AppBar titles corresponding to each tab.
  // 'PrepPal' is used for the Home/Dashboard tab.
  static const List<String> _tabTitles = <String>[
    'PrepPal',       // Title for DashboardTab (Home).
    'Alerts',        // Title for AlertsTab.
    'Community Hub', // Title for CommunityTab.
    'User Profile',  // Title for ProfileTab.
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar title changes based on the selected tab.
        title: Text(_selectedIndex == 0 ? 'PrepPal' : _tabTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Changed to filled settings icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home', // Label for Home tab.
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_outlined),
            activeIcon: Icon(Icons.warning_amber),
            label: 'Alerts', // Label for Alerts tab.
          ),
          // Bottom navigation items align with the wireframe:
          // Home, Alerts, Community, Profile.
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Community',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}