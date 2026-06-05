import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

import '../../../core/widgets/custom_notification.dart';

class CashierController extends GetxController {
  final orderRepository = OrderRepository();

  final pendingPaymentOrders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final selectedOrderId = ''.obs;

  // Safe snackbar call
  void _showSnackbar(String title, String message) {
    try {
      CustomNotification.showSnackbar(title, message);
    } catch (e) {
      // Silently fail if context is not available (e.g., in tests)
    }
  }

  @override
  void onInit() {
    super.onInit();
    // loadPendingPayments is called when the screen opens
  }

  // Load all orders pending payment
  Future<void> loadPendingPayments() async {
    try {
      isLoading.value = true;
      final orders = await orderRepository.getOpenOrders();

      // Filter orders that are payment_pending status
      final paymentPendingOrders = orders
          .where((o) => o.status == 'payment_pending')
          .toList();

      pendingPaymentOrders.value = paymentPendingOrders;
    } catch (e) {
      _showSnackbar('Error', 'Failed to load pending payments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to billing for a specific order
  void goToBilling(String orderId) {
    try {
      selectedOrderId.value = orderId;
      Get.toNamed('/billing/$orderId');
    } catch (e) {
      _showSnackbar('Error', 'Failed to open billing: $e');
    }
  }

  // Get formatted total for an order
  String getFormattedTotal(OrderModel order) {
    double total = 0;
    for (var item in order.items) {
      total += (item.basePrice + item.modifierPrice) * item.quantity;
    }
    // Add GST (5%)
    total = total * 1.05;
    return '₹${total.toStringAsFixed(2)}';
  }

  // Get items count for an order
  int getItemsCount(OrderModel order) {
    return order.items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // Refresh pending payments list
  Future<void> refreshPendingPayments() async {
    await loadPendingPayments();
  }
}
