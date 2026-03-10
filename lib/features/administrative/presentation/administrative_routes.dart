import 'package:flutter/material.dart';

import 'screens/administrative_home_shell.dart';

class AdministrativeRoutes {
  static const home = '/administrative-home';

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const AdministrativeHomeShell(),
  };
}
