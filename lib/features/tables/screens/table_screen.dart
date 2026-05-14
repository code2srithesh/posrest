import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/auth_service.dart';
import '../controllers/table_controller.dart';

class TableScreen extends StatelessWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TableController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tables'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientDarkOLED,
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

            AuthService().logout().then((_) {
              Get.offAllNamed('/login');
            });
          },
        ),
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
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 6),
        ],
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
                                        'Next Gen Table Matrix',
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
                                        'Glassmorphic live floor plan with animated status cards',
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
                              final table = controller.getFilteredTables()[index];
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
            arguments: {'orderId': table.currentOrderId, 'tableId': table.id},
          );
        } else if (table.status == AppConstants.statusFree) {
          Get.toNamed(
            '/order/create',
            arguments: {'tableId': table.id, 'tableNumber': table.tableNumber},
          );
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
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Create New Table',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: tableNumberController,
                decoration: InputDecoration(
                  labelText: 'Table Number',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: capacityController,
                decoration: InputDecoration(
                  labelText: 'Capacity (seats)',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
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
                        if (tableNumberController.text.isNotEmpty &&
                            capacityController.text.isNotEmpty) {
                          controller.createTable(
                            int.parse(tableNumberController.text),
                            int.parse(capacityController.text),
                          );
                        }
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
