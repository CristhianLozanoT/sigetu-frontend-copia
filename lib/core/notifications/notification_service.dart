import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Import condicional para web vs móvil
import 'notification_web.dart'
    if (dart.library.io) 'notification_web_stub.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Aquí puedes manejar la notificación en background/terminated
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (!kIsWeb) {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);
      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {},
      );

      // Crear el canal ANTES de recibir cualquier mensaje
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'citas',
        'Citas',
        description: 'Notificaciones de citas',
        importance: Importance.max,
      );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Permite mostrar notificaciones en primer plano en Android
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    print('[NotificationService] Foreground message recibido:');
    print('  - Title: ${notification?.title}');
    print('  - Body: ${notification?.body}');
    print('  - Data: $data');
    print('  - Platform Web: $kIsWeb');

    if (kIsWeb) {
      // Web: usar Notification API del navegador
      print('[NotificationService] Mostrando notificación web...');
      showWebNotification(
        notification?.title ?? 'Nueva notificación',
        notification?.body ?? data['body'] ?? 'Tienes una nueva notificación',
      );
    } else {
      // Android/iOS: usar flutter_local_notifications
      if (notification != null) {
        print('[NotificationService] Mostrando notificación Android...');
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'citas',
              'Citas',
              channelDescription: 'Notificaciones de citas',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: data.isNotEmpty ? data.toString() : null,
        );
      } else if (data.isNotEmpty) {
        _flutterLocalNotificationsPlugin.show(
          data.hashCode,
          data['title'] ?? 'Notificación',
          data['body'] ?? 'Tienes una nueva notificación',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'citas',
              'Citas',
              channelDescription: 'Notificaciones de citas',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: data.toString(),
        );
      }
    }
  }
}
