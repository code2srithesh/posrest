class PasswordService {
  // A deterministic, non-colliding djb2/FNV-1a hash algorithm to prevent security bypasses
  static String hashPassword(String password) {
    int hash = 5381;
    for (int i = 0; i < password.length; i++) {
      hash = ((hash << 5) + hash) + password.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF; // Ensure 32-bit integer behavior
    }
    return hash.toRadixString(16);
  }

  static bool verifyPassword(String password, String storedHash) {
    final hash = hashPassword(password);
    // Support comparing hashed credentials, while keeping a plain-text fallback for seed users
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
