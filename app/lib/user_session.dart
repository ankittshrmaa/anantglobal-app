// Simple global session — holds logged in user data
class UserSession {
  static String? name;
  static String? mobile;
  static bool get isLoggedIn => name != null;

  static void login(String userName, String userMobile) {
    name   = userName;
    mobile = userMobile;
  }

  static void logout() {
    name   = null;
    mobile = null;
  }
}