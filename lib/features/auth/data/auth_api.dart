import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigetu/core/auth/auth_http.dart';
import 'package:sigetu/core/constants/api_constants.dart';
import 'package:sigetu/features/auth/domain/user.dart';
import 'package:sigetu/features/auth/domain/user_register.dart';

class AuthLoginResponse {
  const AuthLoginResponse({
    required this.accessToken,
    this.refreshToken,
    this.message,
  });

  final String accessToken;
  final String? refreshToken;
  final String? message;
}

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

  String? _extractSuccessMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final message = body['message'] ?? body['detail'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {}

    return null;
  }

  Future<String?> register(UserRegister user, {String? deviceId}) async {
    final uri = Uri.parse('$baseUrl/auth/register').replace(
      queryParameters: deviceId != null && deviceId.isNotEmpty
          ? {'device_id': deviceId}
          : null,
    );

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _extractSuccessMessage(response);
    } else if (response.statusCode == 400 || response.statusCode == 422) {
      throw Exception(_extractErrorMessage(response));
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<AuthLoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final successMessage = _extractSuccessMessage(response);

      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final accessToken =
              body['access_token'] ??
              body['token'] ??
              body['jwt'] ??
              body['accessToken'];
          final refreshToken = body['refresh_token'] ?? body['refreshToken'];

          if (accessToken is String && accessToken.isNotEmpty) {
            return AuthLoginResponse(
              accessToken: accessToken,
              refreshToken: refreshToken is String && refreshToken.isNotEmpty
                  ? refreshToken
                  : null,
              message: successMessage,
            );
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

  Future<AuthLoginResponse> refresh({required String refreshToken}) async {
    final url = Uri.parse('$baseUrl/auth/refresh');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final successMessage = _extractSuccessMessage(response);

      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final accessToken =
              body['access_token'] ??
              body['token'] ??
              body['jwt'] ??
              body['accessToken'];
          final newRefreshToken = body['refresh_token'] ?? body['refreshToken'];

          if (accessToken is String && accessToken.isNotEmpty) {
            return AuthLoginResponse(
              accessToken: accessToken,
              refreshToken:
                  newRefreshToken is String && newRefreshToken.isNotEmpty
                  ? newRefreshToken
                  : refreshToken,
              message: successMessage,
            );
          }
        }
      } catch (_) {}

      throw Exception('No se recibió access_token al renovar sesión');
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 422) {
      throw Exception(_extractErrorMessage(response));
    }

    throw Exception('Error del servidor: ${response.statusCode}');
  }

  Future<String?> logout({required String refreshToken}) async {
    final url = Uri.parse('$baseUrl/auth/logout');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return _extractSuccessMessage(response);
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 422) {
      throw Exception(_extractErrorMessage(response));
    }

    throw Exception('Error del servidor: ${response.statusCode}');
  }

  Future<User> me() async {
    final url = Uri.parse('$baseUrl/auth/me');
    final response = await AuthHttp.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractErrorMessage(response));
  }

  /// Login en modo invitado. Envía el device_id del dispositivo y recibe
  /// un JWT de corta duración con role="guest".
  Future<AuthLoginResponse> loginGuest({required String deviceId}) async {
    final url = Uri.parse('$baseUrl/auth/guest');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'device_id': deviceId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final accessToken =
              body['access_token'] ??
              body['token'] ??
              body['jwt'] ??
              body['accessToken'];
          if (accessToken is String && accessToken.isNotEmpty) {
            return AuthLoginResponse(accessToken: accessToken);
          }
        }
      } catch (_) {}
      throw Exception('No se recibió token de invitado');
    }

    if (response.statusCode == 400 || response.statusCode == 422) {
      throw Exception(_extractErrorMessage(response));
    }

    throw Exception('Error del servidor: ${response.statusCode}');
  }
}
