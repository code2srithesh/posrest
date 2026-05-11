import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../services/auth_service.dart';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment & Billing'),
            Text(
              'Confirm before checkout',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        elevation: 8,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accentOrange, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [const ThemeToggleButton(compact: true)],
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
                FadeInWidget(
                  duration: AppAnimations.medium,
                  child: GlassContainer(
                    backdropColor: AppColors.glassOverlayPurpleMed,
                    shadows: AppAnimations.shadowGlow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.id.substring(0, 8)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentTeal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Table: ${order.tableNumber}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  order.status,
                                ).withOpacity(0.2),
                                border: Border.all(
                                  color: _getStatusColor(order.status),
                                  width: 2,
                                ),
                                borderRadius: AppAnimations.radiusMedium,
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _getStatusColor(order.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Order Items
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => _buildItemRow(item)).toList(),
                const Divider(thickness: 2),

                // Calculations Section with Glass Cards
                const SizedBox(height: 12),
                Text(
                  'Bill Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SlideInWidget(
                  begin: const Offset(-0.5, 0),
                  duration: AppAnimations.medium,
                  child: _buildCalculationCard(
                    'Subtotal',
                    billingController.subtotal,
                    Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                SlideInWidget(
                  begin: const Offset(-0.5, 0),
                  duration: const Duration(milliseconds: 400),
                  child: _buildCalculationCard(
                    'Tax (GST)',
                    billingController.gstAmount,
                    AppColors.info,
                  ),
                ),
                const SizedBox(height: 12),
                SlideInWidget(
                  begin: const Offset(-0.5, 0),
                  duration: const Duration(milliseconds: 450),
                  child: _buildDiscountSection(billingController),
                ),
                const SizedBox(height: 12),
                FadeInWidget(
                  duration: AppAnimations.slow,
                  child: _buildTotalRow(billingController.totalAmount),
                ),

                const SizedBox(height: 24),

                // Payment Method Selection
                SlideInWidget(
                  begin: const Offset(0, 0.5),
                  duration: AppAnimations.medium,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.lightText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodChips(billingController),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                SlideInWidget(
                  begin: const Offset(0, 1),
                  duration: AppAnimations.medium,
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.gradientPrimaryTeal,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppAnimations.radiusLarge,
                        boxShadow: AppAnimations.shadowGlow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handlePayment(billingController),
                          borderRadius: AppAnimations.radiusLarge,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    const Text(
                                      'Complete Payment',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        '₹${billingController.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBorder,
                        width: 2,
                      ),
                      borderRadius: AppAnimations.radiusLarge,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => billingController.printReceipt(),
                        borderRadius: AppAnimations.radiusLarge,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.print, color: AppColors.lightText),
                              SizedBox(width: 12),
                              Text(
                                'Print Receipt',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
    return GlassContainer(
      backdropColor: AppColors.glassOverlayPurple,
      shadows: AppAnimations.shadowSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discount & Service Charge',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightText,
                ),
              ),
              Obx(
                () => Text(
                  '-₹${controller.discountValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: controller.discountPercent.value,
                        min: 0,
                        max: 50,
                        divisions: 50,
                        label:
                            '${controller.discountPercent.value.toStringAsFixed(1)}%',
                        onChanged: controller.applyPercentDiscount,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glassOverlayTeal,
                        borderRadius: AppAnimations.radiusSmall,
                      ),
                      child: Text(
                        '${controller.discountPercent.value.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientPrimaryTeal,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppAnimations.radiusLarge,
        boxShadow: AppAnimations.shadowGlow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationCard(String label, double amount, Color accentColor) {
    return GlassContainer(
      backdropColor: AppColors.glassOverlayPurple,
      shadows: AppAnimations.shadowSmall,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightText,
                ),
              ),
            ],
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChips(BillingController controller) {
    final methods = [
      ('cash', 'Cash', Icons.money),
      ('card', 'Card', Icons.credit_card),
      ('upi', 'UPI', Icons.phone_android),
      ('online', 'Online', Icons.language),
    ];

    return Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: methods.map((method) {
          final isSelected =
              controller.selectedPaymentMethod.value == method.$1;
          return GlassContainer(
            backdropColor: isSelected
                ? AppColors.glassOverlayTealMed
                : AppColors.glassOverlayPurple,
            shadows: isSelected
                ? AppAnimations.shadowGlowTeal
                : AppAnimations.shadowSmall,
            interactive: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  controller.selectedPaymentMethod.value = method.$1;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        method.$3,
                        color: isSelected
                            ? AppColors.accentTeal
                            : AppColors.lightTextSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        method.$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.accentTeal
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'preparing':
        return AppColors.warning;
      case 'ready':
        return AppColors.success;
      case 'served':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.lightTextSecondary;
    }
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
