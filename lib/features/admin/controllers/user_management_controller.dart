import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/table_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/models/menu_category_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../services/auth_service.dart';
import '../../../services/preferences_service.dart';

class UserManagementController extends GetxController {
  // Creation Form Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Settings Controllers
  final restaurantNameController = TextEditingController();
  final taxRateController = TextEditingController();

  // Repositories
  final tableRepository = TableRepository();
  final orderRepository = OrderRepository();
  final paymentRepository = PaymentRepository();
  final menuRepository = MenuRepository();
  final preferencesService = PreferencesService();

  // Active Tab State
  final activeTab = 0.obs; // 0 = Dashboard, 1 = Staff, 2 = Food Menu, 3 = History, 4 = Settings

  // Reactive Data Lists
  final users = <UserModel>[].obs;
  final pendingUsers = <UserModel>[].obs;
  final approvedUsers = <UserModel>[].obs;

  final waitersList = <UserModel>[].obs;
  final chefsList = <UserModel>[].obs;
  final cashiersList = <UserModel>[].obs;
  final customersList = <UserModel>[].obs;

  final tables = <TableModel>[].obs;
  final occupiedTables = <TableModel>[].obs;

  final preparingOrders = <OrderModel>[].obs;
  final allOrders = <OrderModel>[].obs;
  final payments = <PaymentModel>[].obs;

  final menuCategories = <MenuCategoryModel>[].obs;
  final menuItems = <MenuItemModel>[].obs;
  final selectedMenuCategoryId = ''.obs;

  // Selected Creation States
  final selectedRole = AppConstants.roleWaiter.obs;
  final isApproved = true.obs;
  final isLoading = false.obs;

  List<String> get assignableRoles => AuthService.instance.getAssignableRoles();

  @override
  void onInit() {
    super.onInit();
    // Load Settings
    restaurantNameController.text = preferencesService.getRestaurantName();
    taxRateController.text = preferencesService.getTaxRate().toString();

    // Initial load
    loadDashboardData();
  }

  // Load all central admin panel data
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      
      // 1. Fetch Users & Group them
      final loadedUsers = await AuthService.instance.getAllUsers();
      users.assignAll(loadedUsers);
      pendingUsers.assignAll(loadedUsers.where((u) => !u.isActive).toList());
      approvedUsers.assignAll(loadedUsers.where((u) => u.isActive).toList());

      waitersList.assignAll(loadedUsers.where((u) => u.role == AppConstants.roleWaiter).toList());
      chefsList.assignAll(loadedUsers.where((u) => u.role == AppConstants.roleChef).toList());
      cashiersList.assignAll(loadedUsers.where((u) => u.role == AppConstants.roleCashier).toList());
      customersList.assignAll(loadedUsers.where((u) => u.role == 'customer').toList());

      // 2. Fetch Tables
      final loadedTables = await tableRepository.getAllTables();
      tables.assignAll(loadedTables);
      occupiedTables.assignAll(loadedTables.where((t) => t.status == AppConstants.statusOccupied).toList());

      // 3. Fetch Orders (All + preparing/sent_to_kitchen)
      final loadedOrders = await orderRepository.getAllOrders();
      allOrders.assignAll(loadedOrders);
      preparingOrders.assignAll(loadedOrders.where((o) => o.status == 'preparing' || o.status == 'sent_to_kitchen').toList());

      // 4. Fetch Payments
      final loadedPayments = await paymentRepository.getAllPayments();
      payments.assignAll(loadedPayments);

      // 5. Fetch Menu Catalog
      final menu = await menuRepository.getCompleteMenu();
      final List<MenuCategoryModel> loadedCats = menu['categories'] ?? [];
      menuCategories.assignAll(loadedCats.where((c) => c.name.trim().isNotEmpty).toList());
      
