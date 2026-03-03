import 'package:sigetu/core/utils/backend_datetime.dart';

class User {
  final int id;
  final String email;
  final String fullName;
  final String? academicProgram;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.academicProgram,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        fullName: json['full_name'],
        academicProgram:
            json['academic_program']?.toString() ?? json['program']?.toString(),
        isActive: json['is_active'],
        createdAt: BackendDateTime.parse(json['created_at']),
      );
}