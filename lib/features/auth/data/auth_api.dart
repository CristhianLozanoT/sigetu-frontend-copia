import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigetu/core/constants/api_constants.dart';
import 'package:sigetu/features/auth/domain/user_register.dart';

class AuthApi {
  AuthApi({String? baseUrl}) : baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final String baseUrl;

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        if (body['detail'] is List) {
          final errors = (body['detail'] as List)
              .map((e) => e['msg'])
              .join('\n');
          return errors;
        }

        if (body['detail'] != null) {
          return body['detail'].toString();
        }

        if (body['message'] != null) {
          return body['message'].toString();
        }
      }
    } catch (_) {}

    return 'Error desconocido';
  }

  Future<void> register(UserRegister user) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Registro exitoso
      return;
    } else if (response.statusCode == 400 || response.statusCode == 422) {
      throw Exception(_extractErrorMessage(response));
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<String> login({required String email, required String password}) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final token =
              body['access_token'] ?? body['token'] ?? body['jwt'] ?? body['accessToken'];
          if (token is String && token.isNotEmpty) {
            return token;
          }
        }
      } catch (_) {}

      throw Exception('No se recibió token en el login');
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 422) {
      throw Exception(_extractErrorMessage(response));
    }

    throw Exception('Error del servidor: ${response.statusCode}');
  }
}
