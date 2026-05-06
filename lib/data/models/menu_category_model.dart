class MenuCategoryModel {
  final String id;
  final String name;
  final String? description;
  final int displayOrder;
  final bool isActive;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? deletedAt;

  MenuCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
    required this.isActive,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'displayOrder': displayOrder,
      'isActive': isActive ? 1 : 0,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  static MenuCategoryModel fromMap(Map<String, dynamic> map) {
    return MenuCategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      displayOrder: map['displayOrder'] ?? 0,
      isActive: (map['isActive'] ?? 1) == 1,
      imageUrl: map['imageUrl'],
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

  MenuCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? displayOrder,
    bool? isActive,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? deletedAt,
  }) {
    return MenuCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
