import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/user_preferences.dart';
import '../services/profile_service.dart';
import '../services/local_preference_service.dart';

// Firebase Auth provider.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Profile Service provider.
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// Local Preference Service provider.
final localPreferenceServiceProvider = Provider<LocalPreferenceService>((ref) {
  return LocalPreferenceService();
});

// StreamProvider for user profile.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  final authState = ref.watch(firebaseAuthProvider).authStateChanges();

  return authState.asyncMap((user) {
    if (user == null) {
      return null;
    }
    // Fetch profile.
    return profileService.getUserProfile().first;
  });
});


// User Preferences State Notifier.
class UserPreferencesNotifier extends StateNotifier<AsyncValue<UserPreferences?>> {
  final ProfileService _profileService;
  final LocalPreferenceService _localPreferenceService;
  final String? _userId;

  UserPreferencesNotifier(this._profileService, this._localPreferenceService, this._userId)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (_userId == null) {
      state = AsyncValue.data(null);
      return;
    }
    try {
      // 1. Load from local prefs.
      final localPrefs = await _localPreferenceService.getPreferences();
      if (localPrefs != null) {
        state = AsyncValue.data(localPrefs);
      }

      // 2. Fetch from Firestore.
      final firestorePrefsStream = _profileService.getUserPreferences();
      await for (final prefs in firestorePrefsStream) {
        if (prefs != null) {
          state = AsyncValue.data(prefs);
          // Update local cache.
          await _localPreferenceService.savePreferences(prefs);
          break; // Take first valid emission.
        } else if (state is! AsyncData || (state as AsyncData).value == null) {
          // If no local/Firestore prefs, create defaults.
           final defaultPrefs = _localPreferenceService.getDefaultPreferences(_userId!); // Or 'settings'
           await _profileService.updateUserPreferences(defaultPrefs); // Save to Firestore
           await _localPreferenceService.savePreferences(defaultPrefs); // Save to local
           state = AsyncValue.data(defaultPrefs);
           break;
        }
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> updatePreferences(UserPreferences newPreferences) async {
    if (_userId == null) return;
    state = AsyncValue.data(newPreferences); // Optimistic update.
    try {
      await _localPreferenceService.savePreferences(newPreferences);
      await _profileService.updateUserPreferences(newPreferences);
      // Re-fetch or rely on stream.
    } catch (e, s) {
      // Revert or show error.
      state = AsyncValue.error(e, s);
      // Consider re-fetching old state.
    }
  }

  Future<void> updateAppTheme(AppTheme newTheme) async {
    if (state.value == null || _userId == null) return;
    final currentPrefs = state.value!;
    final updatedPrefs = currentPrefs.copyWith(appTheme: newTheme);
    await updatePreferences(updatedPrefs);
  }

  // Other update methods.
  Future<void> updateExpiryRemindersEnabled(bool enabled) async {
    if (state.value == null || _userId == null) return;
    final updatedPrefs = state.value!.copyWith(expiryRemindersEnabled: enabled);
    await updatePreferences(updatedPrefs);
  }

   Future<void> updateSimulatedAlertsEnabled(bool enabled) async {
    if (state.value == null || _userId == null) return;
    final updatedPrefs = state.value!.copyWith(simulatedAlertsEnabled: enabled);
    await updatePreferences(updatedPrefs);
  }

  Future<void> updateProgressNotificationsEnabled(bool enabled) async {
    if (state.value == null || _userId == null) return;
    final updatedPrefs = state.value!.copyWith(progressNotificationsEnabled: enabled);
    await updatePreferences(updatedPrefs);
  }

  Future<void> updateOfflineSyncEnabled(bool enabled) async {
    if (state.value == null || _userId == null) return;
    final updatedPrefs = state.value!.copyWith(offlineSyncEnabled: enabled);
    await updatePreferences(updatedPrefs);
  }
}

// UserPreferences StateNotifierProvider.
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, AsyncValue<UserPreferences?>>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  final localPreferenceService = ref.watch(localPreferenceServiceProvider);
  final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;
  return UserPreferencesNotifier(profileService, localPreferenceService, userId);
});