import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_notification.dart';

class KitchenController extends GetxController {
  final orderRepository = OrderRepository();

  final allOrders = <OrderModel>[].obs;
  final dailyOrders = <OrderModel>[].obs; // Today's orders for chef summary
  final showDashboard = false.obs; // Toggle between active KDS queue and summary
  final pendingItems = <OrderItemModel>[].obs; // Items pending preparation
  final preparingItems = <OrderItemModel>[].obs; // Items being prepared
  final isLoading = false.obs;
  final selectedOrderId = ''.obs;
  final readyOrders = <OrderModel>[].obs; // Orders that are ready for pickup
  final notificationQueue =
      <String>[].obs; // Queue of ready order notifications

  Timer? _refreshTimer;

  // Safe notification overlay call that won't crash in test environments
  void _showNotification(String title, String message, {Color? color}) {
    if (Get.testMode) return;
    try {
      CustomNotification.show(
        title: title,
        message: message,
        color: color ?? AppColors.accentTeal,
        icon: Icons.kitchen_outlined,
      );
    } catch (e) {
      // Silently fail if context is not available
    }
  }

  @override
  void onInit() {
    super.onInit();
    // loadKitchenOrders is called when the screen opens (from KitchenScreen)
    // Not called here to avoid issues in unit tests

    // Schedule auto-refresh every 4 seconds to ensure rapid updates in real restaurant operations
    if (!Get.testMode) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        loadKitchenOrders();
      });
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  // Load all orders for kitchen display
  Future<void> loadKitchenOrders() async {
    try {
      isLoading.value = true;
      final orders = await orderRepository.getOpenOrders();

      // Filter orders that chef should see:
      // - sent_to_kitchen: newly arrived orders
      // - preparing: orders being worked on
      // - ready: orders waiting for waiter pickup
      final activeOrders = orders
          .where(
            (o) =>
                o.status == 'sent_to_kitchen' ||
                o.status == 'preparing' ||
                o.status == 'ready',
          )
          .toList();

      allOrders.value = activeOrders;

      // Load all today's orders for chef summary/dashboard statistics
      final todayOrders = await orderRepository.getDailyOrders(DateTime.now());
      dailyOrders.assignAll(todayOrders);

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
      _showNotification('Error', 'Failed to load kitchen orders: $e', color: AppColors.error);
    } finally {
      isLoading.value = false;
    }
  }

  // Start preparing an order - mark it as 'preparing' status
  Future<void> startPreparingOrder(String orderId) async {
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);

      // Update order status to 'preparing'
      final updatedOrder = order.copyWith(
        status: 'preparing',
        items: order.items.map((item) {
          // Update all items to preparing if they're still pending
          if (item.status == OrderItemStatus.pending) {
            return item.copyWith(status: OrderItemStatus.preparing);
          }
          return item;
        }).toList(),
      );

      await orderRepository.updateOrder(updatedOrder);
      _showNotification('Success', 'Started preparing order', color: AppColors.accentOrange);
      await loadKitchenOrders();
    } catch (e) {
      _showNotification('Error', 'Failed to start preparing: $e', color: AppColors.error);
    }
  }

  // Start preparing an item
  Future<void> startPreparingItem(String orderId, String itemId) async {
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);
      final itemIndex = order.items.indexWhere((i) => i.id == itemId);

      if (itemIndex != -1) {
        // Update in repository
        await orderRepository.updateOrder(order);
        _showNotification('Success', 'Started preparing: ${order.items[itemIndex].itemName}', color: AppColors.accentOrange);
        await loadKitchenOrders();
      }
    } catch (e) {
      _showNotification('Error', 'Failed to update item: $e', color: AppColors.error);
    }
  }

  // Mark item as ready
  Future<void> markItemReady(String orderId, String itemId) async {
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);
      final itemIndex = order.items.indexWhere((i) => i.id == itemId);

      if (itemIndex != -1) {
        final item = order.items[itemIndex];

        // Check if all items are ready
        final allReady = order.items.every(
          (i) => i.id == itemId || i.status == OrderItemStatus.ready,
        );

        if (allReady) {
          // Mark entire order as ready
          final updatedOrder = order.copyWith(status: 'ready');
          await orderRepository.updateOrder(updatedOrder);
          _notifyOrderReady(orderId, order.tableNumber);
          _showNotification('Success', 'Order ready for table!', color: AppColors.success);
        } else {
          _showNotification('Success', '${item.itemName} is ready!', color: AppColors.success);
        }

        await loadKitchenOrders();
      }
    } catch (e) {
      _showNotification('Error', 'Failed to mark item ready: $e', color: AppColors.error);
    }
  }

  // Mark entire order as ready for waiter pickup
  Future<void> markOrderReady(String orderId) async {
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(
        status: 'ready',
        items: order.items.map((item) {
          if (item.status == OrderItemStatus.pending ||
              item.status == OrderItemStatus.preparing) {
            return item.copyWith(
              status: OrderItemStatus.ready,
              completedAt: DateTime.now(),
            );
          }
          return item;
        }).toList(),
      );

      await orderRepository.updateOrder(updatedOrder);
      _notifyOrderReady(orderId, order.tableNumber);
      _showNotification('Success', 'Order is ready for pickup!', color: AppColors.success);
      await loadKitchenOrders();
    } catch (e) {
      _showNotification('Error', 'Failed to mark order ready: $e', color: AppColors.error);
    }
  }

  // Mark entire order as served
  Future<void> markOrderServed(String orderId) async {
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(status: 'served');
      await orderRepository.updateOrder(updatedOrder);
      allOrders.removeWhere((o) => o.id == orderId);
      readyOrders.removeWhere((o) => o.id == orderId);
      _showNotification('Success', 'Order marked as served', color: AppColors.accentTeal);
      await loadKitchenOrders();
    } catch (e) {
      _showNotification('Error', 'Failed to mark order served: $e', color: AppColors.error);
    }
  }

  // Reject an order (Chef action)
  Future<void> rejectOrder(String orderId) async {
    try {
      // Find from allOrders
      final order = allOrders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(
        status: 'cancelled',
        updatedAt: DateTime.now(),
      );
      await orderRepository.updateOrder(updatedOrder);
      _showNotification('Rejected', 'Order for Table ${order.tableNumber} was rejected', color: Colors.red);
      await loadKitchenOrders();
    } catch (e) {
      _showNotification('Error', 'Failed to reject order: $e', color: AppColors.error);
    }
  }

  // Send notification that order is ready
  void _notifyOrderReady(String orderId, int tableNumber) {
    final notification =
        'Table $tableNumber - Order #${orderId.substring(0, 8)} READY!';
    notificationQueue.add(notification);

    // Add to ready orders list
    try {
      final order = allOrders.firstWhere((o) => o.id == orderId);
      if (!readyOrders.any((o) => o.id == orderId)) {
        readyOrders.add(order);
      }
    } catch (e) {
      // Order not found in current list
    }

    // Auto-clear notification after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (notificationQueue.contains(notification)) {
        notificationQueue.remove(notification);
      }
    });
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
