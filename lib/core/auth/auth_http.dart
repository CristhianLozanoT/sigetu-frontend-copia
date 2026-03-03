import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:sigetu/core/auth/auth_session.dart';
import 'package:sigetu/features/auth/data/auth_api.dart';

typedef _AuthorizedRequest = Future<http.Response> Function(String accessToken);

class AuthHttp {
  static Future<bool>? _refreshInFlight;

  static Map<String, String> authorizedJsonHeaders({String? accessToken}) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${accessToken ?? AuthSession.accessToken}',
    };
  }

  static Future<http.Response> get(Uri url) {
    return _sendWithAutoRefresh(
      (token) => http.get(
        url,
        headers: authorizedJsonHeaders(accessToken: token),
      ),
    );
  }

  static Future<http.Response> post(Uri url, {Object? body}) {
    return _sendWithAutoRefresh(
      (token) => http.post(
        url,
        headers: authorizedJsonHeaders(accessToken: token),
        body: body,
      ),
    );
  }

  static Future<http.Response> patch(Uri url, {Object? body}) {
    return _sendWithAutoRefresh(
      (token) => http.patch(
        url,
        headers: authorizedJsonHeaders(accessToken: token),
        body: body,
      ),
    );
  }

  static Future<http.Response> _sendWithAutoRefresh(
    _AuthorizedRequest request,
  ) async {
    if (!AuthSession.hasToken) {
      throw Exception('No autenticado: se requiere token');
    }

    final firstToken = AuthSession.accessToken!;
    var response = await request(firstToken);

    if (response.statusCode != 401) {
      return response;
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed || !AuthSession.hasToken) {
      return response;
    }

    response = await request(AuthSession.accessToken!);
    return response;
  }

  static Future<bool> _refreshAccessToken() async {
    if (!AuthSession.hasRefreshToken) {
      AuthSession.expireSession();
      return false;
    }

    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final completer = Completer<bool>();
    _refreshInFlight = completer.future;

    try {
      final refreshToken = AuthSession.refreshToken!;
      final refreshResponse = await AuthApi().refresh(refreshToken: refreshToken);

      AuthSession.setTokens(
        access: refreshResponse.accessToken,
        refresh: refreshResponse.refreshToken ?? refreshToken,
      );

      completer.complete(true);
      return true;
    } catch (_) {
      AuthSession.expireSession();
      completer.complete(false);
      return false;
    } finally {
      _refreshInFlight = null;
    }
  }
}
