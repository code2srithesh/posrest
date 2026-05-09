class PasswordService {
  // Simple password hashing (in production, use proper bcrypt library)
  static String hashPassword(String password) {
    // For now, use a simple hash - in production use bcrypt
    // This is just a basic implementation
    return password.toString().replaceAll(RegExp(r'.'), '*');
  }

  static bool verifyPassword(String password, String storedHash) {
    // For now, compare directly - in production use bcrypt
    // This is just a basic implementation
    final hash = hashPassword(password);
    // Store plain password for simplicity in this demo
    // In production, never store plain passwords
    return password == storedHash || hash == storedHash;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // At least 6 characters
    return password.length >= 6;
  }
}
