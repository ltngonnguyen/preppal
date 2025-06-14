import 'package:flutter/material.dart';
import 'package:preppal/screens/alerts/simulated_alert_screen.dart'; // import screen

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // demo: show SimulatedAlertScreen.
    return SimulatedAlertScreen();
  }
}