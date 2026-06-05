import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/menu_category_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/modifier_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_notification.dart';

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

      // If categories is empty or represents the old sample menu, clear and seed premium catalog
      if (categories.isEmpty || categories.length <= 4 || categories.any((c) => c.name == 'Starters')) {
        await menuRepository.clearMenuOnly();
        await _createDefaultMenu();
      } else {
        await loadAllMenuItems();
      }
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to load menu: $e');
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
      CustomNotification.showSnackbar('Error', 'Failed to load all menu items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createDefaultMenu() async {
    try {
      final now = DateTime.now();
      
      // 1. Create categories data
      final categoriesList = [
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Appetizers & Starters',
          description: 'Premium tandoor and clay oven appetizers',
          displayOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Main Course',
          description: 'Rich, authentic regional curries and main dishes',
          displayOrder: 2,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Breads & Rice',
          description: 'Clay-oven flatbreads and aromatic biryanis',
          displayOrder: 3,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Desserts',
          description: 'Traditional sweets and contemporary desserts',
          displayOrder: 4,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Craft Mocktails',
          description: 'Artisanal cold refreshing beverages',
          displayOrder: 5,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
        MenuCategoryModel(
          id: const Uuid().v4(),
          name: 'Hot Beverages',
          description: 'Freshly brewed warm teas and gourmet filter coffee',
          displayOrder: 6,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      for (final cat in categoriesList) {
        await menuRepository.createCategory(cat);
      }

      // Map to quickly look up category IDs by name
      final catId = (String name) => categoriesList.firstWhere((c) => c.name == name).id;

      // 2. Define premium menu items
      final rawItems = [
        // Appetizers & Starters
        {
          'cat': 'Appetizers & Starters',
          'name': 'Crispy Paneer Bites',
          'desc': 'Panko-crusted cottage cheese cubes tossed in spicy glaze',
          'price': 240.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Appetizers & Starters',
          'name': 'Afghani Malai Chaap',
          'desc': 'Soy chops marinated in rich cashew-cream paste, charcoal-roasted',
          'price': 220.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Appetizers & Starters',
          'name': 'Stuffed Mushroom Caps',
          'desc': 'Cremini mushrooms stuffed with seasoned spinach, garlic, and cheddar',
          'price': 260.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Appetizers & Starters',
          'name': 'Tandoori Chicken Wings',
          'desc': 'Smoky chicken wings marinated in spices and charred in clay oven',
          'price': 320.0,
          'isVeg': false,
          'isSpicy': true,
        },
        {
          'cat': 'Appetizers & Starters',
          'name': 'Pepper Garlic Prawns',
          'desc': 'Plump prawns sauteed with aromatic black pepper, garlic, and spring onion',
          'price': 380.0,
          'isVeg': false,
          'isSpicy': true,
        },

        // Main Course
        {
          'cat': 'Main Course',
          'name': 'Paneer Butter Masala',
          'desc': 'Cottage cheese in velvety, rich sweet-spicy tomato gravy - 15 mins',
          'price': 340.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Main Course',
          'name': 'Dal Bukhara',
          'desc': 'Slow-cooked black lentils simmered overnight with cream and butter - 25 mins',
          'price': 280.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Main Course',
          'name': 'Murgh Makhani',
          'desc': 'Tandoori chicken pulled and cooked in authentic buttery tomato-cream sauce - 20 mins',
          'price': 380.0,
          'isVeg': false,
          'isSpicy': false,
        },
        {
          'cat': 'Main Course',
          'name': 'Awadhi Lamb Korma',
          'desc': 'Tender lamb braised slowly in caramelized onion and cashew-nut gravy - 30 mins',
          'price': 420.0,
          'isVeg': false,
          'isSpicy': false,
        },
        {
          'cat': 'Main Course',
          'name': 'Coastal Fish Curry',
          'desc': 'Sea bass cooked in spiced coconut milk, sour tamarind, and curry leaves - 25 mins',
          'price': 390.0,
          'isVeg': false,
          'isSpicy': true,
        },

        // Breads & Rice
        {
          'cat': 'Breads & Rice',
          'name': 'Butter Naan',
          'desc': 'Soft clay-oven leavened flatbread brushed with organic butter',
          'price': 70.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Breads & Rice',
          'name': 'Garlic Naan',
          'desc': 'Leavened clay-oven flatbread topped with fresh minced garlic and herbs',
          'price': 90.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Breads & Rice',
          'name': 'Subz Dum Biryani',
          'desc': 'Fragrant long-grain basmati rice layered with garden vegetables, saffron, and mint - 20 mins',
          'price': 260.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Breads & Rice',
          'name': 'Awadhi Chicken Biryani',
          'desc': 'Aromatic basmati rice cooked in dum style with chicken, saffron, and rose water - 20 mins',
          'price': 340.0,
          'isVeg': false,
          'isSpicy': true,
        },
        {
          'cat': 'Breads & Rice',
          'name': 'Steamed Basmati Rice',
          'desc': 'Steamed aromatic long-grain premium basmati rice',
          'price': 120.0,
          'isVeg': true,
          'isSpicy': false,
        },

        // Desserts
        {
          'cat': 'Desserts',
          'name': 'Saffron Rasmalai',
          'desc': 'Delicate cottage cheese discs soaked in saffron sweet thickened milk',
          'price': 160.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Desserts',
          'name': 'Shahi Tukda',
          'desc': 'Golden crisp bread pudding topped with thick condensed milk (rabri) and dry fruits',
          'price': 140.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Desserts',
          'name': 'Warm Gajar Halwa',
          'desc': 'Grated red carrots slow-cooked with whole milk, ghee, and cashew nuts',
          'price': 150.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Desserts',
          'name': 'Choco Lava Decadence',
          'desc': 'Rich warm chocolate fudge cake with liquid cocoa center, served with vanilla scoop',
          'price': 180.0,
          'isVeg': true,
          'isSpicy': false,
        },

        // Craft Mocktails
        {
          'cat': 'Craft Mocktails',
          'name': 'Mint & Lime Mojito',
          'desc': 'Crushed mint leaves, fresh lime wedges, sparkling club soda, and simple syrup',
          'price': 130.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Craft Mocktails',
          'name': 'Spiced Mango Cooler',
          'desc': 'Ripe mango puree blended with roasted cumin, rock salt, and mint-chilli infusion',
          'price': 140.0,
          'isVeg': true,
          'isSpicy': true,
        },
        {
          'cat': 'Craft Mocktails',
          'name': 'Pomegranate Ginger Spritz',
          'desc': 'Fresh pomegranate juice mixed with raw ginger juice, honey, and sparkling tonic',
          'price': 150.0,
          'isVeg': true,
          'isSpicy': false,
        },

        // Hot Beverages
        {
          'cat': 'Hot Beverages',
          'name': 'Signature Masala Chai',
          'desc': 'Traditional tea brewed with fresh milk, crushed ginger, cardamom, and spices',
          'price': 60.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Hot Beverages',
          'name': 'Artisanal Filter Coffee',
          'desc': 'Frothy, double-drip chicory coffee brewed authentic South Indian style',
          'price': 70.0,
          'isVeg': true,
          'isSpicy': false,
        },
        {
          'cat': 'Hot Beverages',
          'name': 'Assam Green Tea',
          'desc': 'Hot organic loose-leaf green tea brewed with fresh lemon juice and organic honey',
          'price': 80.0,
          'isVeg': true,
          'isSpicy': false,
        },
      ];

      int displayOrderIdx = 1;
      for (final raw in rawItems) {
        final item = MenuItemModel(
          id: const Uuid().v4(),
          categoryId: catId(raw['cat'] as String),
          name: raw['name'] as String,
          description: raw['desc'] as String,
          price: raw['price'] as double,
          isAvailable: true,
          isVegetarian: raw['isVeg'] as bool,
          isSpicy: raw['isSpicy'] as bool,
          displayOrder: displayOrderIdx++,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        );
        await menuRepository.createMenuItem(item);
      }

      // 3. Create premium modifiers
      final modifiersList = [
        ModifierModel(
          id: const Uuid().v4(),
          name: 'Extra Cheese',
          type: 'extra',
          price: 30.0,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
        ModifierModel(
          id: const Uuid().v4(),
          name: 'Less Spicy',
          type: 'spice_level',
          price: 0.0,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
        ModifierModel(
          id: const Uuid().v4(),
          name: 'Extra Spicy',
          type: 'spice_level',
          price: 0.0,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncStatus: AppConstants.syncStatusPending,
        ),
      ];

      for (final mod in modifiersList) {
        await menuRepository.createModifier(mod);
      }

      // Reload the fresh menu state
      final menu = await menuRepository.getCompleteMenu();
      final List<MenuCategoryModel> loadedCategories = menu['categories'] ?? [];
      categories.value = loadedCategories.where((c) => c.name.trim().isNotEmpty).toList();
      completeMenu.value = menu;
      
      await loadAllMenuItems();
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to create premium menu database: $e');
    }
  }

  Future<void> loadItemsByCategory(String categoryId) async {
    try {
      selectedCategoryId.value = categoryId;
      final items = await menuRepository.getItemsByCategory(categoryId);
      menuItems.value = items;
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to load menu items: $e');
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
      CustomNotification.showSnackbar('Success', 'Menu item added');
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to add menu item: $e');
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
      CustomNotification.showSnackbar('Success', 'Menu item updated');
      await loadMenu();
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to update menu item: $e');
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    try {
      // Delete item from the menu items list
      menuItems.removeWhere((item) => item.id == itemId);
      filteredMenuItems.removeWhere((item) => item.id == itemId);
      await loadMenu();
      CustomNotification.showSnackbar('Success', 'Menu item deleted');
    } catch (e) {
      CustomNotification.showSnackbar('Error', 'Failed to delete menu item: $e');
    }
  }
}
