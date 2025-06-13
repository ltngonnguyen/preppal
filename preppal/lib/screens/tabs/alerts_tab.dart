import 'package:flutter/material.dart';
import 'package:preppal/screens/alerts/simulated_alert_screen.dart'; // Import the screen

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // For demonstration, directly show the SimulatedAlertScreen.
    // In a real app, this tab might show a list of past alerts,
    // or show the SimulatedAlertScreen only if an alert is active.
    return SimulatedAlertScreen();
  }
}