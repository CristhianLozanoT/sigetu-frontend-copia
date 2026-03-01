import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sigetu/core/constants/appointment_statuses.dart';
import 'package:sigetu/core/realtime/appointments_realtime_service.dart';
import 'package:sigetu/core/widgets/app_toast.dart';
import 'package:sigetu/features/secretary/data/secretary_appointments_api.dart';
import 'package:sigetu/features/secretary/domain/secretary_appointment.dart';
import 'package:sigetu/features/secretary/presentation/screens/secretary_appointment_detail_screen.dart';

class SecretaryScreen extends StatefulWidget {
  const SecretaryScreen({super.key});

  @override
  State<SecretaryScreen> createState() => _SecretaryScreenState();
}

class _SecretaryScreenState extends State<SecretaryScreen> {
  final _api = SecretaryAppointmentsApi();
  final _realtime = AppointmentsRealtimeService();

  bool _isLoading = true;
  bool _isFetching = false;
  String? _errorMessage;
  List<SecretaryAppointment> _appointments = [];
  int? _openingAppointmentId;
  StreamSubscription<void>? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _realtime.connect();
    _realtimeSubscription = _realtime.updates.listen((_) {
      if (!mounted) return;
      _loadAppointments(showLoader: false);
    });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    unawaited(_realtime.dispose());
    super.dispose();
  }

  Future<void> _loadAppointments({bool showLoader = true}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final appointments = await _api.fetchQueueAppointments();
      if (!mounted) return;
      setState(() {
        _appointments = appointments;
        if (!showLoader) {
          _errorMessage = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isFetching = false;
      if (mounted) {
        setState(() {
          if (showLoader) {
            _isLoading = false;
          }
        });
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    final dd = dateTime.day.toString().padLeft(2, '0');
    final mm = dateTime.month.toString().padLeft(2, '0');
    final yyyy = dateTime.year;
    return '$dd/$mm/$yyyy';
  }

  String _formatTime(DateTime dateTime) {
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$hh:$min';
  }

  String _titleCase(String value) {
    return value
        .split('_')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _statusLabel(String status) {
    switch (status) {
      case AppointmentStatuses.attended:
        return 'Atendido';
      case AppointmentStatuses.absent:
        return 'No asistió';
      case AppointmentStatuses.canceled:
        return 'Cancelada';
      case AppointmentStatuses.calling:
        return 'Llamando';
      case AppointmentStatuses.pending:
        return 'Pendiente';
      default:
        return _titleCase(status);
    }
  }

  String _normalizeStatus(String status) => status.trim().toLowerCase();

  Color _statusBackgroundColor(BuildContext context, String status) {
    final normalized = _normalizeStatus(status);
    final scheme = Theme.of(context).colorScheme;

    if (normalized == AppointmentStatuses.attended) {
      return Colors.green.withOpacity(0.16);
    }

    if (normalized == AppointmentStatuses.absent ||
        normalized == AppointmentStatuses.canceled) {
      return scheme.error.withOpacity(0.14);
    }

    if (normalized == AppointmentStatuses.calling) {
      return scheme.primary.withOpacity(0.14);
    }

    if (normalized == AppointmentStatuses.inAttention || normalized == 'atendiendo') {
      return Colors.green.withOpacity(0.16);
    }

    return scheme.outline.withOpacity(0.16);
  }

  Color _statusForegroundColor(BuildContext context, String status) {
    final normalized = _normalizeStatus(status);
    final scheme = Theme.of(context).colorScheme;

    if (normalized == AppointmentStatuses.attended) {
      return Colors.green.shade800;
    }

    if (normalized == AppointmentStatuses.absent ||
        normalized == AppointmentStatuses.canceled) {
      return scheme.error;
    }

    if (normalized == AppointmentStatuses.calling) {
      return scheme.primary;
    }

    if (normalized == AppointmentStatuses.inAttention || normalized == 'atendiendo') {
      return Colors.green.shade800;
    }

    return scheme.onSurface;
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final foreground = _statusForegroundColor(context, status);

    return Chip(
      backgroundColor: _statusBackgroundColor(context, status),
      side: BorderSide(color: foreground.withOpacity(0.35)),
      label: Text(
        _statusLabel(status),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _openTurn(SecretaryAppointment appointment) async {
    setState(() => _openingAppointmentId = appointment.id);

    try {
      final detail = await _api.fetchAppointmentDetail(appointmentId: appointment.id);
      if (!mounted) return;

      final updateResult = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => SecretaryAppointmentDetailScreen(detail: detail),
        ),
      );

      if (!mounted) return;
      final updatedStatus = updateResult?['status']?.toString();
      final backendMessage = updateResult?['message']?.toString();

      if (updatedStatus != null) {
        await AppToast.showSuccess(
          context,
          message:
              backendMessage?.trim().isNotEmpty == true
                  ? backendMessage!
                  : 'Turno ${detail.turnNumber}: ${_statusLabel(updatedStatus)}',
        );
      }
      await _loadAppointments(showLoader: false);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      await AppToast.showError(
        context,
        message: message,
      );
    } finally {
      if (mounted) {
        setState(() => _openingAppointmentId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secretaría - Citas')),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_errorMessage != null) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadAppointments,
                    child: const Text('Reintentar'),
                  ),
                ],
              );
            }

            if (_appointments.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      'No hay citas registradas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                appointment.turnNumber,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _buildStatusChip(context, appointment.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Estudiante: ${appointment.studentName}'),
                        Text('Categoría: ${_titleCase(appointment.category)}'),
                        Text('Contexto: ${_titleCase(appointment.context)}'),
                        const SizedBox(height: 6),
                        Text('Programada: ${_formatDate(appointment.scheduledAt)}'),
                        Text('Hora: ${_formatTime(appointment.scheduledAt)}'),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _openingAppointmentId != appointment.id
                                ? () => _openTurn(appointment)
                                : null,
                            icon: _openingAppointmentId == appointment.id
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.open_in_new_outlined),
                            label: const Text('Abrir turno'),
                          ),
                        ),
                      ],
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
