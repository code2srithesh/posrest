# POSRest - Restaurant POS System

A complete Flutter-based Point of Sale system for restaurants with offline-first architecture, real-time sync, and hardware support.

## ✨ Features Implemented

### ✅ Phase 1 - Core POS (COMPLETE)
- **Table Management** - Create, view, and manage restaurant tables with status tracking
- **Menu Management** - Categorized menu with items, modifiers, and dietary indicators
- **Order Management** - Create orders, add items with customizations
- **Billing** - Automatic calculation of subtotal, tax, and totals
- **Authentication** - Secure login with role-based access
- **Database** - SQLite with offline support

### 🏗️ Phase 2 - Restaurant Features (IN PROGRESS)
- Kitchen Order Tickets (KOT) display system
- Split bill functionality
- Advanced modifiers and combo meals
- Reports and analytics

### 🔌 Phase 3 - Hardware Integration (PLANNED)
- Thermal printer support (ESC/POS)
- Bluetooth connectivity
- Cash drawer control
- Barcode scanner integration

### 🔄 Phase 4 - Sync & Cloud (PLANNED)
- Backend API integration
- Auto-sync when online
- Conflict resolution
- Crash recovery

## 🏗️ Project Architecture

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── themes/             # Material Design theme
│   └── widgets/            # Reusable UI components
├── data/
│   ├── database/           # SQLite configuration
│   ├── models/             # Data models with serialization
│   └── repositories/       # Data access layer (Repository pattern)
├── features/
│   ├── auth/               # Authentication flows
│   ├── tables/             # Table management feature
│   ├── menu/               # Menu browsing feature
│   ├── orders/             # Order creation feature
│   ├── billing/            # Billing & payments (coming)
│   ├── kitchen/            # Kitchen display system (coming)
│   ├── reports/            # Analytics & reports (coming)
│   └── settings/           # Configuration (coming)
├── services/               # Business logic services
└── main.dart               # Application entry point
```

## 🚀 Getting Started

### Prerequisites
- **Flutter:** 3.10.0 or higher
- **Dart:** 3.0.0 or higher
- **Android SDK** or **iOS SDK**

### Installation Steps

1. **Navigate to project directory:**
   ```bash
   cd /Users/srithesh/Desktop/posrest
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate JSON serialization (if needed):**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

### Demo Credentials
- **Email:** demo@posrest.com
- **Password:** demo123
- **Role:** Waiter

## 📱 Module Documentation

### 1. Authentication Module
**Purpose:** Secure staff access and role management

**Files:**
- `lib/features/auth/screens/login_screen.dart` - UI
- `lib/features/auth/controllers/auth_controller.dart` - Logic

**Roles:**
- Admin - Full access
- Manager - Can edit menu and reports
- Cashier - Billing and payments
- Waiter - Order creation
- Chef - Kitchen display only

---

### 2. Table Management
**Purpose:** Manage physical restaurant tables

**Key Features:**
- View tables in responsive grid (3 columns)
- Status tracking: Free, Occupied, Reserved
- Quick create new tables
- Filter tables by status
- Occupancy analytics

**Files:**
- `lib/features/tables/screens/table_screen.dart` - UI
- `lib/features/tables/controllers/table_controller.dart` - Logic

**Workflow:**
```
Tables Screen → Select Table → Create Order
                  ↓
           (if occupied) → Edit Order
```

**Default Tables:** Auto-creates 12 tables on first run

---

### 3. Menu Management
**Purpose:** Browse and manage restaurant menu

**Components:**
- Categories (Starters, Mains, Drinks, Desserts)
- Menu Items (name, price, availability)
- Modifiers (extras, toppings, spice levels)
- Dietary indicators (vegetarian, spicy)

**Files:**
- `lib/features/menu/controllers/menu_controller.dart` - Menu logic
- `lib/data/repositories/menu_repository.dart` - Data access

**Default Menu Items:**
```
Starters:
- Samosa (₹80, Vegetarian, Spicy)
- Paneer Tikka (₹180, Vegetarian)

Main Course:
- Butter Chicken (₹320, Non-Veg)
- Biryani (₹280, Non-Veg, Spicy)

Drinks:
- Lassi (₹60, Vegetarian)
- Mango Juice (₹80, Vegetarian)

Desserts:
- Gulab Jamun (₹100, Vegetarian)
```

---

### 4. Order Management
**Purpose:** Create and manage customer orders

