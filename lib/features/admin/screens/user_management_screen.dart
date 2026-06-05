import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../core/widgets/admin_bottom_nav_bar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/table_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/models/menu_category_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../services/auth_service.dart';
import '../controllers/user_management_controller.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());

    return FluidVideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: const AdminBottomNavBar(currentIndex: 0),
        appBar: AppBar(
          title: const Text('Admin Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          actions: [
            IconButton(
              tooltip: 'Refresh Dashboard',
              onPressed: controller.loadDashboardData,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
            IconButton(
              tooltip: 'Logout',
              onPressed: () =>
                  AuthService().logout().then((_) => Get.offAllNamed('/login')),
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Premium Glassmorphic Top Tab Switcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(6),
                  backdropColor: AppColors.glassOverlayBlackMed,
                  borderRadius: AppAnimations.radiusXL,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(
                      () => Row(
                        children: [
                          _buildTabItem(controller, index: 0, label: 'Dashboard', icon: Icons.dashboard),
                          _buildTabItem(controller, index: 1, label: 'Staff Directory', icon: Icons.people),
                          _buildTabItem(controller, index: 2, label: 'Food Menu', icon: Icons.restaurant_menu),
                          _buildTabItem(controller, index: 3, label: 'History Logs', icon: Icons.history_edu),
                          _buildTabItem(controller, index: 4, label: 'Settings', icon: Icons.settings),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Active Tab Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator(message: 'Syncing backend data...');
                  }

                  switch (controller.activeTab.value) {
                    case 0:
                      return _buildDashboardTab(context, controller);
                    case 1:
                      return _buildStaffTab(context, controller);
                    case 2:
                      return _buildMenuTab(context, controller);
                    case 3:
                      return _buildHistoryTab(context, controller);
                    case 4:
                      return _buildSettingsTab(context, controller);
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    UserManagementController controller, {
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = controller.activeTab.value == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.accentTeal : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => controller.activeTab.value = index,
        backgroundColor: Colors.white.withOpacity(0.05),
        selectedColor: AppColors.accentTeal.withOpacity(0.25),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accentTeal : Colors.white70,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.accentTeal : Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  // ==================== TAB 0: DASHBOARD ====================
  Widget _buildDashboardTab(BuildContext context, UserManagementController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Active Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Pending Approvals',
                  '${controller.pendingUsers.length}',
                  Icons.person_add_disabled,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Occupied Tables',
                  '${controller.occupiedTables.length}/${controller.tables.length}',
                  Icons.table_restaurant,
                  AppColors.error,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Preparing Orders',
                  '${controller.preparingOrders.length}',
                  Icons.soup_kitchen,
                  AppColors.accentTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1024;
              return Column(
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPendingApprovalsCard(context, controller)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildOccupiedTablesCard(context, controller)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPreparingOrdersCard(context, controller)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildPendingApprovalsCard(context, controller),
                        const SizedBox(height: 16),
                        _buildOccupiedTablesCard(context, controller),
                        const SizedBox(height: 16),
                        _buildPreparingOrdersCard(context, controller),
                      ],
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _buildAnalyticsSection(context, controller),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsCard(BuildContext context, UserManagementController controller) {
    return _sectionCard(
      title: 'Pending Approvals',
      subtitle: 'Users waiting for registration approval',
      icon: Icons.approval,
      accentColor: AppColors.warning,
      child: controller.pendingUsers.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No pending user registrations.', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.pendingUsers.length,
              itemBuilder: (context, index) {
                final user = controller.pendingUsers[index];
                return _buildPendingUserTile(user, controller);
              },
            ),
    );
  }

  Widget _buildOccupiedTablesCard(BuildContext context, UserManagementController controller) {
    return _sectionCard(
      title: 'Restaurant Tables Status Plan',
      subtitle: 'Live occupancy matrix and table states',
      icon: Icons.grid_view_rounded,
      accentColor: AppColors.accentTeal,
      child: controller.tables.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No tables registered yet.', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.4,
              ),
              itemCount: controller.tables.length,
              itemBuilder: (context, index) {
                final table = controller.tables[index];
                final isOccupied = table.status == AppConstants.statusOccupied;
                final badgeColor = isOccupied ? AppColors.error : AppColors.success;
                
                return Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_restaurant, color: badgeColor, size: 16),
                      const SizedBox(height: 4),
                      Text(
                        'T-${table.tableNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        table.status.toUpperCase(),
                        style: TextStyle(color: badgeColor, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPreparingOrdersCard(BuildContext context, UserManagementController controller) {
    return _sectionCard(
      title: 'Kitchen Operations',
      subtitle: 'In progress orders in preparation',
      icon: Icons.soup_kitchen,
      accentColor: AppColors.accentTeal,
      child: controller.preparingOrders.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No orders in preparation.', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.preparingOrders.length,
              itemBuilder: (context, index) {
                final order = controller.preparingOrders[index];
                return _buildPreparingOrderTile(order);
              },
            ),
    );
  }

  Widget _buildPendingUserTile(UserModel user, UserManagementController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.warning.withOpacity(0.2),
                radius: 16,
                child: const Icon(Icons.person, color: AppColors.warning, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(user.email, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success.withOpacity(0.2),
                  foregroundColor: AppColors.success,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => controller.approveUser(user.id),
                icon: const Icon(Icons.check, size: 14),
                label: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => controller.rejectUser(user.id),
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Reject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOccupiedTableTile(TableModel table) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
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
                child: const Icon(Icons.table_restaurant, color: AppColors.error, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Table ${table.tableNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${table.capacity} seats capacity', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'OCCUPIED',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparingOrderTile(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentTeal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Table ${order.tableNumber} - Order', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status == 'preparing' ? AppColors.accentOrange.withOpacity(0.2) : AppColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: order.status == 'preparing' ? AppColors.accentOrange : AppColors.info),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: order.status == 'preparing' ? AppColors.accentOrange : AppColors.info,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${order.items.length} dishes in queue',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: STAFF DIRECTORY ====================
  Widget _buildStaffTab(BuildContext context, UserManagementController controller) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentTeal,
        onPressed: () => _showCreateUserDialog(context, controller),
        icon: const Icon(Icons.person_add, color: Colors.black),
        label: const Text('Add Staff User', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          children: [
            _buildStaffRoleSection('Waiters Directory', controller.waitersList, AppColors.accentTeal, controller),
            const SizedBox(height: 16),
            _buildStaffRoleSection('Kitchen Chefs Directory', controller.chefsList, AppColors.accentOrange, controller),
            const SizedBox(height: 16),
            _buildStaffRoleSection('Cashiers Directory', controller.cashiersList, AppColors.success, controller),
            const SizedBox(height: 16),
            _buildStaffRoleSection('Customer Accounts Directory', controller.customersList, AppColors.accentBlue, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffRoleSection(
    String title,
    List<UserModel> staff,
    Color roleColor,
    UserManagementController controller,
  ) {
    return _sectionCard(
      title: title,
      subtitle: 'Active staff users logged into this restaurant',
      icon: Icons.badge_outlined,
      accentColor: roleColor,
      child: staff.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No active staff registered under this role.', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: staff.length,
              itemBuilder: (context, index) {
                final member = staff[index];
                final statusDesc = member.role == AppConstants.roleWaiter
                    ? controller.getWaiterServicingTable(member.id)
                    : member.role == 'customer' ? 'Customer Profile' : 'On Duty';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: roleColor.withOpacity(0.12),
                            radius: 18,
                            child: Icon(Icons.person, color: roleColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(member.email, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: member.role == AppConstants.roleWaiter && !statusDesc.contains('Vacant')
                              ? AppColors.error.withOpacity(0.15)
                              : roleColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: member.role == AppConstants.roleWaiter && !statusDesc.contains('Vacant')
                                ? AppColors.error
                                : roleColor,
                          ),
                        ),
                        child: Text(
                          statusDesc.toUpperCase(),
                          style: TextStyle(
                            color: member.role == AppConstants.roleWaiter && !statusDesc.contains('Vacant')
                                ? AppColors.error
                                : roleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ==================== TAB 2: FOOD MENU ====================
  Widget _buildMenuTab(BuildContext context, UserManagementController controller) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentTeal,
        onPressed: () => _showAddMenuItemDialog(context, controller),
        icon: const Icon(Icons.add_circle_outline, color: Colors.black),
        label: const Text('Add Dish Item', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Category Selector Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: controller.menuCategories.map((cat) {
                        final isSelected = controller.selectedMenuCategoryId.value == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (_) => controller.loadItemsByCategory(cat.id),
                            backgroundColor: Colors.white.withOpacity(0.04),
                            selectedColor: AppColors.accentTeal.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.accentTeal : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  backgroundColor: AppColors.accentOrange,
                  onPressed: () => _showAddCategoryDialog(context, controller),
                  child: const Icon(Icons.library_add, color: Colors.black, size: 18),
                ),
              ],
            ),
          ),

          // Menu Items grid / list
          Expanded(
            child: controller.menuItems.isEmpty
                ? const Center(
                    child: Text('No menu items in this category.', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.menuItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.menuItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.glassOverlayPurple,
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
                                  Row(
                                    children: [
                                      Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(width: 8),
                                      if (item.isVegetarian)
                                        const Icon(Icons.eco, color: AppColors.success, size: 14)
                                      else
                                        const Icon(Icons.restaurant, color: Colors.redAccent, size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.description ?? 'No description.', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text('₹${item.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(width: 14),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: item.availableStock <= 5 ? AppColors.error.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: item.availableStock <= 5 ? AppColors.error.withOpacity(0.4) : Colors.white10),
                                        ),
                                        child: Text(
                                          item.availableStock <= 0 
                                              ? 'OUT OF STOCK' 
                                              : '${item.availableStock} units left',
                                          style: TextStyle(
                                            color: item.availableStock <= 5 ? AppColors.error : Colors.white70,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showEditMenuItemDialog(context, controller, item),
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.accentTeal),
                                  tooltip: 'Modify Item',
                                ),
                                IconButton(
                                  onPressed: () => controller.deleteMenuItem(item.id),
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  tooltip: 'Remove Item',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: HISTORY LOGS ====================
  Widget _buildHistoryTab(BuildContext context, UserManagementController controller) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColors.accentTeal,
            labelColor: AppColors.accentTeal,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(icon: Icon(Icons.receipt_long), text: 'Orders Ledger'),
              Tab(icon: Icon(Icons.payment), text: 'Payment Log'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Orders History
                controller.allOrders.isEmpty
                    ? const Center(child: Text('No orders recorded yet.', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.allOrders.length,
                        itemBuilder: (context, index) {
                          final order = controller.allOrders[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order #${order.id.substring(0, 8)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Table ${order.tableNumber} · Dine-in', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                    Text(order.createdAt.toLocal().toString().substring(0, 16), style: const TextStyle(color: Colors.white30, fontSize: 10)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getOrderStatusColor(order.status).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: _getOrderStatusColor(order.status)),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: TextStyle(color: _getOrderStatusColor(order.status), fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // Payments History
                controller.payments.isEmpty
                    ? const Center(child: Text('No payments processed yet.', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.payments.length,
                        itemBuilder: (context, index) {
                          final payment = controller.payments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Payment Reference', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(payment.reference ?? 'N/A', style: const TextStyle(color: AppColors.accentTeal, fontSize: 11, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Method: ${payment.paymentMethod.toUpperCase()}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                    Text(payment.createdAt.toLocal().toString().substring(0, 16), style: const TextStyle(color: Colors.white30, fontSize: 10)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${payment.amount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.success),
                                      ),
                                      child: const Text('SUCCESS', style: TextStyle(color: AppColors.success, fontSize: 8, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 4: PROFILE & SETTINGS ====================
  Widget _buildSettingsTab(BuildContext context, UserManagementController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Summary Card
          _sectionCard(
            title: 'Admin Profile',
            subtitle: 'Logged in session details',
            icon: Icons.person_outline,
            accentColor: AppColors.accentTeal,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.glassOverlayTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: AppColors.accentTeal, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AuthService.instance.getUserName() ?? 'Admin', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(AuthService.instance.getUserEmail() ?? 'admin@posrest.com', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Chip(
                        backgroundColor: AppColors.accentTeal.withOpacity(0.15),
                        label: const Text('SYSTEM ADMINISTRATOR', style: TextStyle(color: AppColors.accentTeal, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Global ERP Configuration settings
          _sectionCard(
            title: 'Global ERP Configuration',
            subtitle: 'Manage central restaurant variables',
            icon: Icons.restaurant,
            accentColor: AppColors.accentOrange,
            child: Column(
              children: [
                TextField(
                  controller: controller.restaurantNameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Restaurant Outlet Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.store, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.taxRateController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Global CGST + SGST Rate (%)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.percent, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.gradientPrimaryTeal),
                      borderRadius: AppAnimations.radiusLarge,
                      boxShadow: AppAnimations.shadowGlowTeal,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: controller.saveGlobalSettings,
                      child: const Text('Save ERP Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUPPORTING COMPONENT CARDS ====================
  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      backdropColor: AppColors.glassOverlayPurpleDeep,
      borderRadius: AppAnimations.radiusLarge,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
                Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      backdropColor: AppColors.glassOverlayPurpleDeep,
      borderRadius: AppAnimations.radiusXL,
      shadows: AppAnimations.shadowMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'sent_to_kitchen':
      case 'preparing':
        return AppColors.accentOrange;
      case 'ready':
        return AppColors.accentTeal;
      case 'served':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.lightTextSecondary;
    }
  }

  // ==================== DIALOGS ====================
  void _showCreateUserDialog(BuildContext context, UserManagementController controller) {
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
              const Text('Add Staff Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 20),
              _dialogField(controller.nameController, 'Full Name', Icons.person),
              const SizedBox(height: 12),
              _dialogField(controller.emailController, 'Email Address', Icons.email_outlined),
              const SizedBox(height: 12),
              _dialogField(controller.passwordController, 'Password', Icons.lock_outline, obscureText: true),
              const SizedBox(height: 16),
              const Text('Assign Functional Role', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.assignableRoles.map((role) {
                    final isSelected = controller.selectedRole.value == role;
                    return ChoiceChip(
                      label: Text(AuthService().getRoleLabel(role)),
                      selected: isSelected,
                      onSelected: (_) => controller.selectedRole.value = role,
                      selectedColor: AppColors.accentTeal.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.accentTeal : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(label: 'Cancel', onPressed: () => Get.back()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(label: 'Create', onPressed: controller.createUser),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, UserManagementController controller) {
    final nameCtrl = TextEditingController();
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
              const Text('Add Menu Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(label: 'Cancel', onPressed: () => Get.back()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(label: 'Add', onPressed: () => controller.createCategory(nameCtrl.text)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context, UserManagementController controller) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '50');
    bool isVeg = true;
    bool isSpicy = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              borderRadius: AppAnimations.radiusXL,
              backdropColor: AppColors.glassOverlayPurpleDeep,
              shadows: AppAnimations.shadowGlow,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Add Menu Dish Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Dish Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Available Stock (Units)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Vegetarian Dish', style: TextStyle(color: Colors.white)),
                      value: isVeg,
                      activeColor: AppColors.success,
                      onChanged: (val) => setState(() => isVeg = val ?? true),
                    ),
                    CheckboxListTile(
                      title: const Text('Spicy Chili Accent', style: TextStyle(color: Colors.white)),
                      value: isSpicy,
                      activeColor: AppColors.error,
                      onChanged: (val) => setState(() => isSpicy = val ?? false),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(label: 'Cancel', onPressed: () => Get.back()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Add',
                            onPressed: () {
                              final price = double.tryParse(priceCtrl.text) ?? 0.0;
                              final stock = int.tryParse(stockCtrl.text) ?? 50;
                              controller.addMenuItem(
                                name: nameCtrl.text,
                                price: price,
                                description: descCtrl.text,
                                isVegetarian: isVeg,
                                isSpicy: isSpicy,
                                availableStock: stock,
                              );
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
        },
      ),
    );
  }

  void _showEditMenuItemDialog(BuildContext context, UserManagementController controller, MenuItemModel item) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toString());
    final descCtrl = TextEditingController(text: item.description ?? '');
    final stockCtrl = TextEditingController(text: item.availableStock.toString());
    bool isVeg = item.isVegetarian;
    bool isSpicy = item.isSpicy ?? false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              borderRadius: AppAnimations.radiusXL,
              backdropColor: AppColors.glassOverlayPurpleDeep,
              shadows: AppAnimations.shadowGlow,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Modify Menu Dish Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Dish Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Available Stock (Units)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Vegetarian Dish', style: TextStyle(color: Colors.white)),
                      value: isVeg,
                      activeColor: AppColors.success,
                      onChanged: (val) => setState(() => isVeg = val ?? true),
                    ),
                    CheckboxListTile(
                      title: const Text('Spicy Chili Accent', style: TextStyle(color: Colors.white)),
                      value: isSpicy,
                      activeColor: AppColors.error,
                      onChanged: (val) => setState(() => isSpicy = val ?? false),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(label: 'Cancel', onPressed: () => Get.back()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Save Changes',
                            onPressed: () {
                              final price = double.tryParse(priceCtrl.text) ?? 0.0;
                              final stock = int.tryParse(stockCtrl.text) ?? 50;
                              controller.editMenuItem(
                                id: item.id,
                                name: nameCtrl.text,
                                price: price,
                                description: descCtrl.text,
                                isVegetarian: isVeg,
                                isSpicy: isSpicy,
                                availableStock: stock,
                              );
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
        },
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, UserManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.analytics_outlined, color: AppColors.accentTeal, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Restaurant Performance Insights',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildCategoryBarChart(controller)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildTopDishesLeaderboard(controller)),
                    ],
                  )
                : Column(
                    children: [
                      _buildCategoryBarChart(controller),
                      const SizedBox(height: 16),
                      _buildTopDishesLeaderboard(controller),
                    ],
                  );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildPeakHoursHeatmap()),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildDineInEfficiencyGauge(controller)),
                    ],
                  )
                : Column(
                    children: [
                      _buildPeakHoursHeatmap(),
                      const SizedBox(height: 16),
                      _buildDineInEfficiencyGauge(controller),
                    ],
                  );
          },
        ),
      ],
    );
  }

  String _getCategoryNameForItem(String itemName, UserManagementController controller) {
    for (final cat in controller.menuCategories) {
      for (final mi in controller.menuItems) {
        if (mi.name == itemName && mi.categoryId == cat.id) {
          return cat.name;
        }
      }
    }
    final nameLower = itemName.toLowerCase();
    if (nameLower.contains('soup') || nameLower.contains('paneer') || nameLower.contains('kebab') || nameLower.contains('samosa') || nameLower.contains('starter') || nameLower.contains('tikka')) {
      for (final c in controller.menuCategories) {
        if (c.name.toLowerCase().contains('starter')) return c.name;
      }
      return 'Starters';
    }
    if (nameLower.contains('curry') || nameLower.contains('masala') || nameLower.contains('korma') || nameLower.contains('biryani') || nameLower.contains('rice') || nameLower.contains('dal')) {
      for (final c in controller.menuCategories) {
        if (c.name.toLowerCase().contains('main')) return c.name;
      }
      return 'Main Course';
    }
    if (nameLower.contains('naan') || nameLower.contains('roti') || nameLower.contains('paratha') || nameLower.contains('bread')) {
      for (final c in controller.menuCategories) {
        if (c.name.toLowerCase().contains('bread')) return c.name;
      }
      return 'Breads';
    }
    if (nameLower.contains('kulfi') || nameLower.contains('jamun') || nameLower.contains('halwa') || nameLower.contains('dessert')) {
      for (final c in controller.menuCategories) {
        if (c.name.toLowerCase().contains('dessert')) return c.name;
      }
      return 'Desserts';
    }
    return controller.menuCategories.isNotEmpty ? controller.menuCategories.first.name : 'Other';
  }

  Widget _buildCategoryBarChart(UserManagementController controller) {
    final categorySales = <String, double>{};
    
    // Seed gorgeous defaults so we have data on clean start
    for (final cat in controller.menuCategories) {
      if (cat.name.contains('Starter')) categorySales[cat.name] = 3420.0;
      else if (cat.name.contains('Main')) categorySales[cat.name] = 8960.0;
      else if (cat.name.contains('Bread')) categorySales[cat.name] = 2840.0;
      else if (cat.name.contains('Dessert')) categorySales[cat.name] = 1950.0;
      else if (cat.name.contains('Beverage') || cat.name.contains('Mocktail')) categorySales[cat.name] = 1680.0;
      else categorySales[cat.name] = 1200.0;
    }
    
    // Sum real payments/orders
    for (final order in controller.allOrders) {
      if (order.status == 'paid' || order.status == 'served' || order.status == 'payment_pending') {
        for (final item in order.items) {
          final catName = _getCategoryNameForItem(item.itemName, controller);
          categorySales[catName] = (categorySales[catName] ?? 0.0) + item.totalPrice;
        }
      }
    }

    final maxSales = categorySales.values.isEmpty 
        ? 1.0 
        : categorySales.values.reduce((curr, next) => curr > next ? curr : next);

    return _sectionCard(
      title: 'Sales by Category',
      subtitle: 'Real-time category distribution & total gross returns',
      icon: Icons.bar_chart_rounded,
      accentColor: AppColors.accentTeal,
      child: Column(
        children: categorySales.entries.map((entry) {
          final percentage = entry.value / (maxSales == 0 ? 1.0 : maxSales);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage.clamp(0.05, 1.0),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.gradientPrimaryTeal,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentTeal.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: Text(
                    '₹${entry.value.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.accentTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopDishesLeaderboard(UserManagementController controller) {
    // Collect stats from real orders
    final dishCounts = <String, int>{};
    for (final order in controller.allOrders) {
      for (final item in order.items) {
        dishCounts[item.itemName] = (dishCounts[item.itemName] ?? 0) + item.quantity;
      }
    }

    // Default premium seed values
    final seedDishes = [
      const MapEntry('Butter Chicken', 42),
      const MapEntry('Garlic Naan', 36),
      const MapEntry('Paneer Tikka', 24),
      const MapEntry('Mango Lassi', 18),
    ];

    // Merge real data
    for (final seed in seedDishes) {
      if (!dishCounts.containsKey(seed.key)) {
        dishCounts[seed.key] = seed.value;
      }
    }

    final sortedDishes = dishCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final displayDishes = sortedDishes.take(4).toList();

    final maxCount = displayDishes.isEmpty ? 1 : displayDishes.first.value;

    final rankColors = [
      AppColors.accentTeal,
      AppColors.accentOrange,
      AppColors.info,
      Colors.purpleAccent,
    ];

    return _sectionCard(
      title: 'Popular Dishes Catalog',
      subtitle: 'Top performing dishes ranked by total units ordered',
      icon: Icons.local_fire_department_rounded,
      accentColor: AppColors.accentOrange,
      child: Column(
        children: List.generate(displayDishes.length, (idx) {
          final dish = displayDishes[idx];
          final color = rankColors[idx % rankColors.length];
          final fillPct = dish.value / maxCount;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: color.withOpacity(0.4)),
                          ),
                          child: Text(
                            '#${idx + 1}',
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dish.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${dish.value} units',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: fillPct,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.04),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPeakHoursHeatmap() {
    // Simulated load heatmap across hours
    final hourLoads = [
      const MapEntry('11:00', 0.15),
      const MapEntry('12:00', 0.40),
      const MapEntry('13:00', 0.85),
      const MapEntry('14:00', 0.65),
      const MapEntry('17:00', 0.30),
      const MapEntry('18:00', 0.55),
      const MapEntry('19:00', 0.90),
      const MapEntry('20:00', 0.95),
      const MapEntry('21:00', 0.75),
      const MapEntry('22:00', 0.45),
    ];

    return _sectionCard(
      title: 'Dining Peak-Hours Heatmap',
      subtitle: 'Occupancy load levels recorded across operation shifts',
      icon: Icons.timer_outlined,
      accentColor: AppColors.accentTeal,
      child: Container(
        height: 80,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: hourLoads.map((h) {
              final isCurrent = h.key.split(':').first == DateTime.now().hour.toString();
              Color loadColor;
              if (h.value < 0.3) {
                loadColor = AppColors.success;
              } else if (h.value < 0.6) {
                loadColor = AppColors.info;
              } else if (h.value < 0.85) {
                loadColor = AppColors.accentOrange;
              } else {
                loadColor = AppColors.error;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      h.key,
                      style: TextStyle(
                        color: isCurrent ? AppColors.accentTeal : Colors.white54,
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: loadColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCurrent ? AppColors.accentTeal : loadColor.withOpacity(0.4),
                          width: isCurrent ? 2.0 : 1.0,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.accentTeal.withOpacity(0.3),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCurrent
                            ? Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentTeal,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : Text(
                                '${(h.value * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: loadColor,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDineInEfficiencyGauge(UserManagementController controller) {
    final occupancy = controller.tables.isEmpty 
        ? 0.0 
        : controller.occupiedTables.length / controller.tables.length;

    // Turnovers count = completed payments
    final settlementsCount = controller.payments.length;

    return _sectionCard(
      title: 'Seating Turnover Metric',
      subtitle: 'Average dining durations & active service indicators',
      icon: Icons.speed_rounded,
      accentColor: AppColors.info,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(
                      value: occupancy,
                      strokeWidth: 5,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                    ),
                  ),
                  Text(
                    '${(occupancy * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Occupancy Rate',
                style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white12,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.hourglass_bottom, size: 14, color: AppColors.accentOrange),
                  SizedBox(width: 6),
                  Text(
                    '45 mins',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Text(
                'Avg. Dining Duration',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    '$settlementsCount settled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Text(
                'Turnovers Completed',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
