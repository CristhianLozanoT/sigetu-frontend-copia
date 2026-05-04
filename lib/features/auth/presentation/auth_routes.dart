import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/password_reset_request_screen.dart';
import 'screens/password_reset_confirm_screen.dart';

class AuthRoutes {
  static const login = '/login';
  static const register = '/register';
  static const passwordResetRequest = '/password-reset';
  static const passwordResetConfirm = '/reset-password';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => LoginScreen(),
    register: (_) => RegisterScreen(),
    passwordResetRequest: (_) => PasswordResetRequestScreen(),
    passwordResetConfirm: (_) => PasswordResetConfirmScreen(),
  };
}