**Key Features:**
- Add items from menu
- Customize with modifiers
- Add special instructions
- Real-time price calculation
- View order summary

**Files:**
- `lib/features/orders/screens/order_screen.dart` - UI
- `lib/features/orders/controllers/order_controller.dart` - Logic

**Order Statuses:**
- Open - Being prepared
- Preparing - In kitchen
- Served - Ready for customer
- Paid - Transaction complete
- Cancelled - Order cancelled

**Split View:**
- Left: Menu browser (2-column grid)
- Right: Order cart with totals

---

### 5. Database (SQLite)
**Purpose:** Offline-first data persistence

**Tables Created:**
1. **users** - Staff profiles (id, email, role, active)
2. **tables** - Physical tables (number, capacity, status)
3. **menu_categories** - Item categories
4. **menu_items** - Individual menu items
5. **modifiers** - Item add-ons/extras
6. **orders** - Customer orders
7. **order_items** - Items in orders
8. **payments** - Transaction records
9. **sync_queue** - Pending cloud syncs

**All tables include:**
- UUID as primary key
- created_at, updated_at timestamps
- sync_status (for cloud sync)
- deleted_at (soft deletes)

**File:** `lib/data/database/database_helper.dart`

---

## 🎨 UI/UX Design

### Color Scheme
| Element | Color | Hex |
|---------|-------|-----|
| Primary | Green | #2E7D32 |
| Primary Dark | Dark Green | #1B5E20 |
| Accent | Orange | #FF6F00 |
| Success | Light Green | #4CAF50 |
| Error | Red | #FF5252 |
| Warning | Yellow | #FFC107 |
| Info | Blue | #2196F3 |

