import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../core/widgets/admin_bottom_nav_bar.dart';
import '../../../services/auth_service.dart';
import '../../../data/models/order_model.dart';
import '../controllers/kitchen_controller.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kitchenController = Get.put(KitchenController());
    final role = AuthService.instance.getUserRole();

    // Trigger loading orders on screen launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      kitchenController.loadKitchenOrders();
    });

    return FluidVideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: const AdminBottomNavBar(currentIndex: 3),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kitchen Display System', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                'Real-time order tracking',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: (Navigator.of(context).canPop() || role == 'admin')
              ? IconButton(
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
                  },
                )
              : null,
          actions: [
            Obx(() => TextButton.icon(
              onPressed: () => kitchenController.showDashboard.toggle(),
              icon: Icon(
                kitchenController.showDashboard.value ? Icons.restaurant_menu : Icons.analytics_outlined,
                color: Colors.white,
              ),
              label: Text(
                kitchenController.showDashboard.value ? 'Active Queue' : 'Chef Summary',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => kitchenController.refreshOrders(),
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
        body: Obx(() {
          if (kitchenController.isLoading.value) {
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
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          }

          if (kitchenController.showDashboard.value) {
            return _buildChefDashboard(context, kitchenController);
          }

          if (kitchenController.allOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientBluePurple,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.done_all,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Pending Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kitchen all caught up! 🎉',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 1380
                  ? 4
                  : width >= 1040
                  ? 3
                  : width >= 720
                  ? 2
                  : 1;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: width < 720 ? 1.15 : 0.85,
                ),
                itemCount: kitchenController.allOrders.length,
                itemBuilder: (context, index) {
                  final order = kitchenController.allOrders[index];
                  return SlideInWidget(
                    begin: Offset((index % 2) * 0.5 - 0.25, (index ~/ 2) * 0.3),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    child: _buildOrderCard(context, order, kitchenController),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    dynamic order,
    KitchenController controller,
  ) {
    final isReadyOrServed = order.status == 'ready' || order.status == 'served';

    return PulseWidget(
      minScale: 0.95,
      maxScale: 1.0,
      duration: isReadyOrServed ? AppAnimations.medium : AppAnimations.verySlow,
      child: GlassContainer(
        backdropColor: AppColors.glassOverlayBlueMed,
        shadows: AppAnimations.shadowGlowTeal,
        borderRadius: AppAnimations.radiusLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header with Status Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getOrderStatusGradient(order.status),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppAnimations.radiusMedium,
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
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Table ${order.tableNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  PulseWidget(
                    minScale: 0.9,
                    maxScale: 1.1,
                    duration: AppAnimations.fast,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        _getStatusIcon(order.status),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Order Items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order.items.asMap().entries.map<Widget>((entry) {
                    final itemIndex = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SlideInWidget(
                        begin: const Offset(-0.3, 0),
                        duration: Duration(
                          milliseconds: 350 + ((itemIndex as int) * 50),
                        ),
                        child: _buildItemDisplay(item),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                String label;
                IconData icon;
                List<Color> gradientColors;
                VoidCallback onTap;

                if (order.status == 'sent_to_kitchen') {
                  label = 'Start Preparing';
                  icon = Icons.local_fire_department;
                  gradientColors = const [AppColors.accentOrange, Color(0xFFD84315)];
                  onTap = () => controller.startPreparingOrder(order.id);
                } else if (order.status == 'preparing') {
                  label = 'Mark Ready';
                  icon = Icons.done;
                  gradientColors = const [AppColors.accentTeal, AppColors.accentTealDark];
                  onTap = () => controller.markOrderReady(order.id);
                } else {
                  label = 'Mark Served';
                  icon = Icons.check_circle;
                  gradientColors = const [AppColors.success, Color(0xFF2E7D32)];
                  onTap = () => controller.markOrderServed(order.id);
                }

                if (order.status == 'sent_to_kitchen' || order.status == 'preparing') {
                  return Row(
                    children: [
                      // Reject Button
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red.shade800, Colors.red.shade500],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppAnimations.radiusLarge,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.rejectOrder(order.id),
                              borderRadius: AppAnimations.radiusLarge,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.cancel_outlined, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Reject',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Primary action button (Start Prep / Ready)
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppAnimations.radiusLarge,
                            boxShadow: AppAnimations.shadowGlow,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onTap,
                              borderRadius: AppAnimations.radiusLarge,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icon, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
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
                  );
                }

                // Full width button for serving
                return SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppAnimations.radiusLarge,
                      boxShadow: AppAnimations.shadowGlow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: AppAnimations.radiusLarge,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
        color: AppColors.glassOverlayPurple,
        borderRadius: AppAnimations.radiusSmall,
        border: const Border(
          left: BorderSide(color: AppColors.accentTeal, width: 3),
        ),
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
                    fontSize: 13,
                    color: AppColors.lightText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if ((item.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '📝 ${item.notes}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.warning,
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

  List<Color> _getOrderStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return [Colors.orange.shade700, Colors.orange.shade600];
      case 'confirmed':
        return [Colors.blue.shade700, Colors.blue.shade600];
      case 'preparing':
        return [Colors.amber.shade700, Colors.amber.shade600];
      case 'ready':
        return [Colors.green.shade700, Colors.green.shade600];
      case 'served':
        return [Colors.teal.shade700, Colors.teal.shade600];
      case 'cancelled':
        return [Colors.red.shade700, Colors.red.shade600];
      default:
        return [AppColors.primary, AppColors.accentTeal];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.local_fire_department;
      case 'ready':
        return Icons.done;
      case 'served':
        return Icons.restaurant;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  // ==================== CHEF DASHBOARD UI HELPER METHODS ====================
  Widget _buildChefDashboard(BuildContext context, KitchenController controller) {
    final acceptedCount = controller.dailyOrders.where((o) => o.status == 'preparing').length;
    final preparedCount = controller.dailyOrders.where((o) => o.status == 'ready' || o.status == 'served' || o.status == 'paid').length;
    final rejectedCount = controller.dailyOrders.where((o) => o.status == 'cancelled').length;

    final preparedDishCounts = <String, int>{};
    for (final order in controller.dailyOrders) {
      if (order.status != 'cancelled') {
        for (final item in order.items) {
          if (item.status == OrderItemStatus.ready ||
              item.status == OrderItemStatus.served) {
            preparedDishCounts[item.itemName] = (preparedDishCounts[item.itemName] ?? 0) + item.quantity;
          }
        }
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chef Performance Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Real-time overview of accepted, prepared, and rejected kitchen orders for today.',
              style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDashboardMetricTile(
                    'Accepted & Cooking',
                    '$acceptedCount',
                    Icons.soup_kitchen_outlined,
                    AppColors.accentOrange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDashboardMetricTile(
                    'Prepared (Ready)',
                    '$preparedCount',
                    Icons.check_circle_outline,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDashboardMetricTile(
                    'Rejected / Cancelled',
                    '$rejectedCount',
                    Icons.cancel_outlined,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                
                final leftColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PREPARED FOOD DETAILS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      backdropColor: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      child: preparedDishCounts.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text(
                                  'No dishes prepared today yet.',
                                  style: TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              ),
                            )
                          : Column(
                              children: preparedDishCounts.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.restaurant, color: AppColors.accentTeal, size: 14),
                                          const SizedBox(width: 8),
                                          Text(
                                            entry.key,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentTeal.withOpacity(0.14),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Qty: ${entry.value}',
                                          style: const TextStyle(
                                            color: AppColors.accentTeal,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                );

                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY ORDERS LOG',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    controller.dailyOrders.isEmpty
                        ? GlassContainer(
                            backdropColor: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.all(24),
                            child: const Center(
                              child: Text(
                                'No orders processed today.',
                                style: TextStyle(color: Colors.white38, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.dailyOrders.length,
                            itemBuilder: (context, index) {
                              final order = controller.dailyOrders[index];
                              return _buildChefHistoryTile(order);
                            },
                          ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: leftColumn),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: rightColumn),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      leftColumn,
                      const SizedBox(height: 24),
                      rightColumn,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChefHistoryTile(OrderModel order) {
    Color statusColor;
    switch (order.status) {
      case 'sent_to_kitchen':
        statusColor = AppColors.info;
        break;
      case 'preparing':
        statusColor = AppColors.accentOrange;
        break;
      case 'ready':
      case 'served':
      case 'paid':
        statusColor = AppColors.success;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
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
                    'Table ${order.tableNumber} - Order',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'ID: #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 6),
          Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.white30, size: 5),
                    const SizedBox(width: 6),
                    Text(
                      '${item.quantity}x ${item.itemName}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
