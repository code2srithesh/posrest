import '../database/database_helper.dart';
import '../models/order_model.dart';

class OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<String> createOrder(OrderModel order) async {
    await _dbHelper.insertOrder(order);
    return order.id;
  }

  Future<OrderModel?> getOrderById(String id) {
    return _dbHelper.getOrder(id);
  }

  Future<List<OrderModel>> getAllOrders() {
    return _dbHelper.getAllOrders();
  }

  Future<List<OrderModel>> getOrdersByTableId(String tableId) {
    return _dbHelper.getOrdersByTableId(tableId);
  }

  Future<List<OrderModel>> getOpenOrders() {
    return _dbHelper.getOpenOrders();
  }

  Future<void> updateOrder(OrderModel order) async {
    await _dbHelper.updateOrder(order);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final order = await getOrderById(orderId);
    if (order != null) {
      final updated = order.copyWith(status: status, updatedAt: DateTime.now());
      await _dbHelper.updateOrder(updated);
    }
  }

  Future<List<OrderModel>> getDailyOrders(DateTime date) async {
    final allOrders = await getAllOrders();
    return allOrders.where((order) {
      return order.createdAt.year == date.year &&
          order.createdAt.month == date.month &&
          order.createdAt.day == date.day;
    }).toList();
  }

  Future<double> getDailySales(DateTime date) async {
    final orders = await getDailyOrders(date);
    double total = 0;
    for (final order in orders) {
      if (order.status == 'paid') {
        total += order.totalAmount;
      }
    }
    return total;
  }
}
