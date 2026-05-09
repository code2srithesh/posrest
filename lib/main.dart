import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/themes/app_theme.dart';
import 'features/settings/controllers/theme_controller.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/tables/screens/table_screen.dart';
import 'features/orders/screens/order_screen.dart';
import 'features/billing/screens/billing_screen.dart';
import 'features/kitchen/screens/kitchen_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AuthService().initialize();
  await PreferencesService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        title: 'POSRest',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: AuthService().isLoggedIn()
            ? const TableScreen()
            : const LoginScreen(),
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/tables', page: () => const TableScreen()),
          GetPage(name: '/order', page: () => const OrderScreen()),
          GetPage(name: '/order/create', page: () => const OrderScreen()),
          GetPage(
            name: '/billing/:orderId',
            page: () => BillingScreen(orderId: Get.parameters['orderId'] ?? ''),
          ),
          GetPage(name: '/kitchen', page: () => const KitchenScreen()),
        ],
      ),
    );
  }
}
