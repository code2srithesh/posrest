import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../controllers/kitchen_controller.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kitchenController = Get.put(KitchenController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display System'),
        elevation: 0,
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => kitchenController.refreshOrders(),
          ),
          const ThemeToggleButton(compact: true),
        ],
      ),
      body: Obx(() {
        if (kitchenController.isLoading.value) {
          return const LoadingIndicator(message: 'Loading orders...');
        }

        if (kitchenController.pendingOrders.isEmpty) {
          return const EmptyStateWidget(
            title: 'No Pending Orders',
            message: 'Kitchen all caught up!',
            icon: Icons.done_all,
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: kitchenController.pendingOrders.length,
          itemBuilder: (context, index) {
            final order = kitchenController.pendingOrders[index];
            return _buildOrderCard(context, order, kitchenController);
          },
        );
      }),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    dynamic order,
    KitchenController controller,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.red, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Table ${order.tableNumber}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Icon(Icons.local_restaurant, color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Order Items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order.items.map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildItemDisplay(item),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => controller.markOrderServed(order.id),
                child: const Text(
                  'Served ✓',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDisplay(dynamic item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.quantity}x ${item.itemName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Notes: ${item.notes}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
