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

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    final raw = value.toString();
    return DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory SecretaryAppointment.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDate(json['created_at']);
    final scheduledAt = _parseDate(json['scheduled_at']);

    return SecretaryAppointment(
      id: _parseInt(json['id']),
      studentName: (json['student_name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      context: (json['context'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      turnNumber: (json['turn_number'] ?? '').toString(),
      createdAt: createdAt,
      scheduledAt: scheduledAt,
    );
  }
}