      if (menuCategories.isNotEmpty) {
        if (selectedMenuCategoryId.value.isEmpty) {
          selectedMenuCategoryId.value = menuCategories.first.id;
        }
        await loadItemsByCategory(selectedMenuCategoryId.value);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load menu items by category
  Future<void> loadItemsByCategory(String categoryId) async {
    try {
      selectedMenuCategoryId.value = categoryId;
      final items = await menuRepository.getItemsByCategory(categoryId);
      menuItems.assignAll(items);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load items: $e');
    }
  }

  // Create Staff User
  Future<void> createUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;
      final result = await AuthService.instance.createUserByAdmin(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: selectedRole.value,
        isActive: isApproved.value,
      );

      if (result['success'] == true) {
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        isApproved.value = true;
        await loadDashboardData();
        Get.back(); // Close dialog
        Get.snackbar('Success', result['message'] ?? 'User created');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to create user');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // User Approvals
  Future<void> approveUser(String userId) async {
    final result = await AuthService.instance.approveUser(userId);
    if (result['success'] == true) {
      await loadDashboardData();
      Get.snackbar('Approved', result['message'] ?? 'User approved');
    } else {
      Get.snackbar('Error', result['message'] ?? 'Approval failed');
    }
  }

  Future<void> rejectUser(String userId) async {
    final result = await AuthService.instance.rejectUser(userId);
    if (result['success'] == true) {
      await loadDashboardData();
      Get.snackbar('Rejected', result['message'] ?? 'User removed');
    } else {
      Get.snackbar('Error', result['message'] ?? 'Rejection failed');
    }
  }

  // Food Menu Actions
  Future<void> createCategory(String name) async {
    if (name.trim().isEmpty) return;
    try {
      final category = MenuCategoryModel(
        id: const Uuid().v4(),
        name: name.trim(),
        description: 'Custom category',
        displayOrder: menuCategories.length + 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusPending,
      );
      await menuRepository.createCategory(category);
      await loadDashboardData();
      Get.back();
      Get.snackbar('Success', 'Category added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e');
    }
  }

  Future<void> addMenuItem({
    required String name,
    required double price,
    required String description,
    required bool isVegetarian,
    required bool isSpicy,
  }) async {
    if (name.trim().isEmpty || price <= 0 || selectedMenuCategoryId.value.isEmpty) {
      Get.snackbar('Error', 'Invalid inputs');
      return;
    }
    try {
      final item = MenuItemModel(
        id: const Uuid().v4(),
        categoryId: selectedMenuCategoryId.value,
        name: name.trim(),
        description: description.trim(),
        price: price,
        isAvailable: true,
        isVegetarian: isVegetarian,
        isSpicy: isSpicy,
        displayOrder: menuItems.length + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusPending,
      );
      await menuRepository.createMenuItem(item);
      await loadDashboardData();
      Get.back();
      Get.snackbar('Success', 'Menu item added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add menu item: $e');
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    try {
      await menuRepository.deleteMenuItem(itemId);
      await loadDashboardData();
      Get.snackbar('Success', 'Menu item deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete menu item: $e');
    }
  }

  Future<void> editMenuItem({
    required String id,
    required String name,
    required double price,
    required String description,
    required bool isVegetarian,
    required bool isSpicy,
  }) async {
    if (name.trim().isEmpty || price <= 0) {
      Get.snackbar('Error', 'Invalid inputs');
      return;
    }
    try {
      final existing = await menuRepository.getMenuItemById(id);
      if (existing != null) {
        final updated = existing.copyWith(
          name: name.trim(),
          price: price,
          description: description.trim(),
          isVegetarian: isVegetarian,
          isSpicy: isSpicy,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        );
        await menuRepository.updateMenuItem(updated);
        await loadDashboardData();
        Get.back();
        Get.snackbar('Success', 'Menu item updated');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update menu item: $e');
    }
  }

  // Settings Actions
  Future<void> saveGlobalSettings() async {
    final name = restaurantNameController.text.trim();
    final tax = double.tryParse(taxRateController.text.trim()) ?? 5.0;

    try {
      if (name.isEmpty) {
        Get.snackbar('Error', 'Restaurant name cannot be empty');
        return;
      }

      await preferencesService.setRestaurantName(name);
      await preferencesService.setTaxRate(tax);

      Get.snackbar('Success', 'Global settings updated successfully');
      await loadDashboardData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e');
    }
  }

  // Simulate active table waiter assignment
  String getWaiterServicingTable(String waiterId) {
    if (occupiedTables.isEmpty) return 'Vacant / Idle';
    // Calculate a deterministic table assignment based on ID hash
    final index = waiterId.codeUnits.fold<int>(0, (sum, val) => sum + val) % occupiedTables.length;
    final table = occupiedTables[index];
    return 'Servicing Table ${table.tableNumber}';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    restaurantNameController.dispose();
    taxRateController.dispose();
    super.onClose();
  }
}
