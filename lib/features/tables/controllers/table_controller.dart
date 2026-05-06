import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../core/constants/app_constants.dart';

class TableController extends GetxController {
  final tableRepository = TableRepository();

  final tables = <TableModel>[].obs;
  final isLoading = false.obs;
  final selectedTableId = RxnString();
  final filterStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTables();
  }

  Future<void> loadTables() async {
    try {
      isLoading.value = true;
      final allTables = await tableRepository.getAllTables();

      if (allTables.isEmpty) {
        // Create default tables if none exist
        await createDefaultTables();
      } else {
        tables.value = allTables;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tables: $e');
    } finally {
      isLoading.value = false;
    }
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
      Get.snackbar('Error', 'Failed to create default tables: $e');
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
      Get.snackbar('Success', 'Table created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create table: $e');
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
      Get.snackbar('Error', 'Failed to update table: $e');
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
      Get.snackbar('Error', 'Failed to set table occupied: $e');
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
      Get.snackbar('Error', 'Failed to set table free: $e');
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
