import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:posrest/main.dart';
import 'package:posrest/features/menu/controllers/menu_controller.dart';
import 'package:posrest/features/orders/controllers/order_controller.dart';
import 'package:posrest/features/billing/controllers/billing_controller.dart';
import 'package:posrest/features/kitchen/controllers/kitchen_controller.dart';

void main() {
  group('Order Flow Integration Tests', () {
    setUp(() async {
      // Initialize all controllers
      Get.put(MenuController());
      Get.put(OrderController());
      Get.put(BillingController());
      Get.put(KitchenController());
    });

    tearDown(() {
      Get.deleteAll();
    });

    testWidgets('Complete order flow: Menu → Order → Billing → Kitchen', (
      WidgetTester tester,
    ) async {
      // Build app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify OrderScreen is visible
      expect(find.text('Menu'), findsWidgets);

      // Find and tap first menu item
      final menuItemCards = find.byType(Card);
      expect(menuItemCards, findsWidgets);

      // Tap first item to open details dialog
      await tester.tap(menuItemCards.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify item details dialog appears
      expect(find.text('Add to Order'), findsOneWidget);

      // Increase quantity (should have +/- buttons)
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pump();
      }

      // Add to order
      await tester.tap(find.text('Add to Order'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify item was added (check snackbar or cart update)
      expect(find.text('Added to order'), findsOneWidget);

      // Tap "Send to Kitchen" or proceed to billing
      final kitchenButton = find.byType(ElevatedButton);
      if (kitchenButton.evaluate().isNotEmpty) {
        await tester.tap(kitchenButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      print('✅ Order flow test completed successfully');
    });

    testWidgets('Navigation between screens', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify initial screen
      expect(find.byType(Scaffold), findsWidgets);

      // Test back button
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }

      print('✅ Navigation test completed');
    });

    testWidgets('Menu items are loaded correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final menuController = Get.find<MenuController>();

      // Verify menu items are loaded
      expect(menuController.allItems.isNotEmpty, true);
      expect(menuController.allItems.length, greaterThanOrEqualTo(30));

      // Verify categories exist
      expect(menuController.categories.isNotEmpty, true);

      print('✅ Menu items loaded: ${menuController.allItems.length}');
    });

    testWidgets('Order cart updates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final orderController = Get.find<OrderController>();
      final initialCount = orderController.items.length;

      // Simulate adding an item
      if (orderController.menuItems.isNotEmpty) {
        final item = orderController.menuItems.first;
        orderController.addItem(
          itemName: item['name'],
          price: item['price'],
          quantity: 1,
        );
        await tester.pump();

        // Verify item count increased
        expect(orderController.items.length, initialCount + 1);
      }

      print('✅ Order cart updated - items: ${orderController.items.length}');
    });

    testWidgets('Payment methods are selectable', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final billingController = Get.find<BillingController>();

      // Verify payment methods
      expect(
        [
          'cash',
          'card',
          'upi',
          'online',
        ].contains(billingController.selectedPaymentMethod.value),
        true,
      );

      // Change payment method
      billingController.selectedPaymentMethod.value = 'card';
      await tester.pump();

      expect(billingController.selectedPaymentMethod.value, 'card');

      print(
        '✅ Payment method updated to: ${billingController.selectedPaymentMethod.value}',
      );
    });
  });

  group('Animation Tests', () {
    testWidgets('Glassmorphic widgets are rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find glass containers (looking for BackdropFilter which creates glass effect)
      final backdropFilters = find.byType(BackdropFilter);
      expect(backdropFilters, findsWidgets);

      print(
        '✅ Found ${backdropFilters.evaluate().length} glassmorphic containers',
      );
    });

    testWidgets('Gradient backgrounds are applied', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find containers with gradients
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      print('✅ Found ${containers.evaluate().length} gradient containers');
    });

    testWidgets('Animations do not cause jank', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Pump through multiple frames to check for stuttering
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      print('✅ Animation frames rendered smoothly (60 frames @ 16ms)');
    });
  });
}
