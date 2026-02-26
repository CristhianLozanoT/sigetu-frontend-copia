import 'package:flutter/material.dart';
import 'package:sigetu/core/widgets/section_header.dart';
import 'package:sigetu/features/headquarters/presentation/screens/asistencia_estudiantil_screen.dart';
import 'package:sigetu/features/student_dashboard/presentation/widgets/dashboard_card.dart';

class SeleccionarSedeScreen extends StatelessWidget {
  const SeleccionarSedeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar sede')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SectionHeader(
              title: 'Selecciona la sede',
              subtitle: 'Elige la ubicación donde deseas solicitar tu turno',
            ),
            const SizedBox(height: 24),

            DashboardCard(
              title: 'Asistencia Estudiantil',
              subtitle: 'Orientación y apoyo académico',
              imagePath: 'assets/images/asistencia_estudiantil.png',
              icon: Icons.support_agent_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AsistenciaEstudiantilScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            DashboardCard(
              title: 'Sede Administrativa',
              subtitle: 'Trámites y documentación',
              imagePath: 'assets/images/asistencia_estudiantil.png',
              icon: Icons.apartment_outlined,
              onTap: () {
                _irASiguiente(context, 'Sede Administrativa');
              },
            ),

            const SizedBox(height: 16),

            DashboardCard(
              title: 'Admisiones',
              subtitle: 'Procesos de inscripción y matrícula',
              imagePath: 'assets/images/asistencia_estudiantil.png',
              icon: Icons.how_to_reg_outlined,
              onTap: () {
                _irASiguiente(context, 'Admisiones');
              },
            ),

            const SizedBox(height: 16),

            DashboardCard(
              title: 'Mercadeo',
              subtitle: 'Información institucional y eventos',
              icon: Icons.campaign_outlined,
              onTap: () {
                _irASiguiente(context, 'Mercadeo');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _irASiguiente(BuildContext context, String sede) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(sede)),
          body: Center(
            child: Text(
              'Pantalla de $sede',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