### Status Colors
- **Free Table:** Green (#81C784)
- **Occupied Table:** Red (#EF5350)
- **Reserved Table:** Orange (#FFB74D)

### Typography
- **Font Family:** Poppins (Google Fonts)
- **Headlines:** Bold, 32-24px
- **Body:** Regular, 14-16px

**Theme File:** `lib/core/themes/app_theme.dart`

---

## 💰 Billing & Calculations

### Tax Calculation
```
Subtotal = Sum of all item prices
Tax = Subtotal × Tax Rate (%)
Total = Subtotal + Tax
```

**Default Tax Rate:** 5% GST  
**Configurable in:** PreferencesService

### Example Calculation
```
Item 1: Butter Chicken (₹320) × 1
Item 2: Biryani (₹280) × 1
Item 3: Lassi (₹60) × 2

Subtotal = 320 + 280 + 120 = ₹720
Tax (5%) = 720 × 0.05 = ₹36
Total = 720 + 36 = ₹756
```

---

## 🔧 Core Services

### AuthService
```dart
// Login user
await AuthService().login(email, password);

// Check if logged in
bool isLoggedIn = AuthService().isLoggedIn();

// Get current user info
String? email = AuthService().getUserEmail();
String? role = AuthService().getUserRole();

// Check permissions
bool canEdit = AuthService().hasPermission('admin');

// Logout
await AuthService().logout();
```

**File:** `lib/services/auth_service.dart`

### PreferencesService
```dart
// Get tax rate
double taxRate = PreferencesService().getTaxRate();

// Set tax rate
await PreferencesService().setTaxRate(10.0);

// Get restaurant name
String name = PreferencesService().getRestaurantName();

// Set restaurant name
await PreferencesService().setRestaurantName('My Restaurant');

// Sync tracking
DateTime? lastSync = PreferencesService().getLastSyncTime();
```

**File:** `lib/services/preferences_service.dart`

---

## 📦 Data Models

### TableModel
```dart
TableModel(
  id: 'uuid',
  tableNumber: 1,
  capacity: 4,
  status: 'free', // free, occupied, reserved
  occupiedSeats: 2,
  currentOrderId: 'order-uuid',
  mergedTableIds: [],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: 'pending',
  deletedAt: null,
);
```

### MenuItemModel
```dart
MenuItemModel(
  id: 'uuid',
  categoryId: 'category-uuid',
  name: 'Butter Chicken',
  description: 'Tender chicken in creamy tomato sauce',
  price: 320,
  isAvailable: true,
  isVegetarian: false,
  isSpicy: false,
  modifierIds: ['mod1', 'mod2'],
  displayOrder: 1,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: 'pending',
);
```

### OrderModel
```dart
OrderModel(
  id: 'uuid',
  tableId: 'table-uuid',
  tableNumber: 5,
  orderType: 'dine-in',
  status: 'open',
  subtotal: 720,
  taxAmount: 36,
  discountAmount: 0,
  totalAmount: 756,
  items: [OrderItemModel(...)],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: 'pending',
);
```

---

## 🎯 Key Workflows

### Workflow 1: Taking an Order
```
1. User logs in → Dashboard
2. Click free table → Create Order (generates Order ID)
3. Browse menu by category
4. Click menu item → Item details dialog
5. Select quantity, add notes, confirm modifiers
6. Item added to cart (right panel)
7. Cart shows: Item list, Subtotal, Tax, Total
8. Click "Send to Kitchen" → Order status = "preparing"
9. Kitchen receives KOT (Kitchen Order Ticket)
10. Waiter updates status when served
11. Generate bill for payment
```

### Workflow 2: Managing Table
```
1. View all tables in grid layout
2. Color coding shows status:
   - Green = Free (click to create order)
   - Red = Occupied (click to edit order)
   - Orange = Reserved
3. Filter by status using chips
4. Add new table using + button
```

### Workflow 3: Billing Process
```
1. Order ready for payment
2. Click table → View order
3. System auto-calculates:
   - Subtotal
   - Tax (5% by default)
   - Total amount
4. Select payment method:
   - Cash
   - Card
   - UPI
   - Online (future)
5. Print receipt
6. Mark table as free
```

---

## 🔐 Role-Based Access Control

### Admin
- Create/edit/delete menu items
- Create/edit/delete users
- View reports
- Configure settings
- Access all features

### Manager
- View/edit menu (limited)
- View reports
- Manage inventory
- Limited admin access

### Cashier
- View bills
- Process payments
- Print receipts
- View completed orders

### Waiter
- Create orders
- Add items to orders
- View table status
- Request bill

### Chef
- View kitchen tickets
- Update order status
- No access to billing/payments

---

## 📊 Customization Guide

### Change App Name
Edit `pubspec.yaml`:
```yaml
name: your_app_name
```

### Change Theme Colors
Edit `lib/core/themes/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF...);
static const Color accentColor = Color(0xFF...);
```

### Add Menu Categories
```dart
MenuCategoryModel category = MenuCategoryModel(
  id: const Uuid().v4(),
  name: 'Breads',
  displayOrder: 5,
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: 'pending',
);

await MenuRepository().createCategory(category);
```

### Add Menu Items
```dart
MenuItemModel item = MenuItemModel(
  id: const Uuid().v4(),
  categoryId: 'category-id',
  name: 'Naan',
  price: 50,
  isAvailable: true,
  isVegetarian: true,
  isSpicy: false,
  displayOrder: 1,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: 'pending',
);

await MenuRepository().createMenuItem(item);
```

### Modify Tax Rate
```dart
// In PreferencesService initialization or settings page
await PreferencesService().setTaxRate(18.0); // 18% GST
```

---

## 🧪 Testing

### Test Demo Functionality
1. Run app: `flutter run`
2. Login with demo@posrest.com / demo123
3. Create order from any table
4. Add items with modifications
5. Verify calculations
6. Send to kitchen

### Test Offline
1. Put device in airplane mode
2. Data should still load from local database
3. Orders saved locally
4. Sync when online (future feature)

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| App won't start | `flutter clean && flutter pub get` |
| Database errors | Uninstall app and reinstall |
| UI not loading | Check dependencies: `flutter pub get` |
| Build errors | Update Dart/Flutter: `flutter upgrade` |
| Slow performance | Clear app cache and data |

---

## 📝 File Checklist for Completion

✅ = Done | 🏗️ = In Progress | ⭕ = TODO

- ✅ Project structure
- ✅ Theme & colors
- ✅ Database schema
- ✅ Authentication
- ✅ Table management
- ✅ Menu system
- ✅ Order management
- ✅ UI components
- 🏗️ Billing screen
- ⭕ Kitchen display
- ⭕ Reports
- ⭕ Printer integration
- ⭕ Cloud sync
- ⭕ Settings page

---

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [GetX State Management](https://pub.dev/packages/get)
- [SQLite in Flutter](https://pub.dev/packages/sqflite)
- [Material Design](https://material.io/design)

---

**Version:** 1.0.0 (Phase 1 Complete)  
**Last Updated:** May 6, 2026  
**Status:** ✅ Ready for Development

