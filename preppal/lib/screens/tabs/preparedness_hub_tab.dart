import 'package:flutter/material.dart';
import 'package:preppal/screens/preparedness_hub/hcmc_risk_info_screen.dart';

// Main preparedness hub screen.
class PreparednessHubTab extends StatelessWidget {
  const PreparednessHubTab({super.key});

  // Builds hub section card.
  Widget _buildHubSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preparedness Hub'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          Text(
            'Explore HCMC-specific risks, manage your emergency kits, and develop preparedness plans.',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildHubSection(
            context,
            icon: Icons.dangerous_outlined,
            title: 'HCMC Risk Information',
            description: 'Learn about key risks in Ho Chi Minh City and how to prepare.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HcmcRiskInfoScreen()),
              );
            },
          ),
          _buildHubSection(
            context,
            icon: Icons.medical_services_outlined,
            title: 'Emergency Kits',
            description: 'View, manage, and build your essential emergency kits.',
            onTap: () {
              // TODO: Implement nav to Emergency Kits screen.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency Kits screen not yet implemented.')),
              );
            },
          ),
          _buildHubSection(
            context,
            icon: Icons.assignment_outlined,
            title: 'Preparedness Plans',
            description: 'Create and review your family and personal preparedness plans.',
            onTap: () {
              // TODO: Implement nav to Preparedness Plans screen.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preparedness Plans screen not yet implemented.')),
              );
            },
          ),
          // Skill Building section (dashboard wireframe).
           _buildHubSection(
            context,
            icon: Icons.school_outlined,
            title: 'Skill Building Resources',
            description: 'Access resources to learn essential preparedness skills.',
            onTap: () {
              // TODO: Implement nav to Skill Building Resources screen.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Skill Building Resources not yet implemented.')),
              );
            },
          ),
        ],
      ),
    );
  }
}