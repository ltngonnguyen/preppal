import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/community_tab.dart';
import 'tabs/profile_tab.dart';
import 'settings_screen.dart'; // SettingsScreen import

class HomeScreen extends StatefulWidget {
 const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // default tab

  // bottom nav tabs
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardTab(), // home
    const AlertsTab(),    // alerts
    const CommunityTab(), // community
    const ProfileTab(),   // profile
  ];

  // appbar titles
  static const List<String> _tabTitles = <String>[
    'PrepPal',       // dashboard title
    'Alerts',        // alerts title
    'Community Hub', // community title
    'User Profile',  // profile title
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
        // title changes with tab
        title: Text(_selectedIndex == 0 ? 'PrepPal' : _tabTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // settings icon
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
            label: 'Home', // home label
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_outlined),
            activeIcon: Icon(Icons.warning_amber),
            label: 'Alerts', // alerts label
          ),
          // nav items
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