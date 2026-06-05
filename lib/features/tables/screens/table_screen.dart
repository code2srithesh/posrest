import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/admin_bottom_nav_bar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/auth_service.dart';
import '../controllers/table_controller.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class TableScreen extends StatelessWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final role = AuthService.instance.getUserRole();
    if (role == AppConstants.roleCashier) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/cashier');
      });
      return const Scaffold(body: SizedBox.shrink());
    } else if (role == AppConstants.roleChef) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/kitchen');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final controller = Get.put(TableController());

    return FluidVideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: const AdminBottomNavBar(currentIndex: 1),
        appBar: AppBar(
          title: const Text('Tables', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Obx(
                  () => GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    borderRadius: AppAnimations.radiusCircle,
                    backdropColor: AppColors.glassOverlayTealDeep,
                    shadows: AppAnimations.shadowGlowTeal,
                    child: Text(
                      'Occupied ${controller.getTablesCount(AppConstants.statusOccupied)}/${controller.tables.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const ThemeToggleButton(compact: true),
            IconButton(
              tooltip: 'Logout',
              onPressed: () {
                AuthService().logout().then((_) {
                  Get.offAllNamed('/login');
                });
              },
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              top: -80,
              right: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentTeal.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(message: 'Loading tables...');
              }

              if (controller.tables.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassContainer(
                    backdropColor: AppColors.glassOverlayPurpleDeep,
                    shadows: AppAnimations.shadowGlow,
                    child: EmptyStateWidget(
                      icon: Icons.table_restaurant_outlined,
                      title: 'No Tables',
                      message: 'Create your first table to get started',
                      action: PrimaryButton(
                        label: 'Create Table',
                        width: 200,
                        onPressed: () =>
                            _showCreateTableDialog(context, controller),
                      ),
                    ),
                  ),
                );
              }

              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: GlassContainer(
                        backdropColor: AppColors.glassOverlayPurpleDeep,
                        shadows: AppAnimations.shadowGlow,
                        borderRadius: AppAnimations.radiusXL,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.gradientPrimaryTeal,
                                    ),
                                    borderRadius: AppAnimations.radiusMedium,
                                  ),
                                  child: const Icon(
                                    Icons.table_restaurant,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Restaurant Tables Plan',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppColors.lightText,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap a table to manage dine-in orders and settlements',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  AppColors.lightTextSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                FloatingActionButton.small(
                                  backgroundColor: AppColors.accentTeal,
                                  onPressed: () => _showCreateTableDialog(
                                    context,
                                    controller,
                                  ),
                                  tooltip: 'Add Table',
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Dining Occupancy Rate Progress Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                borderRadius: AppAnimations.radiusMedium,
                                border: Border.all(color: Colors.white.withOpacity(0.04)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(Icons.analytics_outlined, size: 14, color: Colors.white70),
                                          SizedBox(width: 6),
                                          Text(
                                            'Dining Occupancy Rate',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${(controller.getTableOccupancyRate() * 100).toStringAsFixed(0)}% Capacity',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: controller.getTableOccupancyRate(),
                                      backgroundColor: Colors.white10,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricTile(
                                    'Free',
                                    controller.getTablesCount(
                                      AppConstants.statusFree,
                                    ),
                                    AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildMetricTile(
                                    'Occupied',
                                    controller.getTablesCount(
                                      AppConstants.statusOccupied,
                                    ),
                                    AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildMetricTile(
                                    'Reserved',
                                    controller.getTablesCount(
                                      AppConstants.statusReserved,
                                    ),
                                    AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassContainer(
                        backdropColor: AppColors.glassOverlayBlackMed,
                        borderRadius: AppAnimations.radiusXL,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterPill(
                                label: 'All',
                                selected: controller.filterStatus.value.isEmpty,
                                onTap: () => controller.filterStatus.value = '',
                              ),
                              _buildFilterPill(
                                label:
                                    'Free (${controller.getTablesCount(AppConstants.statusFree)})',
                                selected:
                                    controller.filterStatus.value ==
                                    AppConstants.statusFree,
                                onTap: () => controller.filterStatus.value =
                                    AppConstants.statusFree,
                              ),
                              _buildFilterPill(
                                label:
                                    'Occupied (${controller.getTablesCount(AppConstants.statusOccupied)})',
                                selected:
                                    controller.filterStatus.value ==
                                    AppConstants.statusOccupied,
                                onTap: () => controller.filterStatus.value =
                                    AppConstants.statusOccupied,
                              ),
                              _buildFilterPill(
                                label:
                                    'Reserved (${controller.getTablesCount(AppConstants.statusReserved)})',
                                selected:
                                    controller.filterStatus.value ==
                                    AppConstants.statusReserved,
                                onTap: () => controller.filterStatus.value =
                                    AppConstants.statusReserved,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount = width >= 1280
                              ? 5
                              : width >= 980
                              ? 4
                              : width >= 680
                              ? 3
                              : 2;
                          final aspectRatio = width < 680 ? 0.78 : 0.9;

                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: aspectRatio,
                                ),
                            itemCount: controller.getFilteredTables().length,
                            itemBuilder: (context, index) {
                              final table = controller
                                  .getFilteredTables()[index];
                              return SlideInWidget(
                                begin: const Offset(0, 0.12),
                                duration: Duration(
                                  milliseconds: 280 + index * 40,
                                ),
                                child: FadeInWidget(
                                  duration: Duration(
                                    milliseconds: 320 + index * 40,
                                  ),
                                  child: _buildTableCard(
                                    context,
                                    table,
                                    controller,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    dynamic table,
    TableController controller,
  ) {
    Color accentColor;
    Color glowColor;
    String statusLabel;

    switch (table.status) {
      case 'free':
        accentColor = AppColors.success;
        glowColor = AppColors.success.withOpacity(0.28);
        statusLabel = 'FREE';
        break;
      case 'occupied':
        accentColor = AppColors.error;
        glowColor = AppColors.error.withOpacity(0.28);
        statusLabel = 'OCCUPIED';
        break;
      case 'reserved':
        accentColor = AppColors.warning;
        glowColor = AppColors.warning.withOpacity(0.28);
        statusLabel = 'RESERVED';
        break;
      default:
        accentColor = AppColors.lightTextSecondary;
        glowColor = AppColors.lightTextSecondary.withOpacity(0.18);
        statusLabel = table.status.toUpperCase();
    }

    return GestureDetector(
      onTap: () {
        if (table.status == AppConstants.statusOccupied &&
            table.currentOrderId != null) {
          _showOccupiedTableHUD(context, controller, table);
        } else if (table.status == AppConstants.statusFree) {
          Get.toNamed(
            '/order/create',
            arguments: {'tableId': table.id, 'tableNumber': table.tableNumber},
          )?.then((_) => controller.loadTables());
        }
      },
      child: GlassContainer(
        interactive: true,
        borderRadius: AppAnimations.radiusXL,
        backdropColor: AppColors.glassOverlayPurpleDeep,
        shadows: [
          BoxShadow(
            color: glowColor,
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppAnimations.radiusXL,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                glowColor.withOpacity(0.14),
                Colors.white.withOpacity(0.03),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.35), accentColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.table_restaurant,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Table ${table.tableNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${table.occupiedSeats}/${table.capacity} seats',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.14),
                  borderRadius: AppAnimations.radiusCircle,
                  border: Border.all(color: accentColor.withOpacity(0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: AppAnimations.radiusCircle,
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: table.capacity == 0
                      ? 0
                      : table.occupiedSeats / table.capacity,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              if (table.status == AppConstants.statusOccupied)
                Obx(() {
                  final order = controller.openOrders[table.currentOrderId ?? ''];
                  if (order == null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.gradientPrimaryTeal,
                          ),
                          borderRadius: AppAnimations.radiusCircle,
                        ),
                        child: const Text(
                          'Open Order',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }

                  String label = 'Open Order';
                  Color startColor = AppColors.primary;
                  Color endColor = AppColors.accentTeal;
                  bool shouldPulse = false;

                  switch (order.status) {
                    case 'open':
                      label = 'Cart Empty';
                      startColor = Colors.teal;
                      endColor = Colors.teal.shade300;
                      break;
                    case 'sent_to_kitchen':
                      label = 'In Kitchen 🧑‍🍳';
                      startColor = Colors.blue.shade700;
                      endColor = Colors.blue.shade400;
                      break;
                    case 'preparing':
                      label = 'Cooking 🍳';
                      startColor = Colors.orange.shade700;
                      endColor = Colors.orange.shade400;
                      shouldPulse = true;
                      break;
                    case 'ready':
                      label = 'FOOD READY 🛎️';
                      startColor = Colors.green.shade700;
                      endColor = Colors.green.shade400;
                      shouldPulse = true;
                      break;
                    case 'served':
                      label = 'Served 🍽️';
                      startColor = Colors.cyan.shade700;
                      endColor = Colors.cyan.shade400;
                      break;
                    case 'payment_pending':
                      label = 'Payment 🧾';
                      startColor = Colors.amber.shade700;
                      endColor = Colors.amber.shade400;
                      shouldPulse = true;
                      break;
                  }

                  final badgeWidget = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [startColor, endColor],
                      ),
                      borderRadius: AppAnimations.radiusCircle,
                      boxShadow: [
                        if (shouldPulse)
                          BoxShadow(
                            color: startColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: shouldPulse ? PulseWidget(child: badgeWidget) : badgeWidget,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppAnimations.radiusLarge,
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white.withOpacity(0.05),
        selectedColor: AppColors.accentTeal.withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected ? AppColors.accentTeal : AppColors.lightTextSecondary,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(
          color: selected
              ? AppColors.accentTeal
              : Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  void _showCreateTableDialog(
    BuildContext context,
    TableController controller,
  ) {
    final tableNumberController = TextEditingController();
    final capacityController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: AppAnimations.radiusXL,
          backdropColor: AppColors.glassOverlayPurpleDeep,
          shadows: AppAnimations.shadowGlow,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.gradientPrimaryTeal,
                      ),
                      borderRadius: AppAnimations.radiusMedium,
                    ),
                    child: const Icon(Icons.add_circle_outline, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Create New Table',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: tableNumberController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Table Number',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g., 13',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.tag, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Capacity (seats)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g., 4',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.people_outline, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Create',
                      onPressed: () {
                        final tableNum = int.tryParse(tableNumberController.text.trim());
                        final cap = int.tryParse(capacityController.text.trim());
                        if (tableNum == null || cap == null || tableNum <= 0 || cap <= 0) {
                          Get.snackbar(
                            'Validation Error',
                            'Please enter valid numbers greater than 0.',
                            backgroundColor: AppColors.error,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }
                        controller.createTable(tableNum, cap);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOccupiedTableHUD(BuildContext context, TableController controller, dynamic table) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Obx(() {
          final order = controller.openOrders[table.currentOrderId ?? ''];
          if (order == null) {
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0A26).withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 36),
                    const SizedBox(height: 12),
                    const Text('Failed to find active order details', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    )
                  ],
                ),
              ),
            );
          }
          return _buildOccupiedHUDContent(context, controller, table, order);
        });
      },
    );
  }

  Widget _buildOccupiedHUDContent(
    BuildContext context,
    TableController controller,
    dynamic table,
    OrderModel order,
  ) {
    final steps = ['Placed', 'Accepted', 'Cooking', 'Ready', 'Served', 'Paid'];
    int activeIndex = 0;
    switch (order.status) {
      case 'open':
        activeIndex = 0;
        break;
      case 'sent_to_kitchen':
        activeIndex = 1;
        break;
      case 'preparing':
        activeIndex = 2;
        break;
      case 'ready':
        activeIndex = 3;
        break;
      case 'served':
      case 'payment_pending':
        activeIndex = 4;
        break;
      case 'paid':
        activeIndex = 5;
        break;
      default:
        activeIndex = 0;
    }

    final double itemsSubtotal = order.items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final double taxAmount = itemsSubtotal * 0.05; // 5% default tax
    final double totalBill = itemsSubtotal + taxAmount;

    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0A26).withOpacity(0.96),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: const Border(
          top: BorderSide(color: Color(0x29FFFFFF), width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bottom sheet handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.table_restaurant, color: AppColors.error, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Table ${table.tableNumber} - Live Session HUD',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Order #${order.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'OCCUPIED',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Timeline HUD segment
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                backdropColor: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: List.generate(steps.length, (index) {
                    final stepName = steps[index];
                    final isCompleted = index < activeIndex;
                    final isActive = index == activeIndex;
                    
                    Color circleColor;
                    IconData icon;
                    if (isCompleted) {
                      circleColor = AppColors.success;
                      icon = Icons.check;
                    } else if (isActive) {
                      circleColor = order.status == 'preparing' ? AppColors.accentOrange : AppColors.accentTeal;
                      icon = _getStepIcon(index);
                    } else {
                      circleColor = Colors.white24;
                      icon = _getStepIcon(index);
                    }

                    return Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: index == 0 ? Colors.transparent : (isCompleted ? AppColors.success : Colors.white10),
                                ),
                              ),
                              isActive
                                  ? PulseWidget(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: circleColor.withOpacity(0.2),
                                          border: Border.all(color: circleColor, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: circleColor.withOpacity(0.4),
                                              blurRadius: 8,
                                            )
                                          ],
                                        ),
                                        child: Icon(icon, color: Colors.white, size: 14),
                                      ),
                                    )
                                  : Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCompleted ? circleColor : Colors.white.withOpacity(0.04),
                                        border: Border.all(
                                          color: isCompleted ? circleColor : Colors.white24,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: isCompleted ? Colors.white : Colors.white38,
                                        size: 12,
                                      ),
                                    ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: index == steps.length - 1
                                      ? Colors.transparent
                                      : (isCompleted || isActive ? (index == activeIndex ? Colors.white10 : AppColors.success) : Colors.white10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stepName,
                            style: TextStyle(
                              color: isActive
                                  ? circleColor
                                  : (isCompleted ? Colors.white70 : Colors.white38),
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Items summary card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE CART ITEMS',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: order.items.isEmpty
                        ? const Center(
                            child: Text(
                              'No items in cart.',
                              style: TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: order.items.length,
                            itemBuilder: (context, index) {
                              final item = order.items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.itemName} x ${item.quantity}',
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Text(
                                      '₹${item.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Bill aggregates
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('₹${itemsSubtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax (5%):', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('₹${taxAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Bill Amount:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(
                          '₹${totalBill.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.accentTeal, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // "Mark as Served" action button for food ready status
            if (order.status == 'ready')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: PulseWidget(
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.success, Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppAnimations.radiusLarge,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            try {
                              await OrderRepository().updateOrderStatus(order.id, 'served');
                              await controller.loadTables(silent: true);
                              Navigator.of(context).pop();
                              Get.snackbar(
                                'Success',
                                'Table ${table.tableNumber} order marked as served!',
                                backgroundColor: AppColors.success,
                                colorText: Colors.white,
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Failed to mark order served: $e',
                                backgroundColor: AppColors.error,
                                colorText: Colors.white,
                              );
                            }
                          },
                          borderRadius: AppAnimations.radiusLarge,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.restaurant, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Mark as Served 🍽️',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Action Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'View Menu / Add Items',
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.toNamed(
                          '/order',
                          arguments: {'orderId': order.id, 'tableId': table.id, 'tableNumber': table.tableNumber},
                        )?.then((_) => controller.loadTables());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Settle Payment',
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.toNamed('/billing/${order.id}')?.then((_) => controller.loadTables());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0: return Icons.note_add_outlined;
      case 1: return Icons.assignment_turned_in_outlined;
      case 2: return Icons.soup_kitchen_outlined;
      case 3: return Icons.room_service_outlined;
      case 4: return Icons.dining_outlined;
      case 5: return Icons.payments_outlined;
      default: return Icons.circle;
    }
  }
}
