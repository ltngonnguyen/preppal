import 'package:cloud_firestore/cloud_firestore.dart';

class StockpileItem {
  final String? id; // Firestore document ID.
  final String name;
  int quantity;
  final String category;
  String? unit; // e.g., "kg", "L", "pcs".
  DateTime? expiryDate;
  String? notes;
  String? reminderPreference; // Stores user's reminder choice (e.g., "1_week").
  final DateTime addedDate;
  final String userId;

  StockpileItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.unit,
    this.expiryDate,
    this.notes,
    this.reminderPreference,
    required this.addedDate,
    required this.userId,
  });

  // Creates a StockpileItem instance from a Firestore document snapshot.
  factory StockpileItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    final data = snapshot.data();
    return StockpileItem(
      id: id,
      name: data?['name'] ?? '',
      quantity: data?['quantity'] ?? 0,
      category: data?['category'] ?? 'Uncategorized',
      unit: data?['unit'],
      expiryDate: (data?['expiryDate'] as Timestamp?)?.toDate(),
      notes: data?['notes'],
      reminderPreference: data?['reminderPreference'],
      addedDate: (data?['addedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data?['userId'] ?? '',
    );
  }

  // Converts this StockpileItem instance to a Map for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
      'unit': unit,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'notes': notes,
      'reminderPreference': reminderPreference,
      'addedDate': Timestamp.fromDate(addedDate),
      'userId': userId,
    };
  }

  // Creates a new StockpileItem instance with optional field overrides.
  StockpileItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? category,
    String? unit,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
    String? notes,
    String? reminderPreference,
    bool clearNotes = false,
    DateTime? addedDate,
    String? userId,
  }) {
    return StockpileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
      notes: clearNotes ? null : (notes ?? this.notes),
      reminderPreference: reminderPreference ?? this.reminderPreference,
      addedDate: addedDate ?? this.addedDate,
      userId: userId ?? this.userId,
    );
  }
}