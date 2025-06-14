import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stockpile_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's ID
  String? get _userId => _auth.currentUser?.uid;

  // Collection reference for stockpile items, specific to the current user
  CollectionReference<StockpileItem> _stockpileCollection() {
    if (_userId == null) {
      throw Exception("User not logged in. Cannot access stockpile.");
    }
    return _db.collection('users').doc(_userId).collection('stockpileItems').withConverter<StockpileItem>(
          fromFirestore: (snapshot, _) => StockpileItem.fromMap(snapshot.data()!, snapshot.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  // Stream of stockpile items for the current user
  Stream<List<StockpileItem>> getStockpileItems() {
    if (_userId == null) return Stream.value([]); // Return empty stream if no user
    return _stockpileCollection()
        .orderBy('addedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Add or update a stockpile item. If item.id is null, Firestore generates an ID.
  // If item.id is provided, it will set the document with that ID (upsert).
  Future<void> addStockpileItem(StockpileItem item) async {
    if (_userId == null) throw Exception("User not logged in.");
    
    final itemWithUserId = item.copyWith(userId: _userId);

    if (itemWithUserId.id != null && itemWithUserId.id!.isNotEmpty) {
      // If ID is provided, use it to set the document.
      // This is useful for syncing items that already have an ID from the local DB.
      await _stockpileCollection().doc(itemWithUserId.id).set(itemWithUserId);
    } else {
      // If no ID, let Firestore generate one.
      await _stockpileCollection().add(itemWithUserId);
    }
  }

  // Update an existing stockpile item
  Future<void> updateStockpileItem(StockpileItem item) async {
    if (_userId == null || item.id == null) throw Exception("User not logged in or item ID missing.");
    await _stockpileCollection().doc(item.id).update(item.toMap());
  }

  // Delete a stockpile item
  Future<void> deleteStockpileItem(String itemId) async {
    if (_userId == null) throw Exception("User not logged in.");
    await _stockpileCollection().doc(itemId).delete();
  }

  // Example: Get a single item (if needed, though stream usually covers this)
  Future<StockpileItem?> getStockpileItem(String itemId) async {
    if (_userId == null) return null;
    final doc = await _stockpileCollection().doc(itemId).get();
    return doc.exists ? doc.data() : null;
  }
}