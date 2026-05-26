import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/table_model.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../models/modifier_model.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';

class DatabaseHelper {
  static const String dbName = 'posrest.db';
  static const int dbVersion = 2;

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use in-memory database for web platform or unit/integration testing on host VM
    if (kIsWeb) {
      return _MockDatabase._instance;
    }
    
    // Only check Platform.environment on native platforms where dart:io Platform is supported
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      return _MockDatabase._instance;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        isActive INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        deletedAt TEXT
      )
    ''');

    // Tables table
    await db.execute('''
      CREATE TABLE tables (
        id TEXT PRIMARY KEY,
        tableNumber INTEGER NOT NULL UNIQUE,
        capacity INTEGER NOT NULL,
        status TEXT NOT NULL,
        occupiedSeats INTEGER NOT NULL,
        currentOrderId TEXT,
        mergedTableIds TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        deletedAt TEXT,
        notes TEXT
      )
    ''');

    // Menu Categories table
    await db.execute('''
      CREATE TABLE menu_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        displayOrder INTEGER NOT NULL,
        isActive INTEGER NOT NULL,
        imageUrl TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        deletedAt TEXT
      )
    ''');

    // Menu Items table
    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        isAvailable INTEGER NOT NULL,
        isVegetarian INTEGER NOT NULL,
        isSpicy INTEGER NOT NULL,
        imageUrl TEXT,
        displayOrder INTEGER NOT NULL,
        modifierIds TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        deletedAt TEXT,
        FOREIGN KEY (categoryId) REFERENCES menu_categories(id)
      )
    ''');

    // Modifiers table
    await db.execute('''
      CREATE TABLE modifiers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        price REAL NOT NULL,
        isActive INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        deletedAt TEXT
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        tableId TEXT NOT NULL,
        tableNumber INTEGER NOT NULL,
        orderType TEXT NOT NULL,
        status TEXT NOT NULL,
        waiterName TEXT,
        notes TEXT,
        subtotal REAL NOT NULL,
        taxAmount REAL NOT NULL,
        discountAmount REAL NOT NULL,
        totalAmount REAL NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        deletedAt TEXT,
        FOREIGN KEY (tableId) REFERENCES tables(id)
      )
    ''');

    // Order Items table
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        menuItemId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        basePrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        notes TEXT,
        selectedModifierIds TEXT,
        modifierPrice REAL NOT NULL,
        totalPrice REAL NOT NULL,
        status TEXT NOT NULL,
        estimatedPrepTime INTEGER NOT NULL,
        completedAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        deletedAt TEXT,
        FOREIGN KEY (orderId) REFERENCES orders(id),
        FOREIGN KEY (menuItemId) REFERENCES menu_items(id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        amount REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        status TEXT NOT NULL,
        transactionId TEXT,
        reference TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        deletedAt TEXT,
        FOREIGN KEY (orderId) REFERENCES orders(id)
      )
    ''');

    // Sync Queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        syncedAt TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_orders_tableId ON orders(tableId)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
    await db.execute(
      'CREATE INDEX idx_orderItems_orderId ON order_items(orderId)',
    );
    await db.execute(
      'CREATE INDEX idx_menuItems_categoryId ON menu_items(categoryId)',
    );
    await db.execute('CREATE INDEX idx_payments_orderId ON payments(orderId)');
    await db.execute(
      'CREATE INDEX idx_syncQueue_entityType ON sync_queue(entityType)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE order_items ADD COLUMN status TEXT NOT NULL DEFAULT "pending"');
      await db.execute('ALTER TABLE order_items ADD COLUMN estimatedPrepTime INTEGER NOT NULL DEFAULT 15');
      await db.execute('ALTER TABLE order_items ADD COLUMN completedAt TEXT');
    }
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clear all data (for testing/reset)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('order_items');
    await db.delete('payments');
    await db.delete('orders');
    await db.delete('menu_items');
    await db.delete('modifiers');
    await db.delete('menu_categories');
    await db.delete('tables');
    await db.delete('users');
    await db.delete('sync_queue');
  }

  // ==================== USER OPERATIONS ====================
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser(String id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', where: 'deletedAt IS NULL');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== TABLE OPERATIONS ====================
  Future<int> insertTable(TableModel table) async {
    final db = await database;
    return await db.insert('tables', table.toMap());
  }

  Future<TableModel?> getTable(String id) async {
    final db = await database;
    final result = await db.query('tables', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return TableModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<TableModel>> getAllTables() async {
    final db = await database;
    final result = await db.query(
      'tables',
      where: 'deletedAt IS NULL',
      orderBy: 'tableNumber',
    );
    return result.map((map) => TableModel.fromMap(map)).toList();
  }

  Future<TableModel?> getTableByNumber(int tableNumber) async {
    final db = await database;
    final result = await db.query(
      'tables',
      where: 'tableNumber = ? AND deletedAt IS NULL',
      whereArgs: [tableNumber],
    );
    if (result.isNotEmpty) {
      return TableModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateTable(TableModel table) async {
    final db = await database;
    return await db.update(
      'tables',
      table.toMap(),
      where: 'id = ?',
      whereArgs: [table.id],
    );
  }

  Future<int> deleteTable(String id) async {
    final db = await database;
    return await db.delete('tables', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MENU CATEGORY OPERATIONS ====================
  Future<int> insertMenuCategory(MenuCategoryModel category) async {
    final db = await database;
    return await db.insert('menu_categories', category.toMap());
  }

  Future<List<MenuCategoryModel>> getAllMenuCategories() async {
    final db = await database;
    final result = await db.query(
      'menu_categories',
      where: 'deletedAt IS NULL',
      orderBy: 'displayOrder',
    );
    return result.map((map) => MenuCategoryModel.fromMap(map)).toList();
  }

  Future<int> updateMenuCategory(MenuCategoryModel category) async {
    final db = await database;
    return await db.update(
      'menu_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // ==================== MENU ITEM OPERATIONS ====================
  Future<int> insertMenuItem(MenuItemModel item) async {
    final db = await database;
    return await db.insert('menu_items', item.toMap());
  }

  Future<MenuItemModel?> getMenuItem(String id) async {
    final db = await database;
    final result = await db.query(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return MenuItemModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId) async {
    final db = await database;
    final result = await db.query(
      'menu_items',
      where: 'categoryId = ? AND deletedAt IS NULL AND isAvailable = 1',
      whereArgs: [categoryId],
      orderBy: 'displayOrder',
    );
    return result.map((map) => MenuItemModel.fromMap(map)).toList();
  }

  Future<int> updateMenuItem(MenuItemModel item) async {
    final db = await database;
    return await db.update(
      'menu_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // ==================== MODIFIER OPERATIONS ====================
  Future<int> insertModifier(ModifierModel modifier) async {
    final db = await database;
    return await db.insert('modifiers', modifier.toMap());
  }

  Future<ModifierModel?> getModifier(String id) async {
    final db = await database;
    final result = await db.query(
      'modifiers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ModifierModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<ModifierModel>> getModifiersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final result = await db.query(
      'modifiers',
      where: 'id IN ($placeholders) AND deletedAt IS NULL',
      whereArgs: ids,
    );
    return result.map((map) => ModifierModel.fromMap(map)).toList();
  }

  // ==================== ORDER OPERATIONS ====================
  Future<int> insertOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<OrderModel?> getOrder(String id) async {
    final db = await database;
    final result = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return OrderModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<OrderModel>> getAllOrders() async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'deletedAt IS NULL',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => OrderModel.fromMap(map)).toList();
  }

  Future<List<OrderModel>> getOrdersByTableId(String tableId) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'tableId = ? AND deletedAt IS NULL',
      whereArgs: [tableId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => OrderModel.fromMap(map)).toList();
  }

  Future<List<OrderModel>> getOpenOrders() async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'status != ? AND status != ? AND deletedAt IS NULL',
      whereArgs: ['paid', 'cancelled'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => OrderModel.fromMap(map)).toList();
  }

  Future<int> updateOrder(OrderModel order) async {
    final db = await database;
    return await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  // ==================== ORDER ITEM OPERATIONS ====================
  Future<int> insertOrderItem(OrderItemModel item) async {
    final db = await database;
    return await db.insert('order_items', item.toMap());
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    final db = await database;
    final result = await db.query(
      'order_items',
      where: 'orderId = ? AND deletedAt IS NULL',
      whereArgs: [orderId],
    );
    return result.map((map) => OrderItemModel.fromMap(map)).toList();
  }

  Future<int> deleteOrderItem(String id) async {
    final db = await database;
    return await db.delete('order_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteOrderItemsByOrderId(String orderId) async {
    final db = await database;
    return await db.delete(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }

  // ==================== PAYMENT OPERATIONS ====================
  Future<int> insertPayment(PaymentModel payment) async {
    final db = await database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<PaymentModel>> getPaymentsByOrderId(String orderId) async {
    final db = await database;
    final result = await db.query(
      'payments',
      where: 'orderId = ? AND deletedAt IS NULL',
      whereArgs: [orderId],
    );
    return result.map((map) => PaymentModel.fromMap(map)).toList();
  }

  Future<int> updatePayment(PaymentModel payment) async {
    final db = await database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }
}

// ==================== MOCK DATABASE FOR WEB ====================
class _MockDatabase implements Database {
  static final _MockDatabase _instance = _MockDatabase._internal();
  final Map<String, List<Map<String, Object?>>> _store = {};

  _MockDatabase._internal() {
    _store['users'] = [];
    _store['tables'] = [];
    _store['menu_categories'] = [];
    _store['menu_items'] = [];
    _store['modifiers'] = [];
    _store['orders'] = [];
    _store['order_items'] = [];
    _store['payments'] = [];
    _store['sync_queue'] = [];
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    _store[table] ??= [];
    _store[table]!.add(Map.from(values));
    return _store[table]!.length;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    _store[table] ??= [];
    var res = List<Map<String, Object?>>.from(_store[table]!);
    if (where != null && whereArgs != null)
      res = _filter(res, where, whereArgs);
    if (orderBy != null) res = _sort(res, orderBy);
    if (offset != null) res = res.skip(offset).toList();
    if (limit != null) res = res.take(limit).toList();
    return res;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    _store[table] ??= [];
    final rows = where == null
        ? _store[table]!
        : _filter(_store[table]!, where, whereArgs ?? []);
    for (var r in rows) {
      r.addAll(values);
    }
    return rows.length;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    _store[table] ??= [];
    if (where == null) {
      final c = _store[table]!.length;
      _store[table]!.clear();
      return c;
    }
    final d = _filter(_store[table]!, where, whereArgs ?? []);
    _store[table]!.removeWhere((r) => d.contains(r));
    return d.length;
  }

  List<Map<String, Object?>> _filter(
    List<Map<String, Object?>> d,
    String w,
    List<Object?> a,
  ) {
    return d.where((r) {
      // Respect deletedAt IS NULL constraints
      if (w.contains('deletedAt IS NULL') && r['deletedAt'] != null) {
        return false;
      }

      // tableNumber = ? AND deletedAt IS NULL
      if (w.contains('tableNumber = ?')) {
        return r['tableNumber'] == a[0];
      }

      // tableId = ? AND deletedAt IS NULL
      if (w.contains('tableId = ?')) {
        return r['tableId'] == a[0];
      }

      // categoryId = ? AND deletedAt IS NULL AND isAvailable = 1
      if (w.contains('categoryId = ?')) {
        final categoryMatch = r['categoryId'] == a[0];
        if (w.contains('isAvailable = 1')) {
          return categoryMatch && (r['isAvailable'] == 1 || r['isAvailable'] == true);
        }
        return categoryMatch;
      }

      // orderId = ? AND deletedAt IS NULL
      if (w.contains('orderId = ?')) {
        return r['orderId'] == a[0];
      }

      // id = ? AND deletedAt IS NULL
      if (w.contains('id = ?')) {
        return r['id'] == a[0];
      }

      // status != ? AND status != ? AND deletedAt IS NULL (e.g. open orders)
      if (w.contains('status != ?')) {
        if (a.length >= 2) {
          return r['status'] != a[0] && r['status'] != a[1];
        }
        return r['status'] != a[0];
      }

      // status = ? (e.g. general status checks)
      if (w.contains('status = ?')) {
        return r['status'] == a[0];
      }

      // Fallback evaluation for other filters
      if (w.contains('IS NULL')) {
        final key = w.split(' IS NULL')[0].trim();
        return r[key] == null;
      }
      if (w.contains('!=')) {
        final parts = w.split('!=');
        final key = parts[0].trim();
        return r[key] != a[0];
      }
      if (w.contains('=')) {
        final parts = w.split('=');
        final key = parts[0].trim();
        return r[key] == a[0];
      }
      return true;
    }).toList();
  }

  List<Map<String, Object?>> _sort(List<Map<String, Object?>> d, String o) {
    final p = o.split(' ');
    final k = p[0];
    final desc = p.length > 1 && p[1].toUpperCase() == 'DESC';
    final s = List<Map<String, Object?>>.from(d);
    s.sort((a, b) {
      final av = a[k];
      final bv = b[k];
      if (av == null) return 1;
      if (bv == null) return -1;
      final c = (av as Comparable).compareTo(bv);
      return desc ? -c : c;
    });
    return s;
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async => await action(this as Transaction);

  @override
  Future<void> close() async {}

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async => [];

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Batch batch() => throw UnimplementedError();

  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) async =>
      null as T;

  @override
  Future<T> devInvokeSqlMethod<T>(
    String method,
    String sql, [
    List<Object?>? arguments,
  ]) async => null as T;

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) => throw UnimplementedError();

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) => throw UnimplementedError();

  @override
  Future<T> readTransaction<T>(Future<T> Function(Transaction txn) action) =>
      action(this as Transaction);

  int get lastInsertRowId => 0;

  bool get isOpen => true;

  @override
  String get path => ':memory:';

  @override
  Database get database => this;
}
