import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/payment_repository.dart';

class BillingController extends GetxController {
  final orderRepository = OrderRepository();
  final paymentRepository = PaymentRepository();

  final currentOrder = Rxn<OrderModel>();
  final isLoading = false.obs;
  final discountPercent = 0.0.obs;
  final selectedPaymentMethod = 'cash'.obs;

  // Calculated totals
  double get subtotal => currentOrder.value?.subtotal ?? 0;
  double get taxAmount => currentOrder.value?.taxAmount ?? 0;
  double get discountAmount {
    final amount = subtotal * (discountPercent.value / 100);
    return amount;
  }

  double get totalAmount {
    return subtotal + taxAmount - discountAmount;
  }

  // Load order for billing
  Future<void> loadOrderForBilling(String orderId) async {
    try {
      isLoading.value = true;
      final order = await orderRepository.getOrderById(orderId);
      currentOrder.value = order;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Apply discount
  void applyDiscount(double percent) {
    if (percent >= 0 && percent <= 100) {
      discountPercent.value = percent;
    }
  }

  // Process payment
  Future<bool> processPayment(double amount) async {
    try {
      if (currentOrder.value == null) return false;

      isLoading.value = true;

      final payment = PaymentModel(
        id: const Uuid().v4(),
        orderId: currentOrder.value!.id,
        amount: amount,
        paymentMethod: selectedPaymentMethod.value,
        status: 'completed',
        transactionId: const Uuid().v4(),
        reference: 'REF_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      // Save payment
      await paymentRepository.createPayment(payment);

      // Update order status
      final updatedOrder = currentOrder.value!.copyWith(status: 'paid');
      await orderRepository.updateOrder(updatedOrder);
      currentOrder.value = updatedOrder;

      Get.snackbar('Success', 'Payment processed successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Payment failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Print receipt (stub for Phase 3)
  Future<void> printReceipt() async {
    try {
      if (currentOrder.value == null) return;

      Get.snackbar('Info', 'Print functionality coming in Phase 3');
      // TODO: Implement printer service
    } catch (e) {
      Get.snackbar('Error', 'Failed to print receipt: $e');
    }
  }

  // Get payment summary
  Map<String, dynamic> getPaymentSummary() {
    return {
      'subtotal': subtotal,
      'tax': taxAmount,
      'discount': discountAmount,
      'total': totalAmount,
      'paymentMethod': selectedPaymentMethod.value,
    };
  }
}
