import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Language
  Future<void> setLanguage(String language) async {
    await _prefs.setString(AppConstants.spLanguage, language);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.spLanguage) ?? 'en';
  }

  // Theme
  Future<void> setTheme(String theme) async {
    await _prefs.setString(AppConstants.spTheme, theme);
  }

  String getTheme() {
    return _prefs.getString(AppConstants.spTheme) ?? 'light';
  }

  // Tax Rate
  Future<void> setTaxRate(double taxRate) async {
    await _prefs.setDouble(AppConstants.spTaxRate, taxRate);
  }

  double getTaxRate() {
    return _prefs.getDouble(AppConstants.spTaxRate) ?? 5.0; // Default 5% GST
  }

  // Restaurant Name
  Future<void> setRestaurantName(String name) async {
    await _prefs.setString(AppConstants.spRestaurantName, name);
  }

  String getRestaurantName() {
    return _prefs.getString(AppConstants.spRestaurantName) ?? 'My Restaurant';
  }

  // Last Sync Time
  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setString(AppConstants.spLastSyncTime, time.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final timeStr = _prefs.getString(AppConstants.spLastSyncTime);
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  // Clear all preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
