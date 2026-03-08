import 'package:flutter/foundation.dart';

class AuthSession {
  static String? accessToken;
  static String? refreshToken;

  /// true cuando el usuario entró en modo invitado (sin cuenta)
  static bool isGuest = false;

  /// device_id persistente del dispositivo, usado en modo invitado
  static String? deviceId;

  static final ValueNotifier<int> sessionInvalidation = ValueNotifier<int>(0);

  static bool get hasToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  static bool get hasRefreshToken =>
      refreshToken != null && refreshToken!.trim().isNotEmpty;

  static void setTokens({
    required String access,
    String? refresh,
    bool guest = false,
    String? guestDeviceId,
  }) {
    accessToken = access;
    refreshToken = refresh;
    isGuest = guest;
    deviceId = guestDeviceId;
  }

  static void clear({bool notify = false}) {
    accessToken = null;
    refreshToken = null;
    isGuest = false;
    deviceId = null;
    if (notify) {
      sessionInvalidation.value = sessionInvalidation.value + 1;
    }
  }

  static void expireSession() {
    clear(notify: true);
  }
}
