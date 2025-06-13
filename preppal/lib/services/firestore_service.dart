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
          fromFirestore: (snapshots, _) => StockpileItem.fromFirestore(snapshots, snapshots.id),
          toFirestore: (item, _) => item.toJson(),
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

  // Add a new stockpile item
  Future<void> addStockpileItem(StockpileItem item) async {
    if (_userId == null) throw Exception("User not logged in.");
    // Ensure the item's userId is set correctly
    final itemWithUserId = item.copyWith(userId: _userId);
    await _stockpileCollection().add(itemWithUserId);
  }

  // Update an existing stockpile item
  Future<void> updateStockpileItem(StockpileItem item) async {
    if (_userId == null || item.id == null) throw Exception("User not logged in or item ID missing.");
    await _stockpileCollection().doc(item.id).update(item.toJson());
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