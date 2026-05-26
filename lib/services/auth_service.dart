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
      await _createDefaultUsers();
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  // Create default demo users (only if database is empty)
  Future<void> _createDefaultUsers() async {
    try {
      final existingUsers = await _db.getAllUsers();
      // Ensure canonical demo accounts exist even on older databases.
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
        final existing = existingUsers.where(
          (stored) => stored.email.toLowerCase() == user.email.toLowerCase(),
        );

        if (existing.isEmpty) {
          await _db.insertUser(user);
        } else {
          final stored = existing.first;
          final normalized = stored.copyWith(
            name: user.name,
            password: user.password,
            role: user.role,
            isActive: user.isActive,
            syncStatus: user.syncStatus,
            updatedAt: DateTime.now(),
          );
          await _db.updateUser(normalized);
        }
      }
    } catch (e) {
      // Ignore seed errors here and let login surface a usable message.
    }
  }

  // Login user with real validation
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      await _ensureInitialized();

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
        return {'success': false, 'message': 'User not found', 'user': null};
      }

      if (!user.isActive) {
        return {
          'success': false,
          'message': 'Account is pending admin approval',
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

      return {'success': true, 'message': 'Login successful', 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Login error: $e', 'user': null};
    }
  }

  // Logout user
  Future<void> logout() async {
    await _ensureInitialized();
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
    await _ensureInitialized();
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
    await _ensureInitialized();
    return await _db.getAllUsers();
  }

  List<String> getAssignableRoles() {
    return [
      AppConstants.roleWaiter,
      AppConstants.roleCashier,
      AppConstants.roleChef,
    ];
  }

  String getRoleLabel(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Admin';
      case AppConstants.roleManager:
        return 'Manager';
      case AppConstants.roleCashier:
        return 'Cashier';
      case AppConstants.roleWaiter:
        return 'Waiter';
      case AppConstants.roleChef:
        return 'Kitchen Chef';
      default:
        return role;
    }
  }

  String getLandingRouteForRole(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return '/admin/users';
      case AppConstants.roleChef:
        return '/kitchen';
      case AppConstants.roleCashier:
        return '/cashier';
      case AppConstants.roleWaiter:
      case AppConstants.roleManager:
      default:
        return '/tables';
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      await _ensureInitialized();
      final normalizedEmail = email.trim().toLowerCase();

      if (name.trim().isEmpty) {
        return {'success': false, 'message': 'Name is required', 'user': null};
      }

      if (!PasswordService.isValidEmail(normalizedEmail)) {
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

      if (!getAssignableRoles().contains(role)) {
        return {
          'success': false,
          'message': 'Please choose waiter, cashier, or kitchen chef',
          'user': null,
        };
      }

      final users = await _db.getAllUsers();
      final existing = users.where(
        (user) => user.email.toLowerCase() == normalizedEmail,
      );
      if (existing.isNotEmpty) {
        return {
          'success': false,
          'message': 'An account with this email already exists',
          'user': null,
        };
      }

      final user = UserModel(
        id: const Uuid().v4(),
        name: name.trim(),
        email: normalizedEmail,
        password: PasswordService.hashPassword(password),
        role: role,
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _db.insertUser(user);
      return {
        'success': true,
        'message': 'Registration submitted for admin approval',
        'user': user,
      };
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('unique') && message.contains('users.email')) {
        return {
          'success': false,
          'message': 'An account with this email already exists',
          'user': null,
        };
      }

      return {
        'success': false,
        'message': 'Registration error: $e',
        'user': null,
      };
    }
  }

  Future<Map<String, dynamic>> createUserByAdmin({
    required String name,
    required String email,
    required String password,
    required String role,
    bool isActive = true,
  }) async {
    try {
      await _ensureInitialized();

      final result = await registerUser(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      if (result['success'] != true) {
        return result;
      }

      if (result['user'] is! UserModel) {
        return {
          'success': false,
          'message': 'Unable to create user. Please try again.',
          'user': null,
        };
      }

      final user = (result['user'] as UserModel).copyWith(
        isActive: isActive,
        syncStatus: isActive ? 'synced' : 'pending',
        updatedAt: DateTime.now(),
      );

      await _db.updateUser(user);
      return {
        'success': true,
        'message': isActive
            ? 'User created and approved'
            : 'User created and marked pending approval',
        'user': user,
      };
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('unique') && message.contains('users.email')) {
        return {
          'success': false,
          'message': 'An account with this email already exists',
          'user': null,
        };
      }

      return {
        'success': false,
        'message': 'Create user error: $e',
        'user': null,
      };
    }
  }

  Future<Map<String, dynamic>> approveUser(String userId) async {
    try {
      await _ensureInitialized();
      final user = await _db.getUser(userId);
      if (user == null) {
        return {'success': false, 'message': 'User not found', 'user': null};
      }

      final approvedUser = user.copyWith(
        isActive: true,
        syncStatus: 'synced',
        updatedAt: DateTime.now(),
      );
      await _db.updateUser(approvedUser);
      return {
        'success': true,
        'message': 'User approved successfully',
        'user': approvedUser,
      };
    } catch (e) {
      return {'success': false, 'message': 'Approval error: $e', 'user': null};
    }
  }

  Future<Map<String, dynamic>> rejectUser(String userId) async {
    try {
      await _ensureInitialized();
      final removed = await _db.deleteUser(userId);
      return {
        'success': removed > 0,
        'message': removed > 0 ? 'User rejected and removed' : 'User not found',
        'user': null,
      };
    } catch (e) {
      return {'success': false, 'message': 'Rejection error: $e', 'user': null};
    }
  }

  Future<List<UserModel>> getPendingUsers() async {
    await _ensureInitialized();
    final users = await _db.getAllUsers();
    return users
        .where((user) => !user.isActive && user.role != AppConstants.roleAdmin)
        .toList();
  }
}
