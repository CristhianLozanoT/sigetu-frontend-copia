import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sigetu/core/utils/app_date_formatter.dart';
import 'package:sigetu/core/utils/responsive.dart';
import 'package:sigetu/core/widgets/app_toast.dart';
import 'package:sigetu/features/headquarters/data/appointment_api.dart';
import 'package:sigetu/features/headquarters/domain/appointment_request.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_calendar_panel.dart';
import 'package:sigetu/features/headquarters/presentation/widgets/appointment_time_slots_panel.dart';
import 'package:sigetu/features/student_dashboard/data/student_turns_api.dart';
import 'package:sigetu/features/student_dashboard/domain/student_turn.dart';

class ReprogramarCitaScreen extends StatefulWidget {
  const ReprogramarCitaScreen({super.key, required this.turn});

  final StudentTurn turn;

  @override
  State<ReprogramarCitaScreen> createState() => _ReprogramarCitaScreenState();
}

class _ReprogramarCitaScreenState extends State<ReprogramarCitaScreen> {
  final _appointmentApi = AppointmentApi();
  final _turnsApi = StudentTurnsApi();

  static const int _slotIntervalMinutes = 15;
  static const int _startMinutes = 8 * 60;
  static const int _endMinutes = 18 * 60;
  static const int _breakStartMinutes = 12 * 60;
  static const int _breakEndMinutes = 13 * 60;

  late DateTime _displayedMonth;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _isLoadingSlots = false;
  bool _isSubmitting = false;
  List<TimeOfDay> _horariosOcupados = [];

  @override
  void initState() {
    super.initState();
    final scheduled = widget.turn.scheduledAt;
    _fechaSeleccionada = DateTime(scheduled.year, scheduled.month, scheduled.day);
    _horaSeleccionada = TimeOfDay.fromDateTime(scheduled);
    _displayedMonth = DateTime(scheduled.year, scheduled.month);
    _fetchOccupiedSlots(_fechaSeleccionada!);
  }

  bool _isDateSelectable(DateTime date) {
    final today = DateTime.now();
    final min = DateTime(today.year, today.month, today.day);
    final max = DateTime(today.year + 2, today.month, today.day);
    return !date.isBefore(min) && !date.isAfter(max);
  }

  void _changeMonth(int offset) {
    final candidate = DateTime(_displayedMonth.year, _displayedMonth.month + offset);
    final now = DateTime.now();
    final minMonth = DateTime(now.year, now.month);
    final maxMonth = DateTime(now.year + 2, now.month);
    if (candidate.isBefore(minMonth) || candidate.isAfter(maxMonth)) return;
    setState(() => _displayedMonth = candidate);
  }

  void _selectDay(DateTime date) {
    if (!_isDateSelectable(date) || _isSubmitting) return;
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
      final ocupados = await _appointmentApi.fetchOccupiedSlots(date, sede: widget.turn.sede);
      if (!mounted) return;
      setState(() => _horariosOcupados = ocupados);
    } catch (_) {
      if (!mounted) return;
      setState(() => _horariosOcupados = []);
    } finally {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  List<TimeOfDay> _buildTimeSlots() {
    final slots = <TimeOfDay>[];
    final colombiaNow = DateTime.now().toUtc().subtract(const Duration(hours: 5));
    final fecha = _fechaSeleccionada;
    final isToday = fecha != null &&
        fecha.year == colombiaNow.year &&
        fecha.month == colombiaNow.month &&
        fecha.day == colombiaNow.day;
    final nowMinutes = colombiaNow.hour * 60 + colombiaNow.minute;

    for (int minutes = _startMinutes; minutes + _slotIntervalMinutes <= _endMinutes; minutes += _slotIntervalMinutes) {
      if (isToday && minutes < nowMinutes) continue;
      final slotStart = minutes;
      final slotEnd = minutes + _slotIntervalMinutes;
      final overlapsBreak = slotStart < _breakEndMinutes && slotEnd > _breakStartMinutes;
      if (overlapsBreak) continue;
      slots.add(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));
    }
    return slots;
  }

  bool _isSlotEnabled(TimeOfDay slot) {
    if (_isSubmitting || _fechaSeleccionada == null || _isLoadingSlots) return false;
    return !_horariosOcupados.any((o) => o.hour == slot.hour && o.minute == slot.minute);
  }

  Future<void> _confirmar() async {
    if (_isSubmitting) return;
    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      AppToast.showError(context, message: 'Selecciona fecha y hora');
      return;
    }

    final scheduledAt = DateTime(
      _fechaSeleccionada!.year, _fechaSeleccionada!.month, _fechaSeleccionada!.day,
      _horaSeleccionada!.hour, _horaSeleccionada!.minute,
    );

    final request = AppointmentRequest(
      category: widget.turn.category,
      context: widget.turn.context,
      scheduledAt: scheduledAt,
    );

    setState(() => _isSubmitting = true);

    try {
      final successMessage = await _turnsApi.updateAppointment(
        appointmentId: widget.turn.id,
        request: request,
      );
      if (!mounted) return;
      await AppToast.showSuccess(context, message: successMessage ?? 'Turno reprogramado correctamente');
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      await AppToast.showError(context, message: error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isWide = !Responsive.isMobile(context);
    final scheme = Theme.of(context).colorScheme;
    final fechaSeleccionada = _fechaSeleccionada;
    final horaSeleccionada = _horaSeleccionada;

    return Scaffold(
      appBar: AppBar(title: const Text('Reprogramar cita')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Turno a reprogramar',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600,
                              )),
                      const SizedBox(height: 4),
                      Text(widget.turn.turnNumber,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        '${AppDateFormatter.dateLongEs(widget.turn.scheduledAt)} · ${AppDateFormatter.time12FromDateTime(widget.turn.scheduledAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Nueva fecha y horario',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Elige el nuevo día y hora de tu turno', style: Theme.of(context).textTheme.bodyMedium),
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
                              isSlotOccupied: (slot) => _horariosOcupados.any((o) => o.hour == slot.hour && o.minute == slot.minute),
                              onSelectSlot: (slot) => setState(() => _horaSeleccionada = slot),
                              formatSlot: AppDateFormatter.time12,
                            ),
                            if (_isLoadingSlots) ...[const SizedBox(height: 10), const LinearProgressIndicator()],
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
                    isSlotOccupied: (slot) => _horariosOcupados.any((o) => o.hour == slot.hour && o.minute == slot.minute),
                    onSelectSlot: (slot) => setState(() => _horaSeleccionada = slot),
                    formatSlot: AppDateFormatter.time12,
                  ),
                  if (_isLoadingSlots) ...[const SizedBox(height: 10), const LinearProgressIndicator()],
                  if (!_isLoadingSlots && (fechaSeleccionada == null || horaSeleccionada == null)) ...[
                    const SizedBox(height: 10),
                    Text(
                      fechaSeleccionada == null
                          ? 'Selecciona una fecha para habilitar horarios.'
                          : 'Selecciona un horario para continuar.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_isSubmitting || _fechaSeleccionada == null || _horaSeleccionada == null) ? null : _confirmar,
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Confirmar reprogramación'),
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
