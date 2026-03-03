import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:sigetu/core/auth/auth_session.dart';
import 'package:sigetu/core/widgets/app_toast.dart';
import 'package:sigetu/features/auth/data/auth_api.dart';
import 'package:sigetu/features/auth/presentation/auth_routes.dart';
import 'package:sigetu/features/secretary/presentation/secretary_routes.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'package:sigetu/features/student_dashboard/presentation/student_dashboard_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final RegExp _institutionalEmailRegex = RegExp(
    r'^[^@\s]+@uniautonoma\.edu\.co$',
    caseSensitive: false,
  );

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  String _extractRoleFromToken(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return '';
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(payload);

      if (data is Map<String, dynamic>) {
        final role = data['role'] ?? data['rol'];
        if (role is String) {
          return role.toLowerCase();
        }
      }
    } catch (_) {}

    return '';
  }

  Future<void> _showRequestMessage(String message, {required bool isError}) {
    if (isError) {
      return AppToast.showError(context, message: message);
    }
    return AppToast.showSuccess(context, message: message);
  }

  Future<void> _submitLogin() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loginResponse = await AuthApi().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      AuthSession.setTokens(
        access: loginResponse.accessToken,
        refresh: loginResponse.refreshToken,
      );

      final role = _extractRoleFromToken(loginResponse.accessToken);
      final isSecretaryRole =
          role == 'secretaria' || role == 'secretary' || role == 'role_secretaria';

      await _showRequestMessage(
        loginResponse.message ?? 'Inicio de sesión exitoso',
        isError: false,
      );
      Navigator.pushReplacementNamed(
        context,
        isSecretaryRole
            ? SecretaryRoutes.home
            : StudentDashboardRoutes.dashboard,
      );
    } catch (error) {
      if (!mounted) return;
      await _showRequestMessage(_mapErrorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              //centrar todo el contenido
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlutterLogo(size: 100),
                SizedBox(height: 14),
                Text(
                  'SIGETU - UNIAUTÓNOMA',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Sistema de Gestión de Turnos',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 32),
                AuthTextField(
                  label: 'Correo institucional',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return 'Ingrese su correo';
                    }
                    if (!_institutionalEmailRegex.hasMatch(email)) {
                      return 'Use su correo institucional @uniautonoma.edu.co';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    if (value.length < 8) {
                      return 'Mínimo 8 caracteres';
                    }
                    return null;
                  },
                ),
                // Olvidaste tu contraseña
                TextButton(
                  onPressed: () {},
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
                const SizedBox(height: 22),
                AuthButton(
                  text: 'Ingresar',
                  isLoading: _isLoading,
                  onPressed: _submitLogin,
                ),

                // No tienes cuenta? Registrate
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, AuthRoutes.register);
                        },
                  child: Text.rich(
                    TextSpan(
                      text: '¿No tienes cuenta? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Regístrate',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
