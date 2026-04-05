import 'package:sigetu/core/utils/backend_datetime.dart';

class AppointmentRequest {
  AppointmentRequest({
    required this.category,
    required this.context,
    required this.scheduledAt,
  });

  final String category;
  final String context;
  final DateTime scheduledAt;

  String _toColombiaIso(DateTime dt) {
    // Formatea el datetime con offset Colombia -05:00 explícito
    final s = dt.toIso8601String().split('.').first;
    return '${s}-05:00';
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'context': context,
    'scheduled_at': _toColombiaIso(scheduledAt),
  };
}
