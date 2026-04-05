import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sigetu/core/realtime/appointments_realtime_service.dart';
import 'package:sigetu/core/utils/responsive.dart';
import 'package:sigetu/core/widgets/app_toast.dart';
import 'package:sigetu/features/administrative/data/administrative_appointments_api.dart';
import 'package:sigetu/features/secretary/domain/secretary_appointment.dart';
import 'package:sigetu/features/secretary/presentation/screens/secretary_appointment_detail_screen.dart';
import 'package:sigetu/features/shared/presentation/widgets/appointment_card.dart';

class AdministrativeScreen extends StatefulWidget {
  const AdministrativeScreen({
    super.key,
    this.sede,
    this.appBarTitle = 'Administrativo - Citas',
  });

  final String? sede;
  final String appBarTitle;

  @override
  State<AdministrativeScreen> createState() => _AdministrativeScreenState();
}

class _AdministrativeScreenState extends State<AdministrativeScreen> {
  late final AdministrativeAppointmentsApi _api;
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
    _api = AdministrativeAppointmentsApi(sede: widget.sede);
    _loadAppointments();
    _connectRealtime();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    unawaited(_realtime.dispose());
    super.dispose();
  }

  void _connectRealtime() {
    _realtime.connect();
    _realtimeSubscription = _realtime.updates.listen((_) {
      if (!mounted) return;
      _loadAppointments(showLoader: false);
    });
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
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
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

  Future<void> _openTurn(SecretaryAppointment appointment) async {
    setState(() => _openingAppointmentId = appointment.id);

    try {
      final detail = await _api.fetchAppointmentDetail(
        appointmentId: appointment.id,
      );
      if (!mounted) return;

      final updateResult = await Navigator.of(context)
          .push<Map<String, dynamic>>(
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
          message: backendMessage?.trim().isNotEmpty == true
              ? backendMessage!
              : 'Turno ${detail.turnNumber}: estado actualizado',
        );
      }
      await _loadAppointments(showLoader: false);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      await AppToast.showError(context, message: message);
    } finally {
      if (mounted) {
        setState(() => _openingAppointmentId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.appBarTitle)),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final hPad = Responsive.horizontalPadding(context);

            if (_errorMessage != null) {
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
                children: [
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      'No hay citas registradas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return AppointmentCard(
                  appointment: appointment,
                  isLoading: _openingAppointmentId == appointment.id,
                  onOpenTurn: () => _openTurn(appointment),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
