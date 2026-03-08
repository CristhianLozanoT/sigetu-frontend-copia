import 'package:flutter/material.dart';
import 'screens/secretary_home_shell.dart';

class SecretaryRoutes {
  static const home = '/secretary-home';

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const SecretaryHomeShell(),
  };
}
