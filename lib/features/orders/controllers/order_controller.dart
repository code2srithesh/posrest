import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../services/preferences_service.dart';
import '../../../core/constants/app_constants.dart';

class OrderController extends GetxController {
  final orderRepository = OrderRepository();
  final tableRepository = TableRepository();
  final menuRepository = MenuRepository();
  final preferencesService = PreferencesService();

  final currentOrder = Rxn<OrderModel>();
  final currentOrderItems = <OrderItemModel>[].obs;
  final isLoading = false.obs;

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
      Get.snackbar('Error', 'Failed to create order: $e');
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
        // Load order items from database
        // For now, we'll initialize with empty items
        currentOrderItems.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load order: $e');
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
      Get.snackbar('Error', 'Failed to add item: $e');
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

      // Save order items
      for (final _ in currentOrderItems) {
        // TODO: Save to database
      }

      // Update order
      await orderRepository.updateOrder(currentOrder.value!);
      Get.snackbar('Success', 'Order saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeOrder() async {
    try {
      if (currentOrder.value == null) return;

      isLoading.value = true;

      final updated = currentOrder.value!.copyWith(
        status: AppConstants.orderStatusPreparing,
        updatedAt: DateTime.now(),
      );

      await orderRepository.updateOrder(updated);
      await saveOrder();
      Get.snackbar('Success', 'Order sent to kitchen');

      // Navigate to billing screen
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.toNamed('/billing/${updated.id}');
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete order: $e');
    } finally {
      isLoading.value = false;
    }
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
}
