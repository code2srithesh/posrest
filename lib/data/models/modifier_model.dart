class ModifierModel {
  final String id;
  final String name;
  final String type; // e.g., 'extra', 'spice_level', 'size'
  final double price;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? deletedAt;

  ModifierModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  static ModifierModel fromMap(Map<String, dynamic> map) {
    return ModifierModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      isActive: (map['isActive'] ?? 1) == 1,
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

  ModifierModel copyWith({
    String? id,
    String? name,
    String? type,
    double? price,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? deletedAt,
  }) {
    return ModifierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() => '$name (+₹${price.toStringAsFixed(2)})';
}
