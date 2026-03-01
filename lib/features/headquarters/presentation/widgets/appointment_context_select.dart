import 'package:flutter/material.dart';

class AppointmentContextSelect extends StatelessWidget {
  const AppointmentContextSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Contexto de la cita',
        hintText: 'Selecciona el contexto',
        prefixIcon: Icon(Icons.topic_outlined),
        border: OutlineInputBorder(),
      ),
      items: options
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selected) {
        if (selected == null || selected.isEmpty) {
          return 'Selecciona una opción';
        }
        return null;
      },
    );
  }
}