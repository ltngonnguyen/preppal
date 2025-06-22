import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async'; // for streams
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stockpile_item.dart';
import './firestore_service.dart'; // for sync stuff
import '../utils/simple_logger.dart'; // Added

// Define SyncStatus events
abstract class SyncStatusEvent {
  const SyncStatusEvent();
}

class SyncStarted extends SyncStatusEvent {
  const SyncStarted();
}

class SyncCompleted extends SyncStatusEvent {
  final DateTime timestamp;
  const SyncCompleted(this.timestamp);
}

class SyncError extends SyncStatusEvent {
  final String message;
  const SyncError(this.message);
}

class SyncNoConnection extends SyncStatusEvent {
  const SyncNoConnection();
}

class StockpileRepository {
  static final StockpileRepository instance = StockpileRepository._init();
  static Database? _database;
  // for updates
  final _updateNotifierController = StreamController<void>.broadcast();
  // For sync status updates
  final _syncStatusController = StreamController<SyncStatusEvent>.broadcast();
  Stream<SyncStatusEvent> get syncStatusStream => _syncStatusController.stream;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService(); // use existing firestore stuff

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
    const realType = 'REAL'; // for double
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
  
    // create item
    Future<StockpileItem> create(StockpileItem item) async {
      final db = await instance.database;
      // make unique ID
      final id = item.id ?? '${_userId}_${DateTime.now().millisecondsSinceEpoch.toString()}';
      final itemToInsert = item.copyWith(
        id: id,
        userId: _userId, // set userId
        updatedAt: DateTime.now(),
        syncStatus: 'pending_sync', // mark for sync
      );
      await db.insert('stockpile_items', itemToInsert.toMap(forFirestore: false));
      _notifyListeners(); // notify listeners
      syncWithFirestore(); // sync in background
      return itemToInsert;
    }
  
    // read single item
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
  
    // read all items for user
    Future<List<StockpileItem>> readAllItems({String filter = "All"}) async {
      if (_userId == null) return [];
      final db = await instance.database;
      const orderBy = 'addedDate DESC';
      
      String whereClause = 'userId = ? AND (syncStatus IS NULL OR syncStatus != ?)'; // Exclude pending_delete
      List<dynamic> whereArgs = [_userId!, 'pending_delete']; // Add argument for pending_delete
  
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
      // "All" filter: no extra conditions
  
      final result = await db.query(
        'stockpile_items',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );
      return result.map((json) => StockpileItem.fromMap(json)).toList();
    }
  
