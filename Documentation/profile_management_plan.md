# Implementation Plan: Profile Management & Profile Tab

This plan outlines the steps to implement user profile management and the associated UI in the Profile Tab, keeping in mind the offline-first requirement.

## Phase 1: Data Model Definition

We'll define two primary data models: `UserProfile` and `UserPreferences`.

1.  **`UserProfile` Model (`lib/models/user_profile.dart`)**
    *   **Fields:**
        *   `uid`: `String` (User's Firebase Auth ID - typically the document ID, not stored as a field within its own document)
        *   `email`: `String` (From Firebase Auth, potentially denormalized for display)
        *   `displayName`: `String?`
        *   `profilePicUrl`: `String?` (URL to the image, e.g., stored in Firebase Storage)
        *   `location`: `String?` (e.g., "District 1, HCMC")
        *   `createdAt`: `Timestamp` (Server timestamp for when the profile was first created)
        *   `updatedAt`: `Timestamp` (Server timestamp for last update)
    *   **Methods:**
        *   `UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, String id)`
        *   `Map<String, dynamic> toJson()`
        *   `UserProfile copyWith(...)`

2.  **`UserPreferences` Model (`lib/models/user_preferences.dart`)**
    *   **Fields:**
        *   `expiryRemindersEnabled`: `bool` (default: `true`)
        *   `simulatedAlertsEnabled`: `bool` (default: `true`)
        *   `progressNotificationsEnabled`: `bool` (default: `true`)
        *   `appTheme`: `String` (e.g., "system", "light", "dark", "calmResilience" - default: "system")
        *   `offlineSyncEnabled`: `bool` (default: `true`)
        *   `updatedAt`: `Timestamp` (Server timestamp for last update)
    *   **Methods:**
        *   `UserPreferences.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, String id)`
        *   `Map<String, dynamic> toJson()`
        *   `UserPreferences copyWith(...)`
        *   `UserPreferences.fromMap(Map<String, dynamic> map)` (for local storage)
        *   `Map<String, dynamic> toMap()` (for local storage)

## Phase 2: Backend Service - `ProfileService`

We'll create a new service, `ProfileService`.

**`ProfileService` (`lib/services/profile_service.dart`)**

*   **Dependencies:** `FirebaseFirestore`, `FirebaseAuth`.
*   **User Profile Management:**
    *   `Stream<UserProfile?> getUserProfile()`: Streams the current user's profile from `users/{userId}`. Creates a default profile if one doesn't exist on first access after registration.
    *   `Future<void> updateUserProfile(UserProfile profile)`: Updates the user's profile in Firestore.
    *   `Future<String?> uploadProfilePicture(File imageFile)`: (Optional, if direct image upload is handled here) Uploads image to Firebase Storage and returns URL.
*   **User Preferences Management:**
    *   `Stream<UserPreferences?> getUserPreferences()`: Streams user preferences from `users/{userId}/preferences/settings`. Creates default preferences if none exist.
    *   `Future<void> updateUserPreferences(UserPreferences preferences)`: Updates preferences in Firestore.

## Phase 3: Local Storage for Preferences (Offline-First)

To support offline access to preferences and reduce Firestore reads, we'll use `shared_preferences`.

1.  **Add `shared_preferences` dependency:**
    *   Add `shared_preferences: ^latest_version` to `pubspec.yaml`.
2.  **`LocalPreferenceService` (`lib/services/local_preference_service.dart`)**
    *   **Methods:**
        *   `Future<UserPreferences?> getPreferences()`: Loads preferences from `shared_preferences`.
        *   `Future<void> savePreferences(UserPreferences preferences)`: Saves preferences to `shared_preferences`.
        *   `Future<void> clearPreferences()`: Clears local preferences (e.g., on logout).
3.  **Sync Strategy:**
    *   **On App Load/Login:** Fetch from Firestore, update local.
    *   **On Preference Change (UI):** Update local immediately, then update Firestore. If Firestore update fails, queue for later sync (more advanced: consider a flag or separate queue).
    *   **Offline:** Read from local. Changes made offline are saved locally and synced when back online.

## Phase 4: Profile Tab UI Implementation

Update `lib/screens/tabs/profile_tab.dart` and create supporting widgets/screens.

1.  **`ProfileTab` (`profile_tab.dart`)**
    *   Display user's `displayName`, `email`, and `profilePicUrl` (with a placeholder).
    *   Button/Icon to navigate to `EditProfileScreen`.
    *   Section for "Preferences" with toggles/options:
        *   Expiry Reminders (SwitchListTile)
        *   Simulated Alerts (SwitchListTile)
        *   Progress Notifications (SwitchListTile)
        *   App Theme (DropdownButton or custom selector)
        *   Offline Sync (SwitchListTile)
    *   "Link to Gamification/Progress" (Placeholder button/text).
    *   "Logout" button.
2.  **`EditProfileScreen` (`lib/screens/profile/edit_profile_screen.dart`) - New File**
    *   Form to edit `displayName`.
    *   Option to change/upload `profilePicUrl` (could involve an image picker and uploading service).
    *   Field to edit `location`.
    *   Save/Cancel buttons.
3.  **Widgets:**
    *   Consider creating reusable widgets for profile picture display, form fields, etc.

## Phase 5: State Management (using Riverpod)

We will use Riverpod for state management.

*   **Providers:**
    *   `userProfileProvider`: A `StreamProvider` that exposes the `UserProfile` stream from `ProfileService.getUserProfile()`.
    *   `userPreferencesProvider`: A `StreamProvider` that exposes the `UserPreferences` stream from `ProfileService.getUserPreferences()`.
    *   `localUserPreferencesProvider`: A `StateNotifierProvider` for managing local `UserPreferences` via `LocalPreferenceService` and handling the sync logic.
*   **Notifiers (Example for Preferences):**
    *   `UserPreferencesNotifier` (extends `StateNotifier<AsyncValue<UserPreferences>>`):
        *   Initializes by loading from `LocalPreferenceService`, then attempts to sync with Firestore via `ProfileService`.
        *   Provides methods to update individual preferences (e.g., `updateTheme(String newTheme)`). These methods will:
            1.  Update the local state optimistically.
            2.  Call `LocalPreferenceService.savePreferences()`.
            3.  Call `ProfileService.updateUserPreferences()`.
            4.  Handle potential errors from Firestore update (e.g., revert optimistic update or show an error).
*   **Data Flow:**
    *   UI widgets will `watch` these providers to get data and rebuild.
    *   Actions in the UI (e.g., toggling a switch) will call methods on the appropriate Notifier or directly on the `ProfileService` (if not using a complex notifier for simple updates).
    *   Services (`ProfileService`, `LocalPreferenceService`) handle the actual data fetching and saving.

## Mermaid Diagram: Profile System Architecture

```mermaid
graph TD
    subgraph "UI Layer"
        A[ProfileTab UI]
        B[EditProfileScreen UI]
    end

    subgraph "State Management (Riverpod)"
        C[Providers/Notifiers e.g., UserPreferencesNotifier]
    end

    subgraph "Service Layer"
        D[ProfileService]
        E[LocalPreferenceService]
        F[FirebaseAuthService (Existing)]
    end

    subgraph "Data Layer"
        G[Firebase Firestore]
        H[Firebase Storage (for Profile Pic)]
        I[SharedPreferences (Local)]
    end

    subgraph "Models"
        J[UserProfile Model]
        K[UserPreferences Model]
    end

    A -- watches/calls --> C
    B -- watches/calls --> C
    C -- interacts with --> D
    C -- interacts with --> E
    C -- interacts with --> F

    D -- Manages UserProfile & UserPreferences --> G[users/{uid}/profile\nusers/{uid}/preferences/settings]
    D -- Stores/Retrieves Profile Pic URL --> H
    E -- Caches/Retrieves --> I[UserPreferences]

    F -- Provides Auth State --> C
    F -- Provides Auth State --> D

    G -- data for --> J
    G -- data for --> K
    I -- data for --> K

    D -. uses .-> J
    D -. uses .-> K
    E -. uses .-> K
```

## Implementation Steps & Priorities:

1.  **Models:** Define `UserProfile` and `UserPreferences` classes.
2.  **`ProfileService` (Firestore part):** Implement methods for fetching/updating profile and preferences from Firestore.
3.  **Basic `ProfileTab` UI:** Display basic info (read-only) and logout button. Integrate with `ProfileService` via Riverpod providers.
4.  **`shared_preferences` & `LocalPreferenceService`:** Implement local caching for `UserPreferences`.
5.  **State Management (Riverpod):** Fully implement Riverpod providers and notifiers for profile and preferences, including sync logic.
6.  **Full `ProfileTab` UI:** Implement all preference toggles and theme selection, making them functional using Riverpod.
7.  **`EditProfileScreen` UI & Logic:** Implement profile editing functionality using Riverpod.
8.  **Profile Picture Handling:** Implement image picker and upload to Firebase Storage, integrated with `ProfileService` and state management.
9.  **Offline Sync Refinements:** Ensure robust sync logic for preferences, handling edge cases and potential conflicts if necessary.