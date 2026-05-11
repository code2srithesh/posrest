import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:posrest/features/billing/controllers/billing_controller.dart';
import 'package:posrest/data/models/order_model.dart';

void main() {
  group('Payment Calculation Tests', () {
    late BillingController billingController;

    setUp(() {
      billingController = BillingController();
      Get.put(billingController);
    });

    tearDown(() {
      Get.delete<BillingController>();
    });

    test('GST calculation for standard food items (5%)', () {
      // Create a mock order with food item
      final order = OrderModel(
        id: 'test-order-1',
        tableId: 'table-1',
        tableNumber: 1,
        orderType: 'dine-in',
        status: 'open',
        items: [
          OrderItemModel(
            id: 'item-1',
            orderId: 'test-order-1',
            menuItemId: 'menu-1',
            itemName: 'Butter Chicken',
            basePrice: 500.0,
            quantity: 1,
            modifierPrice: 0,
            totalPrice: 500,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
        ],
        subtotal: 500,
        taxAmount: 25,
        discountAmount: 0,
        totalAmount: 525,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );

      billingController.currentOrder.value = order;

      // GST should be 5% of 500 = 25
      expect(billingController.gstAmount, 25.0);
      print('✅ Food GST: ₹500 → GST (5%): ₹25');
    });

    test('GST calculation for premium items (18%)', () {
      // Create a mock order with premium item (alcohol)
      final order = OrderModel(
        id: 'test-order-2',
        tableId: 'table-2',
        tableNumber: 2,
        orderType: 'dine-in',
        status: 'open',
        items: [
          OrderItemModel(
            id: 'item-1',
            orderId: 'test-order-2',
            menuItemId: 'menu-1',
            itemName: 'Wine Selection',
            basePrice: 500.0,
            quantity: 1,
            modifierPrice: 0,
            totalPrice: 500,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
        ],
        subtotal: 500,
        taxAmount: 90,
        discountAmount: 0,
        totalAmount: 590,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );

      billingController.currentOrder.value = order;

      // GST should be 18% of 500 = 90
      expect(billingController.gstAmount, 90.0);
      print('✅ Premium GST: ₹500 → GST (18%): ₹90');
    });

    test('Discount calculation (percentage)', () {
      final order = OrderModel(
        id: 'test-order-3',
        tableId: 'table-3',
        tableNumber: 3,
        orderType: 'dine-in',
        status: 'open',
        items: [
          OrderItemModel(
            id: 'item-1',
            orderId: 'test-order-3',
            menuItemId: 'menu-1',
            itemName: 'Biryani',
            basePrice: 1000.0,
            quantity: 1,
            modifierPrice: 0,
            totalPrice: 1000,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
        ],
        subtotal: 1000,
        taxAmount: 50,
        discountAmount: 0,
        totalAmount: 1050,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );

      billingController.currentOrder.value = order;
      billingController.applyPercentDiscount(10);

      // 10% of 1000 = 100
      expect(billingController.discountValue, 100.0);
      print('✅ Discount: ₹1000 with 10% → Discount: ₹100');
    });

    test('Service charge calculation', () {
      final order = OrderModel(
        id: 'test-order-4',
        tableId: 'table-4',
        tableNumber: 4,
        orderType: 'dine-in',
        status: 'open',
        items: [
          OrderItemModel(
            id: 'item-1',
            orderId: 'test-order-4',
            menuItemId: 'menu-1',
            itemName: 'Paneer Tikka',
            basePrice: 1000.0,
            quantity: 1,
            modifierPrice: 0,
            totalPrice: 1000,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
        ],
        subtotal: 1000,
        taxAmount: 50,
        discountAmount: 0,
        totalAmount: 1050,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );

      billingController.currentOrder.value = order;
      billingController.setServiceCharge(10);

      // 10% of 1000 = 100
      expect(billingController.serviceCharge, 100.0);
      print('✅ Service charge: ₹1000 with 10% → Charge: ₹100');
    });

    test('Payment methods are available', () {
      final methods = ['cash', 'card', 'upi', 'online'];

      for (var method in methods) {
        billingController.selectedPaymentMethod.value = method;
        expect(billingController.selectedPaymentMethod.value, method);
      }

      print('✅ All payment methods available: ${methods.join(", ")}');
    });

    test('Total amount calculation', () {
      final order = OrderModel(
        id: 'test-order-5',
        tableId: 'table-5',
        tableNumber: 5,
        orderType: 'dine-in',
        status: 'open',
        items: [
          OrderItemModel(
            id: 'item-1',
            orderId: 'test-order-5',
            menuItemId: 'menu-1',
            itemName: 'Samosa',
            basePrice: 500.0,
            quantity: 2,
            modifierPrice: 0,
            totalPrice: 1000,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
        ],
        subtotal: 1000,
        taxAmount: 50,
        discountAmount: 0,
        totalAmount: 1050,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );

      billingController.currentOrder.value = order;
      billingController.applyPercentDiscount(5);
      billingController.setServiceCharge(10);

      // Subtotal: 1000
      // Discount: 50 (5% of 1000)
      // After discount: 950
      // GST: 50 (5% of 1000)
      // Service charge: 95 (10% of 950)
      // Total: 950 + 50 + 95 = 1095

      expect(billingController.subtotal, 1000.0);
      expect(billingController.discountValue, 50.0);
      expect(billingController.gstAmount, 50.0);
      expect(billingController.serviceCharge, 95.0);

      print(
        '✅ Total: ₹${billingController.totalAmount.toStringAsFixed(2)} (Subtotal: ₹1000 - Discount: ₹50 + GST: ₹50 + Service: ₹95)',
      );
    });
  });

  group('Payment Methods Tests', () {
    late BillingController billingController;

    setUp(() {
      billingController = BillingController();
      Get.put(billingController);
    });

    tearDown(() {
      Get.delete<BillingController>();
    });

    test('Payment method selection', () {
      expect(billingController.selectedPaymentMethod.value, 'cash');

      billingController.selectedPaymentMethod.value = 'card';
      expect(billingController.selectedPaymentMethod.value, 'card');

      billingController.selectedPaymentMethod.value = 'upi';
      expect(billingController.selectedPaymentMethod.value, 'upi');

      print('✅ Payment method selection working correctly');
    });

    test('Payment summary generation', () {
      final order = OrderModel(
        id: 'test-order-6',
        tableId: 'table-6',
        tableNumber: 6,
        orderType: 'dine-in',
        status: 'open',
        items: [
          OrderItemModel(
            id: 'item-1',
            orderId: 'test-order-6',
            menuItemId: 'menu-1',
            itemName: 'Lassi',
            basePrice: 150.0,
            quantity: 2,
            modifierPrice: 0,
            totalPrice: 300,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
        ],
        subtotal: 300,
        taxAmount: 15,
        discountAmount: 0,
        totalAmount: 315,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );

      billingController.currentOrder.value = order;

      final summary = billingController.getPaymentSummary();
      expect(summary.containsKey('subtotal'), true);
      expect(summary.containsKey('tax'), true);
      expect(summary.containsKey('total'), true);
      expect(summary.containsKey('paymentMethod'), true);

      print('✅ Payment summary generated with keys: ${summary.keys.toList()}');
    });
  });
}
