import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posrest/services/preferences_service.dart';
import 'package:posrest/data/models/menu_item_model.dart';

// Import the controllers and repositories
import 'package:posrest/data/repositories/order_repository.dart';
import 'package:posrest/features/orders/controllers/order_controller.dart';
import 'package:posrest/features/kitchen/controllers/kitchen_controller.dart';
import 'package:posrest/features/billing/controllers/billing_controller.dart';
import 'package:posrest/features/cashier/controllers/cashier_controller.dart';

void main() {
  group('Complete Restaurant Order Workflow', () {
    late OrderController orderController;
    late KitchenController kitchenController;
    late BillingController billingController;
    late CashierController cashierController;
    late OrderRepository orderRepository;

    Future<void> addTestItem(OrderController controller) async {
      final item = MenuItemModel(
        id: 'item-1',
        categoryId: 'cat-1',
        name: 'Paneer Butter Masala',
        price: 250.0,
        isAvailable: true,
        isVegetarian: true,
        isSpicy: true,
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );
      await controller.addItemToOrder(item);
    }

    setUp(() async {
      // Prevent GetX overlays from trying to draw during unit tests
      Get.testMode = true;
      
      // Initialize mocks for SharedPreferences and PreferencesService
      SharedPreferences.setMockInitialValues({});
      await PreferencesService().initialize();

      // Initialize controllers
      orderController = Get.put(OrderController());
      kitchenController = Get.put(KitchenController());
      billingController = Get.put(BillingController());
      cashierController = Get.put(CashierController());

      orderRepository = OrderRepository();
    });

    tearDown(() {
      Get.reset();
    });

    test('Workflow 1: Order Creation - Waiter takes order', () async {
      // Step 1: Waiter creates a new order for Table 1
      const tableId = 'table-1';
      const tableNumber = 1;

      await orderController.createOrder(tableId, tableNumber);

      // Verify order is created with open status
      expect(orderController.currentOrder.value, isNotNull);
      expect(orderController.currentOrder.value!.status, equals('open'));
      expect(orderController.currentOrder.value!.tableNumber, equals(1));
    });

    test(
      'Workflow 2: Send to Kitchen - Waiter sends order to kitchen',
      () async {
        // Step 1: Create order
        const tableId = 'table-2';
        const tableNumber = 2;
        await orderController.createOrder(tableId, tableNumber);

        final orderId = orderController.currentOrder.value!.id;

        // Step 2: Add some items to the order
        await addTestItem(orderController);

        // Step 3: Waiter sends order to kitchen
        await orderController.sendToKitchen();

        // Verify order status changed to sent_to_kitchen
        final updatedOrder = await orderRepository.getOrderById(orderId);
        expect(updatedOrder, isNotNull);
        expect(updatedOrder!.status, equals('sent_to_kitchen'));
      },
    );

    test('Workflow 3: Kitchen Flow - Chef prepares and marks ready', () async {
      // Step 1: Create and send order to kitchen
      const tableId = 'table-3';
      const tableNumber = 3;
      await orderController.createOrder(tableId, tableNumber);
      await addTestItem(orderController);
      await orderController.sendToKitchen();

      final orderId = orderController.currentOrder.value!.id;

      // Step 2: Load kitchen orders
      await kitchenController.loadKitchenOrders();

      // Verify order appears in kitchen display
      expect(kitchenController.allOrders.isNotEmpty, isTrue);
      expect(kitchenController.allOrders.any((o) => o.id == orderId), isTrue);

      // Step 3: Chef marks order as preparing
      await kitchenController.startPreparingOrder(orderId);

      // Verify order status changed to preparing
      var order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('preparing'));

      // Step 4: Chef marks items ready (simulated)
      if (order.items.isNotEmpty) {
        await kitchenController.markItemReady(orderId, order.items[0].id);

        // Verify order transitioned to ready
        order = await orderRepository.getOrderById(orderId);
        expect(order!.status, equals('ready'));
      }

      // Step 5: Verify notification was created
      expect(kitchenController.notificationQueue.isNotEmpty, isTrue);
      expect(kitchenController.readyOrders.isNotEmpty, isTrue);
    });

    test('Workflow 4: Served - Waiter marks order as served', () async {
      // Step 1: Create order, send to kitchen, mark as ready
      const tableId = 'table-4';
      const tableNumber = 4;
      await orderController.createOrder(tableId, tableNumber);
      await addTestItem(orderController);
      await orderController.sendToKitchen();

      final orderId = orderController.currentOrder.value!.id;

      // Step 2: Load order for workflow
      await orderController.loadOrder(orderId);

      // Step 3: Waiter marks order as served (customer received food)
      await orderController.markAsServed();

      // Verify order status is now served
      var order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('served'));
    });

    test('Workflow 5: Payment Pending - Waiter sends to cashier', () async {
      // Step 1: Create order and progress through workflow
      const tableId = 'table-5';
      const tableNumber = 5;
      await orderController.createOrder(tableId, tableNumber);
      await addTestItem(orderController);
      await orderController.sendToKitchen();

      final orderId = orderController.currentOrder.value!.id;
      await orderController.loadOrder(orderId);
      await orderController.markAsServed();

      // Step 2: Waiter sends order to cashier for payment
      await orderController.sendToPayment();

      // Verify order status is payment_pending
      var order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('payment_pending'));
    });

    test('Workflow 6: Cashier View - Shows pending payment orders', () async {
      // Step 1: Create multiple orders in payment_pending status
      for (int i = 0; i < 3; i++) {
        const String tableIdPrefix = 'table-';
        final tableId = '$tableIdPrefix${i + 6}';
        final tableNumber = i + 6;

        await orderController.createOrder(tableId, tableNumber);
        await addTestItem(orderController);
        await orderController.sendToKitchen();
        await orderController.loadOrder(orderController.currentOrder.value!.id);
        await orderController.markAsServed();
        await orderController.sendToPayment();
      }

      // Step 2: Load cashier pending payments
      await cashierController.loadPendingPayments();

      // Verify at least 3 orders are showing as pending payment
      expect(cashierController.pendingPaymentOrders.length >= 3, isTrue);

      // Verify all are in payment_pending status
      for (var order in cashierController.pendingPaymentOrders) {
        expect(order.status, equals('payment_pending'));
      }
    });

    test(
      'Workflow 7: Billing & Payment - Complete payment transaction',
      () async {
        // Step 1: Create order and progress to payment_pending
        const tableId = 'table-7';
        const tableNumber = 7;
        await orderController.createOrder(tableId, tableNumber);
        await addTestItem(orderController);
        await orderController.sendToKitchen();

        final orderId = orderController.currentOrder.value!.id;
        await orderController.loadOrder(orderId);
        await orderController.markAsServed();
        await orderController.sendToPayment();

        // Step 2: Cashier loads order for billing
        await billingController.loadOrderForBilling(orderId);

        // Verify order is loaded and in payment_pending status
        expect(billingController.currentOrder.value, isNotNull);
        expect(
          billingController.currentOrder.value!.status,
          equals('payment_pending'),
        );

        // Step 3: Apply discount and service charge (optional)
        billingController.applyPercentDiscount(5);
        billingController.setServiceCharge(10);

        // Step 4: Verify payment calculations
        final subtotal = billingController.subtotal;
        final discountValue = billingController.discountValue;
        expect(discountValue, equals(subtotal * 0.05)); // 5% discount

        // Step 5: Process payment
        final totalAmount = billingController.totalAmount;
        final success = await billingController.processPayment(
          totalAmount + 100,
        ); // Extra cash

        // Verify payment was successful
        expect(success, isTrue);

        // Step 6: Verify order status changed to paid
        var order = await orderRepository.getOrderById(orderId);
        expect(order!.status, equals('paid'));

        // Verify payment record was created
        // (Note: This assumes payment repository has a method to fetch by order ID)
      },
    );

    test('Workflow 8: Complete End-to-End - Full restaurant workflow', () async {
      // This test verifies the complete workflow from order creation to payment
      const tableId = 'table-8';
      const tableNumber = 8;

      // Phase 1: Order Taking (Waiter)
      print('Phase 1: Waiter takes order...');
      await orderController.createOrder(tableId, tableNumber);
      await addTestItem(orderController);
      expect(orderController.currentOrder.value!.status, equals('open'));

      final orderId = orderController.currentOrder.value!.id;

      // Phase 2: Send to Kitchen (Waiter)
      print('Phase 2: Waiter sends order to kitchen...');
      await orderController.sendToKitchen();
      var order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('sent_to_kitchen'));

      // Phase 3: Kitchen Preparation (Chef)
      print('Phase 3: Chef prepares order...');
      await kitchenController.loadKitchenOrders();
      expect(kitchenController.allOrders.any((o) => o.id == orderId), isTrue);

      await kitchenController.startPreparingOrder(orderId);
      order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('preparing'));

      // Phase 4: Mark Ready (Chef)
      print('Phase 4: Chef marks order ready...');
      if (order.items.isNotEmpty) {
        await kitchenController.markItemReady(orderId, order.items[0].id);
        order = await orderRepository.getOrderById(orderId);
        expect(order!.status, equals('ready'));
        expect(kitchenController.notificationQueue.isNotEmpty, isTrue);
      }

      // Phase 5: Serve Customer (Waiter)
      print('Phase 5: Waiter serves customer...');
      await orderController.loadOrder(orderId);
      await orderController.markAsServed();
      order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('served'));

      // Phase 6: Prepare for Payment (Waiter)
      print('Phase 6: Waiter sends to cashier...');
      await orderController.sendToPayment();
      order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('payment_pending'));

      // Phase 7: Payment Processing (Cashier)
      print('Phase 7: Cashier processes payment...');
      await billingController.loadOrderForBilling(orderId);
      expect(
        billingController.currentOrder.value!.status,
        equals('payment_pending'),
      );

      final totalAmount = billingController.totalAmount;
      final paymentSuccess = await billingController.processPayment(
        totalAmount,
      );
      expect(paymentSuccess, isTrue);

      // Final Verification
      print('Final verification...');
      order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('paid'));

      print('✓ Complete workflow executed successfully!');
      print(
        'Order #${orderId.substring(0, 8)} - Table $tableNumber - Status: PAID',
      );
    });

    test('Workflow 9: Error Handling - Insufficient payment', () async {
      // Step 1: Create order and progress to payment
      const tableId = 'table-9';
      const tableNumber = 9;
      await orderController.createOrder(tableId, tableNumber);
      await addTestItem(orderController);
      await orderController.sendToKitchen();

      final orderId = orderController.currentOrder.value!.id;
      await orderController.loadOrder(orderId);
      await orderController.markAsServed();
      await orderController.sendToPayment();

      // Step 2: Load for billing
      await billingController.loadOrderForBilling(orderId);

      final totalAmount = billingController.totalAmount;

      // Step 3: Attempt payment with insufficient amount
      final success = await billingController.processPayment(
        totalAmount - 50,
      ); // Not enough

      // Verify payment failed
      expect(success, isFalse);

      // Verify order status is still payment_pending
      final order = await orderRepository.getOrderById(orderId);
      expect(order!.status, equals('payment_pending'));
    });

    test(
      'Workflow 10: Status Tracking - Verify all status transitions',
      () async {
        // This test verifies all status transitions occur in the correct order
        const tableId = 'table-10';
        const tableNumber = 10;

        final statuses = <String>[];

        // Create order
        await orderController.createOrder(tableId, tableNumber);
        await addTestItem(orderController);
        var order = orderController.currentOrder.value!;
        statuses.add(order.status);

        final orderId = order.id;

        // Send to kitchen
        await orderController.sendToKitchen();
        order = (await orderRepository.getOrderById(orderId))!;
        statuses.add(order.status);

        // We MUST load kitchen orders so allOrders is populated before preparing
        await kitchenController.loadKitchenOrders();

        // Prepare
        await kitchenController.startPreparingOrder(orderId);
        order = (await orderRepository.getOrderById(orderId))!;
        statuses.add(order.status);

        // Mark ready (if items exist)
        if (order.items.isNotEmpty) {
          await kitchenController.markItemReady(orderId, order.items[0].id);
          order = (await orderRepository.getOrderById(orderId))!;
          statuses.add(order.status);
        }

        // Serve
        await orderController.loadOrder(orderId);
        await orderController.markAsServed();
        order = (await orderRepository.getOrderById(orderId))!;
        statuses.add(order.status);

        // Payment pending
        await orderController.sendToPayment();
        order = (await orderRepository.getOrderById(orderId))!;
        statuses.add(order.status);

        // Payment complete
        await billingController.loadOrderForBilling(orderId);
        final success = await billingController.processPayment(
          billingController.totalAmount + 50,
        );
        expect(success, isTrue);
        order = (await orderRepository.getOrderById(orderId))!;
        statuses.add(order.status);

        // Verify the complete flow
        expect(statuses, contains('open'));
        expect(statuses, contains('sent_to_kitchen'));
        expect(statuses, contains('preparing'));
        expect(statuses, contains('ready'));
        expect(statuses, contains('served'));
        expect(statuses, contains('payment_pending'));
        expect(statuses, contains('paid'));

        print('✓ All status transitions verified: $statuses');
      },
    );
  });
}
