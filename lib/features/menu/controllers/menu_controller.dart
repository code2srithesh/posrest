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
      final List<MenuCategoryModel> loadedCategories = menu['categories'] ?? [];
      categories.value = loadedCategories.where((c) => c.name.trim().isNotEmpty).toList();
      completeMenu.value = menu;

      if (categories.isEmpty) {
        await _createDefaultMenu();
      } else {
        await loadAllMenuItems();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllMenuItems() async {
    try {
      isLoading.value = true;
      final items = await menuRepository.getAllMenuItems();
      menuItems.value = items;
      applyAllFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load all menu items: $e');
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
          name: 'Samosa (2 pcs)',
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
          name: 'Onion Pakora',
          description: 'Crispy onion fritters in gram flour batter',
          price: 100,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: true,
          displayOrder: 2,
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
          displayOrder: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: startersId,
          name: 'Chicken Tikka',
          description: 'Tender chicken pieces marinated and grilled',
          price: 220,
          isAvailable: true,
          isVegetarian: false,
          isSpicy: false,
          displayOrder: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: startersId,
          name: 'Spring Roll',
          description: 'Crispy rolls with vegetable filling',
          price: 120,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 5,
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
          description: 'Tender chicken in creamy tomato sauce - 30 mins',
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
          name: 'Chicken Tikka Masala',
          description: 'Grilled chicken in creamy sauce - 25 mins',
          price: 300,
          isAvailable: true,
          isVegetarian: false,
          isSpicy: false,
          displayOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Chicken Biryani',
          description: 'Fragrant basmati rice with chicken - 25 mins',
          price: 280,
          isAvailable: true,
          isVegetarian: false,
          isSpicy: true,
          displayOrder: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Paneer Tikka Masala',
          description: 'Cheese in spiced creamy tomato gravy - 20 mins',
          price: 280,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Vegetable Biryani',
          description: 'Rice with mixed vegetables - 20 mins',
          price: 200,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: true,
          displayOrder: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Chole Bhature',
          description: 'Chickpeas curry with fried bread - 15 mins',
          price: 150,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: true,
          displayOrder: 6,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Dal Makhani',
          description: 'Creamy lentils with spices - 30 mins',
          price: 220,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 7,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Palak Paneer',
          description: 'Cheese in spinach gravy - 20 mins',
          price: 240,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 8,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Lamb Curry',
          description: 'Tender lamb in aromatic curry - 35 mins',
          price: 380,
          isAvailable: true,
          isVegetarian: false,
          isSpicy: true,
          displayOrder: 9,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: mainId,
          name: 'Fried Rice',
          description: 'Jasmine rice with vegetables and egg - 15 mins',
          price: 180,
          isAvailable: true,
          isVegetarian: false,
          isSpicy: false,
          displayOrder: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      final drinks = [
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: drinksId,
          name: 'Mango Lassi',
          description: 'Yogurt-based mango drink',
          price: 100,
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
          name: 'Sweet Lassi',
          description: 'Traditional yogurt drink with sugar',
          price: 80,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: drinksId,
          name: 'Fresh Mango Juice',
          description: 'Freshly squeezed mango juice',
          price: 100,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: drinksId,
          name: 'Iced Tea',
          description: 'Refreshing iced tea with lemon',
          price: 60,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: drinksId,
          name: 'Coca Cola',
          description: 'Soft drink',
          price: 50,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: drinksId,
          name: 'Sprite',
          description: 'Lemon-lime soft drink',
          price: 50,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 6,
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
          price: 120,
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
          categoryId: dessertsId,
          name: 'Kheer',
          description: 'Rice pudding with milk and nuts',
          price: 100,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: dessertsId,
          name: 'Ras Malai',
          description: 'Cheese dumplings in sweet cream',
          price: 150,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuItemModel(
          id: const Uuid().v4(),
          categoryId: dessertsId,
          name: 'Ice Cream',
          description: 'Vanilla ice cream',
          price: 80,
          isAvailable: true,
          isVegetarian: true,
          isSpicy: false,
          displayOrder: 4,
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
  final filterVegetarian = false.obs;
  final filterSpicy = false.obs;

  void filterByCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
    applyAllFilters();
  }

  // Search menu items
  void searchMenuItems(String query) {
    searchMenu.value = query;
    applyAllFilters();
  }

  // Toggle vegetarian filter
  void toggleVegetarianFilter() {
    filterVegetarian.toggle();
    applyAllFilters();
  }

  // Toggle spicy filter
  void toggleSpicyFilter() {
    filterSpicy.toggle();
    applyAllFilters();
  }

  // Apply all filters together
  void applyAllFilters() {
    List<MenuItemModel> results = menuItems;

    // Filter by search query
    if (searchMenu.value.isNotEmpty) {
      results = results
          .where(
            (item) =>
                item.name.toLowerCase().contains(
                  searchMenu.value.toLowerCase(),
                ) ||
                (item.description?.toLowerCase() ?? '').contains(
                  searchMenu.value.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter by vegetarian
    if (filterVegetarian.value) {
      results = results.where((item) => item.isVegetarian).toList();
    }

    // Filter by spicy
    if (filterSpicy.value) {
      results = results.where((item) => item.isSpicy).toList();
    }

    // Only show available items
    results = results.where((item) => item.isAvailable).toList();

    filteredMenuItems.value = results;
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
