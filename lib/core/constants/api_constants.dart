import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb
        ? 'http://localhost:8000'
        : 'http://192.168.1.4:8000',
  );

  static const String appointmentsWsUrlOverride = String.fromEnvironment(
    'APPOINTMENTS_WS_URL',
    defaultValue: '',
  );

  static const int backendTimezoneOffsetMinutes = int.fromEnvironment(
    'BACKEND_TIMEZONE_OFFSET_MINUTES',
    defaultValue: -300,
  );

  static String get appointmentsWsUrl {
    if (appointmentsWsUrlOverride.isNotEmpty) {
      return appointmentsWsUrlOverride;
    }

    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';

    return uri.replace(scheme: scheme, path: '/appointments/ws').toString();
  }
}