import 'package:flutter/material.dart';
import 'package:sigetu/features/headquarters/presentation/screens/agendar_cita_screen.dart';

import '../widgets/sede_option_card.dart';

class AdmisionesMercadeoScreen extends StatelessWidget {
  const AdmisionesMercadeoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opciones = [
      {
        'title': 'Información académica',
        'subtitle':
            'Información para primer semestre y oferta de pregrados/posgrados.',
        'icon': Icons.menu_book_outlined,
      },
      {
        'title': 'Inscripción y matrícula',
        'subtitle':
            'Información de matrícula para estudiantes nuevos de primer semestre.',
        'icon': Icons.assignment_turned_in_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Admisiones y mercadeo')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: opciones.length,
          itemBuilder: (context, index) {
            final opcion = opciones[index];

            return SedeOptionCard(
              title: opcion['title'] as String,
              subtitle: opcion['subtitle'] as String,
              icon: opcion['icon'] as IconData,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgendarCitaScreen(
                      categoria: opcion['title'] as String,
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
