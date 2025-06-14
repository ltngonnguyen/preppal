import 'package:flutter/material.dart';


// HCMC risk info.
class HcmcRiskInfoScreen extends StatelessWidget {
  const HcmcRiskInfoScreen({super.key});

  // navigate to risk detail.
  void _navigateToRiskDetail(BuildContext context, String riskName) {
    // TODO: nav to risk detail screen.
    // shows "before, during, after" info.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for $riskName - TBD')),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HCMC Risk Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: risk search.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search risks - TBD')),
              );
            },
            tooltip: 'Search Risks',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Key Risks for HCMC:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text('- Urban Flooding'),
            const Text('- Extreme Heat'),
            const Text('- Air Quality Issues'), // example risk.
            const SizedBox(height: 20.0),
            Card(
              elevation: 2.0,
              child: Container(
                height: 150,
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 40, color: Theme.of(context).hintColor),
                    const SizedBox(height: 8),
                    Text(
                      'Interactive HCMC Risk Map (Placeholder)',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '[Tap for district/area details]',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Select a Risk to Learn More:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildRiskItem(
              context,
              title: 'Urban Flooding in HCMC',
              subItems: [
                'What to do before, during, after.',
                'Evacuation zones (link/info).',
              ],
              onTap: () => _navigateToRiskDetail(context, 'Urban Flooding'),
            ),
            _buildRiskItem(
              context,
              title: 'Extreme Heat in HCMC',
              subItems: [
                'Symptoms, prevention, cooling centers.',
              ],
              onTap: () => _navigateToRiskDetail(context, 'Extreme Heat'),
            ),
            _buildRiskItem(
              context,
              title: 'Air Quality Issues in HCMC',
              subItems: [
                'Understanding AQI, protective measures.',
                'Resources for real-time updates.',
              ],
              onTap: () => _navigateToRiskDetail(context, 'Air Quality'),
            ),
          ],
        ),
      ),
    );
  }

  // Builds tappable ListTile.
  Widget _buildRiskItem(BuildContext context, {required String title, required List<String> subItems, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: subItems.map((item) => Text("• $item", style: Theme.of(context).textTheme.bodySmall)).toList(),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),
    );
  }
}