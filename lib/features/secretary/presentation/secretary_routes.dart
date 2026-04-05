import 'package:flutter/material.dart';
import 'screens/secretary_home_shell.dart';
import 'screens/secretary_history_screen.dart';

class SecretaryRoutes {
  static const home = '/secretary-home';
  static const history = '/secretary-history';

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const SecretaryHomeShell(),
    history: (_) => const SecretaryHistoryScreen(),
  };
}
