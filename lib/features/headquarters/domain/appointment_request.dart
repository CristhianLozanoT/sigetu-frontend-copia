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

  Map<String, dynamic> toJson() => {
        'category': category,
        'context': context,
        'scheduled_at': BackendDateTime.formatForApi(scheduledAt),
      };
}