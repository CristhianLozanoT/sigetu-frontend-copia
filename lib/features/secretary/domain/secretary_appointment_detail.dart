import 'package:sigetu/core/utils/backend_datetime.dart';

class SecretaryAppointmentDetail {
  SecretaryAppointmentDetail({
    required this.id,
    required this.studentId,
    required this.turnNumber,
    required this.sede,
    required this.category,
    required this.context,
    required this.status,
    required this.createdAt,
    required this.scheduledAt,
    required this.student,
    this.attentionStartedAt,
    this.isGuest = false,
    this.deviceId,
  });

  final int id;
  final int studentId;
  final String turnNumber;
  final String sede;
  final String category;
  final String context;
  final String status;
  final DateTime createdAt;
  final DateTime scheduledAt;
  final DateTime? attentionStartedAt;
  final SecretaryStudentDetail student;
  final bool isGuest;
  final String? deviceId;

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    return BackendDateTime.parse(value);
  }

  factory SecretaryAppointmentDetail.fromJson(Map<String, dynamic> json) {
    return SecretaryAppointmentDetail(
      id: _parseInt(json['id']),
      studentId: _parseInt(json['student_id']),
      turnNumber: (json['turn_number'] ?? '').toString(),
      sede: (json['sede'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      context: (json['context'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: _parseDate(json['created_at']),
      scheduledAt: _parseDate(json['scheduled_at']),
      attentionStartedAt: json['attention_started_at'] != null
          ? _parseDate(json['attention_started_at'])
          : null,
      student: SecretaryStudentDetail.fromJson(
        (json['student'] as Map<String, dynamic>? ?? const {}),
      ),
      isGuest: json['is_guest'] == true || json['is_guest'] == 'true',
      deviceId: json['device_id']?.toString(),
    );
  }
}

class SecretaryStudentDetail {
  SecretaryStudentDetail({
    required this.id,
    required this.fullName,
    required this.email,
    required this.academicProgram,
  });

  final int id;
  final String fullName;
  final String email;
  final String academicProgram;

  factory SecretaryStudentDetail.fromJson(Map<String, dynamic> json) {
    return SecretaryStudentDetail(
      id: json['id'] as int? ?? 0,
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      academicProgram: (json['programa_academico'] ?? '').toString(),
    );
  }
}
