import 'package:get/get.dart';
import '../../../services/preferences_service.dart';

class ThemeController extends GetxController {
  static ThemeController get instance => Get.find();

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  void _loadThemePreference() {
    final isDark = PreferencesService.instance.isDarkMode;
    isDarkMode.value = isDark;
  }

  void toggleTheme() {
    isDarkMode.toggle();
    PreferencesService.instance.setDarkMode(isDarkMode.value);
  }

  void setDarkMode(bool value) {
    isDarkMode.value = value;
    PreferencesService.instance.setDarkMode(value);
  }
}
