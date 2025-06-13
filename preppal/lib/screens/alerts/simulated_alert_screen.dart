import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Date formatting.
// TODO: Uncomment and import StockpileTab for navigation.
// import 'package:preppal/screens/tabs/stockpile_tab.dart';

// Displays a simulated urgent alert.
class SimulatedAlertScreen extends StatelessWidget {
  // Constructor initializes alert timestamps.
  // In a real application, alert data would be passed in or fetched.
  SimulatedAlertScreen({super.key})
      : issuedTime = DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
        lastUpdatedTime = DateTime.now().subtract(const Duration(minutes: 5));

  // Example alert data.
  final String alertTitle = "URGENT ALERT: FLOOD WARNING!";
  final DateTime issuedTime;
  final String location = "District 7, HCMC";
  final String details = "Heavy rainfall is causing rapid river level rise. Significant flooding expected in low-lying areas of District 7 within the next 1-2 hours.";
  final List<String> recommendedActions = const [
    "If in a known flood zone, prepare to evacuate.",
    "Move valuables to higher ground.",
    "Secure your home (electricity, gas).",
    "Check your emergency kit.", // This action links to the stockpile.
    "Monitor official HCMC channels for updates.",
  ];
  final DateTime lastUpdatedTime;

  Widget _buildActionItem(BuildContext context, String action, {bool isLink = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                action,
                style: TextStyle(
                  fontSize: 16,
                  color: isLink ? Theme.of(context).primaryColor : null,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrepPal'), // App name in AppBar.
        automaticallyImplyLeading: false, // Urgent alert screen should not have a back button.
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 30), // Alert icon.
          ),
        ],
        backgroundColor: Colors.red[100], // AppBar color to indicate alert severity.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                alertTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text("Issued: ${DateFormat.yMMMd().add_jm().format(issuedTime)}", style: Theme.of(context).textTheme.bodyMedium),
            Text("Location: $location", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text("Details:", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(details, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text("Recommended Actions (HCMC Specific):", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recommendedActions.map((action) {
              if (action.contains("Check your emergency kit")) {
                return _buildActionItem(context, action, isLink: true, onTap: () {
                  // TODO: Implement navigation to StockpileTab.
                  // Requires StockpileTab to be importable and potentially specific navigator setup
                  // if this screen is outside the main tab navigation stack.
                  // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => const StockpileTab()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stockpile navigation - TBD')),
                  );
                });
              }
              return _buildActionItem(context, action);
            }).toList(),
            const SizedBox(height: 24),
            Card(
              elevation: 2.0,
              child: ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('View HCMC Flood Evacuation Routes'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement navigation/linking to evacuation routes map/info.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Evacuation routes - TBD')),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2.0,
              child: ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: const Text('Mark Yourself Safe / Request Assistance'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement "Mark Safe / Request Assistance" feature.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mark Safe / Request Assistance - TBD')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                "Last Updated: ${DateFormat.jm().format(lastUpdatedTime)}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      // BottomNavigationBar is intentionally omitted as per wireframe interpretation
      // for an urgent alert screen that takes full focus.
      // If integrated into a tab, AlertsTab would manage its display.
    );
  }
}