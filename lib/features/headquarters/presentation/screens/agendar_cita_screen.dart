import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sigetu/features/headquarters/data/appointment_api.dart';
import 'package:sigetu/features/headquarters/domain/appointment_contexts.dart';
import 'package:sigetu/features/headquarters/domain/appointment_request.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_category_header.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_context_select.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_picker_button.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_time_slot_picker.dart';
import 'package:sigetu/features/student_dashboard/presentation/student_dashboard_routes.dart';

class AgendarCitaScreen extends StatefulWidget {
  const AgendarCitaScreen({super.key, required this.categoria});

  final String categoria;

  @override
  State<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends State<AgendarCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentApi = AppointmentApi();

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  String? _contextoSeleccionado;
  bool _isSubmitting = false;

  List<String> get _contextosDisponibles =>
      AppointmentContexts.forCategory(widget.categoria);

  Future<void> _seleccionarFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: _fechaSeleccionada ?? now,
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Seleccionar fecha';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  DateTime _buildScheduledAt(DateTime fecha, TimeOfDay hora) {
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );
  }

  String _normalizeForApi(String value) {
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ñ': 'n',
      'Ñ': 'N',
    };

    var normalized = value;
    replacements.forEach((key, replacement) {
      normalized = normalized.replaceAll(key, replacement);
    });

    return normalized.trim().toLowerCase();
  }

  Future<void> _agendarCita() async {
    if (_isSubmitting) return;

    final formValido = _formKey.currentState?.validate() ?? false;

    if (!formValido) return;

    final fechaSeleccionada = _fechaSeleccionada;
    final horaSeleccionada = _horaSeleccionada;
    final contextoSeleccionado = _contextoSeleccionado;

    if (fechaSeleccionada == null || horaSeleccionada == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora para continuar')),
      );
      return;
    }

    if (contextoSeleccionado == null || contextoSeleccionado.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un contexto para continuar')),
      );
      return;
    }

    final request = AppointmentRequest(
      category: _normalizeForApi(widget.categoria),
      context: _normalizeForApi(contextoSeleccionado),
      scheduledAt: _buildScheduledAt(fechaSeleccionada, horaSeleccionada),
    );

    final payload = request.toJson();
    debugPrint('Payload agendar cita: ${jsonEncode(payload)}');

    setState(() => _isSubmitting = true);

    try {
      await _appointmentApi.createAppointment(request);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cita agendada'),
          content: Text(
            'Tu cita para ${widget.categoria} ($contextoSeleccionado) fue registrada para el ${_formatearFecha(fechaSeleccionada)} en el horario ${AppointmentTimeSlotPicker.formatRange(horaSeleccionada)}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        StudentDashboardRoutes.dashboard,
        (route) => false,
        arguments: {'initialIndex': 1},
      );
    } catch (error, stackTrace) {
      debugPrint('Error al agendar cita: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Cita')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [

                const SizedBox(height: 16),
                AppointmentCategoryHeader(category: widget.categoria),
                const SizedBox(height: 14),
                AppointmentContextSelect(
                  value: _contextoSeleccionado,
                  options: _contextosDisponibles,
                  onChanged: (value) => setState(() => _contextoSeleccionado = value),
                ),
                const SizedBox(height: 8),
                AppointmentPickerButton(
                  onPressed: _isSubmitting ? null : _seleccionarFecha,
                  icon: Icons.calendar_today_outlined,
                  label: _formatearFecha(_fechaSeleccionada),
                ),
                const SizedBox(height: 10),
                AppointmentTimeSlotPicker(
                  selectedTime: _horaSeleccionada,
                  enabled: !_isSubmitting,
                  onChanged: (hora) => setState(() => _horaSeleccionada = hora),
                ),
                const SizedBox(height: 24),

                const SizedBox(height: 18),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _agendarCita,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Agendar cita'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
