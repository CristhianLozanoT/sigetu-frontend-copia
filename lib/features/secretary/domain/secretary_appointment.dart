class SecretaryAppointment {
  SecretaryAppointment({
    required this.id,
    required this.studentName,
    required this.category,
    required this.context,
    required this.status,
    required this.turnNumber,
    required this.createdAt,
    required this.scheduledAt,
  });

  final int id;
  final String studentName;
  final String category;
  final String context;
  final String status;
  final String turnNumber;
  final DateTime createdAt;
  final DateTime scheduledAt;

  factory SecretaryAppointment.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String).toLocal();
    final scheduledAtRaw = json['scheduled_at']?.toString();

    return SecretaryAppointment(
      id: json['id'] as int,
      studentName: (json['student_name'] ?? '').toString(),
      category: json['category'] as String,
      context: json['context'] as String,
      status: json['status'] as String,
      turnNumber: json['turn_number'] as String,
      createdAt: createdAt,
      scheduledAt: DateTime.parse(scheduledAtRaw as String).toLocal(),
    );
  }
}
