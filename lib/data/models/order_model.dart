// Order item status enum
enum OrderItemStatus { pending, preparing, ready, served, cancelled }

class OrderItemModel {
  final String id;
  final String orderId;
  final String menuItemId;
  final String itemName;
  final double basePrice;
  final int quantity;
  final String? notes; // e.g., "no onion, less spicy"
  final List<String> selectedModifierIds;
  final double modifierPrice;
  final double totalPrice;
  final OrderItemStatus status; // NEW: Track item status
  final int estimatedPrepTime; // NEW: In minutes
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt; // NEW: When item was ready
  final String syncStatus;
  final DateTime? deletedAt;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.itemName,
    required this.basePrice,
    required this.quantity,
    this.notes,
    this.selectedModifierIds = const [],
    required this.modifierPrice,
    required this.totalPrice,
    this.status = OrderItemStatus.pending,
    this.estimatedPrepTime = 15,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    required this.syncStatus,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'menuItemId': menuItemId,
      'itemName': itemName,
      'basePrice': basePrice,
      'quantity': quantity,
      'notes': notes,
      'selectedModifierIds': selectedModifierIds.join(','),
      'modifierPrice': modifierPrice,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'estimatedPrepTime': estimatedPrepTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  static OrderItemModel fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      menuItemId: map['menuItemId'] ?? '',
      itemName: map['itemName'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      notes: map['notes'],
      selectedModifierIds:
          (map['selectedModifierIds'] as String?)?.split(',') ?? [],
      modifierPrice: (map['modifierPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: OrderItemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'pending'),
        orElse: () => OrderItemStatus.pending,
      ),
      estimatedPrepTime: map['estimatedPrepTime'] ?? 15,
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
    );
  }

  OrderItemModel copyWith({
    String? id,
    String? orderId,
    String? menuItemId,
    String? itemName,
    double? basePrice,
    int? quantity,
    String? notes,
    List<String>? selectedModifierIds,
    double? modifierPrice,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? deletedAt,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      itemName: itemName ?? this.itemName,
      basePrice: basePrice ?? this.basePrice,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      selectedModifierIds: selectedModifierIds ?? this.selectedModifierIds,
      modifierPrice: modifierPrice ?? this.modifierPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class OrderModel {
  final String id;
  final String tableId;
  final int tableNumber;
  final String orderType; // 'dine-in', 'takeaway', 'delivery'
  final String status; // open, preparing, served, paid, cancelled
  final String? waiterName;
  final String? notes;
  final List<OrderItemModel> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? deletedAt;

  OrderModel({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.orderType,
    required this.status,
    this.waiterName,
    this.notes,
    this.items = const [],
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'orderType': orderType,
      'status': status,
      'waiterName': waiterName,
      'notes': notes,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  static OrderModel fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      tableId: map['tableId'] ?? '',
      tableNumber: map['tableNumber'] ?? 0,
      orderType: map['orderType'] ?? 'dine-in',
      status: map['status'] ?? 'open',
      waiterName: map['waiterName'],
      notes: map['notes'],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
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
    );
  }

  OrderModel copyWith({
    String? id,
    String? tableId,
    int? tableNumber,
    String? orderType,
    String? status,
    String? waiterName,
    String? notes,
    List<OrderItemModel>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? deletedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      waiterName: waiterName ?? this.waiterName,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() =>
      'Order #$id - Table $tableNumber - ₹${totalAmount.toStringAsFixed(2)}';
}
