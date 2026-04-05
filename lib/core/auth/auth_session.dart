import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigetu/core/auth/http_client_stub.dart'
    if (dart.library.html) 'package:sigetu/core/auth/http_client_web.dart';
import 'package:sigetu/core/constants/api_constants.dart';

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

  // Android storage keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyIsGuest = 'is_guest';
  static const String _keyDeviceId = 'device_id';

  // Android secure storage instance
  static final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Web client (envía cookies automáticamente)
  static final http.Client _webClient = buildWebClient();

  /// Restaura la sesión al iniciar la app.
  /// - Web: llama a /auth/refresh (cookie HttpOnly) para validar sesión
  /// - Android: lee de flutter_secure_storage y verifica expiración
  static Future<void> restore() async {
    if (kIsWeb) {
      // Web: el refresh token está en cookie HttpOnly
      // Intentar renovar sesión usando la cookie
      try {
        final response = await _callRefreshWithoutToken();
        accessToken = response;
        refreshToken = null; // Web no guarda refresh token
        isGuest = false;
        deviceId = null;
      } catch (_) {
        // Cookie expirada o inválida → sesión vacía
        await _clearStorage();
      }
    } else {
      // Android: leer de flutter_secure_storage
      final storedAccess = await _secureStorage.read(key: _keyAccessToken);
      final storedRefresh = await _secureStorage.read(key: _keyRefreshToken);
      final prefs = await SharedPreferences.getInstance();
      final storedIsGuest = prefs.getBool(_keyIsGuest) ?? false;
      final storedDeviceId = prefs.getString(_keyDeviceId);

      if (storedAccess != null && storedAccess.isNotEmpty) {
        if (isTokenExpired(storedAccess)) {
          // Token expirado → intentar refresh
          if (storedRefresh != null && storedRefresh.isNotEmpty) {
            try {
              final newAccess = await _refreshAndroidToken(storedRefresh);
              accessToken = newAccess;
              refreshToken = storedRefresh;
              isGuest = storedIsGuest;
              deviceId = storedDeviceId;
              return;
            } catch (_) {
              // Refresh falló → limpiar
              await _clearStorage();
              return;
            }
          }
          await _clearStorage();
          return;
        }

        accessToken = storedAccess;
        refreshToken = storedRefresh;
        isGuest = storedIsGuest;
        deviceId = storedDeviceId;
      }
    }
  }

  /// Llama a /auth/refresh sin body (Web usa cookie HttpOnly)
  static Future<String> _callRefreshWithoutToken() async {
    final response = await _webClient.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = body['access_token'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        return accessToken;
      }
    }
    throw Exception('Refresh fallido');
  }

  /// Refresca token en Android
  static Future<String> _refreshAndroidToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = body['access_token'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        return accessToken;
      }
    }
    throw Exception('Refresh fallido');
  }

  /// Verifica si un token JWT está expirado decodificando el payload.
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = json['exp'];
      if (exp == null) return true;

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expDate);
    } catch (_) {
      return true;
    }
  }

  /// Guarda los tokens.
  /// - Web: solo guarda access_token en memoria (cookie HttpOnly maneja refresh)
  /// - Android: guarda ambos tokens en flutter_secure_storage
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

    if (!kIsWeb) {
      _persistAndroid();
    }
    // Web no persiste nada en disco
  }

  static Future<void> _persistAndroid() async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken ?? '');
    await _secureStorage.write(
      key: _keyRefreshToken,
      value: refreshToken ?? '',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, isGuest);
    await prefs.setString(_keyDeviceId, deviceId ?? '');
  }

  /// Limpia la sesión.
  /// - Web: solo limpia memoria
  /// - Android: limpia flutter_secure_storage y SharedPreferences
  static Future<void> clear({bool notify = false}) async {
    accessToken = null;
    refreshToken = null;
    isGuest = false;
    deviceId = null;

    await _clearStorage();

    if (notify) {
      sessionInvalidation.value = sessionInvalidation.value + 1;
    }
  }

  static Future<void> _clearStorage() async {
    if (kIsWeb) {
      // Web: no hay storage que limpiar (cookies son HttpOnly)
      return;
    }
    // Android: limpiar secure storage y prefs
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    // Eliminar solo las claves de sesión, NO tocar 'sigetu_device_id'
    await prefs.remove(_keyIsGuest);
    await prefs.remove(_keyDeviceId);
  }

  static Future<void> expireSession() async {
    await clear(notify: true);
  }
}
