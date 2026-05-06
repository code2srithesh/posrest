class TableModel {
  final String id;
  final int tableNumber;
  final int capacity;
  final String status; // free, occupied, reserved
  final int occupiedSeats;
  final String? currentOrderId;
  final List<String> mergedTableIds; // For merged tables
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? deletedAt;
  final String? notes;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    required this.occupiedSeats,
    this.currentOrderId,
    this.mergedTableIds = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.deletedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'status': status,
      'occupiedSeats': occupiedSeats,
      'currentOrderId': currentOrderId,
      'mergedTableIds': mergedTableIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'deletedAt': deletedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  static TableModel fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id'] ?? '',
      tableNumber: map['tableNumber'] ?? 0,
      capacity: map['capacity'] ?? 2,
      status: map['status'] ?? 'free',
      occupiedSeats: map['occupiedSeats'] ?? 0,
      currentOrderId: map['currentOrderId'],
      mergedTableIds: (map['mergedTableIds'] as String?)?.split(',') ?? [],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      syncStatus: map['syncStatus'] ?? 'pending',
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'])
          : null,
      notes: map['notes'],
    );
  }

  TableModel copyWith({
    String? id,
    int? tableNumber,
    int? capacity,
    String? status,
    int? occupiedSeats,
    String? currentOrderId,
    List<String>? mergedTableIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? deletedAt,
    String? notes,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      occupiedSeats: occupiedSeats ?? this.occupiedSeats,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      mergedTableIds: mergedTableIds ?? this.mergedTableIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'Table ${tableNumber} (Status: $status)';
}
