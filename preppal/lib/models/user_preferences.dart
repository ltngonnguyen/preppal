import 'package:cloud_firestore/cloud_firestore.dart';

enum AppTheme {
  system,
  light,
  dark,
  calmResilience,
}

// string to AppTheme
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
  final String id; // doc ID
  final bool expiryRemindersEnabled;
  final bool simulatedAlertsEnabled;
  final bool progressNotificationsEnabled;
  final AppTheme appTheme; // theme
  final bool offlineSyncEnabled;
  final Timestamp updatedAt;

  UserPreferences({
    required this.id,
    this.expiryRemindersEnabled = true,
    this.simulatedAlertsEnabled = true,
    this.progressNotificationsEnabled = true,
    this.appTheme = AppTheme.system, // default theme
    this.offlineSyncEnabled = true,
    required this.updatedAt,
  });

  // create from Firestore snapshot
  factory UserPreferences.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    final data = snapshot.data() ?? {}; // ensure data
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

  // convert to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'expiryRemindersEnabled': expiryRemindersEnabled,
      'simulatedAlertsEnabled': simulatedAlertsEnabled,
      'progressNotificationsEnabled': progressNotificationsEnabled,
      'appTheme': appTheme.toString().split('.').last, // store as string
      'offlineSyncEnabled': offlineSyncEnabled,
      'updatedAt': updatedAt,
      // 'id' not stored
    };
  }

  // create from Map
  factory UserPreferences.fromMap(Map<String, dynamic> map, String id) {
    return UserPreferences(
      id: id, // or map['id']
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

  // convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // optional local ID
      'expiryRemindersEnabled': expiryRemindersEnabled,
      'simulatedAlertsEnabled': simulatedAlertsEnabled,
      'progressNotificationsEnabled': progressNotificationsEnabled,
      'appTheme': appTheme.toString().split('.').last, // store as string
      'offlineSyncEnabled': offlineSyncEnabled,
      'updatedAt': updatedAt.millisecondsSinceEpoch, // store as int
    };
  }

  // create new with overrides
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