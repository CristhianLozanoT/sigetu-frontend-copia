import 'package:sigetu/core/utils/backend_datetime.dart';

class StudentTurn {
  StudentTurn({
    required this.id,
    this.studentId,
    this.deviceId,
    required this.sede,
    required this.category,
    required this.context,
    required this.status,
    required this.turnNumber,
    required this.createdAt,
    required this.scheduledAt,
  });

  final int id;
  final int? studentId;
  final String? deviceId;
  final String sede;
  final String category;
  final String context;
  final String status;
  final String turnNumber;
  final DateTime createdAt;
  final DateTime scheduledAt;

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    return BackendDateTime.parse(value);
  }

  factory StudentTurn.fromJson(Map<String, dynamic> json) {
    return StudentTurn(
      id: _parseInt(json['id']),
      studentId: json['student_id'] != null
          ? _parseInt(json['student_id'])
          : null,
      deviceId: json['device_id']?.toString(),
      sede: (json['sede'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      context: (json['context'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      turnNumber: (json['turn_number'] ?? '').toString(),
      createdAt: _parseDate(json['created_at']),
      scheduledAt: _parseDate(json['scheduled_at']),
    );
  }
}
