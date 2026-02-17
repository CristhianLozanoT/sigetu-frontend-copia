import 'package:flutter/material.dart';
import 'package:sigetu/features/student_dashboard/presentation/widgets/dashboard_card.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Estudiante')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DashboardCard(
              title: 'Solicitar Turno',
              subtitle: 'Agenda una nueva cita',
              icon: Icons.add_circle_outline,
              // cardColor: Colors.blue.shade50,
              // iconColor: Colors.blue,
              // textColor: Colors.blue.shade900,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            DashboardCard(
              title: 'Mis Turnos',
              subtitle: 'Consulta tus turnos asignados',
              icon: Icons.calendar_today_outlined,
              onTap: () {},
            ),

            const SizedBox(height: 16),
            DashboardCard(
              title: 'Perfil',
              subtitle: 'Ver información personal',
              icon: Icons.person_outline,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
