import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/profile_providers.dart'; // Providers
// Login screen import.
// import '../login_screen.dart'; 

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final auth = ref.watch(firebaseAuthProvider); // For signOut

    return Scaffold(
      body: Center(
        child: userProfileAsync.when(
          data: (userProfile) {
            print('[ProfileTab] userProfileAsync.when data: ${userProfile?.toJson()}');
            if (userProfile == null) {
              print('[ProfileTab] UserProfile is null.');
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Profile data not available yet.'),
                ],
              );
            }
            print('[ProfileTab] UserProfile ID: ${userProfile.id}, DisplayName: ${userProfile.displayName}, ProfilePicUrl: ${userProfile.profilePicUrl}');
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userProfile.profilePicUrl != null && userProfile.profilePicUrl!.isNotEmpty
                        ? NetworkImage(userProfile.profilePicUrl!)
                        : null,
                    child: userProfile.profilePicUrl == null || userProfile.profilePicUrl!.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userProfile.displayName ?? 'N/A',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProfile.email,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                   Text(
                    'Location: ${userProfile.location ?? 'Not set'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  // Edit Profile button placeholder.
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Navigate to EditProfileScreen
                  //   },
                  //   child: const Text('Edit Profile'),
                  // ),
                  const Spacer(),
                ],
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) {
            print('Error fetching profile: $error');
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading profile: $error'),
                ],
              );
          }
        ),
      ),
    );
  }
}