class AppConstants {
  // App Info
  static const String appName = 'POSRest';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.posrest.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Database
  static const String dbName = 'posrest.db';
  static const int dbVersion = 1;

  // Table Names
  static const String tableUsers = 'users';
  static const String tableTables = 'tables';
  static const String tableMenuCategories = 'menu_categories';
  static const String tableMenuItems = 'menu_items';
  static const String tableModifiers = 'modifiers';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';
  static const String tablePayments = 'payments';
  static const String tableTaxes = 'taxes';
  static const String tableSyncQueue = 'sync_queue';
  static const String tableInventory = 'inventory';

  // Shared Preferences Keys
  static const String spAuthToken = 'auth_token';
  static const String spUserId = 'user_id';
  static const String spUserRole = 'user_role';
  static const String spUserEmail = 'user_email';
  static const String spLanguage = 'language';
  static const String spTheme = 'theme';
  static const String spTaxRate = 'tax_rate';
  static const String spRestaurantName = 'restaurant_name';
  static const String spLastSyncTime = 'last_sync_time';

  // Status Constants
  static const String statusFree = 'free';
  static const String statusOccupied = 'occupied';
  static const String statusReserved = 'reserved';

  static const String orderStatusOpen = 'open';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusServed = 'served';
  static const String orderStatusPaid = 'paid';
  static const String orderStatusCancelled = 'cancelled';

  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';

  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentUPI = 'upi';
  static const String paymentOnline = 'online';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleCashier = 'cashier';
  static const String roleWaiter = 'waiter';
  static const String roleChef = 'chef';

  // Sync Status
  static const String syncStatusPending = 'pending';
  static const String syncStatusCompleted = 'completed';
  static const String syncStatusFailed = 'failed';

  // Validation
  static const int minTableNumber = 1;
  static const int maxTableNumber = 100;
  static const int minCapacity = 1;
  static const int maxCapacity = 50;

  // Formatting
  static const String currencySymbol = '₹';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration normalAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}
