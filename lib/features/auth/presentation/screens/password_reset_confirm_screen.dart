import 'package:flutter/material.dart';
import 'package:sigetu/core/utils/responsive.dart';
import 'package:sigetu/core/widgets/app_toast.dart';
import 'package:sigetu/features/auth/data/auth_api.dart';
import 'package:sigetu/features/auth/presentation/auth_routes.dart';
import 'login_screen.dart' show BubblesPainter;
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class PasswordResetConfirmScreen extends StatefulWidget {
  const PasswordResetConfirmScreen({super.key});

  @override
  State<PasswordResetConfirmScreen> createState() =>
      _PasswordResetConfirmScreenState();
}

class _PasswordResetConfirmScreenState
    extends State<PasswordResetConfirmScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _token = Uri.base.queryParameters['token'] ?? '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  Future<void> _showRequestMessage(String message, {required bool isError}) {
    if (isError) {
      return AppToast.showError(context, message: message);
    }
    return AppToast.showSuccess(context, message: message);
  }

  Future<void> _submitReset() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    if (_token.isEmpty) {
      await _showRequestMessage(
        'El enlace no es valido o el token esta ausente',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final successMessage = await AuthApi().confirmPasswordReset(
        token: _token,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;

      await _showRequestMessage(
        successMessage ?? 'Contrasena actualizada correctamente',
        isError: false,
      );
      Navigator.pushReplacementNamed(context, AuthRoutes.login);
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
    final isWide = !Responsive.isMobile(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  Color.lerp(bgColor, scheme.primary, 0.08)!,
                  bgColor,
                ],
              ),
            ),
          ),
          CustomPaint(painter: BubblesPainter(primaryColor: scheme.primary)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.horizontalPadding(context),
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 440 : double.infinity,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Nueva contrasena',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crea una contrasena segura para tu cuenta',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.06),
                              blurRadius: 60,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthTextField(
                                label: 'Nueva contrasena',
                                icon: Icons.lock_outline,
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onEditingComplete: () => FocusScope.of(
                                  context,
                                ).requestFocus(_confirmPasswordFocusNode),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese una contrasena';
                                  }
                                  if (value.length < 8) {
                                    return 'Minimo 8 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                label: 'Confirmar contrasena',
                                icon: Icons.lock_outline,
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocusNode,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onEditingComplete: _submitReset,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirme su contrasena';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Las contrasenas no coinciden';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AuthButton(
                                text: 'Actualizar contrasena',
                                isLoading: _isLoading,
                                onPressed: _submitReset,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushReplacementNamed(
                                  context,
                                  AuthRoutes.login,
                                ),
                        child: Text(
                          'Volver a iniciar sesion',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
