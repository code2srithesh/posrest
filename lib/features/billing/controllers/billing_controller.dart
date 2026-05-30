import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/table_repository.dart';
import '../../tables/controllers/table_controller.dart';
import '../../orders/controllers/order_controller.dart';
import '../../admin/controllers/user_management_controller.dart';

class BillingController extends GetxController {
  void _showSnackbar(String title, String message, {bool isError = false}) {
    if (Get.testMode) return;
    try {
      Get.snackbar(
        title,
        message,
        backgroundColor: isError ? Colors.red : Colors.green,
        colorText: Colors.white,
      );
    } catch (_) {}
  }
  final orderRepository = OrderRepository();
  final paymentRepository = PaymentRepository();
  final tableRepository = TableRepository();

  final currentOrder = Rxn<OrderModel>();
  final isLoading = false.obs;
  final discountPercent = 0.0.obs;
  final discountType = 'percent'.obs; // percent or fixed
  final discountAmount = 0.0.obs;
  final serviceChargePercent = 0.0.obs; // 0, 10, 15 typically
  final selectedPaymentMethod = 'cash'.obs;
  final paidAmount = 0.0.obs;

  // Tax rates for India (GST)
  static const double GST_STANDARD = 0.05; // 5% for most food items
  static const double GST_PREMIUM = 0.18; // 18% for special/alcoholic items

  // Calculated totals - these react to changes
  double get subtotal {
    if (currentOrder.value?.items.isEmpty ?? true) return 0;
    return currentOrder.value!.items.fold<double>(
      0,
      (sum, item) =>
          sum +
          (item.basePrice * item.quantity) +
          (item.modifierPrice * item.quantity),
    );
  }

  double get discountValue {
    if (discountType.value == 'percent') {
      return subtotal * (discountPercent.value / 100);
    } else {
      return discountAmount.value;
    }
  }

  double get subtotalAfterDiscount => subtotal - discountValue;

  double get gstAmount {
    // Calculate GST on each item (5% standard, 18% for premium items)
    if (currentOrder.value?.items.isEmpty ?? true) return 0;
    double tax = 0;
    for (var item in currentOrder.value!.items) {
      // Check if premium item (alcohol, special)
      final isPremium =
          item.itemName.toLowerCase().contains('alcohol') ||
          item.itemName.toLowerCase().contains('beer') ||
          item.itemName.toLowerCase().contains('wine');
      final rate = isPremium ? GST_PREMIUM : GST_STANDARD;
      tax += (item.basePrice * item.quantity * rate);
    }
    return tax;
  }

  double get serviceCharge =>
      subtotalAfterDiscount * (serviceChargePercent.value / 100);

  double get totalAmount => subtotalAfterDiscount + gstAmount + serviceCharge;

  double get changeAmount => paidAmount.value - totalAmount;

  // Load order for billing
  Future<void> loadOrderForBilling(String orderId) async {
    try {
      isLoading.value = true;
      final order = await orderRepository.getOrderById(orderId);

      if (order == null) {
        _showSnackbar('Error', 'Order not found', isError: true);
        return;
      }

      currentOrder.value = order;
      paidAmount.value = 0;
      discountPercent.value = 0;
      serviceChargePercent.value = 0;
    } catch (e) {
      _showSnackbar('Error', 'Failed to load order: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Apply discount by percentage
  void applyPercentDiscount(double percent) {
    if (percent >= 0 && percent <= 100) {
      discountType.value = 'percent';
      discountPercent.value = percent;
      discountAmount.value = 0;
    }
  }

  // Apply fixed discount amount
  void applyFixedDiscount(double amount) {
    if (amount >= 0 && amount <= subtotal) {
      discountType.value = 'fixed';
      discountAmount.value = amount;
      discountPercent.value = 0;
    }
  }

  // Apply service charge
  void setServiceCharge(double percent) {
    if (percent >= 0 && percent <= 20) {
      serviceChargePercent.value = percent;
    }
  }

  // Calculate change from paid amount
  void updatePaidAmount(double amount) {
    paidAmount.value = amount;
  }

  // Process payment
  Future<bool> processPayment(double paidAmountValue) async {
    try {
      if (currentOrder.value == null) {
        _showSnackbar('Error', 'No order found', isError: true);
        return false;
      }

      if (paidAmountValue < totalAmount) {
        _showSnackbar(
          'Error',
          'Insufficient payment. Need ₹${totalAmount.toStringAsFixed(2)}',
          isError: true,
        );
        return false;
      }

      isLoading.value = true;

      final payment = PaymentModel(
        id: const Uuid().v4(),
        orderId: currentOrder.value!.id,
        amount: totalAmount,
        paymentMethod: selectedPaymentMethod.value,
        status: 'completed',
        transactionId: const Uuid().v4(),
        reference: 'REF_${DateTime.now().millisecondsSinceEpoch}',
        notes:
            'Discount: ${discountValue.toStringAsFixed(2)}, GST: ${gstAmount.toStringAsFixed(2)}, Service: ${serviceCharge.toStringAsFixed(2)}',
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

      // Release table to free/vacant status
      await tableRepository.setTableFree(updatedOrder.tableId);

      // 1. Refresh TableController floor plan to show FREE (green) instantly
      try {
        if (Get.isRegistered<TableController>()) {
          final tableController = Get.find<TableController>();
          await tableController.loadTables();
        }
      } catch (_) {}

      // 2. Clear order cache in OrderController so table is blank
      try {
        if (Get.isRegistered<OrderController>()) {
          final orderController = Get.find<OrderController>();
          if (orderController.currentOrder.value?.id == updatedOrder.id) {
            orderController.clearOrder();
          }
        }
      } catch (_) {}

      // 3. Refresh Admin ERP Dashboard matrix instantly
      try {
        if (Get.isRegistered<UserManagementController>()) {
          final adminController = Get.find<UserManagementController>();
          await adminController.loadDashboardData();
        }
      } catch (_) {}

      _showSnackbar('Success', 'Payment processed successfully');
      return true;
    } catch (e) {
      _showSnackbar('Error', 'Payment failed: $e', isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Print receipt
  Future<void> printReceipt() async {
    try {
      if (currentOrder.value == null) return;
      _showSnackbar('Info', 'Print functionality coming in Phase 3');
    } catch (e) {
      _showSnackbar('Error', 'Failed to print receipt: $e', isError: true);
    }
  }

  // Get payment summary for display
  Map<String, dynamic> getPaymentSummary() {
    return {
      'subtotal': subtotal,
      'tax': gstAmount,
      'discount': discountValue,
      'serviceCharge': serviceCharge,
      'total': totalAmount,
      'paymentMethod': selectedPaymentMethod.value,
    };
  }
}
