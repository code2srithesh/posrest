import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/menu/controllers/menu_controller.dart' as menu_ctrl;
import '../controllers/order_controller.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuController = Get.put(menu_ctrl.MenuController());
    final orderController = Get.put(OrderController());

    // Get arguments from navigation
    final arguments = Get.arguments ?? {};
    final tableId = arguments['tableId'] as String?;
    final tableNumber = arguments['tableNumber'] as int?;

    // Create order if needed
    if (tableId != null &&
        tableNumber != null &&
        orderController.currentOrder.value == null) {
      Future.microtask(() => orderController.createOrder(tableId, tableNumber));
    }

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text('Table ${tableNumber ?? 'N/A'} - Order'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => Center(
                child: Text(
                  'Items: ${orderController.getItemCount()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (menuController.isLoading.value || orderController.isLoading.value) {
          return const LoadingIndicator(message: 'Loading...');
        }

        return Row(
          children: [
            // Menu Section (Left)
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Category Tabs
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      itemCount: menuController.categories.length,
                      itemBuilder: (context, index) {
                        final category = menuController.categories[index];
                        final isSelected =
                            menuController.selectedCategoryId.value ==
                            category.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(category.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              menuController.loadItemsByCategory(category.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Menu Items Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: menuController.menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuController.menuItems[index];
                        return _buildMenuItemCard(
                          item,
                          orderController,
                          context,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Order Cart Section (Right)
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  border: Border(left: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Column(
                  children: [
                    // Cart Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        border: Border(
                          bottom: BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                      child: const Text(
                        'Current Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Items List
                    Expanded(
                      child: Obx(() {
                        if (orderController.currentOrderItems.isEmpty) {
                          return const Center(
                            child: Text(
                              'No items added yet',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: orderController.currentOrderItems.length,
                          itemBuilder: (context, index) {
                            final item =
                                orderController.currentOrderItems[index];
                            return _buildOrderItemTile(
                              item,
                              index,
                              orderController,
                            );
                          },
                        );
                      }),
                    ),
                    // Totals Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                      child: Obx(
                        () => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal:',
                                  style: TextStyle(fontSize: 14),
                                ),
                                CurrencyDisplay(
                                  amount: orderController.subtotal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tax (${AppConstants.currencySymbol}):',
                                  style: TextStyle(fontSize: 14),
                                ),
                                CurrencyDisplay(
                                  amount: orderController.taxAmount,
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                CurrencyDisplay(
                                  amount: orderController.totalAmount,
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    label: 'Cancel',
                                    onPressed: () => Get.back(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: PrimaryButton(
                                    label: 'Send to Kitchen',
                                    onPressed: () =>
                                        orderController.completeOrder(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMenuItemCard(
    dynamic item,
    OrderController orderController,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => _showItemDetailsDialog(item, orderController, context),
      child: PosCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Icon/Image placeholder
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant_menu,
                  size: 32,
                  color: AppTheme.textLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Item Name
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              item.description ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CurrencyDisplay(
                  amount: item.price,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (item.isVegetarian)
                  const Tooltip(
                    message: 'Vegetarian',
                    child: Icon(
                      Icons.eco,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemTile(
    dynamic item,
    int index,
    OrderController orderController,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.notes != null)
                      Text(
                        'Note: ${item.notes}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => orderController.removeItemFromOrder(index),
                icon: const Icon(Icons.close, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => orderController.updateItemQuantity(
                      index,
                      item.quantity - 1,
                    ),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          '-',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => orderController.updateItemQuantity(
                      index,
                      item.quantity + 1,
                    ),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          '+',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              CurrencyDisplay(
                amount: item.totalPrice,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showItemDetailsDialog(
    dynamic item,
    OrderController orderController,
    BuildContext context,
  ) {
    int quantity = 1;
    // final selectedModifiers = <String>[].obs; // TODO: Implement modifier selection
    final notes = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Price: ${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                // Quantity
                const Text(
                  'Quantity:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) quantity--;
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        quantity++;
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  controller: notes,
                  decoration: InputDecoration(
                    labelText: 'Special Instructions',
                    hintText: 'e.g., No onion, Less spicy',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                // Add to Order Button
                PrimaryButton(
                  label: 'Add to Order',
                  onPressed: () {
                    orderController.addItemToOrder(
                      item,
                      quantity: quantity,
                      notes: notes.text.isNotEmpty ? notes.text : null,
                    );
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
