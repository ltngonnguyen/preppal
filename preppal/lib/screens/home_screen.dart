import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Added
import 'dart:async'; // Added

import '../services/stockpile_repository.dart'; // Added for SyncStatusEvent
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
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none]; // Updated
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription; // Updated
  String _syncStatusMessage = ''; // Added
  late StreamSubscription<SyncStatusEvent> _syncStatusSubscription; // Added

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
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) { // Updated
      setState(() {
        _connectionStatus = result;
      });
    });
    // Get initial connectivity status
    Connectivity().checkConnectivity().then((List<ConnectivityResult> result) { // Updated
      setState(() {
        _connectionStatus = result;
      });
    });

    // Listen to sync status
    _syncStatusSubscription = StockpileRepository.instance.syncStatusStream.listen((event) {
      if (!mounted) return;
      setState(() {
        if (event is SyncStarted) {
          _syncStatusMessage = 'Syncing...';
        } else if (event is SyncCompleted) {
          final formattedTime = TimeOfDay.fromDateTime(event.timestamp).format(context);
          _syncStatusMessage = 'Synced: $formattedTime';
        } else if (event is SyncError) {
          _syncStatusMessage = 'Sync Error!'; // Keep it short for AppBar
          // Optionally, show full error in a snackbar or log
          print("Sync Error: ${event.message}");
        } else if (event is SyncNoConnection) {
          _syncStatusMessage = 'Sync: Offline';
        }
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _syncStatusSubscription.cancel(); // Added
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

    // Check if any connection type in the list is not 'none'
    if (_connectionStatus.contains(ConnectivityResult.wifi) ||
        _connectionStatus.contains(ConnectivityResult.ethernet) ||
        _connectionStatus.contains(ConnectivityResult.mobile)) {
      statusText = 'Online';
      statusColor = Colors.green;
    } else if (_connectionStatus.contains(ConnectivityResult.none)) {
      statusText = 'Offline';
      statusColor = Colors.red;
    } else {
      statusText = 'Checking...';
      statusColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        // title changes with tab
        title: Text(_selectedIndex == 0 ? 'PrepPal' : _tabTitles[_selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          if (_syncStatusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text(
                  _syncStatusMessage,
                  style: TextStyle(fontSize: 12, color: _syncStatusMessage.startsWith("Sync Error") ? Colors.red : Colors.grey[700]),
                ),
              ),
            ),
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