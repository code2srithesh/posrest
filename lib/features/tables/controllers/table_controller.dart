import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_notification.dart';

class TableController extends GetxController {
  final tableRepository = TableRepository();
  final orderRepository = OrderRepository();

  final tables = <TableModel>[].obs;
  final openOrders = <String, OrderModel>{}.obs;
  final isLoading = false.obs;
  final selectedTableId = RxnString();
  final filterStatus = ''.obs;
  
  Timer? _refreshTimer;
  final Map<String, String> _previousStatuses = {};

  @override
  void onInit() {
    super.onInit();
    loadTables();
    if (!Get.testMode) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        loadTables(silent: true);
      });
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> loadTables({bool silent = false}) async {
    try {
      if (!silent) {
        isLoading.value = true;
      }
      final allTables = await tableRepository.getAllTables();
      
      // Load active open orders
      final activeOrders = await orderRepository.getOpenOrders();
      final orderMap = <String, OrderModel>{};
      
      for (final order in activeOrders) {
        orderMap[order.id] = order;
        
        // Notify on transition to 'ready'
        final oldStatus = _previousStatuses[order.id];
        if (oldStatus != null && oldStatus != 'ready' && order.status == 'ready') {
          _showOrderReadyNotification(order);
        }
        
        _previousStatuses[order.id] = order.status;
      }
      
      // Populate statuses for orders already in the list on startup, if map is empty
      if (_previousStatuses.isEmpty && activeOrders.isNotEmpty) {
        for (final order in activeOrders) {
          _previousStatuses[order.id] = order.status;
        }
      }
      
      openOrders.value = orderMap;

      if (allTables.isEmpty) {
        // Create default tables if none exist
        await createDefaultTables();
      } else {
        tables.value = allTables;
      }
    } catch (e) {
      if (!silent) {
        CustomNotification.showSnackbar('Error', 'Failed to load tables: $e');
      }
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  void _showOrderReadyNotification(OrderModel order) {
    if (Get.testMode) return;
    try {
      CustomNotification.show(
        title: '🛎️ Food Ready!',
        message: 'Table ${order.tableNumber}: Order is ready for pickup!',
        icon: Icons.room_service,
        color: AppColors.success,
      );
    } catch (_) {}
  }

  Future<void> createDefaultTables() async {
    try {
      for (int i = 1; i <= 12; i++) {
        final table = TableModel(
          id: const Uuid().v4(),
          tableNumber: i,
          capacity: i <= 4 ? 2 : (i <= 8 ? 4 : 6),
          status: AppConstants.statusFree,
          occupiedSeats: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        );
        await tableRepository.createTable(table);
        tables.add(table);
      }
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to create default tables: $e');
    }
  }

  Future<void> createTable(int tableNumber, int capacity) async {
    try {
      final table = TableModel(
        id: const Uuid().v4(),
        tableNumber: tableNumber,
        capacity: capacity,
        status: AppConstants.statusFree,
        occupiedSeats: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusPending,
      );

      await tableRepository.createTable(table);
      tables.add(table);
      Get.back();
      CustomNotification.showSnackbar('Success', 'Table created successfully');
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to create table: $e');
    }
  }

  Future<void> updateTableStatus(String tableId, String status) async {
    try {
      final table = await tableRepository.getTableById(tableId);
      if (table != null) {
        final updated = table.copyWith(
          status: status,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        );
        await tableRepository.updateTable(updated);

        final index = tables.indexWhere((t) => t.id == tableId);
        if (index >= 0) {
          tables[index] = updated;
        }
      }
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to update table: $e');
    }
  }

  Future<void> setTableOccupied(String tableId, String orderId) async {
    try {
      await tableRepository.setTableOccupied(tableId, orderId);
      final table = await tableRepository.getTableById(tableId);
      if (table != null) {
        final index = tables.indexWhere((t) => t.id == tableId);
        if (index >= 0) {
          tables[index] = table;
        }
      }
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to set table occupied: $e');
    }
  }

  Future<void> setTableFree(String tableId) async {
    try {
      await tableRepository.setTableFree(tableId);
      final table = await tableRepository.getTableById(tableId);
      if (table != null) {
        final index = tables.indexWhere((t) => t.id == tableId);
        if (index >= 0) {
          tables[index] = table;
        }
      }
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to set table free: $e');
    }
  }

  List<TableModel> getFilteredTables() {
    if (filterStatus.value.isEmpty) {
      return tables;
    }
    return tables.where((table) => table.status == filterStatus.value).toList();
  }

  int getTablesCount(String status) {
    return tables.where((t) => t.status == status).length;
  }

  double getTableOccupancyRate() {
    if (tables.isEmpty) return 0;
    final occupied = tables
        .where((t) => t.status == AppConstants.statusOccupied)
        .length;
    return occupied / tables.length;
  }
}
