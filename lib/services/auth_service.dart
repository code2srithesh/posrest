import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    // TODO: Implement actual authentication with backend
    // For now, store user info
    await _prefs.setString(AppConstants.spUserEmail, email);
    await _prefs.setString(AppConstants.spAuthToken, 'dummy_token_$email');
    return true;
  }

  // Logout user
  Future<void> logout() async {
    await _prefs.remove(AppConstants.spAuthToken);
    await _prefs.remove(AppConstants.spUserId);
    await _prefs.remove(AppConstants.spUserRole);
    await _prefs.remove(AppConstants.spUserEmail);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getString(AppConstants.spAuthToken) != null;
  }

  // Get auth token
  String? getAuthToken() {
    return _prefs.getString(AppConstants.spAuthToken);
  }

  // Get current user ID
  String? getUserId() {
    return _prefs.getString(AppConstants.spUserId);
  }

  // Get current user email
  String? getUserEmail() {
    return _prefs.getString(AppConstants.spUserEmail);
  }

  // Get current user role
  String? getUserRole() {
    return _prefs.getString(AppConstants.spUserRole) ?? 'waiter';
  }

  // Set user info
  Future<void> setUserInfo(String userId, String email, String role) async {
    await _prefs.setString(AppConstants.spUserId, userId);
    await _prefs.setString(AppConstants.spUserEmail, email);
    await _prefs.setString(AppConstants.spUserRole, role);
  }

  // Check if user has permission
  bool hasPermission(String requiredRole) {
    final currentRole = getUserRole();
    final roleHierarchy = ['admin', 'manager', 'cashier', 'waiter', 'chef'];

    final currentIndex = roleHierarchy.indexOf(currentRole ?? 'waiter');
    final requiredIndex = roleHierarchy.indexOf(requiredRole);

    return currentIndex <= requiredIndex;
  }
}
