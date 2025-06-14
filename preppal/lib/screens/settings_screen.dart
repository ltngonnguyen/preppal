import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for logout
import 'package:preppal/models/user_preferences.dart';
import 'package:preppal/providers/profile_providers.dart';
import 'package:preppal/screens/profile/edit_profile_screen.dart';
import 'package:preppal/models/user_profile.dart'; // for UserProfile
import 'package:preppal/services/profile_service.dart'; // for ProfileService
import 'dart:io'; // for File

class SettingsScreen extends ConsumerStatefulWidget { // consumer stateful
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState(); // create state
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> { // state
  // no old state vars

  Future<void> _navigateToEditProfile() async {
    // navigate to EditProfileScreen.
    await Navigator.push<void>( // no save trigger
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    // EditProfileScreen refreshes userProfileProvider.
  }

  // _saveChanges() removed

  @override
  Widget build(BuildContext context) { // ref available via this.ref
    final userPreferences = ref.watch(userPreferencesProvider);
    final userPreferencesNotifier = ref.read(userPreferencesProvider.notifier);
    final auth = ref.watch(firebaseAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // save button removed
      ),
      body: userPreferences.when(
        data: (prefs) {
          if (prefs == null) {
            return const Center(child: Text('User preferences not found.'));
          }
          return ListView(
            children: [
              // General Settings
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'General Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                title: const Text('App Theme'),
                trailing: DropdownButton<AppTheme>(
                  value: prefs.appTheme,
                  onChanged: (AppTheme? newValue) {
                    if (newValue != null) {
                      userPreferencesNotifier.updateAppTheme(newValue);
                    }
                  },
                  items: AppTheme.values
                      .map<DropdownMenuItem<AppTheme>>((AppTheme value) {
                    return DropdownMenuItem<AppTheme>(
                      value: value,
                      child: Text(value.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ),
              SwitchListTile(
                title: const Text('Expiry Reminders'),
                value: prefs.expiryRemindersEnabled,
                onChanged: (bool value) {
                  userPreferencesNotifier.updateExpiryRemindersEnabled(value);
                },
              ),
              SwitchListTile(
                title: const Text('Simulated Alerts'),
                value: prefs.simulatedAlertsEnabled,
                onChanged: (bool value) {
                  userPreferencesNotifier.updateSimulatedAlertsEnabled(value);
                },
              ),
              SwitchListTile(
                title: const Text('Progress Notifications'),
                value: prefs.progressNotificationsEnabled,
                onChanged: (bool value) {
                  userPreferencesNotifier.updateProgressNotificationsEnabled(value);
                },
              ),
              const Divider(),

              // User Settings
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'User Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                title: const Text('Edit Profile Information'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _navigateToEditProfile, // navigate to edit profile
              ),
              const Divider(),

              // Local Storage Settings
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Local Storage Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SwitchListTile(
                title: const Text('Offline Sync'),
                value: prefs.offlineSyncEnabled,
                onChanged: (bool value) {
                  userPreferencesNotifier.updateOfflineSyncEnabled(value);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error, // error color
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: () async {
                    await auth.signOut();
                    // navigate to root, AuthWrapper shows LoginScreen
                    if (mounted) { // ensure widget in tree
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Text('Log Out'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}