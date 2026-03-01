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
  final SecretaryStudentDetail student;

  factory SecretaryAppointmentDetail.fromJson(Map<String, dynamic> json) {
    return SecretaryAppointmentDetail(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      turnNumber: (json['turn_number'] ?? '').toString(),
      sede: (json['sede'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      context: (json['context'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String).toLocal(),
      student: SecretaryStudentDetail.fromJson(
        (json['student'] as Map<String, dynamic>? ?? const {}),
      ),
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
