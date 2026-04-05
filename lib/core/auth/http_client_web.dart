import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// Cliente HTTP para Web con soporte de cookies (credentials)
http.Client buildWebClient() {
  return BrowserClient()..withCredentials = true;
}
