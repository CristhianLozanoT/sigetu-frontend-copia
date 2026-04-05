import 'package:flutter/material.dart';
import 'package:sigetu/features/secretary/data/secretary_appointments_api.dart';
import 'package:sigetu/features/shared/presentation/widgets/appointment_history_view.dart';

class SecretaryHistoryScreen extends StatelessWidget {
  const SecretaryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = SecretaryAppointmentsApi();

    return AppointmentHistoryView(
      title: 'Secretaría - Citas',
      fetchHistory: api.fetchHistory,
      emptyMessage: 'No hay citas de secretaría en el historial',
    );
  }
}
