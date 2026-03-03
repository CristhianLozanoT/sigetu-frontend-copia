import 'package:flutter/foundation.dart';

class AuthSession {
  static String? accessToken;
  static String? refreshToken;
  static final ValueNotifier<int> sessionInvalidation = ValueNotifier<int>(0);

  static bool get hasToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  static bool get hasRefreshToken =>
      refreshToken != null && refreshToken!.trim().isNotEmpty;

  static void setTokens({
    required String access,
    String? refresh,
  }) {
    accessToken = access;
    refreshToken = refresh;
  }

  static void clear({bool notify = false}) {
    accessToken = null;
    refreshToken = null;
    if (notify) {
      sessionInvalidation.value = sessionInvalidation.value + 1;
    }
  }

  static void expireSession() {
    clear(notify: true);
  }
}
