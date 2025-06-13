import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp

class LocalPreferenceService {
  static const String _preferencesKey = 'user_preferences';

  // Save UserPreferences to shared_preferences
  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(preferences.toMap());
    await prefs.setString(_preferencesKey, jsonString);
  }

  // Load UserPreferences from shared_preferences
  Future<UserPreferences?> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_preferencesKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> map = json.decode(jsonString);
        // Assuming 'settings' as a default ID if not stored in the map itself
        // Or, you might decide to store the ID within the map if it can vary.
        // For UserPreferences, it's often a single settings document.
        return UserPreferences.fromMap(map, map['id'] ?? 'settings');
      } catch (e) {
        // Handle potential decoding errors, e.g., by returning null or default
        print('Error decoding UserPreferences from SharedPreferences: $e');
        return null;
      }
    }
    return null;
  }

  // Clear UserPreferences from shared_preferences (e.g., on logout)
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferencesKey);
  }

  // Helper to create default preferences if none are found locally or from Firestore
  // This might be used during initial setup or if local/remote data is corrupted.
  UserPreferences getDefaultPreferences(String id) {
    return UserPreferences(
      id: id, // Typically 'settings'
      updatedAt: Timestamp.now(),
      // Default values are already set in the UserPreferences model constructor
    );
  }
}