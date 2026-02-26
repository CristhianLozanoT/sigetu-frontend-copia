class AuthSession {
  static String? accessToken;

  static bool get hasToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  static void clear() {
    accessToken = null;
  }
}
