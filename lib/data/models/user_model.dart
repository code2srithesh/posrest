class UserModel {
  final String id;
  final String name;
  final String email;
  final String password; // Hashed in production
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? deletedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'waiter',
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      syncStatus: json['syncStatus'] ?? 'pending',
      deletedAt: json['deletedAt'] is String
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'role': role,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'syncStatus': syncStatus,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      isActive: (map['isActive'] ?? 0) == 1,
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

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? deletedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
