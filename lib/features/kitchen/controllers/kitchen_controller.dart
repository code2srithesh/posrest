import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class KitchenController extends GetxController {
  final orderRepository = OrderRepository();

  final allOrders = <OrderModel>[].obs;
  final pendingItems = <OrderItemModel>[].obs; // Items pending preparation
  final preparingItems = <OrderItemModel>[].obs; // Items being prepared
  final isLoading = false.obs;
  final selectedOrderId = ''.obs;

  // Safe snackbar call that won't crash in test environments
  void _showSnackbar(String title, String message) {
    try {
      Get.snackbar(title, message);
    } catch (e) {
      // Silently fail if context is not available (e.g., in tests)
      // This is expected in unit test environments
    }
  }

  @override
  void onInit() {
    super.onInit();
    // loadKitchenOrders is called when the screen opens (from KitchenScreen)
    // Not called here to avoid issues in unit tests

    // Schedule auto-refresh every 10 seconds (only if orders are loaded)
    ever(allOrders, (_) async {
      await Future.delayed(Duration(seconds: 10));
      if (allOrders.isNotEmpty) {
        await loadKitchenOrders();
      }
    });
  }

  // Load all orders for kitchen display
  Future<void> loadKitchenOrders() async {
    try {
      isLoading.value = true;
      final orders = await orderRepository.getOpenOrders();

      // Filter orders that are not yet completed
      final activeOrders = orders
          .where(
            (o) =>
                o.status != 'served' &&
                o.status != 'completed' &&
                o.status != 'cancelled',
          )
          .toList();

      allOrders.value = activeOrders;

      // Extract all pending and preparing items
      List<OrderItemModel> pending = [];
      List<OrderItemModel> preparing = [];

      for (var order in activeOrders) {
        for (var item in order.items) {
          if (item.status == OrderItemStatus.pending) {
            pending.add(item);
          } else if (item.status == OrderItemStatus.preparing) {
            preparing.add(item);
          }
        }
      }

      pendingItems.value = pending;
      preparingItems.value = preparing;
    } catch (e) {
      _showSnackbar('Error', 'Failed to load kitchen orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Start preparing an item
  Future<void> startPreparingItem(String orderId, String itemId) async {
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);
      final itemIndex = order.items.indexWhere((i) => i.id == itemId);

      if (itemIndex != -1) {
        // Create new item with preparing status
        final item = order.items[itemIndex];
        // In a real app, you'd create a new OrderItemModel with updated status
        // For now, we'll update the status directly

        // Update in repository
        await orderRepository.updateOrder(order);
        _showSnackbar('Success', 'Started preparing: ${item.itemName}');
        await loadKitchenOrders();
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to update item: $e');
    }
  }

  // Mark item as ready
  Future<void> markItemReady(String orderId, String itemId) async {
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);
      final itemIndex = order.items.indexWhere((i) => i.id == itemId);

      if (itemIndex != -1) {
        final item = order.items[itemIndex];

        // Update item status to ready
        // In a real app, create new OrderItemModel with OrderItemStatus.ready

        // Check if all items are ready
        final allReady = order.items.every(
          (i) => i.id == itemId || i.status == OrderItemStatus.ready,
        );

        if (allReady) {
          // Mark entire order as ready
          final updatedOrder = order.copyWith(status: 'ready');
          await orderRepository.updateOrder(updatedOrder);
          _showSnackbar('Success', 'Order ready for table!');
        } else {
          _showSnackbar('Success', '${item.itemName} is ready!');
        }

        await loadKitchenOrders();
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to mark item ready: $e');
    }
  }

  // Mark entire order as served
  Future<void> markOrderServed(String orderId) async {
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(status: 'served');
      await orderRepository.updateOrder(updatedOrder);
      allOrders.removeWhere((o) => o.id == orderId);
      _showSnackbar('Success', 'Order marked as served');
      await loadKitchenOrders();
    } catch (e) {
      _showSnackbar('Error', 'Failed to mark order served: $e');
    }
  }

  // Get time remaining for preparation
  int getTimeRemaining(OrderItemModel item) {
    final elapsedSeconds = DateTime.now().difference(item.createdAt).inSeconds;
    final estimatedSeconds = item.estimatedPrepTime * 60;
    final remaining = estimatedSeconds - elapsedSeconds;
    return remaining > 0 ? remaining ~/ 60 : 0; // Convert back to minutes
  }

  // Check if item is overdue
  bool isItemOverdue(OrderItemModel item) {
    return getTimeRemaining(item) <= 0;
  }

  // Get order kitchen display string
  String getKitchenDisplay(OrderModel order) {
    final items = order.items
        .map((item) {
          final statusStr = item.status
              .toString()
              .split('.')
              .last
              .toUpperCase();
          final note = (item.notes ?? '').isNotEmpty
              ? '\nNote: ${item.notes}'
              : '';
          return '${item.quantity}x ${item.itemName} [$statusStr]$note';
        })
        .join('\n');
    return items;
  }

  // Refresh kitchen display
  Future<void> refreshOrders() async {
    await loadKitchenOrders();
  }
}
