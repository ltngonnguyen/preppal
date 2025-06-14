import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async'; // for streams
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stockpile_item.dart';
import './firestore_service.dart'; // for sync stuff

class StockpileRepository {
  static final StockpileRepository instance = StockpileRepository._init();
  static Database? _database;
  // for updates
  final _updateNotifierController = StreamController<void>.broadcast();
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
  
      // on stream cancel
      controller.onCancel = () {
        print("StockpileRepository: Stream for filter '$filter' cancelled.");
        subscription.cancel();
        if (!controller.isClosed) {
          controller.close();
        }
      };
  
      return controller.stream;
    }
  
    // notify listeners
    Future<void> _notifyListeners() async {
      print("StockpileRepository: Notifying listeners of data change.");
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
  
    // delete item
    Future<int> delete(String id) async {
      if (_userId == null) return 0;
      final db = await instance.database;
      
      final itemToDelete = await readItem(id); // get item before delete
      
      final result = await db.delete(
        'stockpile_items',
        where: 'id = ? AND userId = ?',
        whereArgs: [id, _userId],
      );
  
      if (result > 0) {
        _notifyListeners(); // notify listeners
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
        // need to store pending deletions if offline
        return;
      }
       if (_userId == null) return;
  
      try {
        print('Deleting item from Firestore: ${itemToDelete.id}');
        await _firestoreService.deleteStockpileItem(itemToDelete.id!);
        print('Item ${itemToDelete.id} deleted from Firestore.');
      } catch (e) {
        print('Error deleting item ${itemToDelete.id} from Firestore: $e');
        // retry or leave pending
      }
    }
  
    // TODO: sync logic here
  
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
  
      // 1. get local pending items
      final db = await instance.database;
      final localPendingItems = (await db.query(
        'stockpile_items',
        where: 'syncStatus = ? AND userId = ?',
        whereArgs: ['pending_sync', _userId],
      )).map((json) => StockpileItem.fromMap(json)).toList();
  
      // 2. push local changes to Firestore
      for (final localItem in localPendingItems) {
        try {
          // check if item has ID
          if (localItem.id == null) {
              print('Error: Local item ${localItem.name} has no ID, cannot sync.');
              continue;
          }
  
          // check for deletion, add/update based on existence
          DocumentSnapshot firestoreDoc;
          try {
            firestoreDoc = await _db.collection('users').doc(_userId).collection('stockpileItems').doc(localItem.id).get();
          } catch (e) {
            // handle errors
            print('Error fetching Firestore document ${localItem.id} for sync: $e');
            continue; // skip item
          }
  
          final itemToSync = localItem.copyWith(updatedAt: DateTime.now()); // fresh timestamp
  
          if (firestoreDoc.exists) {
            print('Updating item in Firestore: ${localItem.id}');
            // update item
            await _firestoreService.updateStockpileItem(itemToSync);
          } else {
            print('Adding item to Firestore: ${localItem.id}');
            // add item
            await _db.collection('users').doc(_userId).collection('stockpileItems').doc(localItem.id).set(itemToSync.toMap(forFirestore: true));
          }
          // }
  
          // mark as synced locally
          await db.update(
            'stockpile_items',
            {'syncStatus': 'synced', 'updatedAt': itemToSync.updatedAt?.toIso8601String()},
            where: 'id = ?',
            whereArgs: [localItem.id],
          );
        } catch (e) {
          print('Error syncing item ${localItem.id} to Firestore: $e');
          // retry or leave pending
        }
      }
      
      // sync pending deletions (placeholder)
      // await _syncPendingDeletions(); // placeholder
  
  
      // 3. fetch all items from Firestore
      print('Fetching all items from Firestore for comparison...');
      List<StockpileItem> firestoreItems = [];
      try {
        final snapshot = await _db.collection('users').doc(_userId).collection('stockpileItems').get();
        final firestoreItems = snapshot.docs.map((doc) => StockpileItem.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        print('Error fetching items from Firestore: $e');
        return; // stop sync if no data
      }
      
      // 4. compare/update local DB
      for (final firestoreItem in firestoreItems) {
        final localItem = await readItem(firestoreItem.id!);
        if (localItem == null) {
          // item in firestore but not local, add to local
          print('Adding Firestore item to local DB: ${firestoreItem.id}');
          await db.insert('stockpile_items', firestoreItem.copyWith(syncStatus: 'synced').toMap(forFirestore: false));
        } else {
          // item in both. conflict: local data precedence if newer
          if (localItem.syncStatus == 'synced' &&
              firestoreItem.updatedAt != null &&
              (localItem.updatedAt == null || firestoreItem.updatedAt!.isAfter(localItem.updatedAt!))) {
            // firestore item newer, local synced
            print('Updating local item from Firestore: ${firestoreItem.id}');
            await db.update(
              'stockpile_items',
              firestoreItem.copyWith(syncStatus: 'synced').toMap(forFirestore: false),
              where: 'id = ?',
              whereArgs: [firestoreItem.id],
            );
          }
          // if local newer, should be pending
        }
      }
      print('Sync with Firestore completed.');
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
        print('Local DB is empty and online, performing initial sync from Firestore...');
        // fetch from firestore, populate local
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
        await syncWithFirestore(); // regular sync if online
        // sync might change data
        dataChanged = true;
      } else {
        print('Local DB is empty and offline. No initial sync possible.');
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
    }
}