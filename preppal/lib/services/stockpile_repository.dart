import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async'; // Added for StreamController
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stockpile_item.dart';
import './firestore_service.dart'; // Will be used for sync

class StockpileRepository {
  static final StockpileRepository instance = StockpileRepository._init();
  static Database? _database;
  // StreamController for generic update notifications
  final _updateNotifierController = StreamController<void>.broadcast();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService(); // To leverage existing Firestore logic for sync

  StockpileRepository._init();

  String? get _userId => _auth.currentUser?.uid;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stockpile.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const intType = 'INTEGER';
    const realType = 'REAL'; // For double values
    const nullableTextType = 'TEXT NULL';
    const nullableIntType = 'INTEGER NULL';
    const nullableRealType = 'REAL NULL';

    await db.execute('''
CREATE TABLE stockpile_items (
  id $idType,
  name $textType NOT NULL,
  quantity $intType NOT NULL,
  category $textType NOT NULL,
  unit $nullableTextType,
  expiryDate $nullableTextType,
  notes $nullableTextType,
  reminderPreference $nullableTextType,
  addedDate $textType NOT NULL,
  updatedAt $nullableTextType,
  userId $textType NOT NULL,
  unitVolumeLiters $nullableRealType,
  totalDaysOfSupplyPerItem $nullableRealType,
  syncStatus $nullableTextType
  )
''');
  }

  // Create (Insert)
  Future<StockpileItem> create(StockpileItem item) async {
    final db = await instance.database;
    // Ensure unique ID if not provided. Using UUID is better for actual production.
    final id = item.id ?? '${_userId}_${DateTime.now().millisecondsSinceEpoch.toString()}';
    final itemToInsert = item.copyWith(
      id: id,
      userId: _userId, // Ensure userId is set
      updatedAt: DateTime.now(),
      syncStatus: 'pending_sync', // Mark for sync
    );
    await db.insert('stockpile_items', itemToInsert.toMap(forFirestore: false));
    _notifyListeners(); // Notify stream listeners
    syncWithFirestore(); // Attempt sync in background
    return itemToInsert;
  }

  // Read (Single Item)
  Future<StockpileItem?> readItem(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'stockpile_items',
      columns: null, // all columns
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return StockpileItem.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Read (All Items for a user with filter)
  Future<List<StockpileItem>> readAllItems({String filter = "All"}) async {
    if (_userId == null) return [];
    final db = await instance.database;
    const orderBy = 'addedDate DESC';
    
    String whereClause = 'userId = ?';
    List<dynamic> whereArgs = [_userId!];

    if (filter == "Food") {
      whereClause += ' AND category = ?';
      whereArgs.add('Food');
    } else if (filter == "Water") {
      whereClause += ' AND category = ?';
      whereArgs.add('Water');
    } else if (filter == "Expiring") {
      whereClause += ' AND expiryDate IS NOT NULL AND expiryDate < ?';
      final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
      whereArgs.add(thirtyDaysFromNow.toIso8601String());
    }
    // "All" filter doesn't add further conditions to whereClause beyond userId.

    final result = await db.query(
      'stockpile_items',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return result.map((json) => StockpileItem.fromMap(json)).toList();
  }

  // Stream of items for a user, supporting filtering.
  Stream<List<StockpileItem>> getStockpileItemsStream({String filter = "All"}) {
    final controller = StreamController<List<StockpileItem>>.broadcast();

    // Initial fetch for the given filter
    readAllItems(filter: filter).then((items) {
      if (!controller.isClosed) {
        controller.add(items);
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    });

    // Listen for general update notifications to re-fetch with the specific filter
    final StreamSubscription<void> subscription = _updateNotifierController.stream.listen((_) {
      print("StockpileRepository: Update notification received, re-fetching for filter: $filter");
      readAllItems(filter: filter).then((items) {
        if (!controller.isClosed) {
          controller.add(items);
        }
      }).catchError((e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      });
    });

    // When the stream is cancelled, close its controller and cancel its subscription.
    controller.onCancel = () {
      print("StockpileRepository: Stream for filter '$filter' cancelled.");
      subscription.cancel();
      if (!controller.isClosed) {
        controller.close();
      }
    };

    return controller.stream;
  }

  // Helper to notify listeners of a data change by pinging the notifier controller.
  Future<void> _notifyListeners() async {
    print("StockpileRepository: Notifying listeners of data change.");
    if (!_updateNotifierController.isClosed) {
      _updateNotifierController.add(null); // Send a void event to trigger re-fetch in active streams.
    }
  }

  // Update
  Future<int> update(StockpileItem item) async {
    final db = await instance.database;
    final itemToUpdate = item.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: 'pending_sync', // Mark for sync
    );
    final result = await db.update(
      'stockpile_items',
      itemToUpdate.toMap(forFirestore: false),
      where: 'id = ? AND userId = ?',
      whereArgs: [item.id, _userId],
    );
    if (result > 0) {
      _notifyListeners(); // Notify stream listeners
      syncWithFirestore(); // Attempt sync in background
    }
    return result;
  }

  // Delete
  Future<int> delete(String id) async {
    if (_userId == null) return 0;
    final db = await instance.database;
    
    final itemToDelete = await readItem(id); // Get item before deleting to use in sync
    
    final result = await db.delete(
      'stockpile_items',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, _userId],
    );

    if (result > 0) {
      _notifyListeners(); // Notify stream listeners
      if (itemToDelete != null) {
         _syncDeletionWithFirestore(itemToDelete);
      }
    }
    return result;
  }
  
  Future<void> _syncDeletionWithFirestore(StockpileItem itemToDelete) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection. Deletion for ${itemToDelete.id} will be synced later.');
      // We need a mechanism to store pending deletions if offline.
      // For now, if offline, it won't sync. This needs improvement.
      // One way is to add to a 'pendingDeletions' list/table.
      return;
    }
     if (_userId == null) return;

    try {
      print('Deleting item from Firestore: ${itemToDelete.id}');
      await _firestoreService.deleteStockpileItem(itemToDelete.id!);
      print('Item ${itemToDelete.id} deleted from Firestore.');
    } catch (e) {
      print('Error deleting item ${itemToDelete.id} from Firestore: $e');
      // Handle error, maybe re-add to a pending deletion queue.
    }
  }

  // TODO: Implement synchronization logic
  // - Detect internet connectivity
  // - When online:
  //   - Fetch items from Firestore.
  //   - Compare with local items, resolve conflicts (offline data takes precedence).
  //   - Update both local DB and Firestore.

  Future<void> syncWithFirestore() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection. Skipping sync.');
      return;
    }

    if (_userId == null) {
      print('User not logged in. Skipping sync.');
      return;
    }

    print('Starting sync with Firestore...');

    // 1. Get local items marked 'pending_sync'
    final db = await instance.database;
    final localPendingItems = (await db.query(
      'stockpile_items',
      where: 'syncStatus = ? AND userId = ?',
      whereArgs: ['pending_sync', _userId],
    )).map((json) => StockpileItem.fromMap(json)).toList();

    // 2. Push local changes to Firestore
    for (final localItem in localPendingItems) {
      try {
        // FirestoreService's add/update methods handle creation or update if ID exists.
        // We need to ensure the item passed to firestoreService has an ID.
        if (localItem.id == null) {
            print('Error: Local item ${localItem.name} has no ID, cannot sync.');
            continue;
        }

        // Check if item was marked for deletion (this part is not fully implemented yet)
        // if (localItem.syncStatus == 'deleted_pending_sync') {
        //   await _firestoreService.deleteStockpileItem(localItem.id!);
        // } else {
          // Determine if it's an add or update based on Firestore existence
          // For simplicity, we can try to get it. If not exists, it's an add.
          // However, FirestoreService.addStockpileItem might need to be smarter or
          // we use a specific "upsert" if available, or check existence first.
          // The current FirestoreService.addStockpileItem uses .add() which creates a new ID.
          // We need to use .doc(id).set() for upsert or .doc(id).update()
          
          // Let's refine this:
          // If local item has an ID, we assume it might exist in Firestore.
          // We should use `doc(id).set(data, SetOptions(merge: true))` for an upsert behavior.
          // Or, check existence then add/update.
          // The current `_firestoreService.addStockpileItem` uses `collection.add()`, which generates a new ID.
          // This is not suitable for syncing existing items.
          // `_firestoreService.updateStockpileItem` uses `doc(id).update()`.

          DocumentSnapshot firestoreDoc;
          try {
            firestoreDoc = await _db.collection('users').doc(_userId).collection('stockpileItems').doc(localItem.id).get();
          } catch (e) {
            // Handle case where doc path is invalid or other Firestore errors during get
            print('Error fetching Firestore document ${localItem.id} for sync: $e');
            continue; // Skip this item
          }

          final itemToSync = localItem.copyWith(updatedAt: DateTime.now()); // Use a fresh timestamp

          if (firestoreDoc.exists) {
            print('Updating item in Firestore: ${localItem.id}');
            // Ensure `updateStockpileItem` uses the localItem.id
            await _firestoreService.updateStockpileItem(itemToSync);
          } else {
            print('Adding item to Firestore: ${localItem.id}');
            // We need an addOrSet method in FirestoreService that takes an ID.
            // For now, let's modify addStockpileItem or create a new one.
            // Quick fix: use set directly here for items with ID.
            await _db.collection('users').doc(_userId).collection('stockpileItems').doc(localItem.id).set(itemToSync.toMap(forFirestore: true));
          }
        // }

        // Mark as synced locally
        await db.update(
          'stockpile_items',
          {'syncStatus': 'synced', 'updatedAt': itemToSync.updatedAt?.toIso8601String()},
          where: 'id = ?',
          whereArgs: [localItem.id],
        );
      } catch (e) {
        print('Error syncing item ${localItem.id} to Firestore: $e');
        // Optionally, implement retry logic or leave as 'pending_sync'
      }
    }
    
    // Sync pending deletions (This requires a list of pending deletions)
    // await _syncPendingDeletions(); // Placeholder for a more robust deletion sync


    // 3. Fetch all items from Firestore
    print('Fetching all items from Firestore for comparison...');
    List<StockpileItem> firestoreItems = [];
    try {
      final snapshot = await _db.collection('users').doc(_userId).collection('stockpileItems').get();
      firestoreItems = snapshot.docs.map((doc) => StockpileItem.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error fetching items from Firestore: $e');
      return; // Stop sync if we can't get Firestore data
    }
    

    // 4. Compare and update local DB from Firestore (conflict resolution)
    for (final firestoreItem in firestoreItems) {
      final localItem = await readItem(firestoreItem.id!);
      if (localItem == null) {
        // Item exists in Firestore but not locally - add to local
        print('Adding Firestore item to local DB: ${firestoreItem.id}');
        await db.insert('stockpile_items', firestoreItem.copyWith(syncStatus: 'synced').toMap(forFirestore: false));
      } else {
        // Item exists in both. Conflict resolution: offline (local) data takes precedence if newer.
        // The 'pending_sync' items were already handled. This is for items that are 'synced' locally.
        if (localItem.syncStatus == 'synced' && 
            firestoreItem.updatedAt != null && 
            (localItem.updatedAt == null || firestoreItem.updatedAt!.isAfter(localItem.updatedAt!))) {
          // Firestore item is newer and local item was 'synced' (not pending an outgoing sync)
          print('Updating local item from Firestore: ${firestoreItem.id}');
          await db.update(
            'stockpile_items',
            firestoreItem.copyWith(syncStatus: 'synced').toMap(forFirestore: false),
            where: 'id = ?',
            whereArgs: [firestoreItem.id],
          );
        }
        // If localItem.updatedAt is newer, it should have been 'pending_sync' and pushed up.
        // If they are the same, no action needed.
      }
    }
    print('Sync with Firestore completed.');
  }
  
  // Initial data fetch logic
  Future<void> performInitialDataLoad() async {
    if (_userId == null) return;

    // Use readAllItems with default "All" filter for initial check
    final localItems = await readAllItems();
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;
    bool dataChanged = false;

    if (localItems.isEmpty && isOnline) {
      print('Local DB is empty and online, performing initial sync from Firestore...');
      // Fetch from Firestore and populate local DB
      try {
        final snapshot = await _db.collection('users').doc(_userId).collection('stockpileItems').get();
        final firestoreItems = snapshot.docs.map((doc) => StockpileItem.fromMap(doc.data(), doc.id)).toList();
        
        if (firestoreItems.isNotEmpty) {
          final db = await instance.database;
          for (final item in firestoreItems) {
            await db.insert('stockpile_items', item.copyWith(syncStatus: 'synced').toMap(forFirestore: false));
          }
          print('Initial sync from Firestore completed. ${firestoreItems.length} items loaded.');
          dataChanged = true;
        }
      } catch (e) {
        print('Error during initial sync from Firestore: $e');
      }
    } else if (localItems.isNotEmpty) {
      print('Local DB has data. Will attempt regular sync if needed.');
      await syncWithFirestore(); // Attempt a regular sync if online
      // Sync might change data, so consider dataChanged = true or let sync handle its own notify.
      // For simplicity, we'll notify if local items existed, as their state might need refresh.
      dataChanged = true;
    } else {
      print('Local DB is empty and offline. No initial sync possible.');
    }
    
    if (dataChanged) {
      _notifyListeners(); // Notify that data might have changed
    }
  }


  Future close() async {
    final db = _database; // Use the local static variable
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
    if (!_updateNotifierController.isClosed) {
      await _updateNotifierController.close();
    }
  }
}