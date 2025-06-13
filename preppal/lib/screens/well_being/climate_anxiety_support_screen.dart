import 'package:flutter/material.dart';
// TODO: Uncomment and add url_launcher to pubspec.yaml to enable opening links.
// import 'package:url_launcher/url_launcher.dart';

// Screen providing resources and support for climate anxiety.
class ClimateAnxietySupportScreen extends StatelessWidget {
  const ClimateAnxietySupportScreen({super.key});

  // Utility to launch URLs. Requires url_launcher package.
  // Future<void> _launchUrl(String urlString) async {
  //   final Uri url = Uri.parse(urlString);
  //   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //     // Log error or show user feedback.
  //     debugPrint('Could not launch $urlString');
  //   }
  // }

  Widget _buildInfoSection(BuildContext context, {required String title, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios) : null,
        onTap: onTap ?? () {},
      ),
    );
  }

  Widget _buildCopingStrategy(BuildContext context, {required IconData icon, required String title, required String actionText, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: TextButton(
          onPressed: onTap ?? () {},
          child: Text(actionText),
        ),
        onTap: onTap, // Allows tapping the whole list item.
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Well-being & Climate Support'),
        leading: IconButton( // Standard back navigation.
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Shows a disclaimer dialog.
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Important Information'),
                  content: const Text('This information is for general guidance and support. It is not a substitute for professional medical or psychological advice. If you are in distress, please consult a qualified professional or local HCMC mental health service.'),
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                ),
              );
            },
            tooltip: 'Disclaimer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Feeling Overwhelmed by Climate News?",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "You're not alone. Here are some resources to help.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),

            Text(
              "Understanding Climate Anxiety (HCMC Context):",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildInfoSection(
              context,
              title: "What is it & Why it's normal",
              onTap: () {
                // TODO: Navigate to detailed info or show dialog for "What is it".
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Climate anxiety info - TBD')),
                );
              },
            ),
            const SizedBox(height: 24),

            Text(
              "Simple Coping Strategies:",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildCopingStrategy(
              context,
              icon: Icons.self_improvement, // Example icon.
              title: "Guided Breathing Exercise (2 min)",
              actionText: "Play >",
              onTap: () {
                // TODO: Implement audio playback or navigation for breathing exercise.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Breathing exercise - TBD')),
                );
              },
            ),
            _buildCopingStrategy(
              context,
              icon: Icons.psychology_outlined,
              title: "Positive Self-Talk Prompts",
              actionText: "View >",
              onTap: () {
                // TODO: Implement display of self-talk prompts.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Self-talk prompts - TBD')),
                );
              },
            ),
            _buildCopingStrategy(
              context,
              icon: Icons.construction_outlined,
              title: "Taking Action: Small Prep Steps",
              actionText: "Tips >",
              onTap: () {
                // TODO: Implement navigation to preparedness tasks/tips.
                // Could link to PreparednessHubTab or specific guides.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prep step tips - TBD')),
                );
              },
            ),
            const SizedBox(height: 24),

            Text(
              "Further HCMC Resources (Curated Links):",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // TODO: Replace with actual HCMC resource links and enable _launchUrl.
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Local HCMC Mental Health Organization'),
              onTap: () { /* _launchUrl('https://example-hcmc-mental-health.org'); */
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mental health org link - TBD')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Positive Climate Action Group HCMC'),
              onTap: () { /* _launchUrl('https://example-hcmc-climate-action.org'); */
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Climate action group link - TBD')));
              },
            ),
            // Add more curated HCMC-specific resource links as needed.
          ],
        ),
      ),
    );
  }
}