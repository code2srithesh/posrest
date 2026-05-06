# POSRest - Quick Start Guide

## 🚀 Get Running in 5 Minutes

### Step 1: Install Dependencies
```bash
cd /Users/srithesh/Desktop/posrest
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
```

### Step 3: Login with Demo Credentials
- **Email:** demo@posrest.com  
- **Password:** demo123

### Step 4: Explore Features
- See 12 auto-created tables
- Create a new order
- Add menu items
- View calculated bill

---

## 📱 Main Features Quick Access

### Feature 1: Take an Order
```
Home → Click "Free" Table → Select Items → Review Cart → Send to Kitchen
```

### Feature 2: View All Tables
```
Home → See grid of tables colored by status (Green=Free, Red=Occupied, Orange=Reserved)
```

### Feature 3: Create New Table
```
Home → Click + Button → Enter Table Number & Capacity → Create
```

### Feature 4: Check Bill
```
Home → Click Table → Right Panel Shows → Subtotal + Tax = Total
```

---

## 💻 Important Files to Know

### To Add New Menu Items:
**File:** `lib/features/menu/controllers/menu_controller.dart`
**Function:** `_createDefaultMenu()` - Modify this to add items

### To Change Tax Rate:
**File:** `lib/core/constants/app_constants.dart`  
**Change:** `spTaxRate` default value

### To Modify Colors:
**File:** `lib/core/themes/app_theme.dart`  
**Change:** `primaryColor`, `accentColor`, etc.

### To Add Authentication:
**File:** `lib/services/auth_service.dart`  
**Function:** `login()` - Add backend API call

### To Add Database Table:
**File:** `lib/data/database/database_helper.dart`  
**Function:** `_onCreate()` - Add SQL CREATE TABLE

---

## 🔗 Navigation Routes

| URL | What | File |
|-----|------|------|
| `/login` | Login page | `auth/screens/login_screen.dart` |
| `/tables` | Main table view | `tables/screens/table_screen.dart` |
| `/order/create` | New order | `orders/screens/order_screen.dart` |
| `/order` | Edit order | `orders/screens/order_screen.dart` |

### Navigate Programmatically:
```dart
// Go to tables
Get.offAllNamed('/tables');

// Go to create order
Get.toNamed('/order/create', arguments: {
  'tableId': table.id,
  'tableNumber': table.tableNumber
});

// Go back
Get.back();
```

---

## 🛠️ Common Tasks

### Add a New Menu Item
```dart
// In menu_controller.dart, _createDefaultMenu()
final newItem = MenuItemModel(
  id: const Uuid().v4(),
  categoryId: startersId,  // or mains/drinks/desserts
  name: 'Samosa',
  price: 80,
  isAvailable: true,
  isVegetarian: true,
  isSpicy: true,
  displayOrder: 1,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: AppConstants.syncStatusPending,
);
await menuRepository.createMenuItem(newItem);
```

### Get All Tables
```dart
final tables = await TableRepository().getAllTables();
for (final table in tables) {
  print('Table ${table.tableNumber}: ${table.status}');
}
```

### Create an Order
```dart
final order = OrderModel(
  id: const Uuid().v4(),
  tableId: tableId,
  tableNumber: 5,
  orderType: 'dine-in',
  status: 'open',
  subtotal: 0,
  taxAmount: 0,
  discountAmount: 0,
  totalAmount: 0,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: 'pending',
);
await OrderRepository().createOrder(order);
```

### Add Item to Order
```dart
await orderController.addItemToOrder(
  menuItem,
  quantity: 2,
  selectedModifierIds: ['extra-spicy'],
  notes: 'No onion'
);
```

### Get Order Total
```dart
print('Total: ₹${orderController.totalAmount}');
print('Tax: ₹${orderController.taxAmount}');
print('Subtotal: ₹${orderController.subtotal}');
```

---

## 🎨 Styling Custom UI

### Use Theme Colors
```dart
Container(
  color: AppTheme.primaryColor,  // Green
  child: Text(
    'Amount: ₹100',
    style: TextStyle(color: AppTheme.textPrimary),  // Dark text
  ),
)
```

### Use Custom Widgets
```dart
// Button
PrimaryButton(
  label: 'Place Order',
  onPressed: () { /* Action */ },
)

// Card
PosCard(
  child: Column(/* Content */),
  backgroundColor: AppTheme.cardBg,
)

// Status Badge
StatusBadge(status: 'occupied')  // Shows colored status

// Currency Display
CurrencyDisplay(amount: 750.50)  // Shows ₹750.50
```

---

## 🔧 Debugging Tips

