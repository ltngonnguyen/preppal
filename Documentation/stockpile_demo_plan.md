# PrepPal Stockpile Offline-First Demo Plan

## Objective

Create a compelling video demonstration of the PrepPal stockpile's offline-first synchronization feature, highlighting its reliability and seamless user experience.

## Key Aspects to Demonstrate in the Video

1.  **Initial Online State & Sync:** User logs in, existing data from Firestore populates the local app.
2.  **Going Offline:** Clearly show the device disconnecting from the network.
3.  **Offline Operations:** User adds, edits, and deletes stockpile items smoothly, with immediate UI updates.
4.  **Re-establishing Connectivity:** Device reconnects to the network.
5.  **Automatic Background Sync:**
    *   Local changes (adds, edits, deletes) are pushed to Firestore.
    *   Changes made elsewhere (e.g., directly in Firestore console or another device while the primary device was offline) are pulled down.
6.  **Data Consistency:** The app's local data and Firestore data are shown to be consistent post-sync.

## Phase 1: Application Enhancements for Demo Clarity

*   **A. UI Indicators:**
    1.  **Connectivity Status:**
        *   **What:** Implement a clear visual indicator in the app (e.g., in the app bar or a small banner) displaying "Online" or "Offline".
        *   **How:** Utilize the `connectivity_plus` stream to update this status dynamically.
    2.  **Item-Level Sync Status (Recommended):**
        *   **What:** For items in the stockpile list, provide a subtle visual cue (e.g., a small icon like a cloud outline for 'pending_sync', cloud filled for 'synced') if an item has local changes not yet pushed to Firestore.
        *   **How:** Check the `syncStatus` field of each `StockpileItem`.
    3.  **Global Sync Activity Indicator:**
        *   **What:** Display a global status message like "Syncing...", "Last synced: [timestamp/Just now]", or "Sync pending (Offline)".
        *   **How:** Update based on the `syncWithFirestore()` activity and connectivity status.
    4.  **Manual "Force Sync" Button (For Demo Control):**
        *   **What:** Add a button (e.g., in a debug menu or settings page) that explicitly triggers the `syncWithFirestore()` method.
        *   **Why:** This gives precise control during filming to initiate sync when you want to showcase it, rather than waiting for purely automatic triggers.

*   **B. Enhanced Logging & In-App Log Viewer:**
    1.  **Replace `print()` with Structured Logging:**
        *   **What:** Transition from basic `print()` statements in `StockpileRepository` and related logic to a more robust logging approach.
        *   **How:** Use a simple custom logger class or a package like `logger`.
    2.  **Granular and Descriptive Log Messages:**
        *   **Connectivity:** "Network status changed: Online/Offline."
        *   **Local DB:** "LocalDB: Creating item [ID/Name]", "LocalDB: Updating item [ID/Name]", "LocalDB: Deleting item [ID/Name]".
        *   **Sync Process:**
            *   "Sync: Process started."
            *   "Sync: Pushing local item [ID/Name] to Firestore."
            *   "Sync: Item [ID/Name] pushed successfully."
            *   "Sync: Error pushing item [ID/Name]: [error details]."
            *   "Sync: Fetching remote changes from Firestore."
            *   "Sync: Pulled item [ID/Name] from Firestore (New)."
            *   "Sync: Pulled item [ID/Name] from Firestore (Updated)."
            *   "Sync: Local item [ID/Name] updated from Firestore."
            *   "Sync: Deleting item [ID/Name] from Firestore."
            *   "Sync: Process completed."
    3.  **In-App Log Viewer (Crucial for Demo):**
        *   **What:** Implement a simple, scrollable panel or screen within the app (perhaps accessible via a debug gesture or menu) that displays these logs in real-time.
        *   **Why:** This makes the "invisible" background processes visible and very compelling for the demonstration.

## Phase 2: Demo Scenario & Filming Preparation

*   **A. Prepare Your Environment:**
    1.  **Firebase Console:** Have your Firebase project's Firestore database console open and ready to be recorded. This will visually confirm backend changes.
    2.  **Test Data:** Populate Firestore with a few initial stockpile items.

