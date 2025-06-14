import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:preppal/screens/well_being/climate_anxiety_support_screen.dart';
import 'package:preppal/screens/tabs/preparedness_hub_tab.dart';
import 'package:preppal/screens/tabs/stockpile_tab.dart';

// dashboard screen.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  // styled card button for nav.
  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 40.0, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    // TODO: fetch alert status.
    const String alertStatus = "No Active Alerts"; // example

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, ${user?.displayName ?? user?.email ?? 'User'}!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Current Alert Status: $alertStatus',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: alertStatus == "No Active Alerts"
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              onPressed: () {
                // navigate to Alerts tab.
                final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
                final Widget? bottomNavWidget = Scaffold.of(context).widget.bottomNavigationBar;
                if (bottomNavWidget is BottomNavigationBar && bottomNavWidget.onTap != null) {
                    bottomNavWidget.onTap!(1); // index 1 for AlertsTab.
                } else {
                    // fallback if direct tap not possible.
                    scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Could not navigate to Alerts. Try bottom navigation.')),
                    );
                }
              },
              child: const Text(
                'View Current HCMC Alerts',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 24.0),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // disables GridView scrolling.
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.1, // aspect ratio for buttons.
              children: [
                _buildDashboardButton(
                  context,
                  icon: Icons.shield_outlined,
                  title: 'Preparedness Hub',
                  subtitle: '',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PreparednessHubTab()),
                    );
                  },
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Stockpile Management',
                  subtitle: '',
                  onPressed: () {
                    Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const StockpileTab()),
                   );
                  },
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.school_outlined,
                  title: 'Skill Building',
                  subtitle: '',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigate to Skill Building - TBD')),
                    );
                  },
                ),
                _buildDashboardButton(
                  context,
                  icon: Icons.self_improvement_outlined,
                  title: 'Climate Anxiety Support',
                  subtitle: '',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ClimateAnxietySupportScreen()),
                    );
                  },
                ),
             ],
           ),
         ],
        ),
      ),
    );
  }
}