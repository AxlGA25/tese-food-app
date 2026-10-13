import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ServicioNotificaciones {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. INICIALIZAR Y SOLICITAR PERMISOS NATIVOS
  static Future<void> inicializar() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // 2. DISPARAR NOTIFICACIÓN NATIVA DE BANNER (ALERTA DE PEDIDO)
  static Future<void> mostrarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pedidos_tese_canal',
          'Pedidos TESE',
          channelDescription: 'Notificaciones en vivo del estado de comida',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(id, titulo, cuerpo, notificationDetails);
  }

  // 3. NOTIFICACIÓN FIJA DE MONITOREO (EVITA QUE ANDROID DUERMA LA APP AL SALIRTE)
  static Future<void> iniciarMonitoreoOrden(String idPedido) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'monitoreo_tese_canal',
          'Monitoreo de Pedidos',
          channelDescription:
              'Mantiene viva la conexión mientras se prepara la comida',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true, // Le prohíbe al sistema operativo congelar la conexión
          autoCancel: false,
          playSound: false,
          enableVibration: false,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      999, // ID fijo de monitoreo
      '🦆 TESE Hambreados',
      'Monitoreando tu orden $idPedido en tiempo real...',
      notificationDetails,
    );
  }

  // 4. CANCELAR EL MONITOREO CUANDO YA ESTÁ LISTO O ENTREGADO
  static Future<void> cancelarMonitoreo() async {
    await _notificationsPlugin.cancel(999);
  }
}
