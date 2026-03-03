import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sigetu/core/constants/appointment_statuses.dart';
import 'package:sigetu/core/realtime/appointments_realtime_service.dart';
import 'package:sigetu/core/utils/app_date_formatter.dart';
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

  Color _statusColor(BuildContext context, String status) {
    final normalized = _normalizeStatus(status);
    final scheme = Theme.of(context).colorScheme;

    if (normalized == AppointmentStatuses.attended) {
      return Colors.green;
    }

    if (normalized == AppointmentStatuses.absent ||
        normalized == AppointmentStatuses.canceled) {
      return scheme.error;
    }

    if (normalized == AppointmentStatuses.calling) {
      return scheme.primary;
    }

    if (normalized == AppointmentStatuses.inAttention || normalized == 'atendiendo') {
      return Colors.green;
    }

    return scheme.outline;
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final statusColor = _statusColor(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: statusColor,
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
                final scheme = Theme.of(context).colorScheme;
                final infoIconColor = scheme.onSurface.withValues(alpha: 0.58);
                final primaryTone = scheme.primary;
                final titleTone = scheme.onSurface;
                final detailText = appointment.context.trim().isNotEmpty
                    ? _titleCase(appointment.context)
                    : _titleCase(appointment.category);
                final secretariaLabel =
                  (appointment.secretariaName == null ||
                    appointment.secretariaName!.trim().isEmpty)
                  ? 'Sin asignar'
                  : appointment.secretariaName!;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: titleTone,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Turno '),
                                    TextSpan(
                                      text: appointment.turnNumber,
                                      style: TextStyle(
                                        color: primaryTone,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _buildStatusBadge(context, appointment.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.person_outline,
                                color: infoIconColor,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.studentName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    detailText,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: scheme.onSurface.withValues(alpha: 0.86),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.support_agent_outlined,
                              size: 18,
                              color: infoIconColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Atendiendo por: $secretariaLabel',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.86),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                    color: infoIconColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppDateFormatter.dateShort(appointment.scheduledAt),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                    color: infoIconColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppDateFormatter.time12FromDateTime(
                                      appointment.scheduledAt,
                                    ),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openingAppointmentId != appointment.id
                                ? () => _openTurn(appointment)
                                : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: scheme.primary.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                              foregroundColor: scheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: _openingAppointmentId == appointment.id
                                ? SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.primary,
                                    ),
                                  )
                                : const Icon(Icons.open_in_new_outlined, size: 18),
                            label: const Text(
                              'Abrir turno',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
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
