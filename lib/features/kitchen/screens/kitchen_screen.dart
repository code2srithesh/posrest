import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../core/widgets/admin_bottom_nav_bar.dart';
import '../../../services/auth_service.dart';
import '../controllers/kitchen_controller.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kitchenController = Get.put(KitchenController());
    final role = AuthService.instance.getUserRole();

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
}
