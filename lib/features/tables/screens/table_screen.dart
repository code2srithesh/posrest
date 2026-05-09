import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
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
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Tables'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            AuthService().logout().then((_) {
              Get.offAllNamed('/login');
            });
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Obx(
                () => Text(
                  'Occupied: ${controller.getTablesCount(AppConstants.statusOccupied)}/${controller.tables.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const ThemeToggleButton(compact: true),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(message: 'Loading tables...');
        }

        if (controller.tables.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.table_restaurant_outlined,
            title: 'No Tables',
            message: 'Create your first table to get started',
            action: PrimaryButton(
              label: 'Create Table',
              width: 200,
              onPressed: () => _showCreateTableDialog(context, controller),
            ),
          );
        }

        return Column(
          children: [
            // Filter and Action Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: controller.filterStatus.value.isEmpty,
                            onSelected: (selected) {
                              controller.filterStatus.value = '';
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(
                              'Free (${controller.getTablesCount(AppConstants.statusFree)})',
                            ),
                            selected:
                                controller.filterStatus.value ==
                                AppConstants.statusFree,
                            onSelected: (selected) {
                              controller.filterStatus.value =
                                  AppConstants.statusFree;
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(
                              'Occupied (${controller.getTablesCount(AppConstants.statusOccupied)})',
                            ),
                            selected:
                                controller.filterStatus.value ==
                                AppConstants.statusOccupied,
                            onSelected: (selected) {
                              controller.filterStatus.value =
                                  AppConstants.statusOccupied;
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(
                              'Reserved (${controller.getTablesCount(AppConstants.statusReserved)})',
                            ),
                            selected:
                                controller.filterStatus.value ==
                                AppConstants.statusReserved,
                            onSelected: (selected) {
                              controller.filterStatus.value =
                                  AppConstants.statusReserved;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: () =>
                        _showCreateTableDialog(context, controller),
                    tooltip: 'Add Table',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            // Tables Grid
            Expanded(
              child: Obx(
                () => GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: controller.getFilteredTables().length,
                  itemBuilder: (context, index) {
                    final table = controller.getFilteredTables()[index];
                    return _buildTableCard(context, table, controller);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    dynamic table,
    TableController controller,
  ) {
    Color bgColor;
    Color iconColor;
    Color textColor;

    switch (table.status) {
      case 'free':
        bgColor = AppTheme.tableFreeBg;
        iconColor = AppTheme.tableFreeIcon;
        textColor = AppTheme.tableFreeIcon;
        break;
      case 'occupied':
        bgColor = AppTheme.tableOccupiedBg;
        iconColor = AppTheme.tableOccupiedIcon;
        textColor = AppTheme.tableOccupiedIcon;
        break;
      case 'reserved':
        bgColor = AppTheme.tableReservedBg;
        iconColor = AppTheme.tableReservedIcon;
        textColor = AppTheme.tableReservedIcon;
        break;
      default:
        bgColor = AppTheme.bgColor;
        iconColor = AppTheme.textSecondary;
        textColor = AppTheme.textSecondary;
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
      child: PosCard(
        backgroundColor: bgColor,
        isSelected: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_restaurant, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(
              'Table ${table.tableNumber}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${table.occupiedSeats}/${table.capacity} seats',
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
            ),
            const SizedBox(height: 12),
            StatusBadge(status: table.status),
            if (table.status == AppConstants.statusOccupied)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  label: const Text(
                    'Open Order',
                    style: TextStyle(fontSize: 10),
                  ),
                  backgroundColor: iconColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: iconColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create New Table',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: tableNumberController,
                decoration: InputDecoration(
                  labelText: 'Table Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: capacityController,
                decoration: InputDecoration(
                  labelText: 'Capacity (seats)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
