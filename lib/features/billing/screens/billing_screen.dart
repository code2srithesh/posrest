import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../controllers/billing_controller.dart';
import '../../../services/auth_service.dart';

class BillingScreen extends StatelessWidget {
  final String orderId;

  const BillingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final billingController = Get.put(BillingController());
    final scrollController = ScrollController();

    // Load order on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      billingController.loadOrderForBilling(orderId);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.accentBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }

            final role = AuthService.instance.getUserRole();
            if (role == 'cashier') {
              Get.offAllNamed('/cashier');
            } else {
              Get.offAllNamed('/tables');
            }
          },
        ),
        actions: [const ThemeToggleButton(compact: true)],
      ),
      body: AnimatedGradientBG(
        colors: const [
          AppColors.gradientStart,
          AppColors.primaryDark,
          AppColors.gradientEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -60,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentTeal.withOpacity(0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -70,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentOrange.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Obx(() {
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

              return ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  overscroll: false,
                ),
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInWidget(
                              duration: AppAnimations.medium,
                              child: GlassContainer(
                                backdropColor: AppColors.glassOverlayPurpleDeep,
                                shadows: AppAnimations.shadowGlow,
                                borderRadius: AppAnimations.radiusXL,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Order #${order.id.substring(0, 8)}',
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.accentTeal,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Table: ${order.tableNumber}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors
                                                    .lightTextSecondary,
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
                                            ).withOpacity(0.16),
                                            border: Border.all(
                                              color: _getStatusColor(
                                                order.status,
                                              ),
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                AppAnimations.radiusCircle,
                                          ),
                                          child: Text(
                                            order.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: _getStatusColor(
                                                order.status,
                                              ),
                                              letterSpacing: 1.0,
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
                            GlassContainer(
                              backdropColor: AppColors.glassOverlayBlackMed,
                              borderRadius: AppAnimations.radiusXL,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Items',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.lightText,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...items
                                      .map((item) => _buildItemRow(item))
                                      .toList(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Bill Breakdown',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.lightText,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SlideInWidget(
                              begin: const Offset(-0.5, 0),
                              duration: AppAnimations.medium,
                              child: _buildCalculationCard(
                                'Subtotal',
                                billingController.subtotal,
                                AppColors.accentTeal,
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
                            const SizedBox(height: 8),
                            SlideInWidget(
                              begin: const Offset(-0.5, 0),
                              duration: const Duration(milliseconds: 430),
                              child: Obx(
                                () => _buildCalculationCard(
                                  'Service Charge',
                                  billingController.serviceCharge,
                                  AppColors.accentOrange,
                                ),
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
                              child: _buildTotalRow(
                                billingController.totalAmount,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SlideInWidget(
                              begin: const Offset(0, 0.5),
                              duration: AppAnimations.medium,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment Method',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: AppColors.lightText,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPaymentMethodChips(billingController),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SlideInWidget(
                              begin: const Offset(0, 1),
                              duration: AppAnimations.medium,
                              child: SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.gradientPrimaryTeal,
                                    ),
                                    borderRadius: AppAnimations.radiusLarge,
                                    boxShadow: AppAnimations.shadowGlowTeal,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () =>
                                          _handlePayment(billingController),
                                      borderRadius: AppAnimations.radiusLarge,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                Obx(
                                                  () => Text(
                                                    '₹${billingController.totalAmount.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w800,
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
                            GlassContainer(
                              borderRadius: AppAnimations.radiusLarge,
                              backdropColor: AppColors.glassOverlayBlackMed,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => billingController.printReceipt(),
                                  borderRadius: AppAnimations.radiusLarge,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.print,
                                          color: AppColors.lightText,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Print Receipt',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.lightText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: AppAnimations.radiusLarge,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((item.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Notes: ${item.notes}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.glassOverlayTeal,
                borderRadius: AppAnimations.radiusCircle,
              ),
              child: Text(
                '${item.quantity}x',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentTeal,
                ),
              ),
            ),
            const SizedBox(width: 12),
            CurrencyDisplay(
              amount: item.totalPrice,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSection(BillingController controller) {
    return GlassContainer(
      backdropColor: AppColors.glassOverlayBlueMed,
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
                    color: AppColors.error,
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
                        activeColor: AppColors.accentTeal,
                        inactiveColor: Colors.white24,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: controller.serviceChargePercent.value,
                        min: 0,
                        max: 15,
                        divisions: 15,
                        label:
                            '${controller.serviceChargePercent.value.toStringAsFixed(0)}%',
                        onChanged: controller.setServiceCharge,
                        activeColor: AppColors.accentOrange,
                        inactiveColor: Colors.white24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glassOverlayPurple,
                        borderRadius: AppAnimations.radiusSmall,
                      ),
                      child: Text(
                        'SC ${controller.serviceChargePercent.value.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentOrange,
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
        final role = AuthService.instance.getUserRole();
        if (role == 'cashier') {
          Get.offAllNamed('/cashier');
        } else {
          Get.offAllNamed('/tables');
        }
      });
    }
  }
}
