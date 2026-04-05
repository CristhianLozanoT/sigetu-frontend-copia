import 'package:flutter/material.dart';
import 'package:sigetu/features/admisiones_mercadeo/data/admisiones_mercadeo_appointments_api.dart';
import 'package:sigetu/features/headquarters/domain/appointment_contexts.dart';
import 'package:sigetu/features/shared/presentation/widgets/appointment_history_view.dart';

class AdmisionesMercadeoHistoryScreen extends StatelessWidget {
  const AdmisionesMercadeoHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = AdmisionesMercadeoAppointmentsApi(
      sede: AppointmentContexts.sedeAdmisionesMercadeo,
    );

    return AppointmentHistoryView(
      title: 'Admisiones y Mercadeo - Historial',
      fetchHistory: api.fetchHistory,
      emptyMessage: 'No hay citas de admisiones y mercadeo en el historial',
      autoRefreshSeconds: null, // Desactiva auto-refresco
    );
  }
}
