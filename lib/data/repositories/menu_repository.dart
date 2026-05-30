import '../database/database_helper.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../models/modifier_model.dart';

class MenuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ==================== CATEGORY OPERATIONS ====================
  Future<String> createCategory(MenuCategoryModel category) async {
    await _dbHelper.insertMenuCategory(category);
    return category.id;
  }

  Future<List<MenuCategoryModel>> getAllCategories() {
    return _dbHelper.getAllMenuCategories();
  }

  Future<void> updateCategory(MenuCategoryModel category) async {
    await _dbHelper.updateMenuCategory(category);
  }

  // ==================== MENU ITEM OPERATIONS ====================
  Future<String> createMenuItem(MenuItemModel item) async {
    await _dbHelper.insertMenuItem(item);
    return item.id;
  }

  Future<MenuItemModel?> getMenuItemById(String id) {
    return _dbHelper.getMenuItem(id);
  }

  Future<List<MenuItemModel>> getItemsByCategory(String categoryId) {
    return _dbHelper.getMenuItemsByCategory(categoryId);
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    await _dbHelper.updateMenuItem(item);
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _dbHelper.deleteMenuItem(itemId);
  }

  // ==================== MODIFIER OPERATIONS ====================
  Future<String> createModifier(ModifierModel modifier) async {
    await _dbHelper.insertModifier(modifier);
    return modifier.id;
  }

  Future<ModifierModel?> getModifierById(String id) {
    return _dbHelper.getModifier(id);
  }

  Future<List<ModifierModel>> getModifiersByIds(List<String> ids) {
    return _dbHelper.getModifiersByIds(ids);
  }

  // ==================== COMBINED OPERATIONS ====================
  Future<Map<String, dynamic>> getCompleteMenu() async {
    final categories = await getAllCategories();
    final categoryMenuMap = <String, List<MenuItemModel>>{};

    for (final category in categories) {
      final items = await getItemsByCategory(category.id);
      categoryMenuMap[category.id] = items;
    }

    return {'categories': categories, 'items': categoryMenuMap};
  }

  Future<MenuItemModel?> getItemWithModifiers(String itemId) async {
    final item = await getMenuItemById(itemId);
    if (item != null && item.modifierIds.isNotEmpty) {
      // Modifiers are already loaded separately
      return item;
    }
    return item;
  }

  Future<List<MenuItemModel>> getAllMenuItems() {
    return _dbHelper.getAllMenuItems();
  }
}
