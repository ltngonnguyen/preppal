import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stockpile_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID.
  String? get _userId => _auth.currentUser?.uid;

  // Stockpile items collection ref for current user.
  CollectionReference<StockpileItem> _stockpileCollection() {
    if (_userId == null) {
      throw Exception("User not logged in. Cannot access stockpile.");
    }
    return _db.collection('users').doc(_userId).collection('stockpileItems').withConverter<StockpileItem>(
          fromFirestore: (snapshot, _) => StockpileItem.fromMap(snapshot.data()!, snapshot.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  // Stream of stockpile items for current user.
  Stream<List<StockpileItem>> getStockpileItems() {
    if (_userId == null) return Stream.value([]); // Return empty stream if no user
    return _stockpileCollection()
        .orderBy('addedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Add/update stockpile item.
  Future<void> addStockpileItem(StockpileItem item) async {
    if (_userId == null) throw Exception("User not logged in.");
    
    final itemWithUserId = item.copyWith(userId: _userId);

    if (itemWithUserId.id != null && itemWithUserId.id!.isNotEmpty) {
      // Useful for syncing items with local DB ID.
      await _stockpileCollection().doc(itemWithUserId.id).set(itemWithUserId);
    } else {
      // No ID, Firestore generates.
      await _stockpileCollection().add(itemWithUserId);
    }
  }

  // Update existing stockpile item.
  Future<void> updateStockpileItem(StockpileItem item) async {
    if (_userId == null || item.id == null) throw Exception("User not logged in or item ID missing.");
    await _stockpileCollection().doc(item.id).update(item.toMap());
  }

  // Delete stockpile item.
  Future<void> deleteStockpileItem(String itemId) async {
    if (_userId == null) throw Exception("User not logged in.");
    await _stockpileCollection().doc(itemId).delete();
  }

  // Example: Get single item (stream usually covers).
  Future<StockpileItem?> getStockpileItem(String itemId) async {
    if (_userId == null) return null;
    final doc = await _stockpileCollection().doc(itemId).get();
    return doc.exists ? doc.data() : null;
  }
}