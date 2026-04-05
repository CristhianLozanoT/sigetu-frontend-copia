import 'package:flutter/material.dart';
import 'package:sigetu/core/auth/auth_session.dart';
import 'package:sigetu/core/utils/responsive.dart';
import 'package:sigetu/core/widgets/app_toast.dart';
import 'package:sigetu/features/auth/data/auth_api.dart';
import 'package:sigetu/features/auth/domain/user.dart';
import 'package:sigetu/features/auth/presentation/auth_routes.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _api = AuthApi();
  bool _isLoggingOut = false;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // En modo invitado no hay perfil que cargar
    if (AuthSession.isGuest) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final user = await _api.me();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    final refreshToken = AuthSession.refreshToken;
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      try {
        await AuthApi().logout(refreshToken: refreshToken);
      } catch (error) {
        if (mounted) {
          await AppToast.showError(
            context,
            message: error.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    }

    AuthSession.clear();
    if (!mounted) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AuthRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.horizontalPadding(context),
                      vertical: 20,
                    ),
                    children: [
                      const SizedBox(height: 24),
                      // Banner invitado
                      if (AuthSession.isGuest) _GuestBanner(),
                      // Avatar
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: scheme.primaryContainer,
                          child: Text(
                            _user != null && _user!.fullName.isNotEmpty
                                ? _user!.fullName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_user != null)
                        Center(
                          child: Text(
                            _user!.fullName,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      const SizedBox(height: 28),
                      // Info card
                      if (_user != null)
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _InfoTile(
                                icon: Icons.email_outlined,
                                label: 'Correo',
                                value: _user!.email,
                              ),
                              if (_user!.academicProgram != null &&
                                  _user!.academicProgram!.isNotEmpty) ...[
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                _InfoTile(
                                  icon: Icons.school_outlined,
                                  label: 'Programa',
                                  value: _user!.academicProgram!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Cerrar sesión
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isLoggingOut ? null : _logout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: scheme.error,
                            side: BorderSide(
                              color: scheme.error.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isLoggingOut
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: scheme.error,
                                  ),
                                )
                              : Icon(
                                  AuthSession.isGuest
                                      ? Icons.exit_to_app_outlined
                                      : Icons.logout_outlined,
                                ),
                          label: Text(
                            AuthSession.isGuest
                                ? 'Salir del modo invitado'
                                : 'Cerrar sesión',
                          ),
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  const _GuestBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Modo invitado',
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Estás usando la app sin cuenta. Regístrate para guardar tu historial de turnos y acceder a todas las sedes.',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pushNamed(AuthRoutes.register),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Crear cuenta'),
            ),
          ),
        ],
      ),
    );
  }
}
