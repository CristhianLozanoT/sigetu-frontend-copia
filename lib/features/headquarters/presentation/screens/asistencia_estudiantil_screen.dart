import 'package:flutter/material.dart';
import 'package:sigetu/features/headquarters/presentation/screens/agendar_cita_screen.dart';
import '../widgets/sede_option_card.dart';

class AsistenciaEstudiantilScreen extends StatelessWidget {
  const AsistenciaEstudiantilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opciones = [
      {
        "title": "Académico",
        "subtitle":
            "Trabajos de grado, docentes y salones, preparatorios, judicaturas, Saber Pro y homologaciones.",
        "icon": Icons.school_outlined,
      },
      {
        "title": "Administrativo / Legal",
        "subtitle":
            "Cancelaciones y derechos de petición para solicitudes formales y procesos institucionales.",
        "icon": Icons.gavel_outlined,
      },
      {
        "title": "Financiero",
        "subtitle":
            "Cursos, extensión, dirigidos y temas financieros con soporte y orientación.",
        "icon": Icons.attach_money_outlined,
      },
      {
        "title": "Otros",
        "subtitle":
            "Asesoría personalizada para consultas y servicios adicionales.",
        "icon": Icons.miscellaneous_services_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia Estudiantil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: opciones.length,
          itemBuilder: (context, index) {
            final opcion = opciones[index];

            return SedeOptionCard(
              title: opcion["title"] as String,
              subtitle: opcion["subtitle"] as String,
              icon: opcion["icon"] as IconData,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgendarCitaScreen(
                      categoria: opcion["title"] as String,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
