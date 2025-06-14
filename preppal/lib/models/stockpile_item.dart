import 'package:cloud_firestore/cloud_firestore.dart';

class StockpileItem {
  final String? id; // ID
  final String name;
  int quantity;
  final String category;
  String? unit; // e.g., "kg", "L"
  DateTime? expiryDate;
  String? notes;
  String? reminderPreference; // reminder
  final DateTime addedDate; // creation date
  DateTime? updatedAt; // for sync
  final String userId;
  double? unitVolumeLiters; // liters per item
  double? totalDaysOfSupplyPerItem; // supply days
  String? syncStatus; // sync status

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
    this.updatedAt,
    required this.userId,
    this.unitVolumeLiters,
    this.totalDaysOfSupplyPerItem,
    this.syncStatus,
  });

  // create from map
  factory StockpileItem.fromMap(Map<String, dynamic> map, [String? idFromDocument]) {
    return StockpileItem(
      id: idFromDocument ?? map['id'] as String?,
      name: map['name'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      category: map['category'] as String? ?? 'Uncategorized',
      unit: map['unit'] as String?,
      expiryDate: map['expiryDate'] == null
          ? null
          : (map['expiryDate'] is Timestamp
              ? (map['expiryDate'] as Timestamp).toDate()
              : DateTime.tryParse(map['expiryDate'] as String? ?? '')),
      notes: map['notes'] as String?,
      reminderPreference: map['reminderPreference'] as String?,
      addedDate: map['addedDate'] == null
          ? DateTime.now()
          : (map['addedDate'] is Timestamp
              ? (map['addedDate'] as Timestamp).toDate()
              : DateTime.tryParse(map['addedDate'] as String? ?? '') ?? DateTime.now()),
      updatedAt: map['updatedAt'] == null
          ? null
          : (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'] as String? ?? '')),
      userId: map['userId'] as String? ?? '',
      unitVolumeLiters: (map['unitVolumeLiters'] as num?)?.toDouble(),
      totalDaysOfSupplyPerItem: (map['totalDaysOfSupplyPerItem'] as num?)?.toDouble(),
      syncStatus: map['syncStatus'] as String?,
    );
  }

  // convert to map
  Map<String, dynamic> toMap({bool forFirestore = true}) {
    return {
      // ID not for Firestore auto-ID, but for SQLite.
      if (!forFirestore && id != null) 'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'unit': unit,
      'expiryDate': forFirestore
          ? (expiryDate != null ? Timestamp.fromDate(expiryDate!) : null)
          : expiryDate?.toIso8601String(),
      'notes': notes,
      'reminderPreference': reminderPreference,
      'addedDate': forFirestore
          ? Timestamp.fromDate(addedDate)
          : addedDate.toIso8601String(),
      'updatedAt': updatedAt == null
          ? null
          : (forFirestore ? Timestamp.fromDate(updatedAt!) : updatedAt!.toIso8601String()),
      'userId': userId,
      'unitVolumeLiters': unitVolumeLiters,
      'totalDaysOfSupplyPerItem': totalDaysOfSupplyPerItem,
      'syncStatus': syncStatus,
    };
  }

  // create copy with overrides
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
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
    String? userId,
    double? unitVolumeLiters,
    bool clearUnitVolumeLiters = false,
    double? totalDaysOfSupplyPerItem,
    bool clearTotalDaysOfSupplyPerItem = false,
    String? syncStatus,
    bool clearSyncStatus = false,
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
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      userId: userId ?? this.userId,
      unitVolumeLiters: clearUnitVolumeLiters ? null : (unitVolumeLiters ?? this.unitVolumeLiters),
      totalDaysOfSupplyPerItem: clearTotalDaysOfSupplyPerItem ? null : (totalDaysOfSupplyPerItem ?? this.totalDaysOfSupplyPerItem),
      syncStatus: clearSyncStatus ? null : (syncStatus ?? this.syncStatus),
    );
  }
}