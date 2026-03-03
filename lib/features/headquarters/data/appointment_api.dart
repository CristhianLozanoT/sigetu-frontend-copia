import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sigetu/core/auth/auth_http.dart';
import 'package:sigetu/core/constants/api_constants.dart';
import 'package:sigetu/features/headquarters/domain/appointment_request.dart';

class AppointmentApi {
  AppointmentApi({
    String? baseUrl,
    this.endpointPath = '/appointments',
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final String baseUrl;
  final String endpointPath;

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        if (body['detail'] is List) {
          return (body['detail'] as List).map((e) => e['msg']).join('\n');
        }
        if (body['detail'] != null) return body['detail'].toString();
        if (body['message'] != null) return body['message'].toString();
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

  Future<String?> createAppointment(AppointmentRequest request) async {
    final url = Uri.parse('$baseUrl$endpointPath');

    final response = await AuthHttp.post(
      url,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _extractSuccessMessage(response);
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 404 ||
        response.statusCode == 409 ||
        response.statusCode == 422) {
      throw Exception(_extractErrorMessage(response));
    }

    throw Exception('Error del servidor: ${response.statusCode}');
  }
}
