import 'package:flutter/material.dart';

/// Puntos de corte responsive.
/// mobile  < 600px
/// tablet  600–1023px
/// web    >= 1024px
class Responsive {
  const Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }

  static bool isWeb(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  /// Padding horizontal estándar según plataforma.
  static double horizontalPadding(BuildContext context) {
    if (isWeb(context)) return 32;
    if (isTablet(context)) return 28;
    return 20;
  }

  /// Ancho máximo para formularios centrados (login, registro).
  static double formMaxWidth(BuildContext context) {
    if (isWeb(context)) return 440;
    if (isTablet(context)) return 520;
    return double.infinity;
  }

  /// Helper genérico: devuelve un valor por plataforma.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T web,
  }) {
    if (isWeb(context)) return web;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}
