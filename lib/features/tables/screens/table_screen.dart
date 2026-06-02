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
          Get.toNamed(
            '/order',
            arguments: {'orderId': table.currentOrderId, 'tableId': table.id, 'tableNumber': table.tableNumber},
          )?.then((_) => controller.loadTables());
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
                Padding(
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
                ),
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
}
