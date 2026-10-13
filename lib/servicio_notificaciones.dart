import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ServicioNotificaciones {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. INICIALIZAR Y PEDIR PERMISO NATIVO (Estilo Instagram)
  static Future<void> inicializar() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Pide permiso al usuario en Android 13+ con la ventana nativa
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // 2. DISPARAR LA NOTIFICACIÓN A LA BANDEJA DEL SISTEMA
  static Future<void> mostrarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pedidos_tese_canal', // ID del canal
          'Pedidos TESE', // Nombre visible en ajustes de Android
          channelDescription: 'Notificaciones en vivo del estado de comida',
          importance:
              Importance.max, // Máxima prioridad para que caiga como banner
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(id, titulo, cuerpo, notificationDetails);
  }
}
