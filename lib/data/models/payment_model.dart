class PaymentModel {
  final String id;
  final String orderId;
  final double amount;
  final String paymentMethod; // cash, card, upi, online
  final String status; // pending, completed, failed
  final String? transactionId;
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? deletedAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.reference,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'reference': reference,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  static PaymentModel fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      status: map['status'] ?? 'pending',
      transactionId: map['transactionId'],
      reference: map['reference'],
      notes: map['notes'],
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

  PaymentModel copyWith({
    String? id,
    String? orderId,
    double? amount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    String? reference,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? deletedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() =>
      'Payment #$id - ₹${amount.toStringAsFixed(2)} - $paymentMethod - $status';
}
