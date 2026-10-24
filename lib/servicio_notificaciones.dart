import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class ServicioNotificaciones {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final AudioPlayer _player = AudioPlayer();
  static bool _inicializado = false;
  static DateTime? _ultimoSonido;

  static Future<void> inicializar() async {
    if (_inicializado) return;

    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Aviso AudioContext: $e');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);

    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
      const AndroidNotificationChannel canal = AndroidNotificationChannel(
        'canal_pedidos_tese_silencioso',
        'Seguimiento de Pedidos TESE',
        description: 'Avisos en tiempo real de la cafetería',
        importance: Importance.max,
        playSound: false,
        enableVibration: true,
      );
      await androidImpl.createNotificationChannel(canal);
    }

    _inicializado = true;
  }

  /// Reproduce 'sonidos/exito.mp3' o 'sonidos/cuac.mp3' sin cortes
  static Future<void> sonarEfecto(String rutaAsset) async {
    await inicializar();

    final ahora = DateTime.now();
    if (_ultimoSonido != null &&
        ahora.difference(_ultimoSonido!).inMilliseconds < 700) {
      return;
    }
    _ultimoSonido = ahora;

    final String archivo = rutaAsset
        .replaceFirst('assets/', '')
        .replaceFirst('sonidos/', '');

    try {
      await _player.setVolume(1.0);
      await _player.play(AssetSource('sonidos/$archivo'));
    } catch (_) {
      try {
        await _player.play(AssetSource(archivo));
      } catch (_) {
        SystemSound.play(SystemSoundType.alert);
      }
    }
  }

  static Future<void> sonarCuac({String asset = 'sonidos/cuac.mp3'}) async {
    await sonarEfecto(asset);
  }

  static Future<void> mostrarNotificacionOrden({
    required int id,
    required String titulo,
    required String cuerpo,
    bool enCurso = false,
    bool esPedidoListo = false,
    String sonido = 'sonidos/cuac.mp3',
  }) async {
    try {
      await inicializar();

      if (esPedidoListo) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'canal_pedidos_tese_silencioso',
            'Seguimiento de Pedidos TESE',
            channelDescription: 'Avisos en tiempo real de la cafetería',
            importance: Importance.max,
            priority: Priority.max,
            ongoing: enCurso,
            autoCancel: !enCurso,
            playSound: false,
            enableVibration: true,
          );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      // 1. Mostramos la notificación visual
      await _plugin.show(id, titulo, cuerpo, details);

      // 2. Reproducimos nuestro MP3 ('exito.mp3' al confirmar o 'cuac.mp3' al preparar/listo)
      await sonarEfecto(sonido);
    } catch (e) {
      debugPrint('Error en notificación: $e');
    }
  }

  static Future<void> mostrarNotificacion({
    int id = 1,
    required String titulo,
    required String cuerpo,
    bool ongoing = false,
  }) async {
    await mostrarNotificacionOrden(
      id: id,
      titulo: titulo,
      cuerpo: cuerpo,
      enCurso: ongoing,
      sonido: 'sonidos/cuac.mp3',
    );
  }
}
