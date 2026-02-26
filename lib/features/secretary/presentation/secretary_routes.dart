import 'package:flutter/material.dart';
import 'screens/secretary_screen.dart';

class SecretaryRoutes {
  static const home = '/secretary-home';

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const SecretaryScreen(),
  };
}
