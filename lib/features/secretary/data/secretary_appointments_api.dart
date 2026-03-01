import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sigetu/core/auth/auth_session.dart';
import 'package:sigetu/core/constants/appointment_statuses.dart';
import 'package:sigetu/core/constants/api_constants.dart';
import 'package:sigetu/features/secretary/domain/secretary_appointment.dart';
import 'package:sigetu/features/secretary/domain/secretary_appointment_detail.dart';

class SecretaryAppointmentsApi {
  SecretaryAppointmentsApi({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final String baseUrl;

  Map<String, String> _authorizedJsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthSession.accessToken}',
    };
  }

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

  Future<List<SecretaryAppointment>> fetchQueueAppointments() async {
    if (!AuthSession.hasToken) {
      throw Exception('No autenticado: se requiere token');
    }

    final url = Uri.parse('$baseUrl/appointments/queue');

    final response = await http.get(
      url,
      headers: _authorizedJsonHeaders(),
    );

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

  Future<String?> callTurn({required int appointmentId}) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: AppointmentStatuses.calling,
    );
  }

  Future<SecretaryAppointmentDetail> fetchAppointmentDetail({
    required int appointmentId,
  }) async {
    if (!AuthSession.hasToken) {
      throw Exception('No autenticado: se requiere token');
    }

    final url = Uri.parse('$baseUrl/appointments/$appointmentId/detail');

    final response = await http.get(
      url,
      headers: _authorizedJsonHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return SecretaryAppointmentDetail.fromJson(decoded);
      }

      throw Exception('Respuesta inválida del servidor');
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

  Future<String?> updateAppointmentStatus({
    required int appointmentId,
    required String status,
  }) async {
    if (!AuthSession.hasToken) {
      throw Exception('No autenticado: se requiere token');
    }

    final url = Uri.parse('$baseUrl/appointments/$appointmentId/status');

    final response = await http.patch(
      url,
      headers: _authorizedJsonHeaders(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
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
