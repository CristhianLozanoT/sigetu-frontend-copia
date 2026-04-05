import 'package:http/http.dart' as http;

/// Cliente HTTP para plataformas no-web (Android, iOS, desktop, mobile)
http.Client buildWebClient() {
  return http.Client();
}
