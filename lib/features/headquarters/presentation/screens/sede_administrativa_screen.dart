import 'package:flutter/material.dart';
import 'package:sigetu/features/headquarters/presentation/screens/agendar_cita_screen.dart';

import '../widgets/sede_option_card.dart';

class SedeAdministrativaScreen extends StatelessWidget {
  const SedeAdministrativaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opciones = [
      {
        'title': 'Pagos y facturación',
        'subtitle':
            'Pagos con tarjeta, validación de pagos, facturación electrónica, cruces de saldos y descuentos.',
        'icon': Icons.receipt_long_outlined,
      },
      {
        'title': 'Recibos y certificados',
        'subtitle':
            'Generación de recibos, certificados de valores pagados y constancias.',
        'icon': Icons.description_outlined,
      },
      {
        'title': 'Créditos y financiación',
        'subtitle':
            'Trámites de crédito, financiación interna/externa y procesos relacionados con ICETEX.',
        'icon': Icons.account_balance_wallet_outlined,
      },
      {
        'title': 'Problemas y soporte financiero',
        'subtitle': 'Atención de problemas con matrículas financieras.',
        'icon': Icons.support_agent_outlined,
      },
      {
        'title': 'Plataformas y servicios',
        'subtitle': 'Habilitación de plataformas y servicios institucionales.',
        'icon': Icons.settings_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Sede Administrativa')),
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
