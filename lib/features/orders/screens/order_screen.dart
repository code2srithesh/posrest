import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_animations.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/glassmorphic_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/menu/controllers/menu_controller.dart' as menu_ctrl;
import '../controllers/order_controller.dart';
import '../../../services/auth_service.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

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

    final menuController = Get.put(menu_ctrl.MenuController());
    final orderController = Get.put(OrderController());
    final menuScrollController = ScrollController();
    final orderScrollController = ScrollController();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // Get arguments from navigation
    final arguments = Get.arguments ?? {};
    final tableId = arguments['tableId'] as String?;
    final tableNumber = arguments['tableNumber'] as int?;
    final orderId = arguments['orderId'] as String?;

    // Safe initialization/loading of table orders on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (orderId != null) {
        if (orderController.currentOrder.value?.id != orderId) {
          orderController.loadOrder(orderId);
        }
      } else if (tableId != null && tableNumber != null) {
        if (orderController.currentOrder.value?.tableId != tableId ||
            orderController.currentOrder.value?.status != AppConstants.orderStatusOpen) {
          orderController.createOrder(tableId, tableNumber);
        }
      }
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await orderController.cancelEmptyOrder();
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: _buildCategoryDrawer(context, menuController, orderController),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Table ${tableNumber ?? 'N/A'} - Menu'),
            Text(
              'Tap items to add to order',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
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
            if (role == AppConstants.roleCashier) {
              Get.offAllNamed('/cashier');
            } else if (role == AppConstants.roleChef) {
              Get.offAllNamed('/kitchen');
            } else {
              Get.offAllNamed('/tables');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Obx(() => Icon(
              orderController.isGridView.value ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            )),
            tooltip: 'Toggle Layout',
            onPressed: () => orderController.isGridView.toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            tooltip: 'Filter Categories',
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Obx(
              () => Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassOverlayPurpleMed,
                    borderRadius: AppAnimations.radiusSmall,
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: Text(
                    '${orderController.getItemCount()} items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const ThemeToggleButton(compact: true),
        ],
      ),
      body: Obx(() {
        if (menuController.isLoading.value || orderController.isLoading.value) {
          return const LoadingIndicator(message: 'Loading...');
        }

        return AnimatedGradientBG(
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
                right: -70,
                child: Container(
                  width: 220,
                  height: 220,
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
                bottom: -80,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 1100;
                    final menuGridCount = constraints.maxWidth >= 1300
                        ? 4
                        : constraints.maxWidth >= 980
                        ? 3
                        : 2;

                    return Flex(
                      direction: isCompact ? Axis.vertical : Axis.horizontal,
                      children: [
                        // Menu Section (Left)
                        Expanded(
                          flex: isCompact ? 3 : 3,
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.darkCard.withOpacity(0.4),
                                  borderRadius: AppAnimations.radiusLarge,
                                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.restaurant_menu, color: AppColors.accentTeal, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Restaurant Food Menu',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Tap items below to add to Table ${tableNumber ?? 'N/A'}\'s order cart',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ScrollConfiguration(
                                  behavior: const MaterialScrollBehavior()
                                      .copyWith(overscroll: false),
                                  child: Scrollbar(
                                    controller: menuScrollController,
                                    thumbVisibility: true,
                                    child: Obx(() {
                                      if (menuController.filteredMenuItems.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            'No items match selected filters.',
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }

                                      if (orderController.isGridView.value) {
                                        return GridView.builder(
                                          controller: menuScrollController,
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.all(12),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: menuGridCount,
                                                mainAxisSpacing: 12,
                                                crossAxisSpacing: 12,
                                                childAspectRatio: 0.77,
                                              ),
                                          itemCount:
                                              menuController.filteredMenuItems.length,
                                          itemBuilder: (context, index) {
                                            final item =
                                                menuController.filteredMenuItems[index];
                                            return SlideInWidget(
                                              begin: Offset(
                                                index.isEven ? -0.2 : 0.2,
                                                (index ~/ 2) * 0.1,
                                              ),
                                              duration: Duration(
                                                milliseconds: 350 + (index * 50),
                                              ),
                                              child: _buildMenuItemCard(
                                                item,
                                                orderController,
                                                context,
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return ListView.builder(
                                          controller: menuScrollController,
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.all(12),
                                          itemCount:
                                              menuController.filteredMenuItems.length,
                                          itemBuilder: (context, index) {
                                            final item =
                                                menuController.filteredMenuItems[index];
                                            return SlideInWidget(
                                              begin: Offset(
                                                0.0,
                                                index * 0.05,
                                              ),
                                              duration: Duration(
                                                milliseconds: 350 + (index * 50),
                                              ),
                                              child: _buildCompactMenuItemRow(
                                                item,
                                                orderController,
                                                context,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: isCompact ? 2 : 2,
                          child: Container(
                            margin: isCompact
                                ? const EdgeInsets.fromLTRB(10, 0, 10, 10)
                                : const EdgeInsets.fromLTRB(0, 10, 10, 10),
                            decoration: BoxDecoration(
                              color: AppColors.darkCard.withOpacity(0.7),
                              borderRadius: AppAnimations.radiusXL,
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: ClipRRect(
                              borderRadius: AppAnimations.radiusXL,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.accentGradient2,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: AppAnimations.shadowGlow,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Current Order',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Obx(
                                          () => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  AppAnimations.radiusSmall,
                                            ),
                                            child: Text(
                                              '${orderController.currentOrderItems.length} items',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Obx(() {
                                      if (orderController
                                          .currentOrderItems
                                          .isEmpty) {
                                        return const Center(
                                          child: Text(
                                            'No items added yet',
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        );
                                      }

                                      return ScrollConfiguration(
                                        behavior: const MaterialScrollBehavior()
                                            .copyWith(overscroll: false),
                                        child: Scrollbar(
                                          controller: orderScrollController,
                                          thumbVisibility: true,
                                          child: ListView.builder(
                                            controller: orderScrollController,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.all(8),
                                            itemCount: orderController
                                                .currentOrderItems
                                                .length,
                                            itemBuilder: (context, index) {
                                              final item = orderController
                                                  .currentOrderItems[index];
                                              return _buildOrderItemTile(
                                                item,
                                                index,
                                                orderController,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.12),
                                      border: Border(
                                        top: BorderSide(
                                          color: AppTheme.borderColor,
                                        ),
                                      ),
                                    ),
                                    child: Obx(
                                      () => Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Subtotal:',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              CurrencyDisplay(
                                                amount:
                                                    orderController.subtotal,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Tax (${AppConstants.currencySymbol}):',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              CurrencyDisplay(
                                                amount:
                                                    orderController.taxAmount,
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              CurrencyDisplay(
                                                amount:
                                                    orderController.totalAmount,
                                                textStyle: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          // Action Buttons
                                          Obx(() {
                                            final order = orderController.currentOrder.value;
                                            final status = order?.status ?? 'open';
                                            
                                            // If order is already in the kitchen workflow, enable "Request Bill"
                                            final hasSentToKitchen = status == 'sent_to_kitchen' ||
                                                status == 'preparing' ||
                                                status == 'ready' ||
                                                status == 'served';

                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: SecondaryButton(
                                                    label: 'Cancel',
                                                    onPressed: () => Get.back(),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: PrimaryButton(
                                                    label: hasSentToKitchen ? 'Request Bill' : 'Send to Kitchen',
                                                    backgroundColor: hasSentToKitchen ? AppColors.success : null,
                                                    onPressed: () {
                                                      if (hasSentToKitchen) {
                                                        orderController.sendToPayment();
                                                      } else {
                                                        orderController.completeOrder();
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    ));
  }

  Widget _buildMenuItemCard(
    dynamic item,
    OrderController orderController,
    BuildContext context,
  ) {
    return Obx(() {
      final existingIndex = orderController.currentOrderItems.indexWhere(
        (i) => i.menuItemId == item.id,
      );
      final hasSelected = existingIndex >= 0;
      final quantity = hasSelected ? orderController.currentOrderItems[existingIndex].quantity : 0;

      final cardBorderColor = hasSelected ? AppColors.accentTeal : Colors.white.withOpacity(0.08);
      final cardBorderWidth = hasSelected ? 2.0 : 1.0;

      return GlassContainer(
        backdropColor: hasSelected ? AppColors.glassOverlayTealDeep : AppColors.glassOverlayTealMed,
        shadows: hasSelected ? AppAnimations.shadowGlowTeal : AppAnimations.shadowMedium,
        interactive: true,
        borderRadius: AppAnimations.radiusLarge,
        child: GestureDetector(
          onTap: () => _showItemDetailsDialog(item, orderController, context),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: AppAnimations.radiusLarge,
                  border: Border.all(color: cardBorderColor, width: cardBorderWidth),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Icon/Image placeholder with gradient
                    Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.accentTeal.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          _getItemIcon(item.name),
                          size: 36,
                          color: AppColors.accentTeal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Item Name
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      item.description ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    const Spacer(),
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentTeal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.availableStock <= 0 
                                  ? 'Out of stock' 
                                  : '${item.availableStock} left',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: item.availableStock <= 5 ? AppColors.error : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (item.isVegetarian)
                              Tooltip(
                                message: 'Vegetarian',
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.eco,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            if (item.isSpicy ?? false)
                              Tooltip(
                                message: 'Spicy',
                                child: Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppAnimations.shadowGlow,
                    ),
                    child: Text(
                      '${quantity}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOrderItemTile(
    dynamic item,
    int index,
    OrderController orderController,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.notes != null)
                      Text(
                        'Note: ${item.notes}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => orderController.removeItemFromOrder(index),
                icon: const Icon(Icons.close, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => orderController.updateItemQuantity(
                      index,
                      item.quantity - 1,
                    ),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          '-',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => orderController.updateItemQuantity(
                      index,
                      item.quantity + 1,
                    ),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          '+',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              CurrencyDisplay(
                amount: item.totalPrice,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showItemDetailsDialog(
    dynamic item,
    OrderController orderController,
    BuildContext context,
  ) {
    int quantity = 1;
    final notes = TextEditingController();

    Get.dialog(
      FadeInWidget(
        duration: AppAnimations.fast,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppAnimations.radiusLarge,
          ),
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, dialogSetState) {
              return SingleChildScrollView(
                child: GlassContainer(
              backdropColor: AppColors.glassOverlayPurpleMed,
              shadows: AppAnimations.shadowLarge,
              borderRadius: AppAnimations.radiusLarge,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassOverlayTeal,
                                      borderRadius: AppAnimations.radiusSmall,
                                    ),
                                    child: Text(
                                      '₹${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accentTeal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    item.availableStock <= 5 ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                                    size: 14,
                                    color: item.availableStock <= 5 ? AppColors.error : AppColors.accentTeal,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.availableStock <= 0 
                                        ? 'OUT OF STOCK' 
                                        : '${item.availableStock} left',
                                    style: TextStyle(
                                      color: item.availableStock <= 5 ? AppColors.error : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.glassOverlayPurple,
                              borderRadius: AppAnimations.radiusCircle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.lightText,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      item.description ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Item details badges
                    Row(
                      children: [
                        if (item.isVegetarian)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              border: Border.all(
                                color: AppColors.success,
                                width: 1,
                              ),
                              borderRadius: AppAnimations.radiusSmall,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.eco,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Vegetarian',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.isSpicy ?? false) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              border: Border.all(color: Colors.red, width: 1),
                              borderRadius: AppAnimations.radiusSmall,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Spicy',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Quantity Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.glassOverlayPurple,
                            borderRadius: AppAnimations.radiusMedium,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildQuantityButton('-', () {
                                dialogSetState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                  }
                                });
                              }),
                              Container(
                                width: 50,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentTeal,
                                  ),
                                ),
                              ),
                              _buildQuantityButton('+', () {
                                dialogSetState(() {
                                  if (quantity < item.availableStock) {
                                    quantity++;
                                  } else {
                                    Get.snackbar(
                                      'Stock Limit Reached',
                                      'Only ${item.availableStock} units of ${item.name} are available.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppColors.error.withOpacity(0.9),
                                      colorText: Colors.white,
                                    );
                                  }
                                });
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Special Instructions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.glassOverlayPurple,
                            borderRadius: AppAnimations.radiusMedium,
                            border: Border.all(
                              color: AppColors.lightBorder,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: notes,
                            decoration: const InputDecoration(
                              hintText: 'e.g., No onion, Less spicy',
                              hintStyle: TextStyle(
                                color: AppColors.lightTextTertiary,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(14),
                            ),
                            style: const TextStyle(
                              color: AppColors.lightText,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Add to Order Button
                    item.availableStock <= 0
                        ? Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.15),
                              borderRadius: AppAnimations.radiusMedium,
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: const Text(
                              'Out of Stock',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.gradientPrimaryTeal,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: AppAnimations.radiusMedium,
                              boxShadow: AppAnimations.shadowGlow,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (quantity > item.availableStock) {
                                    Get.snackbar(
                                      'Stock Limit Reached',
                                      'Only ${item.availableStock} units available.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppColors.error,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                  orderController.addItemToOrder(
                                    item,
                                    quantity: quantity,
                                    notes: notes.text.isNotEmpty ? notes.text : null,
                                  );
                                  Get.back();
                                  Get.snackbar(
                                    'Added to Order',
                                    '${quantity}x ${item.name}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Add ${quantity}x to Order',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
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
          );
        },
      ),
    ),
  ),
);
  }

  Widget _buildQuantityButton(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.accentTeal,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('starter') || name.contains('appetizer')) {
      return Icons.breakfast_dining;
    } else if (name.contains('main')) {
      return Icons.restaurant;
    } else if (name.contains('bread') || name.contains('rice')) {
      return Icons.rice_bowl;
    } else if (name.contains('dessert')) {
      return Icons.cake;
    } else if (name.contains('mocktail') || name.contains('drink')) {
      return Icons.local_bar;
    } else if (name.contains('beverage') || name.contains('tea') || name.contains('coffee')) {
      return Icons.coffee;
    }
    return Icons.restaurant_menu;
  }

  IconData _getItemIcon(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('chicken') || name.contains('wings') || name.contains('korma') || name.contains('makhani')) {
      return Icons.emoji_food_beverage;
    } else if (name.contains('biryani') || name.contains('rice')) {
      return Icons.rice_bowl;
    } else if (name.contains('paneer') || name.contains('panir') || name.contains('chaap') || name.contains('mushroom')) {
      return Icons.breakfast_dining;
    } else if (name.contains('lassi') || name.contains('mojito') || name.contains('cooler') || name.contains('spritz') || name.contains('juice')) {
      return Icons.local_bar;
    } else if (name.contains('chai') || name.contains('tea') || name.contains('coffee')) {
      return Icons.coffee;
    } else if (name.contains('rasmalai') || name.contains('tukda') || name.contains('halwa') || name.contains('cake') || name.contains('dessert') || name.contains('chocolate')) {
      return Icons.cake;
    } else if (name.contains('naan') || name.contains('bread') || name.contains('roti')) {
      return Icons.bakery_dining;
    }
    return Icons.restaurant_menu;
  }

  Widget _buildCategoryDrawer(
    BuildContext context,
    menu_ctrl.MenuController menuController,
    OrderController orderController,
  ) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        backdropColor: AppColors.glassOverlayPurpleDeep.withOpacity(0.92),
        borderRadius: BorderRadius.zero,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.accentTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'POSRest Catalog',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // Search Box inside Drawer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search menu dishes...',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 18),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.accentTeal),
                    ),
                  ),
                  onChanged: (val) {
                    menuController.searchMenuItems(val);
                  },
                ),
              ),

              // Vegetarian / Spicy filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Obx(() {
                      final active = menuController.filterVegetarian.value;
                      return ActionChip(
                        avatar: Icon(
                          Icons.eco,
                          color: active ? Colors.black : AppColors.success,
                          size: 14,
                        ),
                        label: Text(
                          'Veg Only',
                          style: TextStyle(
                            fontSize: 11,
                            color: active ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: active ? AppColors.accentTeal : Colors.white.withOpacity(0.04),
                        onPressed: () {
                          menuController.toggleVegetarianFilter();
                        },
                      );
                    }),
                    const SizedBox(width: 8),
                    Obx(() {
                      final active = menuController.filterSpicy.value;
                      return ActionChip(
                        avatar: Icon(
                          Icons.local_fire_department,
                          color: active ? Colors.black : Colors.red,
                          size: 14,
                        ),
                        label: Text(
                          'Spicy Only',
                          style: TextStyle(
                            fontSize: 11,
                            color: active ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: active ? AppColors.accentTeal : Colors.white.withOpacity(0.04),
                        onPressed: () {
                          menuController.toggleSpicyFilter();
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white10, height: 1),

              // Categories List Header
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // Category Items List
              Expanded(
                child: Obx(() {
                  final list = menuController.categories;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: list.length + 1, // +1 for "All Items"
                    itemBuilder: (context, idx) {
                      if (idx == 0) {
                        // "All Items" option
                        final isSelected = menuController.selectedCategoryId.value.isEmpty;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentTeal.withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.restaurant_menu,
                              color: isSelected ? AppColors.accentTeal : Colors.white70,
                              size: 18,
                            ),
                            title: Text(
                              'All Menu Catalog',
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected ? AppColors.accentTeal : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            dense: true,
                            onTap: () {
                              menuController.selectedCategoryId.value = '';
                              menuController.loadAllMenuItems();
                              Navigator.pop(context); // Close Drawer
                            },
                          ),
                        );
                      }

                      final cat = list[idx - 1];
                      final isSelected = menuController.selectedCategoryId.value == cat.id;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentTeal.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Icon(
                            _getCategoryIcon(cat.name),
                            color: isSelected ? AppColors.accentTeal : Colors.white70,
                            size: 18,
                          ),
                          title: Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? AppColors.accentTeal : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          dense: true,
                          onTap: () {
                            menuController.loadItemsByCategory(cat.id);
                            Navigator.pop(context); // Close Drawer
                          },
                        ),
                      );
                    },
                  );
                }),
              ),

              // Footer
              const Divider(color: Colors.white10, height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.white54, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Serving: Waiter Console',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMenuItemRow(
    dynamic item,
    OrderController orderController,
    BuildContext context,
  ) {
    return Obx(() {
      final existingIndex = orderController.currentOrderItems.indexWhere(
        (i) => i.menuItemId == item.id,
      );
      final hasSelected = existingIndex >= 0;
      final quantity = hasSelected ? orderController.currentOrderItems[existingIndex].quantity : 0;

      final cardBorderColor = hasSelected ? AppColors.accentTeal : Colors.white.withOpacity(0.08);
      final cardBorderWidth = hasSelected ? 1.5 : 1.0;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: GlassContainer(
          backdropColor: hasSelected ? AppColors.glassOverlayTealDeep : AppColors.glassOverlayTealMed,
          shadows: hasSelected ? AppAnimations.shadowGlowTeal : AppAnimations.shadowSmall,
          interactive: true,
          borderRadius: AppAnimations.radiusLarge,
          child: GestureDetector(
            onTap: () => _showItemDetailsDialog(item, orderController, context),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppAnimations.radiusLarge,
                border: Border.all(color: cardBorderColor, width: cardBorderWidth),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Line 1: Veg icon + Name + Spicy icon + Price on right
                  Row(
                    children: [
                      if (item.isVegetarian)
                        const Icon(Icons.eco, color: AppColors.success, size: 16)
                      else
                        const Icon(Icons.restaurant, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.lightText,
                                ),
                              ),
                            ),
                            if (item.isSpicy ?? false) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.local_fire_department, color: Colors.red, size: 16),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentTeal,
                            ),
                          ),
                          Text(
                            item.availableStock <= 0 
                                ? 'Out of stock' 
                                : '${item.availableStock} left',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: item.availableStock <= 5 ? AppColors.error : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Line 2: Description and preparation time badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.description ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 10, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text(
                              item.description?.contains('mins') ?? false
                                  ? '${item.description!.split(' - ').last}'
                                  : '15 mins',
                              style: const TextStyle(fontSize: 9, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Line 3: Selected Status and Cart indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasSelected)
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Added to order • Quantity: ${quantity}x',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: const [
                            Icon(Icons.add_circle_outline, color: AppColors.accentTeal, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Tap to add to order',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.accentTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      if (hasSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '₹${(item.price * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
      );
    });
  }
}
