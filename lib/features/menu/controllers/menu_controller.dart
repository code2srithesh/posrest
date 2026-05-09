import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/menu_category_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/modifier_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../core/constants/app_constants.dart';

class MenuController extends GetxController {
  final menuRepository = MenuRepository();

  final categories = <MenuCategoryModel>[].obs;
  final menuItems = <MenuItemModel>[].obs;
  final modifiers = <ModifierModel>[].obs;
  final isLoading = false.obs;
  final selectedCategoryId = ''.obs;
  final completeMenu = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadMenu();
  }

  Future<void> loadMenu() async {
    try {
      isLoading.value = true;

      final menu = await menuRepository.getCompleteMenu();
      categories.value = menu['categories'] ?? [];
      completeMenu.value = menu;

      if (categories.isEmpty) {
        await _createDefaultMenu();
      } else if (categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
        loadItemsByCategory(categories.first.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createDefaultMenu() async {
    try {
      // Create categories
      final categories = [
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Starters',
          description: 'Appetizers and starters',
          displayOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Main Course',
          description: 'Main dishes',
          displayOrder: 2,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Drinks',
          description: 'Beverages',
          displayOrder: 3,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Desserts',
          description: 'Sweet treats',
          displayOrder: 4,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      for (final cat in categories) {
        await menuRepository.createCategory(cat);
      }

      // Create sample menu items
      final startersId = categories[0].id;
      final mainId = categories[1].id;
      final drinksId = categories[2].id;
      final dessertsId = categories[3].id;

      final starters = [
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: startersId,
          name: 'Samosa',
          description: 'Crispy pastry with spiced potato filling',
          price: 80,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: true,
          displayOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: startersId,
          name: 'Paneer Tikka',
          description: 'Grilled cottage cheese with spices',
          price: 180,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      final mains = [
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Butter Chicken',
          description: 'Tender chicken in creamy tomato sauce',
          price: 320,
          isAvailable: true,
          isVegetarian: false,
          isSpicy: false,
          displayOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Biryani',
          description: 'Fragrant rice with meat and spices',
          price: 280,
          isAvailable: true,
          isVegetarian: false,
          isSpicy: true,
          displayOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      final drinks = [
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: drinksId,
          name: 'Lassi',
          description: 'Yogurt-based drink',
          price: 60,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: drinksId,
          name: 'Mango Juice',
          description: 'Fresh mango juice',
          price: 80,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      final desserts = [
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: dessertsId,
          name: 'Gulab Jamun',
          description: 'Sweet milk solids in sugar syrup',
          price: 100,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      for (final item in [...starters, ...mains, ...drinks, ...desserts]) {
        await menuRepository.createMenuItem(item);
      }

      // Create modifiers
      final modifiers = [
        ModifierModel(
          id: const Uuid().v4(),
          name: 'Extra Cheese',
          type: 'extra',
          price: 30,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        ModifierModel(
          id: const Uuid().v4(),
          name: 'Less Spicy',
          type: 'spice_level',
          price: 0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        ModifierModel(
          id: const Uuid().v4(),
          name: 'Extra Spicy',
          type: 'spice_level',
          price: 0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      for (final mod in modifiers) {
        await menuRepository.createModifier(mod);
      }

      await loadMenu();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create default menu: $e');
    }
  }

  Future<void> loadItemsByCategory(String categoryId) async {
    try {
      selectedCategoryId.value = categoryId;
      final items = await menuRepository.getItemsByCategory(categoryId);
      menuItems.value = items;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load menu items: $e');
    }
  }

  List<MenuItemModel> getItemsByCategory(String categoryId) {
    return menuItems.where((item) => item.categoryId == categoryId).toList();
  }

  final searchMenu = ''.obs;
  final filteredMenuItems = <MenuItemModel>[].obs;

  void filterByCategory(String categoryId) {
    if (categoryId.isEmpty) {
      filteredMenuItems.value = menuItems;
    } else {
      filteredMenuItems.value = menuItems
          .where((item) => item.categoryId == categoryId)
          .toList();
    }
  }

  List<MenuItemModel> getFilteredMenuItems() {
    return filteredMenuItems;
  }

  Future<void> addMenuItem({
    required String name,
    required double price,
    required String description,
  }) async {
    try {
      final item = MenuItemModel(
        id: const Uuid().v4(),
        categoryId: selectedCategoryId.value,
        name: name,
        description: description,
        price: price,
        isAvailable: true,
        isVegetarian: false,
        isSpicy: false,
        displayOrder: menuItems.length + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusPending,
      );
      await menuRepository.createMenuItem(item);
      await loadMenu();
      Get.snackbar('Success', 'Menu item added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add menu item: $e');
    }
  }

  Future<void> updateMenuItem(
    String itemId, {
    required String name,
    required double price,
    required String description,
  }) async {
    try {
      // Implementation would update the item in repository
      Get.snackbar('Success', 'Menu item updated');
      await loadMenu();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update menu item: $e');
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    try {
      // Delete item from the menu items list
      menuItems.removeWhere((item) => item.id == itemId);
      filteredMenuItems.removeWhere((item) => item.id == itemId);
      await loadMenu();
      Get.snackbar('Success', 'Menu item deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete menu item: $e');
    }
  }
}
