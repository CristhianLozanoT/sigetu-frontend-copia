// ignore_for_file: avoid_web_libraries_in_flutter, unused_import

import 'dart:js' as js;

/// Muestra notificación en Web usando Notification API del navegador
void showWebNotification(String title, String body) {
  try {
    // Verificar permiso primero
    final permission = js.context['Notification']['permission'] as String?;

    print('[Web Notification] Permission: $permission');

    if (permission != 'granted') {
      print('[Web Notification] Permiso no concedido: $permission');
      // Solicitar permiso
      js.context['Notification'].callMethod('requestPermission');
      return;
    }

    print('[Web Notification] Mostrando notificación: $title - $body');

    // Usar eval para crear la notificación con 'new' correctamente
    // Esto evita el problema de llamar al constructor como función
    final code =
        '''
      new Notification("$title", {
        body: "$body",
        icon: "/icons/icon-192.png",
        badge: "/icons/badge-72.png",
        requireInteraction: true
      })
    ''';

    js.context.callMethod('eval', [code]);

    print('[Web Notification] Notificación mostrada exitosamente');
  } catch (e) {
    print('[Web Notification] Error al mostrar notificación: $e');

    // Fallback: mostrar un toast o alerta
    try {
      // Intentar con window.alert como fallback
      js.context.callMethod('alert', ['Notificación: $title\n$body']);
    } catch (_) {}
  }
}
