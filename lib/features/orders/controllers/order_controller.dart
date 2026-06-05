import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../services/preferences_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../tables/controllers/table_controller.dart';

import '../../../core/widgets/custom_notification.dart';

class OrderController extends GetxController {
  final orderRepository = OrderRepository();
  final tableRepository = TableRepository();
  final menuRepository = MenuRepository();
  final preferencesService = PreferencesService();

  final currentOrder = Rxn<OrderModel>();
  final currentOrderItems = <OrderItemModel>[].obs;
  final isLoading = false.obs;
  final isGridView = true.obs;

  void _showSnackbar(String title, String message, {bool isError = false}) {
    if (Get.testMode) return;
    try {
      CustomNotification.showSnackbar(
        title,
        message,
        backgroundColor: isError ? Colors.red : Colors.green,
        colorText: Colors.white,
      );
    } catch (_) {}
  }

  double get subtotal {
    double total = 0;
    for (final item in currentOrderItems) {
      total += item.totalPrice;
    }
    return total;
  }

  double get taxAmount {
    final taxRate = preferencesService.getTaxRate();
    return subtotal * (taxRate / 100);
  }

  double get totalAmount {
    return subtotal + taxAmount;
  }

  Future<void> createOrder(String tableId, int tableNumber) async {
    try {
      isLoading.value = true;

      final order = OrderModel(
        id: const Uuid().v4(),
        tableId: tableId,
        tableNumber: tableNumber,
        orderType: 'dine-in',
        status: AppConstants.orderStatusOpen,
        subtotal: 0,
        taxAmount: 0,
        discountAmount: 0,
        totalAmount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusPending,
      );

      await orderRepository.createOrder(order);
      await tableRepository.setTableOccupied(tableId, order.id);

      currentOrder.value = order;
      currentOrderItems.clear();
    } catch (e) {
      _showSnackbar('Error', 'Failed to create order: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrder(String orderId) async {
    try {
      isLoading.value = true;
      final order = await orderRepository.getOrderById(orderId);
      if (order != null) {
        currentOrder.value = order;
        currentOrderItems.assignAll(order.items);
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to load order: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItemToOrder(
    MenuItemModel item, {
    int quantity = 1,
    List<String> selectedModifierIds = const [],
    String? notes,
  }) async {
    try {
      if (currentOrder.value == null) return;

      // Calculate modifier price
      double modifierPrice = 0;
      if (selectedModifierIds.isNotEmpty) {
        final modifiers = await menuRepository.getModifiersByIds(
          selectedModifierIds,
        );
        for (final mod in modifiers) {
          modifierPrice += mod.price;
        }
      }

      final itemPrice = (item.price + modifierPrice) * quantity;

      final orderItem = OrderItemModel(
        id: const Uuid().v4(),
        orderId: currentOrder.value!.id,
        menuItemId: item.id,
        itemName: item.name,
        basePrice: item.price,
        quantity: quantity,
        notes: notes,
        selectedModifierIds: selectedModifierIds,
        modifierPrice: modifierPrice,
        totalPrice: itemPrice,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusPending,
      );

      // Check if item already exists with same modifiers
      final existingIndex = currentOrderItems.indexWhere(
        (i) =>
            i.menuItemId == item.id &&
            i.selectedModifierIds.toString() == selectedModifierIds.toString(),
      );

      if (existingIndex >= 0) {
        // Update quantity if item exists
        final existing = currentOrderItems[existingIndex];
        currentOrderItems[existingIndex] = existing.copyWith(
          quantity: existing.quantity + quantity,
          totalPrice: existing.totalPrice + itemPrice,
        );
      } else {
        // Add new item
        currentOrderItems.add(orderItem);
      }

      _updateOrderTotals();
    } catch (e) {
      _showSnackbar('Error', 'Failed to add item: $e', isError: true);
    }
  }

  void removeItemFromOrder(int index) {
    if (index >= 0 && index < currentOrderItems.length) {
      currentOrderItems.removeAt(index);
      _updateOrderTotals();
    }
  }

  void updateItemQuantity(int index, int newQuantity) {
    if (index >= 0 && index < currentOrderItems.length && newQuantity > 0) {
      final item = currentOrderItems[index];
      final pricePerUnit = item.totalPrice / item.quantity;
      currentOrderItems[index] = item.copyWith(
        quantity: newQuantity,
        totalPrice: pricePerUnit * newQuantity,
      );
      _updateOrderTotals();
    }
  }

  void _updateOrderTotals() {
    if (currentOrder.value != null) {
      final updated = currentOrder.value!.copyWith(
        items: currentOrderItems.toList(),
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        updatedAt: DateTime.now(),
      );
      currentOrder.value = updated;
    }
  }

  Future<void> saveOrder() async {
    try {
      if (currentOrder.value == null) return;

      isLoading.value = true;

      final orderWithItems = currentOrder.value!.copyWith(
        items: currentOrderItems.toList(),
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        updatedAt: DateTime.now(),
      );

      await orderRepository.replaceOrderItems(
        orderWithItems.id,
        currentOrderItems.toList(),
      );
      await orderRepository.updateOrder(orderWithItems);
      currentOrder.value = orderWithItems;
      _showSnackbar('Success', 'Order saved successfully');
    } catch (e) {
      _showSnackbar('Error', 'Failed to save order: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Send order to kitchen (Waiter action)
  Future<void> sendToKitchen() async {
    try {
      if (currentOrder.value == null) return;

      isLoading.value = true;

      // Decrement availableStock in database for each item ordered
      for (final orderItem in currentOrderItems) {
        final menuItem = await menuRepository.getMenuItemById(orderItem.menuItemId);
        if (menuItem != null) {
          final newStock = (menuItem.availableStock - orderItem.quantity).clamp(0, 999999);
          final updatedItem = menuItem.copyWith(availableStock: newStock);
          await menuRepository.updateMenuItem(updatedItem);
        }
      }

      final updated = currentOrder.value!.copyWith(
        items: currentOrderItems.toList(),
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        status: 'sent_to_kitchen', // Send to kitchen, not directly to preparing
        updatedAt: DateTime.now(),
      );

      // Set the active observable state first so saveOrder() retains 'sent_to_kitchen'
      currentOrder.value = updated;

      await orderRepository.updateOrder(updated);
      await saveOrder();
      _showSnackbar('Success', 'Order sent to kitchen ✓');
    } catch (e) {
      _showSnackbar('Error', 'Failed to send to kitchen: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Mark order as served (Waiter action - customer received food)
  Future<void> markAsServed() async {
    try {
      if (currentOrder.value == null) return;

      isLoading.value = true;

      final updated = currentOrder.value!.copyWith(
        status: 'served',
        updatedAt: DateTime.now(),
      );

      await orderRepository.updateOrder(updated);
      _showSnackbar('Success', 'Order marked as served');

      currentOrder.value = updated;
    } catch (e) {
      _showSnackbar('Error', 'Failed to mark as served: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Send to payment (Waiter action - customer done eating, send to cashier)
  Future<void> sendToPayment() async {
    try {
      if (currentOrder.value == null) return;

      isLoading.value = true;

      final updated = currentOrder.value!.copyWith(
        status: 'payment_pending',
        updatedAt: DateTime.now(),
      );

      await orderRepository.updateOrder(updated);
      _showSnackbar('Success', 'Order sent to cashier for payment');

      // Navigate to billing screen
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.toNamed('/billing/${updated.id}');
      });

      currentOrder.value = updated;
    } catch (e) {
      _showSnackbar('Error', 'Failed to send to payment: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Old method - kept for compatibility but redirects to sendToKitchen
  Future<void> completeOrder() async {
    await sendToKitchen();
  }

  void clearOrder() {
    currentOrder.value = null;
    currentOrderItems.clear();
  }

  int getItemCount() {
    int count = 0;
    for (final item in currentOrderItems) {
      count += item.quantity;
    }
    return count;
  }

  Future<void> cancelEmptyOrder() async {
    try {
      final order = currentOrder.value;
      if (order != null && currentOrderItems.isEmpty) {
        await orderRepository.deleteOrder(order.id);
        await tableRepository.setTableFree(order.tableId);
        try {
          if (Get.isRegistered<TableController>()) {
            await Get.find<TableController>().loadTables();
          }
        } catch (_) {}
      }
    } catch (_) {}
  }
}
