import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../controllers/billing_controller.dart';

class BillingScreen extends StatelessWidget {
  final String orderId;

  const BillingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final billingController = Get.put(BillingController());

    // Load order on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      billingController.loadOrderForBilling(orderId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: Obx(() {
        if (billingController.isLoading.value) {
          return const LoadingIndicator(message: 'Loading bill...');
        }

        if (billingController.currentOrder.value == null) {
          return const EmptyStateWidget(
            title: 'No Order Found',
            message: 'Unable to load order details',
            icon: Icons.receipt_long,
          );
        }

        final order = billingController.currentOrder.value!;
        final items = order.items;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                PosCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Table: ${order.tableNumber}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(status: order.status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Items
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => _buildItemRow(item)).toList(),
                const Divider(thickness: 2),

                // Calculations
                const SizedBox(height: 12),
                _buildCalculationRow('Subtotal', billingController.subtotal),
                _buildCalculationRow('Tax (5%)', billingController.taxAmount),
                const SizedBox(height: 8),
                _buildDiscountSection(billingController),
                const SizedBox(height: 12),
                _buildTotalRow(billingController.totalAmount),

                const SizedBox(height: 24),

                // Payment Method Selection
                const Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodChips(billingController),

                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label:
                        'Complete Payment (₹${billingController.totalAmount.toStringAsFixed(2)})',
                    onPressed: () => _handlePayment(billingController),
                    isLoading: billingController.isLoading.value,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: 'Print Receipt',
                    onPressed: () => billingController.printReceipt(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildItemRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((item.notes ?? '').isNotEmpty)
                  Text(
                    'Notes: ${item.notes}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${item.quantity}x', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 12),
          CurrencyDisplay(
            amount: item.totalPrice,
            textStyle: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        CurrencyDisplay(
          amount: amount,
          textStyle: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDiscountSection(BillingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Discount', style: TextStyle(fontSize: 14)),
            CurrencyDisplay(
              amount: controller.discountAmount,
              textStyle: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: Slider(
                  value: controller.discountPercent.value,
                  min: 0,
                  max: 50,
                  divisions: 50,
                  label:
                      '${controller.discountPercent.value.toStringAsFixed(1)}%',
                  onChanged: controller.applyDiscount,
                ),
              ),
              Text(
                '${controller.discountPercent.value.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(double total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          CurrencyDisplay(
            amount: total,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChips(BillingController controller) {
    final methods = ['cash', 'card', 'upi', 'online'];
    final methodLabels = {
      'cash': 'Cash',
      'card': 'Card',
      'upi': 'UPI',
      'online': 'Online',
    };

    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: methods.map((method) {
          final isSelected = controller.selectedPaymentMethod.value == method;
          return FilterChip(
            label: Text(methodLabels[method] ?? method),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                controller.selectedPaymentMethod.value = method;
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _handlePayment(BillingController controller) async {
    final amount = controller.totalAmount;
    if (amount <= 0) {
      Get.snackbar('Error', 'Invalid amount');
      return;
    }

    final result = await controller.processPayment(amount);
    if (result) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
        Get.back();
      });
    }
  }
}
