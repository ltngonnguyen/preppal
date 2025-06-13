import 'dart:async';
import 'dart:io'; // Added for File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage; // Added for Firebase Storage
import '../models/user_profile.dart';
import '../models/user_preferences.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance; // Added storage instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;
  User? get _currentUser => _auth.currentUser;

  // --- User Profile Management ---

  // Document reference for the current user's profile
  DocumentReference<UserProfile> _userProfileRef() {
    final userId = _userId;
    if (userId == null) {
      throw Exception("User not logged in. Cannot access profile.");
    }
    return _db.collection('users').doc(userId).withConverter<UserProfile>(
          fromFirestore: (snapshots, _) => UserProfile.fromFirestore(snapshots, snapshots.id),
          toFirestore: (profile, _) => profile.toJson(),
        );
  }

  // Stream of the current user's profile
  // Creates a default profile if one doesn't exist on first access.
  Stream<UserProfile?> getUserProfile() {
    final user = _currentUser;
    if (user == null) return Stream.value(null);

    return _userProfileRef().snapshots().map((snapshot) {
      if (!snapshot.exists) {
        // Potentially create a default profile here if needed upon first read after registration
        // For now, we'll return null and let the UI/Provider handle creating it on demand.
        // Or, we can create it:
        final defaultProfile = UserProfile(
          id: user.uid,
          email: user.email ?? '',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );
        // _userProfileRef().set(defaultProfile); // Uncomment to auto-create
        return defaultProfile; // or return null if creation is handled elsewhere
      }
      return snapshot.data();
    });
  }

  // Update the current user's profile
  Future<void> updateUserProfile(UserProfile profile, {File? imageFile}) async {
    print('[ProfileService] updateUserProfile called. Profile ID: ${profile.id}, ImageFile exists: ${imageFile != null}');
    if (imageFile != null) {
      print('[ProfileService] ImageFile path: ${imageFile.path}');
    }

    if (_userId == null) {
      print('[ProfileService] User not logged in. Throwing exception.');
      throw Exception("User not logged in.");
    }

    UserProfile profileWithPotentiallyNewUrl = profile;

    if (imageFile != null) {
      try {
        final String filePath = 'profile_images/$_userId/profile_pic_${DateTime.now().millisecondsSinceEpoch}';
        print('[ProfileService] Uploading image to Firebase Storage path: $filePath');
        final firebase_storage.Reference ref = _storage.ref().child(filePath);

        final firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
        final firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
        print('[ProfileService] Image upload successful.');
        
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print('[ProfileService] Image download URL: $downloadUrl');
        
        profileWithPotentiallyNewUrl = profile.copyWith(profilePicUrl: downloadUrl);
        print('[ProfileService] Profile updated with new image URL.');
      } catch (e) {
        print('[ProfileService] Error uploading profile image to Firebase Storage: $e');
        // For now, we'll proceed to update Firestore with the profile data (which might have the old URL or no URL)
        // Consider if you want to rethrow or prevent Firestore update on storage failure.
      }
    } else {
      print('[ProfileService] No imageFile provided to updateUserProfile.');
    }
    
    // Ensure the updatedAt field is current
    final profileToUpdate = profileWithPotentiallyNewUrl.copyWith(updatedAt: Timestamp.now());
    print('[ProfileService] Profile to update in Firestore: ${profileToUpdate.toJson()}');
    
    await _userProfileRef().set(profileToUpdate, SetOptions(merge: true));
    print('[ProfileService] Firestore profile update complete for ID: ${profileToUpdate.id}');
  }

  // Create a user profile document (e.g., after registration)
  Future<void> createUserProfile(User user, {String? displayName}) async {
    final initialProfile = UserProfile(
      id: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
    await _userProfileRef().set(initialProfile);
  }


  // --- User Preferences Management ---

  // Document reference for the current user's preferences
  DocumentReference<UserPreferences> _userPreferencesRef() {
    final userId = _userId;
    if (userId == null) {
      throw Exception("User not logged in. Cannot access preferences.");
    }
    // Using a fixed document ID "settings" within the subcollection
    return _db.collection('users').doc(userId).collection('preferences').doc('settings').withConverter<UserPreferences>(
          fromFirestore: (snapshots, _) => UserPreferences.fromFirestore(snapshots, snapshots.id),
          toFirestore: (prefs, _) => prefs.toJson(),
        );
  }

  // Stream of the current user's preferences
  // Creates default preferences if none exist.
  Stream<UserPreferences?> getUserPreferences() {
    if (_userId == null) return Stream.value(null);

    return _userPreferencesRef().snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        final defaultPreferences = UserPreferences(
          id: 'settings', // Fixed ID for the preferences document
          updatedAt: Timestamp.now(),
        );
        // Create the default preferences document if it doesn't exist
        await _userPreferencesRef().set(defaultPreferences);
        return defaultPreferences;
      }
      return snapshot.data();
    });
  }

  // Update the current user's preferences
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    if (_userId == null) throw Exception("User not logged in.");
    // Ensure the updatedAt field is current and id is correct
    final preferencesToUpdate = preferences.copyWith(
      id: 'settings', // Ensure the ID is always 'settings'
      updatedAt: Timestamp.now()
    );
    await _userPreferencesRef().set(preferencesToUpdate, SetOptions(merge: true));
  }
}