    // stream of items
    Stream<List<StockpileItem>> getStockpileItemsStream({String filter = "All"}) {
      final controller = StreamController<List<StockpileItem>>.broadcast();
  
      // initial fetch
      readAllItems(filter: filter).then((items) {
        if (!controller.isClosed) {
          controller.add(items);
        }
      }).catchError((e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      });
  
      // listen for updates
      final StreamSubscription<void> subscription = _updateNotifierController.stream.listen((_) {
        SimpleLogger.log("Update notification received, re-fetching for filter: $filter", tag: "StockpileRepo");
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
  
      // on stream cancel
      controller.onCancel = () {
        SimpleLogger.log("Stream for filter '$filter' cancelled.", tag: "StockpileRepo");
        subscription.cancel();
        if (!controller.isClosed) {
          controller.close();
        }
      };
  
      return controller.stream;
    }
  
    // notify listeners
    Future<void> _notifyListeners() async {
      SimpleLogger.log("Notifying listeners of data change.", tag: "StockpileRepo");
      if (!_updateNotifierController.isClosed) {
        _updateNotifierController.add(null); // send void event
      }
    }
  
    // update item
    Future<int> update(StockpileItem item) async {
      final db = await instance.database;
      final itemToUpdate = item.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: 'pending_sync', // mark for sync
      );
      final result = await db.update(
        'stockpile_items',
        itemToUpdate.toMap(forFirestore: false),
        where: 'id = ? AND userId = ?',
        whereArgs: [item.id, _userId],
      );
      if (result > 0) {
        _notifyListeners(); // notify listeners
        syncWithFirestore(); // sync in background
      }
      return result;
    }
  
    // delete item (marks for deletion, actual deletion happens after sync)
    Future<int> delete(String id) async {
      if (_userId == null) return 0;
      final db = await instance.database;
      
      // Instead of deleting, mark as 'pending_delete'
      final itemToMark = await readItem(id);
      if (itemToMark == null) return 0; // Item not found

      final updatedItem = itemToMark.copyWith(
        syncStatus: 'pending_delete',
        updatedAt: DateTime.now(),
      );
      
      final result = await db.update(
        'stockpile_items',
        updatedItem.toMap(forFirestore: false), // Use the map for local DB
        where: 'id = ? AND userId = ?',
        whereArgs: [id, _userId],
      );
  
      if (result > 0) {
        _notifyListeners(); // Notify listeners so UI updates (item disappears)
        syncWithFirestore(); // Attempt to sync the deletion immediately
      }
      return result;
    }
    
    // This method is now part of the main syncWithFirestore logic
    // Future<void> _syncDeletionWithFirestore(StockpileItem itemToDelete) async { ... }
    // It will be handled by iterating items with 'pending_delete' status.

    // TODO: sync logic here (needs significant update for deletions)
  
    Future<void> syncWithFirestore() async {
      _syncStatusController.add(const SyncStarted()); // Notify sync started

      final connectivityResultList = await Connectivity().checkConnectivity();
      if (connectivityResultList.contains(ConnectivityResult.none) &&
          !connectivityResultList.any((r) => r != ConnectivityResult.none && r != ConnectivityResult.bluetooth)) {
        SimpleLogger.log('No internet connection. Skipping sync.', tag: "StockpileRepo.sync");
        _syncStatusController.add(const SyncNoConnection());
        return;
      }

      if (_userId == null) {
        SimpleLogger.log('User not logged in. Skipping sync.', tag: "StockpileRepo.sync");
        _syncStatusController.add(const SyncError('User not logged in.')); // Or a specific event
        return;
      }

      SimpleLogger.log('Starting sync with Firestore...', tag: "StockpileRepo.sync");

      // 1. Get local items: pending creations/updates and pending deletions
      final db = await instance.database;
      final localPendingCreationsUpdates = (await db.query(
        'stockpile_items',
        where: 'syncStatus = ? AND userId = ?',
        whereArgs: ['pending_sync', _userId],
      )).map((json) => StockpileItem.fromMap(json)).toList();

      final localPendingDeletions = (await db.query(
        'stockpile_items',
        where: 'syncStatus = ? AND userId = ?',
        whereArgs: ['pending_delete', _userId],
      )).map((json) => StockpileItem.fromMap(json)).toList();

      // 2. Process pending deletions: Delete from Firestore, then from local DB
      SimpleLogger.log('Processing ${localPendingDeletions.length} pending deletions...', tag: "StockpileRepo.sync");
      for (final itemToDelete in localPendingDeletions) {
        try {
          if (itemToDelete.id == null) {
            SimpleLogger.log('Error: Local item marked for deletion has no ID: ${itemToDelete.name}', tag: "StockpileRepo.sync");
            // If it has no ID, we can't delete it from Firestore.
            // We should probably delete it locally to clean up.
            await db.delete('stockpile_items', where: 'name = ? AND userId = ? AND syncStatus = ?', whereArgs: [itemToDelete.name, _userId, 'pending_delete']);
            continue;
          }
          SimpleLogger.log('Attempting to delete item from Firestore: ${itemToDelete.id}', tag: "StockpileRepo.sync");
          await _firestoreService.deleteStockpileItem(itemToDelete.id!);
          SimpleLogger.log('Item ${itemToDelete.id} deleted from Firestore. Now deleting locally.', tag: "StockpileRepo.sync");
          // If Firestore deletion is successful, delete from local DB permanently
          await db.delete(
            'stockpile_items',
            where: 'id = ? AND userId = ?',
            whereArgs: [itemToDelete.id, _userId],
          );
        } catch (e) {
          SimpleLogger.log('Error deleting item ${itemToDelete.id} from Firestore: $e. It will remain pending_delete locally.', tag: "StockpileRepo.sync");
          _syncStatusController.add(SyncError('Error deleting item ${itemToDelete.name} from cloud: $e'));
          // If Firestore deletion fails, it remains 'pending_delete' locally for the next sync attempt.
        }
      }

      // 3. Push local creations/updates to Firestore
      SimpleLogger.log('Processing ${localPendingCreationsUpdates.length} pending creations/updates...', tag: "StockpileRepo.sync");
      for (final localItem in localPendingCreationsUpdates) {
        try {
          if (localItem.id == null) {
              SimpleLogger.log('Error: Local item ${localItem.name} has no ID, cannot sync create/update.', tag: "StockpileRepo.sync");
              continue;
          }
          // Ensure updatedAt is current for the sync operation
          final itemToSync = localItem.copyWith(updatedAt: DateTime.now());

          // Check if item exists in Firestore to decide between set (create) or update
          DocumentSnapshot firestoreDoc;
          try {
            firestoreDoc = await _db.collection('users').doc(_userId).collection('stockpileItems').doc(localItem.id).get();
          } catch (e) {
            SimpleLogger.log('Error fetching Firestore document ${localItem.id} for sync decision: $e', tag: "StockpileRepo.sync");
            continue;
          }

          if (firestoreDoc.exists) {
            SimpleLogger.log('Updating item in Firestore: ${itemToSync.id}', tag: "StockpileRepo.sync");
            await _firestoreService.updateStockpileItem(itemToSync);
          } else {
            SimpleLogger.log('Adding item to Firestore: ${itemToSync.id}', tag: "StockpileRepo.sync");
            await _db.collection('users').doc(_userId).collection('stockpileItems').doc(itemToSync.id).set(itemToSync.toMap(forFirestore: true));
          }

          // Mark as synced locally
          await db.update(
            'stockpile_items',
            {'syncStatus': 'synced', 'updatedAt': itemToSync.updatedAt?.toIso8601String()},
            where: 'id = ?',
            whereArgs: [localItem.id],
          );
        } catch (e) {
          SimpleLogger.log('Error syncing (create/update) item ${localItem.id} to Firestore: $e', tag: "StockpileRepo.sync");
          _syncStatusController.add(SyncError('Error syncing item ${localItem.name}: $e'));
        }
      }
      
      // 4. Fetch all items from Firestore (that are not marked for deletion locally)
      SimpleLogger.log('Fetching all items from Firestore for comparison...', tag: "StockpileRepo.sync");
      List<StockpileItem> firestoreItems = [];
      try {
        final snapshot = await _db.collection('users').doc(_userId).collection('stockpileItems').get();
        firestoreItems = snapshot.docs.map((doc) => StockpileItem.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        SimpleLogger.log('Error fetching items from Firestore: $e', tag: "StockpileRepo.sync");
        _syncStatusController.add(SyncError('Error fetching items from Firestore: $e'));
        // We might still want to notify listeners even if Firestore fetch fails, as local changes might have occurred.
        _notifyListeners();
        return;
      }
      
      // 5. Compare Firestore items with local DB and reconcile (pulling changes)
      //    Local data takes precedence for items marked 'pending_sync' or 'pending_delete'.
      //    'pending_sync' items were handled in step 3.
      //    'pending_delete' items were handled in step 2.
      SimpleLogger.log('Reconciling ${firestoreItems.length} Firestore items with local DB...', tag: "StockpileRepo.sync");
      for (final firestoreItem in firestoreItems) {
        if (firestoreItem.id == null) {
            SimpleLogger.log('Firestore item has no ID, skipping: ${firestoreItem.name}', tag: "StockpileRepo.sync");
            continue;
        }
        final localItem = await readItem(firestoreItem.id!); // readItem already filters out 'pending_delete' for UI, but we need to check its actual status here.
        
        // Explicitly get the item from DB without filtering 'pending_delete' for reconciliation
        final rawLocalItemResult = await db.query('stockpile_items', where: 'id = ? AND userId = ?', whereArgs: [firestoreItem.id, _userId]);
        StockpileItem? rawLocalItem = rawLocalItemResult.isNotEmpty ? StockpileItem.fromMap(rawLocalItemResult.first) : null;

        if (rawLocalItem == null) {
          // Item exists in Firestore but not locally (and wasn't pending delete). Add to local.
          SimpleLogger.log('Adding Firestore item to local DB: ${firestoreItem.id}', tag: "StockpileRepo.sync");
          await db.insert('stockpile_items', firestoreItem.copyWith(syncStatus: 'synced').toMap(forFirestore: false));
        } else if (rawLocalItem.syncStatus == 'pending_delete') {
          // This case should ideally be rare if step 2 worked, but as a safeguard:
          // Item is marked for deletion locally. Firestore still has it. Attempt to delete from Firestore again.
          SimpleLogger.log('Local item ${rawLocalItem.id} is pending_delete, but found in Firestore. Attempting Firestore delete again.', tag: "StockpileRepo.sync");
          try {
            await _firestoreService.deleteStockpileItem(rawLocalItem.id!);
            SimpleLogger.log('Successfully deleted ${rawLocalItem.id} from Firestore during reconciliation. Deleting locally.', tag: "StockpileRepo.sync");
            await db.delete('stockpile_items', where: 'id = ?', whereArgs: [rawLocalItem.id]);
          } catch (e) {
            SimpleLogger.log('Failed to delete ${rawLocalItem.id} from Firestore during reconciliation: $e', tag: "StockpileRepo.sync");
          }
        } else if (rawLocalItem.syncStatus == 'synced') {
          // Item exists in both and local is 'synced'.
          // If Firestore's version is newer, update local.
          if (firestoreItem.updatedAt != null &&
              (rawLocalItem.updatedAt == null || firestoreItem.updatedAt!.isAfter(rawLocalItem.updatedAt!))) {
            SimpleLogger.log('Updating local item from Firestore (cloud is newer): ${firestoreItem.id}', tag: "StockpileRepo.sync");
            await db.update(
              'stockpile_items',
              firestoreItem.copyWith(syncStatus: 'synced').toMap(forFirestore: false),
              where: 'id = ?',
              whereArgs: [firestoreItem.id],
            );
          }
        }
        // If rawLocalItem.syncStatus == 'pending_sync', it means it was updated locally.
        // Step 3 should have pushed this to Firestore. If Firestore's version is somehow newer
        // despite this, it implies a complex conflict. For now, we assume local 'pending_sync'
        // was authoritative and pushed. If Firestore has an even newer version after that push,
        // that would be an edge case (e.g. another device synced in between).
        // The current logic: local 'pending_sync' is pushed, then Firestore is pulled.
        // If Firestore's `updatedAt` is newer than the `updatedAt` of the *just pushed* local item,
        // it would be overwritten. This is generally okay if `updatedAt` is managed well.
      }

      // 6. Clean up: Remove any items from local DB that are no longer in Firestore
      //    and are not 'pending_sync' or 'pending_delete' locally.
      //    This handles cases where an item was deleted from Firestore by another client.
      SimpleLogger.log('Performing final local DB cleanup based on Firestore state...', tag: "StockpileRepo.sync");
      final allLocalItemsAfterSync = (await db.query('stockpile_items', where: 'userId = ?', whereArgs: [_userId])).map((json) => StockpileItem.fromMap(json)).toList();
      for (final localItemToCheck in allLocalItemsAfterSync) {
        if (localItemToCheck.id == null) continue;
        // If local item is 'synced' but not found in the latest Firestore fetch, delete it locally.
        if (localItemToCheck.syncStatus == 'synced' && !firestoreItems.any((fsItem) => fsItem.id == localItemToCheck.id)) {
          SimpleLogger.log('Item ${localItemToCheck.id} is synced locally but not in Firestore. Deleting locally.', tag: "StockpileRepo.sync");
          await db.delete('stockpile_items', where: 'id = ?', whereArgs: [localItemToCheck.id]);
        }
      }

      _notifyListeners(); // Notify UI of potential changes from sync
      SimpleLogger.log('Sync with Firestore completed.', tag: "StockpileRepo.sync");
      _syncStatusController.add(SyncCompleted(DateTime.now()));
    }

    // initial data load
    Future<void> performInitialDataLoad() async {
      if (_userId == null) return;
  
      // check local items
      final localItems = await readAllItems();
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;
      bool dataChanged = false;

      if (localItems.isEmpty && isOnline) {
        SimpleLogger.log('Local DB is empty and online, performing initial sync from Firestore...', tag: "StockpileRepo.initLoad");
        // fetch from firestore, populate local
        try {
          final snapshot = await _db.collection('users').doc(_userId).collection('stockpileItems').get();
          final firestoreItems = snapshot.docs.map((doc) => StockpileItem.fromMap(doc.data(), doc.id)).toList();
          
          if (firestoreItems.isNotEmpty) {
            final db = await instance.database;
            for (final item in firestoreItems) {
              await db.insert('stockpile_items', item.copyWith(syncStatus: 'synced').toMap(forFirestore: false));
            }
            SimpleLogger.log('Initial sync from Firestore completed. ${firestoreItems.length} items loaded.', tag: "StockpileRepo.initLoad");
            dataChanged = true;
          }
        } catch (e) {
          SimpleLogger.log('Error during initial sync from Firestore: $e', tag: "StockpileRepo.initLoad");
        }
      } else if (localItems.isNotEmpty) {
        SimpleLogger.log('Local DB has data. Will attempt regular sync if needed.', tag: "StockpileRepo.initLoad");
        // await syncWithFirestore(); // regular sync if online - syncWithFirestore will be called by performInitialDataLoad if needed
        // Let performInitialDataLoad manage its own sync status reporting if it calls syncWithFirestore directly
        // For now, syncWithFirestore is the main reporter.
        // sync might change data
        dataChanged = true;
        // If syncWithFirestore is called within here, it will emit its own events.
        // If we want performInitialDataLoad to have its own "initial sync" events, that's a separate addition.
        // For now, we assume syncWithFirestore is the primary source of sync events.
        await syncWithFirestore();
      } else {
        SimpleLogger.log('Local DB is empty and offline. No initial sync possible.', tag: "StockpileRepo.initLoad");
      }
      
      if (dataChanged) {
        _notifyListeners(); // notify data changed
      }
    }
  
    Future close() async {
      final db = _database; // use local static
      if (db != null && db.isOpen) {
        await db.close();
      }
      _database = null;
      if (!_updateNotifierController.isClosed) {
        await _updateNotifierController.close();
      }
      if (!_syncStatusController.isClosed) {
        await _syncStatusController.close();
      }
    }
}