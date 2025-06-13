import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for logout
import 'package:preppal/models/user_preferences.dart';
import 'package:preppal/providers/profile_providers.dart';
import 'package:preppal/screens/profile/edit_profile_screen.dart';
import 'package:preppal/models/user_profile.dart'; // Added for UserProfile
import 'package:preppal/services/profile_service.dart'; // Added for ProfileService
import 'dart:io'; // Added for File

class SettingsScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState(); // Added createState
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> { // Added _SettingsScreenState
  // Removed _editedUserProfile, _newProfileImageFile, _hasUnsavedChanges, _isSaving state variables

  Future<void> _navigateToEditProfile() async {
    // Simply navigate to EditProfileScreen. It will handle its own saving.
    await Navigator.push<void>( // No longer expecting a result that triggers a save here
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    // After EditProfileScreen pops, userProfileProvider might have been refreshed by EditProfileScreen itself.
    // If not, and an immediate reflection of changes here is needed (e.g. if SettingsScreen displayed profile info),
    // then a mechanism to trigger a refresh or listen to changes would be required.
    // For now, assuming EditProfileScreen handles its refresh and this screen doesn't need to react to a result.
  }

  // Removed _saveChanges() method as it's now handled in EditProfileScreen

  @override
  Widget build(BuildContext context) { // Removed WidgetRef ref as it's available via this.ref
    final userPreferences = ref.watch(userPreferencesProvider);
    final userPreferencesNotifier = ref.read(userPreferencesProvider.notifier);
    final auth = ref.watch(firebaseAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Removed actions list with the Save button
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
                onTap: _navigateToEditProfile, // Changed to call _navigateToEditProfile
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
                    backgroundColor: Theme.of(context).colorScheme.error, // Use error color for logout
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: () async {
                    await auth.signOut();
                    // Navigate to the root, AuthWrapper will then show LoginScreen
                    if (mounted) { // Ensure the widget is still in the tree
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