import 'package:flutter/material.dart';
import 'package:sigetu/core/constants/appointment_statuses.dart';
import 'package:sigetu/features/secretary/data/secretary_appointments_api.dart';
import 'package:sigetu/features/secretary/domain/secretary_appointment_detail.dart';
import 'package:sigetu/features/secretary/presentation/widgets/secretary_status_action_button.dart';

class SecretaryAppointmentDetailScreen extends StatefulWidget {
  const SecretaryAppointmentDetailScreen({
    super.key,
    required this.detail,
  });

  final SecretaryAppointmentDetail detail;

  @override
  State<SecretaryAppointmentDetailScreen> createState() =>
      _SecretaryAppointmentDetailScreenState();
}

class _SecretaryAppointmentDetailScreenState
    extends State<SecretaryAppointmentDetailScreen> {
  final _api = SecretaryAppointmentsApi();
  String? _updatingStatus;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.detail.status;
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

  Future<void> _updateStatus(
    String status, {
    bool closeOnSuccess = true,
  }) async {
    if (_updatingStatus != null) return;

    setState(() => _updatingStatus = status);

    try {
      await _api.updateAppointmentStatus(
        appointmentId: widget.detail.id,
        status: status,
      );

      if (!mounted) return;
      setState(() {
        _currentStatus = status;
        _updatingStatus = null;
      });

      if (closeOnSuccess) {
        Navigator.of(context).pop(status);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Turno cambiado a ${_statusLabel(status)}')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() => _updatingStatus = null);
    }
  }

  Future<void> _showCallModal() async {
    if (_updatingStatus != null) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final isUpdating = _updatingStatus == AppointmentStatuses.inAttention;

        return AlertDialog(
          title: const Text('Gestionar llamado'),
          content: const Text('Se esta llamando al estudiante cual se le asignó el turno. Cuando el estudiante se encuentre en atención, presiona el botón "En atención".'),
          actions: [
            TextButton(
              onPressed: isUpdating
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      await _updateStatus(
                        AppointmentStatuses.inAttention,
                        closeOnSuccess: false,
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                    },
              child: isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('En atención'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCallFlow() async {
    if (_updatingStatus != null) return;

    if (_currentStatus != AppointmentStatuses.calling) {
      await _updateStatus(
        AppointmentStatuses.calling,
        closeOnSuccess: false,
      );
      if (!mounted) return;
      if (_currentStatus != AppointmentStatuses.calling) return;
    }

    await _showCallModal();
  }

  Widget _infoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final normalizedStatus = _normalizeStatus(_currentStatus);
    final canFinalizeAttention =
      normalizedStatus == AppointmentStatuses.inAttention ||
      normalizedStatus == 'atendiendo';
    final canMarkAbsent =
      canFinalizeAttention || normalizedStatus == AppointmentStatuses.calling;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del turno'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            detail.turnNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _buildStatusChip(context, _currentStatus),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _updatingStatus == null &&
                                _currentStatus != AppointmentStatuses.inAttention
                            ? _handleCallFlow
                            : null,
                        icon: _updatingStatus == AppointmentStatuses.calling ||
                                _updatingStatus == AppointmentStatuses.inAttention
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.record_voice_over_outlined),
                        label: const Text('Llamar turno'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoRow(label: 'Categoría', value: _titleCase(detail.category)),
                    _infoRow(label: 'Contexto', value: _titleCase(detail.context)),
                    _infoRow(label: 'Sede', value: _titleCase(detail.sede)),
                    _infoRow(label: 'Fecha', value: _formatDate(detail.scheduledAt)),
                    _infoRow(label: 'Hora', value: _formatTime(detail.scheduledAt)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del estudiante',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    _infoRow(label: 'Nombre', value: detail.student.fullName),
                    _infoRow(label: 'Correo', value: detail.student.email),
                    _infoRow(
                      label: 'Programa',
                      value: _titleCase(detail.student.academicProgram),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SecretaryStatusActionButton(
              label: 'Atendido',
              icon: Icons.check_circle_outline,
              loading: _updatingStatus == AppointmentStatuses.attended,
              onPressed: _updatingStatus == null && canFinalizeAttention
                  ? () => _updateStatus(AppointmentStatuses.attended)
                  : null,
              variant: SecretaryStatusActionVariant.successFilled,
            ),
            const SizedBox(height: 8),
            SecretaryStatusActionButton(
              label: 'No asistió',
              icon: Icons.person_off_outlined,
              loading: _updatingStatus == AppointmentStatuses.absent,
              onPressed: _updatingStatus == null && canMarkAbsent
                  ? () => _updateStatus(AppointmentStatuses.absent)
                  : null,
              variant: SecretaryStatusActionVariant.dangerOutlined,
            ),
            const SizedBox(height: 8),
            SecretaryStatusActionButton(
              label: 'Cancelada',
              icon: Icons.cancel_outlined,
              loading: _updatingStatus == AppointmentStatuses.canceled,
              onPressed: _updatingStatus == null
                  ? () => _updateStatus(AppointmentStatuses.canceled)
                  : null,
              variant: SecretaryStatusActionVariant.dangerOutlined,
            ),
          ],
        ),
      ),
    );
  }
}
