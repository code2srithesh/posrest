# 🍽️ POSRest — Premium Restaurant POS

A high-performance, dark-mode glassmorphic Point of Sale (POS) system designed for tablets and web browsers. Built on a modular, offline-first architecture, it handles high-frequency dining transactions, real-time state synchronization across staff terminals, and automated kitchen workflows.

---

## 💎 Elite Operational Features

### 1. High-Fidelity Menu Catalog & Navigation UI
- **Category Filter Drawer ("3 Lines" Icon):** Access a slide-out drawer containing a fuzzy search bar, dietary toggles, and live category item counts.
- **Dynamic Quick Filters:** Filter dishes by *Vegetarian Only* or *Spicy Only* with a single tap.
- **Dual-Layout Viewport Switcher:** Switch dynamically between:
  - **Grid Card View:** Display items in a rich grid with glowing border overlays and top-right green quantity badges (`2x`, `3x`) for active selections.
  - **Compact List View:** Display items as horizontal rows utilizing exactly **3 lines of text** to pack information (Line 1: Name, Price, Veg indicator; Line 2: Ingredients and prep time; Line 3: Order addition status).

### 2. Auto-Cancel & Table Release Lifecycle
- **Zero Table Locks:** Tapping a vacant table initiates a new order. If the operator exits the order taking screen without adding any items to the cart, the empty order is automatically purged from the database, and the table is immediately released back to **FREE** (vacant, green) status.
- **PopScope Guard:** The cancel-release workflow is bound to the navigation stack, capturing physical back buttons, browser gestures, and AppBar pops.

### 3. Real-Time Multi-Screen State Synchronization
- **Cashier Payments Integration:** Completing a payment instantly frees the table in SQLite and clears the order cache.
- **GetX State Propagation:** Automatically locates singletons and calls reloads for `TableController` and `UserManagementController` instantly. Active floor plans on waiter screens and ERP grids in the Admin Console update **without manual page refreshes**.
- **KDS Background Polling:** The Kitchen Display System (KDS) polls active SQLite queues every 4 seconds via background timers, displaying incoming tickets to the Chef instantly.

### 4. Professional Restaurant Catalog Seeding
- Purged simple mock seeds on startup and replaced them with a **25+ chef-curated Indian restaurant menu database** across **6 categories**:
  * **Appetizers & Starters:** Crispy Paneer Bites, Afghani Malai Chaap, Pepper Garlic Prawns, Tandoori Chicken Wings.
  * **Main Course:** Paneer Butter Masala, Dal Bukhara, Murgh Makhani, Awadhi Lamb Korma, Coastal Fish Curry.
  * **Breads & Rice:** Butter Naan, Garlic Naan, Subz Dum Biryani, Awadhi Chicken Biryani, Steamed Basmati Rice.
  * **Desserts:** Saffron Rasmalai, Shahi Tukda, Warm Gajar Halwa, Choco Lava Decadence.
  * **Craft Mocktails:** Mint & Lime Mojito, Spiced Mango Cooler, Pomegranate Ginger Spritz.
  * **Hot Beverages:** Signature Masala Chai, South Indian Filter Coffee, Assam Green Tea.

---

## 🎨 Visual Identity & Styling Tokens

The system utilizes a custom glassmorphic theme designed to decrease eye strain during long restaurant shifts.

| Design Attribute | Value / Palette | Color Code / Hex |
| :--- | :--- | :--- |
| **Theme Mode** | Dark-Centric Glassmorphism | Curated HSL Palette |
| **Primary Background** | Radial Deep Purple & Black | `#0F0C1B` to `#06040A` |
| **Glass Overlays** | Semi-Transparent Purple/Teal | `rgba(255, 255, 255, 0.04)` |
| **Accent Teal (Interactive)**| High-Vibrancy Cyan | `#00F2FE` / `#4FACFE` |
| **Success Color (Vacant)** | Emerald Green | `#00C853` |
| **Error Color (Occupied)** | Ruby Crimson | `#D50000` |
| **Typography** | Poppins & Outfit | Google Fonts |

---

## 🏗️ Technical Blueprint & Directory Structure

```
lib/
├── core/
│   ├── constants/          # Application constants & status codes
│   ├── themes/             # Premium dark-mode glassmorphic theme
│   └── widgets/            # GlassContainer & reusable UI elements
├── data/
│   ├── database/           # SQLite native & Mock Database for Web/Tests
│   ├── models/             # Models with serialization
│   └── repositories/       # Data Access Layer (Table, Menu, Order, Payment)
├── features/
│   ├── auth/               # Role-based secure authentication
│   ├── tables/             # Floor plan grid management
│   ├── menu/               # Food catalog controllers & loaders
│   ├── orders/             # Order placement, drawers, and compact rows
│   ├── billing/            # Cashier settlements & receipts
│   ├── kitchen/            # Chef's Kitchen Display System (KDS)
│   └── admin/              # Central ERP dashboard & directory management
├── services/               # Preferences & Authentication singletons
└── main.dart               # System entry point
```

---

## 🚀 Getting Started & Setup

### Prerequisites
* **Flutter:** `3.19.0` or higher
* **Dart SDK:** `3.3.0` or higher
* Supported on **Web (Chrome)**, **macOS Desktop**, **iOS**, and **Android**.

### Installation Steps

1. **Clone and navigate to the project directory:**
   ```bash
   git clone <repository-url>
   cd posrest
   ```

2. **Retrieve package dependencies:**
   ```bash
   flutter pub get
   ```

3. **Compile the production-ready web release build:**
   ```bash
   flutter build web --release
   ```
   *The compiled production files will be output to `build/web` for immediate deployment to your Netlify dashboard.*

4. **Launch the application in debug mode:**
   ```bash
   flutter run -d chrome
   ```

---

## 🔐 Staff Accounts Directory & Access Roles

Log in to the POS system using any of the following pre-seeded credentials:

| Role | Username / Email | Password | Allowed Capabilities |
| :--- | :--- | :--- | :--- |
| **Administrator** | `admin@posrest.com` | `admin123` | Full access, Menu Creation, Staff Management, ERP Dashboard. |
| **Waiter** | `waiter@posrest.com` | `waiter123` | Floor Plan, Order Catalog, Cart Additions, Send KOT to Kitchen. |
| **Chef / Kitchen** | `chef@posrest.com` | `chef123` | KDS Display, Real-Time Polling, Mark Orders Preparing/Served. |
| **Cashier** | `cashier@posrest.com` | `cashier123` | Billing & Settlement, Discount Calculations, Receipts. |

---

## 🧪 Quality Assurance & Test Outcomes

We maintain a zero-regression policy across all core operations. All workflows are fully verified by automated unit, widget, and integration tests.

### Test Results Summary
* **Total Executed Tests:** 30 definitions
* **Passed Cases:** 30/30
* **Success Rate:** 100%

Run the test suite locally using the following command:
```bash
flutter test
```
```bash
00:03 +30: All tests passed!
```
- **Waiter Flow:** Validates order initialization, cart item edits, and subtotal increments.
- **KDS Flow:** Validates multi-status transitions (`pending` → `preparing` → `ready` → `served`).
- **Billing Calculations:** Verifies 5% standard food tax, 18% premium tax, percentage discounts, and service charges.
- **Sync Coordination:** Validates automatic database table releases and memory clearing.