*   **B. Script the Demonstration Flow:**
    1.  **Step 1: Initial Setup (Online)**
        *   Show the app launching and the user logging in.
        *   Display the initial stockpile items, with logs showing they were fetched/synced from Firestore.
        *   Point out the "Online" status and "Synced" indicators.
    2.  **Step 2: Go Offline**
        *   Clearly demonstrate disabling the network (e.g., enabling airplane mode on the device).
        *   Show the UI indicator changing to "Offline".
    3.  **Step 3: Offline Operations**
        *   **Add a new item:** Show the item appearing instantly. Point out its "pending_sync" status (if implemented) and the in-app logs showing local DB creation.
        *   **Edit an existing item:** Show changes reflected immediately. Note sync status and logs.
        *   **Delete an item:** Show it removed from the list. Note logs.
    4.  **Step 4: (Optional but Recommended) Simulate Concurrent Change**
        *   While the primary device is still offline, use the Firestore console to manually add a new item or modify an existing item that *wasn't* touched offline on the primary device. This will demonstrate the pull capability.
    5.  **Step 5: Re-establish Connectivity & Sync**
        *   Re-enable the network on the device. Show the UI indicator changing to "Online".
        *   Trigger sync (either automatically or via the "Force Sync" button).
        *   **Crucial Part:** Simultaneously show:
            *   The in-app logs detailing the push of local changes and pull of remote changes.
            *   The Firestore console updating in real-time (new items appearing, edits reflected, deleted items gone, and the item from Step 4 appearing/updating).
            *   Item sync statuses in the app changing to "synced".
    6.  **Step 6: Verification**
        *   Show the final state of the stockpile in the app.
        *   Show the final state in Firestore.
        *   Confirm they are consistent.

## Phase 3: Conceptual Data Flow

```mermaid
sequenceDiagram
    participant User
    participant AppUI
    participant LocalDB (SQLite)
    participant StockpileRepo_SyncLogic
    participant Firestore

    Note over User, Firestore: Initial State: Items A, B in Firestore

    User->>AppUI: Launch App (Online)
    AppUI->>StockpileRepo_SyncLogic: Init/Request Sync
    StockpileRepo_SyncLogic->>Firestore: GET /stockpileItems
    Firestore-->>StockpileRepo_SyncLogic: Items A, B
    StockpileRepo_SyncLogic->>LocalDB: Store/Update A, B (status: synced)
    LocalDB-->>StockpileRepo_SyncLogic: OK
    StockpileRepo_SyncLogic-->>AppUI: Data ready (A, B)

    User->>AppUI: Disable Network
    AppUI-->>User: Show "Offline"

    User->>AppUI: Add Item C
    AppUI->>LocalDB: INSERT Item C (status: pending_sync)
    LocalDB-->>AppUI: OK, UI shows A, B, C

    User->>AppUI: Edit Item B -> B'
    AppUI->>LocalDB: UPDATE Item B to B' (status: pending_sync)
    LocalDB-->>AppUI: OK, UI shows A, B', C

    %% Optional: External Change while App is Offline
    Note right of Firestore: User (or other client) adds Item D to Firestore

    User->>AppUI: Enable Network
    AppUI-->>User: Show "Online"
    AppUI->>StockpileRepo_SyncLogic: Network available, Trigger Sync

    StockpileRepo_SyncLogic->>LocalDB: GET items where status='pending_sync'
    LocalDB-->>StockpileRepo_SyncLogic: Item C, Item B'

    StockpileRepo_SyncLogic->>Firestore: POST /stockpileItems (Item C)
    Firestore-->>StockpileRepo_SyncLogic: OK (C created)
    StockpileRepo_SyncLogic->>LocalDB: UPDATE Item C (status: synced)

    StockpileRepo_SyncLogic->>Firestore: PUT /stockpileItems/B (Item B')
    Firestore-->>StockpileRepo_SyncLogic: OK (B updated to B')
    StockpileRepo_SyncLogic->>LocalDB: UPDATE Item B' (status: synced)

    StockpileRepo_SyncLogic->>Firestore: GET /stockpileItems (fetch changes)
    Firestore-->>StockpileRepo_SyncLogic: Items A, B', C, D (Item D is new from server)
    StockpileRepo_SyncLogic->>LocalDB: Store Item D (status: synced)
    LocalDB-->>StockpileRepo_SyncLogic: OK
    StockpileRepo_SyncLogic-->>AppUI: Data updated
    AppUI->>User: UI shows A, B', C, D