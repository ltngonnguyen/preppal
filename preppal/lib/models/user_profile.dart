import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id; // doc ID
  final String email;
  final String? displayName;
  final String? profilePicUrl;
  final String? location;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.profilePicUrl,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  // create from Firestore snapshot
  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    final data = snapshot.data();
    return UserProfile(
      id: id,
      email: data?['email'] ?? '',
      displayName: data?['displayName'],
      profilePicUrl: data?['profilePicUrl'],
      location: data?['location'],
      createdAt: data?['createdAt'] ?? Timestamp.now(), // default to now
      updatedAt: data?['updatedAt'] ?? Timestamp.now(), // default to now
    );
  }

  // convert to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'profilePicUrl': profilePicUrl,
      'location': location,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // create new with overrides
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    bool clearDisplayName = false,
    String? profilePicUrl,
    bool clearProfilePicUrl = false,
    String? location,
    bool clearLocation = false,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      profilePicUrl: clearProfilePicUrl ? null : (profilePicUrl ?? this.profilePicUrl),
      location: clearLocation ? null : (location ?? this.location),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}