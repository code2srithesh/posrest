import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../core/widgets/admin_bottom_nav_bar.dart';
import '../../../services/auth_service.dart';
import '../controllers/cashier_controller.dart';

class CashierScreen extends StatelessWidget {
  const CashierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cashierController = Get.put(CashierController());

    // Load pending payments on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cashierController.loadPendingPayments();
    });

    final role = AuthService.instance.getUserRole();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cashier - Pending Payments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(
              'Orders waiting for checkout',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            if (role == 'admin') {
              Get.offAllNamed('/admin/users');
              return;
            }
            AuthService().logout().then((_) => Get.offAllNamed('/login'));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => cashierController.refreshPendingPayments(),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () =>
                AuthService().logout().then((_) => Get.offAllNamed('/login')),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
          const ThemeToggleButton(compact: true),
        ],
      ),
      body: FluidVideoBackground(
        child: Obx(() {
          if (cashierController.isLoading.value) {
            return Center(
              child: RotateWidget(
                duration: AppAnimations.slow,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBluePurple,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          }

          if (cashierController.pendingPaymentOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'All Payments Collected',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No pending payments! 🎉',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cashierController.pendingPaymentOrders.length,
            itemBuilder: (context, index) {
              final order = cashierController.pendingPaymentOrders[index];
              return SlideInWidget(
                begin: Offset(0, 0.3 + (index * 0.1)),
                duration: Duration(milliseconds: 300 + (index * 50)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPaymentCard(context, order, cashierController),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    dynamic order,
    CashierController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        backdropColor: AppColors.glassOverlayBlueMed,
        shadows: AppAnimations.shadowGlowTeal,
        borderRadius: AppAnimations.radiusLarge,
        child: InkWell(
          onTap: () => controller.goToBilling(order.id),
          borderRadius: AppAnimations.radiusLarge,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Table Number and Order ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table ${order.tableNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'READY TO PAY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 12),

                // Order Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.getItemsCount(order)} Items',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Amount',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          controller.getFormattedTotal(order),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap to collect payment →',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
