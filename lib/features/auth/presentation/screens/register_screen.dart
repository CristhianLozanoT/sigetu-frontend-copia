import 'package:flutter/material.dart';
import 'package:sigetu/features/auth/data/auth_api.dart';
import 'package:sigetu/features/auth/domain/user_register.dart';
import 'package:sigetu/features/auth/presentation/auth_routes.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static final RegExp _institutionalEmailRegex = RegExp(
    r'^[^@\s]+@uniautonoma\.edu\.co$',
    caseSensitive: false,
  );

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _academicProgram;

  static const List<Map<String, String>> _academicPrograms = [
    {'label': 'Ingenierías', 'value': 'ingenierias'},
    {'label': 'Derecho', 'value': 'derecho'},
    {'label': 'Finanzas', 'value': 'finanzas'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  void _showTopMessage(String message, {required bool isError}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearMaterialBanners()
      ..hideCurrentSnackBar();

    final colorScheme = Theme.of(context).colorScheme;

    messenger.showMaterialBanner(
      MaterialBanner(
        leading: const Icon(Icons.info_outline, color: Colors.white),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError
            ? colorScheme.error
            : colorScheme.primary,
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      messenger.hideCurrentMaterialBanner();
    });
  }

  Future<void> _submitRegister() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final user = UserRegister(
      email: _emailController.text.trim(),
      fullName: _nameController.text.trim(),
      password: _passwordController.text,
      academicProgram: _academicProgram!,
    );

    try {
      await AuthApi().register(user);
      if (!mounted) return;
      _showTopMessage('Registro exitoso', isError: false);
      Navigator.pushReplacementNamed(context, AuthRoutes.login);
    } catch (error) {
      if (!mounted) return;
      _showTopMessage(_mapErrorMessage(error), isError: true);
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
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      48, // padding aproximado
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FlutterLogo(size: 100),
                      const SizedBox(height: 14),

                      const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 32),

                      AuthTextField(
                        label: 'Nombre completo',
                        icon: Icons.person_outline,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su nombre';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

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

                      DropdownButtonFormField<String>(
                        value: _academicProgram,
                        decoration: const InputDecoration(
                          labelText: 'Programa académico',
                          border: OutlineInputBorder(),
                        ),
                        items: _academicPrograms
                            .map(
                              (program) => DropdownMenuItem<String>(
                                value: program['value'],
                                child: Text(program['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() => _academicProgram = value);
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione su programa académico';
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

                      const SizedBox(height: 16),

                      AuthTextField(
                        label: 'Confirmar contraseña',
                        icon: Icons.lock_outline,
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirme su contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      AuthButton(
                        text: 'Registrarse',
                        isLoading: _isLoading,
                        onPressed: _submitRegister,
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(context, AuthRoutes.login);
                              },
                        child: Text.rich(
                          TextSpan(
                            text: '¿Ya tienes cuenta? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Inicia sesión',
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
          ),
        ),
      ),
    );
  }
}
