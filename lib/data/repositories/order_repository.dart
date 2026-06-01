import '../database/database_helper.dart';
import '../models/order_model.dart';

class OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<String> createOrder(OrderModel order) async {
    await _dbHelper.insertOrder(order);
    return order.id;
  }

  Future<OrderModel?> getOrderById(String id) async {
    final order = await _dbHelper.getOrder(id);
    if (order == null) {
      return null;
    }

    final items = await _dbHelper.getOrderItems(order.id);
    return order.copyWith(items: items);
  }

  Future<List<OrderModel>> getAllOrders() async {
    final orders = await _dbHelper.getAllOrders();
    return _hydrateOrdersWithItems(orders);
  }

  Future<List<OrderModel>> getOrdersByTableId(String tableId) async {
    final orders = await _dbHelper.getOrdersByTableId(tableId);
    return _hydrateOrdersWithItems(orders);
  }

  Future<List<OrderModel>> getOpenOrders() async {
    final orders = await _dbHelper.getOpenOrders();
    return _hydrateOrdersWithItems(orders);
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

  Future<void> replaceOrderItems(
    String orderId,
    List<OrderItemModel> items,
  ) async {
    await _dbHelper.deleteOrderItemsByOrderId(orderId);
    for (final item in items) {
      await _dbHelper.insertOrderItem(item);
    }
  }

  Future<List<OrderModel>> _hydrateOrdersWithItems(
    List<OrderModel> orders,
  ) async {
    final hydrated = <OrderModel>[];
    for (final order in orders) {
      final items = await _dbHelper.getOrderItems(order.id);
      hydrated.add(order.copyWith(items: items));
    }
    return hydrated;
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

  Future<void> deleteOrder(String orderId) async {
    await _dbHelper.deleteOrder(orderId);
  }
}