### Check Database
```dart
// In any controller:
final db = await DatabaseHelper().database;
final tables = await db.query('tables');
print(tables);
```

### Check Preferences
```dart
final prefs = await SharedPreferences.getInstance();
final tax = prefs.getDouble('tax_rate');
print('Tax Rate: $tax%');
```

### Print Order Details
```dart
print('Order: ${orderController.currentOrder.value}');
print('Items: ${orderController.currentOrderItems}');
print('Total: ${orderController.totalAmount}');
```

### Listen to Changes
```dart
Obx(() {
  print('Tables updated: ${tableController.tables.length}');
})
```

---

## 📦 Project Structure Overview

```
posrest/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── themes/app_theme.dart
│   │   └── widgets/custom_widgets.dart
│   ├── data/
│   │   ├── database/database_helper.dart
│   │   ├── models/                  # All data models
│   │   └── repositories/            # Data access
│   ├── features/
│   │   ├── auth/                    # Login screens
│   │   ├── tables/                  # Table management
│   │   ├── menu/                    # Menu browsing
│   │   ├── orders/                  # Order creation
│   │   └── billing/                 # (coming soon)
│   └── services/
│       ├── auth_service.dart
│       └── preferences_service.dart
├── pubspec.yaml                     # Dependencies
└── README.md                        # Full documentation
```

---

## 🧪 Testing Checklist

Before considering your app ready:

- [ ] Can login with demo credentials
- [ ] Can see 12 tables
- [ ] Can create new table
- [ ] Can take an order
- [ ] Can add items to order
- [ ] Can see correct calculations (subtotal + tax)
- [ ] Can send order to kitchen
- [ ] Tax rate is applied correctly (5% by default)
- [ ] App doesn't crash on any screen
- [ ] Tables update status when order created
- [ ] Can go back from any screen
- [ ] Menu items display properly

---

## 🎯 Next Steps After Setup

### Immediate (Day 1):
1. Run the app
2. Test login
3. Test creating order
4. Verify calculations
5. Check database (all tables created)

### Short Term (Week 1):
1. Understand code structure
2. Modify menu items to your needs
3. Change colors to match brand
4. Customize tax rate
5. Add printer support (Phase 3)

### Medium Term (Week 2-3):
1. Add billing/payment screen
2. Implement kitchen display
3. Add split bill feature
4. Test on real device

### Long Term (Month 1+):
1. Connect to backend API
2. Implement cloud sync
3. Add reports module
4. Deploy to production

---

## 📞 Troubleshooting

### App won't run
```bash
flutter clean
flutter pub get
flutter run -v  # Verbose mode for debugging
```

### Database errors
```bash
# Reinstall app to reset database
flutter clean
flutter run
```

### Hot reload not working
- Try hot restart: `R` key
- Or manually rebuild: `flutter run`

### Dependencies conflict
```bash
flutter pub upgrade
flutter pub get
flutter pub deps
```

### Permission issues (Android)
- Check `android/app/build.gradle`
- Ensure `minSdkVersion` is 21+

---

## 📚 Key Concepts

### GetX State Management
```dart
// Define reactive variable
final count = 0.obs;

// Listen to changes
Obx(() => Text('${count.value}'))

// Update value
count.value = 5;

// Use in controller
class MyController extends GetxController {
  final items = <ItemModel>[].obs;
}
```

### Repository Pattern
```dart
// Repository handles all data access
class MenuRepository {
  Future<List<MenuItemModel>> getItemsByCategory(String catId) async {
    return await DatabaseHelper().getMenuItemsByCategory(catId);
  }
}

// Controller uses repository
class MenuController extends GetxController {
  final menuRepository = MenuRepository();
  
  Future<void> loadItems() async {
    items.value = await menuRepository.getItemsByCategory(catId);
  }
}
```

### Models with Serialization
```dart
class OrderModel {
  final String id;
  final double totalAmount;
  
  // Convert to JSON
  Map<String, dynamic> toMap() => {...};
  
  // Convert from JSON
  static OrderModel fromMap(Map<String, dynamic> map) => ...;
  
  // Copy with modifications
  OrderModel copyWith({double? totalAmount}) => ...;
}
```

---

## 🚀 Production Checklist

Before going live:

- [ ] All dependencies updated
- [ ] API endpoints configured
- [ ] Database migrations tested
- [ ] Error handling implemented
- [ ] Logging enabled
- [ ] Testing completed
- [ ] Performance optimized
- [ ] Security checks done
- [ ] Offline mode verified
- [ ] Backup/restore working
- [ ] Documentation complete
- [ ] Team trained

---

**Quick Reference:** Ctrl+F to search this document!

**Last Updated:** May 6, 2026  
**Version:** 1.0.0
