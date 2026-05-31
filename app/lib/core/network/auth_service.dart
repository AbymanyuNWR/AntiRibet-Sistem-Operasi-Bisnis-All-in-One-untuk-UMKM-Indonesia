class AuthService {
  static String? token;
  static String? userRole;
  static Map<String, dynamic>? currentUser;

  /// Callback dipanggil saat server mengembalikan 401 (sesi habis)
  static void Function()? onUnauthorized;

  static void logout() {
    token = null;
    userRole = null;
    currentUser = null;
  }

  static bool get isLoggedIn => token != null;
}
