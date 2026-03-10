import 'package:flutter/material.dart';

import 'screens/admisiones_mercadeo_home_shell.dart';

class AdmisionesMercadeoRoutes {
  static const home = '/admisiones-mercadeo-home';

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const AdmisionesMercadeoHomeShell(),
  };
}
