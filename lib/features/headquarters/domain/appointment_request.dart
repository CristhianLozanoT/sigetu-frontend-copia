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
        'scheduled_at': _formatScheduledAt(scheduledAt),
      };

  static String _formatScheduledAt(DateTime value) {
    return value.toIso8601String().split('.').first;
  }
}