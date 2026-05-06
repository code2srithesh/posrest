import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class KitchenController extends GetxController {
  final orderRepository = OrderRepository();

  final pendingOrders = <OrderModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingOrders();
    // Refresh every 5 seconds
    ever(pendingOrders, (_) {});
  }

  // Load all pending orders
  Future<void> loadPendingOrders() async {
    try {
      isLoading.value = true;
      final orders = await orderRepository.getOpenOrders();
      // Filter only preparing orders
      final preparing = orders.where((o) => o.status == 'preparing').toList();
      pendingOrders.value = preparing;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mark item as ready
  Future<void> markItemReady(String orderId, int itemIndex) async {
    try {
      // This would be implemented with item status tracking in Phase 3
      Get.snackbar('Success', 'Item marked as ready');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update item: $e');
    }
  }

  // Mark entire order as served
  Future<void> markOrderServed(String orderId) async {
    try {
      final order = pendingOrders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(status: 'served');
      await orderRepository.updateOrder(updatedOrder);
      pendingOrders.removeWhere((o) => o.id == orderId);
      Get.snackbar('Success', 'Order marked as served');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order: $e');
    }
  }

  // Get order with kitchen-friendly formatting
  String getKitchenDisplay(OrderModel order) {
    final items = order.items
        .map((item) {
          return '${item.quantity}x ${item.itemName}${(item.notes ?? '').isNotEmpty ? ' (${item.notes})' : ''}';
        })
        .join('\n');
    return items;
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadPendingOrders();
  }
}
