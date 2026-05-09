import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../data/database/database_helper.dart';
import '../data/models/user_model.dart';
import 'password_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  static AuthService get instance => _instance;

  AuthService._internal();

  late SharedPreferences _prefs;
  late DatabaseHelper _db;
  bool _initialized = false;
  UserModel? _currentUser;

  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _db = DatabaseHelper();
      _initialized = true;
      _createDefaultUsers();
    }
  }

  // Create default demo users (only if database is empty)
  Future<void> _createDefaultUsers() async {
    try {
      final existingUsers = await _db.getAllUsers();
      if (existingUsers.isEmpty) {
        // Create demo users with different roles
        final demoUsers = [
          UserModel(
            id: const Uuid().v4(),
            name: 'Admin User',
            email: 'admin@posrest.com',
            password: 'admin123', // In production, these would be hashed
            role: 'admin',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
          UserModel(
            id: const Uuid().v4(),
            name: 'Manager',
            email: 'manager@posrest.com',
            password: 'manager123',
            role: 'manager',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
          UserModel(
            id: const Uuid().v4(),
            name: 'Cashier',
            email: 'cashier@posrest.com',
            password: 'cashier123',
            role: 'cashier',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
          UserModel(
            id: const Uuid().v4(),
            name: 'Waiter',
            email: 'waiter@posrest.com',
            password: 'waiter123',
            role: 'waiter',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
          UserModel(
            id: const Uuid().v4(),
            name: 'Chef',
            email: 'chef@posrest.com',
            password: 'chef123',
            role: 'chef',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
          ),
        ];

        for (final user in demoUsers) {
          await _db.insertUser(user);
        }
      }
    } catch (e) {
      print('Error creating default users: $e');
    }
  }

  // Login user with real validation
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Validate inputs
      if (!PasswordService.isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Invalid email format',
          'user': null,
        };
      }

      if (!PasswordService.isValidPassword(password)) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters',
          'user': null,
        };
      }

      // Get all users and find matching email
      final users = await _db.getAllUsers();
      UserModel? user;

      for (final u in users) {
        if (u.email.toLowerCase() == email.toLowerCase()) {
          user = u;
          break;
        }
      }

      if (user == null) {
        return {
          'success': false,
          'message': 'User not found',
          'user': null,
        };
      }

      if (!user.isActive) {
        return {
          'success': false,
          'message': 'User account is inactive',
          'user': null,
        };
      }

      // Verify password
      if (!PasswordService.verifyPassword(password, user.password)) {
        return {
          'success': false,
          'message': 'Invalid credentials',
          'user': null,
        };
      }

      // Login successful
      _currentUser = user;
      await _prefs.setString(AppConstants.spUserEmail, user.email);
      await _prefs.setString(AppConstants.spUserId, user.id);
      await _prefs.setString(AppConstants.spUserRole, user.role);
      await _prefs.setString(
        AppConstants.spAuthToken,
        'auth_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
      );

      return {
        'success': true,
        'message': 'Login successful',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login error: $e',
        'user': null,
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
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

  // Get current user name
  String? getUserName() {
    return _currentUser?.name ?? 'User';
  }

  // Get current user role
  String? getUserRole() {
    return _prefs.getString(AppConstants.spUserRole) ?? 'waiter';
  }

  // Get current user object
  UserModel? getCurrentUser() {
    return _currentUser;
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
    const roleHierarchy = ['admin', 'manager', 'cashier', 'waiter', 'chef'];

    final currentIndex = roleHierarchy.indexOf(currentRole ?? 'waiter');
    final requiredIndex = roleHierarchy.indexOf(requiredRole);

    return currentIndex <= requiredIndex;
  }

  // Get all available users (for testing)
  Future<List<UserModel>> getAllUsers() async {
    return await _db.getAllUsers();
  }
}
