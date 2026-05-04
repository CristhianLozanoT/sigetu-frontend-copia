import 'package:flutter/material.dart';
import 'package:sigetu/core/utils/responsive.dart';
import 'package:sigetu/core/widgets/app_toast.dart';
import 'package:sigetu/features/auth/data/auth_api.dart';
import 'package:sigetu/features/auth/presentation/auth_routes.dart';
import 'login_screen.dart' show BubblesPainter;
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class PasswordResetRequestScreen extends StatefulWidget {
  const PasswordResetRequestScreen({super.key});

  @override
  State<PasswordResetRequestScreen> createState() =>
      _PasswordResetRequestScreenState();
}

class _PasswordResetRequestScreenState
    extends State<PasswordResetRequestScreen> {
  static final RegExp _institutionalEmailRegex = RegExp(
    r'^[^@\s]+@uniautonoma\.edu\.co$',
    caseSensitive: false,
  );

  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
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

  Future<void> _submitRequest() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final successMessage = await AuthApi().requestPasswordReset(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;

      await _showRequestMessage(
        successMessage ??
            'Si el correo existe, enviaremos instrucciones para restablecer la contrasena',
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
                        'Restablecer contrasena',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ingresa tu correo institucional para recibir el enlace',
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
                                label: 'Correo institucional',
                                icon: Icons.email_outlined,
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.email],
                                autocorrect: false,
                                enableSuggestions: false,
                                onEditingComplete: _submitRequest,
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty) {
                                    return 'Ingrese su correo';
                                  }
                                  if (!_institutionalEmailRegex.hasMatch(
                                    email,
                                  )) {
                                    return 'Use su correo @uniautonoma.edu.co';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AuthButton(
                                text: 'Enviar enlace',
                                isLoading: _isLoading,
                                onPressed: _submitRequest,
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
