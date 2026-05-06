import '../database/database_helper.dart';
import '../models/table_model.dart';

class TableRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<String> createTable(TableModel table) async {
    await _dbHelper.insertTable(table);
    return table.id;
  }

  Future<TableModel?> getTableById(String id) {
    return _dbHelper.getTable(id);
  }

  Future<TableModel?> getTableByNumber(int number) {
    return _dbHelper.getTableByNumber(number);
  }

  Future<List<TableModel>> getAllTables() {
    return _dbHelper.getAllTables();
  }

  Future<void> updateTable(TableModel table) async {
    await _dbHelper.updateTable(table);
  }

  Future<void> deleteTable(String id) async {
    await _dbHelper.deleteTable(id);
  }

  Future<List<TableModel>> getTablesByStatus(String status) async {
    final tables = await _dbHelper.getAllTables();
    return tables.where((t) => t.status == status).toList();
  }

  Future<void> setTableOccupied(String tableId, String orderId) async {
    final table = await _dbHelper.getTable(tableId);
    if (table != null) {
      final updated = table.copyWith(
        status: 'occupied',
        currentOrderId: orderId,
      );
      await _dbHelper.updateTable(updated);
    }
  }

  Future<void> setTableFree(String tableId) async {
    final table = await _dbHelper.getTable(tableId);
    if (table != null) {
      final updated = table.copyWith(
        status: 'free',
        currentOrderId: null,
        occupiedSeats: 0,
      );
      await _dbHelper.updateTable(updated);
    }
  }

  Future<void> mergeTables(List<String> tableIds, String mergedOrderId) async {
    for (final tableId in tableIds) {
      final table = await _dbHelper.getTable(tableId);
      if (table != null) {
        final updated = table.copyWith(
          status: 'occupied',
          currentOrderId: mergedOrderId,
          mergedTableIds: tableIds,
        );
        await _dbHelper.updateTable(updated);
      }
    }
  }
}
