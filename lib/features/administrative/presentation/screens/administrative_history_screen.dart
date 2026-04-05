import 'package:flutter/material.dart';
import 'package:sigetu/features/administrative/data/administrative_appointments_api.dart';
import 'package:sigetu/features/shared/presentation/widgets/appointment_history_view.dart';

class AdministrativeHistoryScreen extends StatelessWidget {
  const AdministrativeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = AdministrativeAppointmentsApi();

    return AppointmentHistoryView(
      title: 'Administrative - Citas',
      fetchHistory: api.fetchHistory,
      emptyMessage: 'No hay citas administrativas en el historial',
    );
  }
}
