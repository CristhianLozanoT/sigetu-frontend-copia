import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sigetu/core/realtime/appointments_realtime_service.dart';
import 'package:sigetu/core/utils/responsive.dart';
import 'package:sigetu/core/utils/app_date_formatter.dart';
import 'package:sigetu/core/widgets/app_toast.dart';
import 'package:sigetu/features/headquarters/data/appointment_api.dart';
import 'package:sigetu/features/headquarters/domain/appointment_contexts.dart';
import 'package:sigetu/features/headquarters/domain/appointment_request.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_calendar_panel.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_category_context_card.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_confirmation_dialog.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_time_slots_panel.dart';
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
  final _realtime = AppointmentsRealtimeService();
  StreamSubscription<void>? _realtimeSubscription;
  static const int _slotIntervalMinutes = 15;
  static const int _startMinutes = 8 * 60;
  static const int _endMinutes = 18 * 60;
  static const int _breakStartMinutes = 12 * 60;
  static const int _breakEndMinutes = 13 * 60;

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  String? _contextoSeleccionado;
  bool _isSubmitting = false;
  bool _isLoadingSlots = false;
  List<TimeOfDay> _horariosOcupados = [];
  int _currentStep = 1;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _realtime.connect();
    _realtimeSubscription = _realtime.updates.listen((_) {
      final fecha = _fechaSeleccionada;
      if (!mounted || fecha == null) return;
      _fetchOccupiedSlots(fecha);
    });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    unawaited(_realtime.dispose());
    super.dispose();
  }

  List<String> get _contextosDisponibles =>
      AppointmentContexts.forCategory(widget.categoria);

  bool _isDateSelectable(DateTime date) {
    final today = DateTime.now();
    final min = DateTime(today.year, today.month, today.day);
    final max = DateTime(today.year + 2, today.month, today.day);
    return !date.isBefore(min) && !date.isAfter(max);
  }

  void _changeMonth(int offset) {
    final candidate = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + offset,
    );
    final now = DateTime.now();
    final minMonth = DateTime(now.year, now.month);
    final maxMonth = DateTime(now.year + 2, now.month);

    if (candidate.isBefore(minMonth) || candidate.isAfter(maxMonth)) {
      return;
    }

    setState(() => _displayedMonth = candidate);
  }

  void _selectDay(DateTime date) {
    if (!_isDateSelectable(date) || _isSubmitting) return;
    debugPrint('[AgendarCita] _selectDay: $date');
    setState(() {
      _fechaSeleccionada = date;
      _horaSeleccionada = null;
      _horariosOcupados = [];
    });
    _fetchOccupiedSlots(date);
  }

  Future<void> _fetchOccupiedSlots(DateTime date) async {
    setState(() => _isLoadingSlots = true);
    try {
      final ocupados = await _appointmentApi.fetchOccupiedSlots(date);
      if (!mounted) return;
      setState(() => _horariosOcupados = ocupados);
    } catch (e, st) {
      debugPrint('[AgendarCita] fetchOccupiedSlots error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() => _horariosOcupados = []);
    } finally {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  List<TimeOfDay> _buildTimeSlots() {
    final slots = <TimeOfDay>[];
    final colombiaNow = DateTime.now().toUtc().subtract(
      const Duration(hours: 5),
    );
    final fecha = _fechaSeleccionada;
    final isToday =
        fecha != null &&
        fecha.year == colombiaNow.year &&
        fecha.month == colombiaNow.month &&
        fecha.day == colombiaNow.day;
    final nowMinutes = colombiaNow.hour * 60 + colombiaNow.minute;

    for (
      int minutes = _startMinutes;
      minutes + _slotIntervalMinutes <= _endMinutes;
      minutes += _slotIntervalMinutes
    ) {
      if (isToday && minutes < nowMinutes) continue;

      final slotStart = minutes;
      final slotEnd = minutes + _slotIntervalMinutes;
      final overlapsBreak =
          slotStart < _breakEndMinutes && slotEnd > _breakStartMinutes;

      if (overlapsBreak) continue;

      slots.add(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));
    }

    return slots;
  }

  bool _isSlotEnabled(TimeOfDay slot) {
    if (_isSubmitting || _fechaSeleccionada == null || _isLoadingSlots)
      return false;
    return !_horariosOcupados.any(
      (occupied) =>
          occupied.hour == slot.hour && occupied.minute == slot.minute,
    );
  }

  void _selectSlot(TimeOfDay slot) {
    if (!_isSlotEnabled(slot)) return;
    setState(() => _horaSeleccionada = slot);
  }

  DateTime _buildScheduledAt(DateTime fecha, TimeOfDay hora) {
    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
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

  void _goToDateTimeStep() {
    if (_isSubmitting) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_contextoSeleccionado == null ||
        _contextoSeleccionado!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un contexto para continuar')),
      );
      return;
    }

    setState(() => _currentStep = 2);
  }

  void _goBackToContextStep() {
    if (_isSubmitting) return;
    setState(() => _currentStep = 1);
  }

  bool _validateAppointmentSelection() {
    final formValido = _formKey.currentState?.validate() ?? false;
    if (!formValido) return false;

    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora para continuar')),
      );
      return false;
    }

    if (_contextoSeleccionado == null ||
        _contextoSeleccionado!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un contexto para continuar')),
      );
      return false;
    }

    return true;
  }

  Future<void> _confirmarYAgendar() async {
    if (_isSubmitting) return;

    if (!_validateAppointmentSelection()) return;

    final fechaSeleccionada = _fechaSeleccionada!;
    final horaSeleccionada = _horaSeleccionada!;
    final contextoSeleccionado = _contextoSeleccionado!;

    final shouldSchedule = await AppointmentConfirmationDialog.show(
      context: context,
      area: widget.categoria,
      attentionType: contextoSeleccionado,
      formattedDate: AppDateFormatter.dateLongEs(fechaSeleccionada),
      formattedTime: AppDateFormatter.time12(horaSeleccionada),
    );

    if (!shouldSchedule || !mounted) return;

    await _agendarCita();
  }

  Future<void> _agendarCita() async {
    if (_isSubmitting) return;

    if (!_validateAppointmentSelection()) return;

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
      final successMessage = await _appointmentApi.createAppointment(request);

      if (!mounted) return;

      await AppToast.showSuccess(
        context,
        message: successMessage ?? 'La cita se agendó correctamente.',
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
      await AppToast.showError(context, message: message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateMissing = _fechaSeleccionada == null;
    final selectedTimeMissing = _horaSeleccionada == null;
    final isContextStep = _currentStep == 1;
    final isDateTimeStep = _currentStep == 2;

    final hPad = Responsive.horizontalPadding(context);
    final isWide = !Responsive.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isContextStep ? 'Agendar Cita - Paso 1' : 'Agendar Cita - Paso 2',
        ),
        leading: isDateTimeStep
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToContextStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
                children: [
                  if (isContextStep) ...[
                    Text(
                      'Tipo de atención',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selecciona el motivo de tu visita.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    AppointmentCategoryContextCard(
                      selectedContext: _contextoSeleccionado,
                      contextOptions: _contextosDisponibles,
                      onContextChanged: (value) =>
                          setState(() => _contextoSeleccionado = value),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _goToDateTimeStep,
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],

                  if (isDateTimeStep) ...[
                    Text(
                      'Fecha y horario',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige el día y hora de tu turno',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppointmentCalendarPanel(
                              displayedMonth: _displayedMonth,
                              selectedDate: _fechaSeleccionada,
                              onMonthChange: _changeMonth,
                              onDateSelected: _selectDay,
                              isDateSelectable: _isDateSelectable,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppointmentTimeSlotsPanel(
                                  timeSlots: _buildTimeSlots(),
                                  selectedTime: _horaSeleccionada,
                                  isSlotEnabled: _isSlotEnabled,
                                  isSlotOccupied: (slot) =>
                                      _horariosOcupados.any(
                                        (o) =>
                                            o.hour == slot.hour &&
                                            o.minute == slot.minute,
                                      ),
                                  onSelectSlot: _selectSlot,
                                  formatSlot: AppDateFormatter.time12,
                                ),
                                if (_isLoadingSlots) ...[
                                  const SizedBox(height: 10),
                                  const LinearProgressIndicator(),
                                ],
                                if (!_isLoadingSlots &&
                                    (selectedDateMissing ||
                                        selectedTimeMissing)) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    selectedDateMissing
                                        ? 'Selecciona una fecha para habilitar horarios.'
                                        : 'Selecciona un horario para continuar.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      AppointmentCalendarPanel(
                        displayedMonth: _displayedMonth,
                        selectedDate: _fechaSeleccionada,
                        onMonthChange: _changeMonth,
                        onDateSelected: _selectDay,
                        isDateSelectable: _isDateSelectable,
                      ),
                      const SizedBox(height: 12),
                      AppointmentTimeSlotsPanel(
                        timeSlots: _buildTimeSlots(),
                        selectedTime: _horaSeleccionada,
                        isSlotEnabled: _isSlotEnabled,
                        isSlotOccupied: (slot) => _horariosOcupados.any(
                          (o) => o.hour == slot.hour && o.minute == slot.minute,
                        ),
                        onSelectSlot: _selectSlot,
                        formatSlot: AppDateFormatter.time12,
                      ),
                      if (_isLoadingSlots) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(),
                      ],
                      if (!_isLoadingSlots &&
                          (selectedDateMissing || selectedTimeMissing)) ...[
                        const SizedBox(height: 10),
                        Text(
                          selectedDateMissing
                              ? 'Selecciona una fecha para habilitar horarios.'
                              : 'Selecciona un horario para continuar.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : _goBackToContextStep,
                            child: const Text('Atrás'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : _confirmarYAgendar,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Revisar'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
