import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sigetu/core/auth/auth_http.dart';
import 'package:sigetu/core/constants/api_constants.dart';
import 'package:sigetu/features/secretary/domain/secretary_appointment.dart';

/// API para obtener el historial de citas de Admisiones y Mercadeo.
/// Usa el mismo endpoint que Secretaría pero con filtro por sede.
class AdmisionesMercadeoAppointmentsApi {
  AdmisionesMercadeoAppointmentsApi({String? baseUrl, this.sede})
    : baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final String baseUrl;
  final String? sede;

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

  /// Obtiene el historial de citas de Admisiones y Mercadeo.
  /// El backend filtra por la sede especificada en el query parameter.
  /// Endpoint: GET /appointments/my-history?sede=sede_admisiones_mercadeo
  Future<List<SecretaryAppointment>> fetchHistory() async {
    final trimmedSede = sede?.trim();

    final queryParameters = {
      if (trimmedSede != null && trimmedSede.isNotEmpty) 'sede': trimmedSede,
    };

    final url = Uri.parse('$baseUrl/appointments/my-history').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await AuthHttp.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(SecretaryAppointment.fromJson)
            .toList();
      }

      if (decoded is Map<String, dynamic> && decoded['items'] is List) {
        return (decoded['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(SecretaryAppointment.fromJson)
            .toList();
      }

      return [];
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 404 ||
        response.statusCode == 422) {
      throw Exception(_extractErrorMessage(response));
    }

    throw Exception('Error del servidor: ${response.statusCode}');
  }
}
