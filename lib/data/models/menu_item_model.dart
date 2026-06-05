class MenuItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final bool isAvailable;
  final bool isVegetarian;
  final bool isSpicy;
  final String? imageUrl;
  final int displayOrder;
  final List<String> modifierIds; // IDs of modifiers that apply
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? deletedAt;
  final int availableStock;

  MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.isAvailable,
    required this.isVegetarian,
    required this.isSpicy,
    this.imageUrl,
    required this.displayOrder,
    this.modifierIds = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.deletedAt,
    this.availableStock = 50,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'isAvailable': isAvailable ? 1 : 0,
      'isVegetarian': isVegetarian ? 1 : 0,
      'isSpicy': isSpicy ? 1 : 0,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'modifierIds': modifierIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'deletedAt': deletedAt?.toIso8601String(),
      'availableStock': availableStock,
    };
  }

  static MenuItemModel fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] ?? '',
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      price: (map['price'] ?? 0.0).toDouble(),
      isAvailable: (map['isAvailable'] ?? 1) == 1,
      isVegetarian: (map['isVegetarian'] ?? 0) == 1,
      isSpicy: (map['isSpicy'] ?? 0) == 1,
      imageUrl: map['imageUrl'],
      displayOrder: map['displayOrder'] ?? 0,
      modifierIds: (map['modifierIds'] as String?)?.split(',') ?? [],
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
      availableStock: map['availableStock'] ?? 50,
    );
  }

  MenuItemModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    bool? isAvailable,
    bool? isVegetarian,
    bool? isSpicy,
    String? imageUrl,
    int? displayOrder,
    List<String>? modifierIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? deletedAt,
    int? availableStock,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isSpicy: isSpicy ?? this.isSpicy,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      modifierIds: modifierIds ?? this.modifierIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      availableStock: availableStock ?? this.availableStock,
    );
  }

  @override
  String toString() => '$name - ₹${price.toStringAsFixed(2)}';
}
