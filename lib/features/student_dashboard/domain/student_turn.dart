class StudentTurn {
  StudentTurn({
    required this.id,
    required this.studentId,
    required this.sede,
    required this.category,
    required this.context,
    required this.status,
    required this.turnNumber,
    required this.createdAt,
    required this.scheduledAt,
  });

  final int id;
  final int studentId;
  final String sede;
  final String category;
  final String context;
  final String status;
  final String turnNumber;
  final DateTime createdAt;
  final DateTime scheduledAt;

  factory StudentTurn.fromJson(Map<String, dynamic> json) {
    return StudentTurn(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      sede: json['sede'] as String,
      category: json['category'] as String,
      context: json['context'] as String,
      status: json['status'] as String,
      turnNumber: json['turn_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
    );
  }
}
