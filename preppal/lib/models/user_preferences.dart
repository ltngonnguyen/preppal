import 'package:cloud_firestore/cloud_firestore.dart';

enum AppTheme {
  system,
  light,
  dark,
  calmResilience,
}

// Helper to convert string to AppTheme, defaulting to system
AppTheme _appThemeFromString(String? themeString) {
  if (themeString == null) return AppTheme.system;
  switch (themeString.toLowerCase()) {
    case 'light':
      return AppTheme.light;
    case 'dark':
      return AppTheme.dark;
    case 'calmresilience':
      return AppTheme.calmResilience;
    case 'system':
    default:
      return AppTheme.system;
  }
}

class UserPreferences {
  final String id; // Corresponds to the document ID, typically 'settings' or user UID
  final bool expiryRemindersEnabled;
  final bool simulatedAlertsEnabled;
  final bool progressNotificationsEnabled;
  final AppTheme appTheme; // Changed from String
  final bool offlineSyncEnabled;
  final Timestamp updatedAt;

  UserPreferences({
    required this.id,
    this.expiryRemindersEnabled = true,
    this.simulatedAlertsEnabled = true,
    this.progressNotificationsEnabled = true,
    this.appTheme = AppTheme.system, // Default theme
    this.offlineSyncEnabled = true,
    required this.updatedAt,
  });

  // Creates a UserPreferences instance from a Firestore document snapshot.
  factory UserPreferences.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    final data = snapshot.data() ?? {}; // Ensure data is not null
    return UserPreferences(
      id: id,
      expiryRemindersEnabled: data['expiryRemindersEnabled'] ?? true,
      simulatedAlertsEnabled: data['simulatedAlertsEnabled'] ?? true,
      progressNotificationsEnabled: data['progressNotificationsEnabled'] ?? true,
      appTheme: _appThemeFromString(data['appTheme']),
      offlineSyncEnabled: data['offlineSyncEnabled'] ?? true,
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  // Converts this UserPreferences instance to a Map for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'expiryRemindersEnabled': expiryRemindersEnabled,
      'simulatedAlertsEnabled': simulatedAlertsEnabled,
      'progressNotificationsEnabled': progressNotificationsEnabled,
      'appTheme': appTheme.toString().split('.').last, // Store as string
      'offlineSyncEnabled': offlineSyncEnabled,
      'updatedAt': updatedAt,
      // 'id' is not typically stored as a field in its own document
    };
  }

  // Creates a UserPreferences instance from a Map (e.g., from shared_preferences).
  factory UserPreferences.fromMap(Map<String, dynamic> map, String id) {
    return UserPreferences(
      id: id, // Or map['id'] if you store it in the map
      expiryRemindersEnabled: map['expiryRemindersEnabled'] ?? true,
      simulatedAlertsEnabled: map['simulatedAlertsEnabled'] ?? true,
      progressNotificationsEnabled: map['progressNotificationsEnabled'] ?? true,
      appTheme: _appThemeFromString(map['appTheme']),
      offlineSyncEnabled: map['offlineSyncEnabled'] ?? true,
      updatedAt: (map['updatedAt'] is Timestamp)
          ? map['updatedAt']
          : Timestamp.fromMillisecondsSinceEpoch(map['updatedAt'] ?? Timestamp.now().millisecondsSinceEpoch),
    );
  }

  // Converts this UserPreferences instance to a Map for local storage.
  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Optionally store id if needed for local distinction
      'expiryRemindersEnabled': expiryRemindersEnabled,
      'simulatedAlertsEnabled': simulatedAlertsEnabled,
      'progressNotificationsEnabled': progressNotificationsEnabled,
      'appTheme': appTheme.toString().split('.').last, // Store as string
      'offlineSyncEnabled': offlineSyncEnabled,
      'updatedAt': updatedAt.millisecondsSinceEpoch, // Store as int for broader compatibility
    };
  }

  // Creates a new UserPreferences instance with optional field overrides.
  UserPreferences copyWith({
    String? id,
    bool? expiryRemindersEnabled,
    bool? simulatedAlertsEnabled,
    bool? progressNotificationsEnabled,
    AppTheme? appTheme,
    bool? offlineSyncEnabled,
    Timestamp? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      expiryRemindersEnabled: expiryRemindersEnabled ?? this.expiryRemindersEnabled,
      simulatedAlertsEnabled: simulatedAlertsEnabled ?? this.simulatedAlertsEnabled,
      progressNotificationsEnabled: progressNotificationsEnabled ?? this.progressNotificationsEnabled,
      appTheme: appTheme ?? this.appTheme,
      offlineSyncEnabled: offlineSyncEnabled ?? this.offlineSyncEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}