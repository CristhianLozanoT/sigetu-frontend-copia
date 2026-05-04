import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermissionDialog {
  static Future<void> show(BuildContext context) async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) return;
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: scheme.primary),
              const SizedBox(width: 8),
              const Text('Activar notificaciones'),
            ],
          ),
          content: const Text(
            'Activa las notificaciones para recibir un aviso cuando sea tu turno y no perderte ninguna alerta importante.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ahora no'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await FirebaseMessaging.instance.requestPermission();
              },
              child: const Text('Permitir'),
            ),
          ],
        );
      },
    );
  }
}
