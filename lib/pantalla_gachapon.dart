// ─────────────────────────────────────────────────────────────────────────────
// GACHAPÓN DE PATITOS 🦆🥚
//
// Cambias tus puntos por un "Huevo Misterioso". El huevo se agita, se rompe y
// arranca una ruleta (como al abrir una caja en Counter-Strike) que se frena
// poco a poco sobre tu patito. Hay 5 rarezas y 15 skins de patito dibujadas
// con código (no necesitan imágenes).
//
// USO (desde donde tengas tus puntos):
//
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => PantallaGachapon(
//       puntos: misPuntos,
//       onPuntosCambian: (nuevos) { /* guardar los puntos que quedaron */ },
//       onPatoObtenido: (pato, veces) { /* guardar pato.id y cuántos tiene */ },
//     ),
//   ));
//
// Usa `confetti` (que ya tienes en el proyecto). Nada más.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colores.dart';

// ═════════════════════════════ DATOS ═════════════════════════════

enum Rareza { comun, rara, epica, mitica, legendaria }

extension RarezaInfo on Rareza {
  String get nombre => switch (this) {
    Rareza.comun => 'Común',
    Rareza.rara => 'Rara',
    Rareza.epica => 'Épica',
    Rareza.mitica => 'Mítica',
    Rareza.legendaria => 'Legendaria',
  };

  Color get color => switch (this) {
    Rareza.comun => const Color(0xFF8FB8A8),
    Rareza.rara => const Color(0xFF4DA3FF),
    Rareza.epica => const Color(0xFFA06BFF),
    Rareza.mitica => const Color(0xFFFF5FA2),
    Rareza.legendaria => const Color(0xFFFFC53D),
  };

  // Probabilidad en % (suman 100).
  int get peso => switch (this) {
    Rareza.comun => 55,
    Rareza.rara => 25,
    Rareza.epica => 12,
    Rareza.mitica => 6,
    Rareza.legendaria => 2,
  };
}

enum Accesorio {
  ninguno,
  birrete,
  gorroChef,
  lentes,
  corona,
  casco,
  mago,
  auriculares,
  ninja,
  pirata,
}

enum EfectoCuerpo { ninguno, galaxia, arcoiris, oro, diamante }

class PatoSkin {
  final String id;
  final String nombre;
  final String frase;
  final Rareza rareza;
  final Color cuerpo;
  final Color? cuerpo2;
  final Color pico;
  final EfectoCuerpo efecto;
  final Accesorio accesorio;

  const PatoSkin({
    required this.id,
    required this.nombre,
    required this.frase,
    required this.rareza,
    required this.cuerpo,
    this.cuerpo2,
    this.pico = const Color(0xFFFF9F1C),
    this.efecto = EfectoCuerpo.ninguno,
    this.accesorio = Accesorio.ninguno,
  });

  bool get brilla =>
      efecto == EfectoCuerpo.oro || efecto == EfectoCuerpo.diamante;
}

const List<PatoSkin> catalogoPatos = [
  // ── Comunes ──
  PatoSkin(
    id: 'clasico',
    nombre: 'Patito Clásico',
    frase: 'El de toda la vida. Nunca falla.',
    rareza: Rareza.comun,
    cuerpo: Color(0xFFFFD84D),
  ),
  PatoSkin(
    id: 'estudiante',
    nombre: 'Patito Estudiante',
    frase: 'Se graduó con honores... del receso.',
    rareza: Rareza.comun,
    cuerpo: Color(0xFFFFD84D),
    accesorio: Accesorio.birrete,
  ),
  PatoSkin(
    id: 'matcha',
    nombre: 'Patito Matcha',
    frase: 'Fresco, zen y sin prisa.',
    rareza: Rareza.comun,
    cuerpo: Color(0xFFB7E08C),
  ),
  PatoSkin(
    id: 'chicle',
    nombre: 'Patito Chicle',
    frase: 'Dulce, rosita y un poco pegajoso.',
    rareza: Rareza.comun,
    cuerpo: Color(0xFFFFB3D1),
  ),
  // ── Raras ──
  PatoSkin(
    id: 'chef',
    nombre: 'Chef Patito',
    frase: 'Sus chilaquiles son los más crujientes.',
    rareza: Rareza.rara,
    cuerpo: Color(0xFFFFF3D6),
    accesorio: Accesorio.gorroChef,
  ),
  PatoSkin(
    id: 'hielo',
    nombre: 'Patito Hielo',
    frase: 'Su playlist congela hasta el café.',
    rareza: Rareza.rara,
    cuerpo: Color(0xFFA8DCFF),
    accesorio: Accesorio.auriculares,
  ),
  PatoSkin(
    id: 'cool',
    nombre: 'Patito Cool',
    frase: 'Trae lentes hasta dentro del salón.',
    rareza: Rareza.rara,
    cuerpo: Color(0xFFFFA94D),
    accesorio: Accesorio.lentes,
  ),
  PatoSkin(
    id: 'ninja',
    nombre: 'Patito Ninja',
    frase: 'Llega a la cafetería sin que lo vean.',
    rareza: Rareza.rara,
    cuerpo: Color(0xFF3A3A48),
    accesorio: Accesorio.ninja,
  ),
  // ── Épicas ──
  PatoSkin(
    id: 'pirata',
    nombre: 'Capitán Patito',
    frase: 'Navega entre mesas buscando el último taco.',
    rareza: Rareza.epica,
    cuerpo: Color(0xFFE76F51),
    accesorio: Accesorio.pirata,
  ),
  PatoSkin(
    id: 'mago',
    nombre: 'Patito Mago',
    frase: 'Hace aparecer tortas de la nada.',
    rareza: Rareza.epica,
    cuerpo: Color(0xFF9B7BFF),
    accesorio: Accesorio.mago,
  ),
  PatoSkin(
    id: 'astronauta',
    nombre: 'Patonauta',
    frase: 'Rumbo al kiosko más lejano del campus.',
    rareza: Rareza.epica,
    cuerpo: Color(0xFFF1F5F9),
    accesorio: Accesorio.casco,
  ),
  // ── Míticas ──
  PatoSkin(
    id: 'galaxia',
    nombre: 'Pato Galáctico',
    frase: 'Nació de una estrella a la hora del receso.',
    rareza: Rareza.mitica,
    cuerpo: Color(0xFF2D1B69),
    cuerpo2: Color(0xFF7B4DE0),
    pico: Color(0xFFFFC857),
    efecto: EfectoCuerpo.galaxia,
  ),
  PatoSkin(
    id: 'arcoiris',
    nombre: 'Pato Arcoíris',
    frase: 'Cambia de color según su antojo.',
    rareza: Rareza.mitica,
    cuerpo: Color(0xFF6BC5FF),
    efecto: EfectoCuerpo.arcoiris,
    accesorio: Accesorio.lentes,
  ),
  // ── Legendarias ──
  PatoSkin(
    id: 'oro',
    nombre: 'Pato Dorado',
    frase: 'Leyenda del TESE. Solo 1 de cada 50.',
    rareza: Rareza.legendaria,
    cuerpo: Color(0xFFFFD54A),
    cuerpo2: Color(0xFFE09A00),
    pico: Color(0xFFFF7A00),
    efecto: EfectoCuerpo.oro,
    accesorio: Accesorio.corona,
  ),
  PatoSkin(
    id: 'diamante',
    nombre: 'Pato Diamante',
    frase: 'Brilla tanto que no necesita hacer fila.',
    rareza: Rareza.legendaria,
    cuerpo: Color(0xFFBDF3FF),
    cuerpo2: Color(0xFFFFC2F0),
    efecto: EfectoCuerpo.diamante,
    accesorio: Accesorio.casco,
  ),
];

Color _ajustarLuz(Color c, double delta) {
  final hsl = HSLColor.fromColor(c);
  final luz = math.max(0.0, math.min(1.0, hsl.lightness + delta));
  return hsl.withLightness(luz).toColor();
}

// ═════════════════════════ EL PATITO (dibujado) ═════════════════════════

/// Un patito con su skin. Puedes reutilizarlo en otras pantallas
/// (por ejemplo, para mostrar el patito favorito en el perfil).
class PatoVista extends StatelessWidget {
  final PatoSkin skin;
  final Animation<double>? reloj;
  final double tamano;

  const PatoVista({
    super.key,
    required this.skin,
    this.reloj,
    this.tamano = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(
        painter: _PintorPato(skin, reloj ?? kAlwaysCompleteAnimation),
      ),
    );
  }
}

class _PintorPato extends CustomPainter {
  final PatoSkin skin;
  final Animation<double> reloj;
  _PintorPato(this.skin, this.reloj) : super(repaint: reloj);

  static const List<Offset> _estrellas = [
    Offset(58, 58),
    Offset(140, 46),
    Offset(88, 118),
    Offset(150, 132),
    Offset(52, 150),
    Offset(118, 168),
    Offset(104, 66),
    Offset(30, 110),
  ];

  static const List<Offset> _brillitos = [
    Offset(26, 44),
    Offset(176, 60),
    Offset(20, 138),
    Offset(182, 150),
    Offset(100, 10),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = reloj.value;
    canvas.save();
    canvas.scale(size.width / 200, size.height / 200);
    const area = Rect.fromLTWH(0, 0, 200, 200);

    // sombra y patas
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 194), width: 120, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    final pata = Paint()..color = skin.pico;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(76, 189), width: 30, height: 14),
      pata,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(124, 189), width: 30, height: 14),
      pata,
    );

    final relleno = _relleno(area, t);
    final contorno =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _ajustarLuz(skin.cuerpo, -0.22);
    final alaPintura = Paint()..color = _ajustarLuz(skin.cuerpo, -0.06);

    // cuerpo + cabeza (en una capa, para que el brillo solo caiga sobre el pato)
    canvas.saveLayer(area, Paint());
    final cuerpo = Rect.fromCenter(
      center: const Offset(100, 140),
      width: 140,
      height: 100,
    );
    canvas.drawOval(cuerpo, relleno);
    canvas.drawOval(cuerpo, contorno);
    _ala(canvas, const Offset(40, 142), -0.45, alaPintura, contorno);
    _ala(canvas, const Offset(160, 142), 0.45, alaPintura, contorno);
    final cabeza = Rect.fromCircle(center: const Offset(100, 82), radius: 62);
    canvas.drawOval(cabeza, relleno);
    canvas.drawOval(cabeza, contorno);
    final mechon =
        Path()
          ..moveTo(96, 22)
          ..quadraticBezierTo(90, 4, 108, 4)
          ..quadraticBezierTo(102, 12, 106, 24)
          ..close();
    canvas.drawPath(mechon, relleno);
    canvas.drawPath(mechon, contorno);
    if (skin.efecto == EfectoCuerpo.galaxia) _estrellasCuerpo(canvas, t);
    if (skin.brilla) _brilloBarrido(canvas, t);
    canvas.restore();

    _cara(canvas);
    _accesorio(canvas);
    if (skin.rareza == Rareza.legendaria) _destellos(canvas, t);
    canvas.restore();
  }

  Paint _relleno(Rect area, double t) {
    final p = Paint();
    if (skin.efecto == EfectoCuerpo.arcoiris) {
      p.shader = SweepGradient(
        colors: const [
          Color(0xFFFF6B6B),
          Color(0xFFFFB86B),
          Color(0xFFFFE66B),
          Color(0xFF7BE495),
          Color(0xFF6BC5FF),
          Color(0xFFB892FF),
          Color(0xFFFF6B6B),
        ],
        transform: GradientRotation(t * 2 * math.pi),
      ).createShader(area);
    } else if (skin.cuerpo2 != null) {
      p.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [skin.cuerpo, skin.cuerpo2!],
      ).createShader(area);
    } else {
      p.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _ajustarLuz(skin.cuerpo, 0.10),
          skin.cuerpo,
          _ajustarLuz(skin.cuerpo, -0.08),
        ],
      ).createShader(area);
    }
    return p;
  }

  void _ala(
    Canvas canvas,
    Offset centro,
    double giro,
    Paint relleno,
    Paint contorno,
  ) {
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.rotate(giro);
    final r = Rect.fromCenter(center: Offset.zero, width: 30, height: 56);
    canvas.drawOval(r, relleno);
    canvas.drawOval(r, contorno);
    canvas.restore();
  }

  void _brilloBarrido(Canvas canvas, double t) {
    final x = -70 + 340 * t;
    final banda =
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + 36, 0)
          ..lineTo(x - 24, 200)
          ..lineTo(x - 60, 200)
          ..close();
    canvas.drawPath(
      banda,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..blendMode = BlendMode.srcATop,
    );
  }

  void _estrellasCuerpo(Canvas canvas, double t) {
    for (var i = 0; i < _estrellas.length; i++) {
      final brillo =
          0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 2 * math.pi + i * 1.7));
      canvas.drawCircle(
        _estrellas[i],
        1.6 + (i % 3) * 0.7,
        Paint()
          ..color = Colors.white.withValues(alpha: brillo)
          ..blendMode = BlendMode.srcATop,
      );
    }
  }

  void _destellos(Canvas canvas, double t) {
    for (var i = 0; i < _brillitos.length; i++) {
      final fase = 0.5 + 0.5 * math.sin(t * 2 * math.pi + i * 1.3);
      final r = 5 + 8 * fase;
      final c = _brillitos[i];
      final estrella =
          Path()
            ..moveTo(c.dx, c.dy - r)
            ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
            ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
            ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
            ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
            ..close();
      canvas.drawPath(
        estrella,
        Paint()..color = Colors.white.withValues(alpha: 0.35 + 0.65 * fase),
      );
    }
  }

  void _cara(Canvas canvas) {
    final rubor =
        Paint()..color = const Color(0xFFFF8FAB).withValues(alpha: 0.5);
    canvas.drawCircle(const Offset(58, 100), 9, rubor);
    canvas.drawCircle(const Offset(142, 100), 9, rubor);

    final pico = Rect.fromCenter(
      center: const Offset(100, 100),
      width: 46,
      height: 24,
    );
    canvas.drawOval(pico, Paint()..color = skin.pico);
    canvas.drawOval(
      pico,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _ajustarLuz(skin.pico, -0.15),
    );
    canvas.drawLine(
      const Offset(86, 101),
      const Offset(114, 101),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = _ajustarLuz(skin.pico, -0.25),
    );

    final ojo = Paint()..color = const Color(0xFF1B1B1B);
    final luz = Paint()..color = Colors.white;
    for (final c in const [Offset(76, 80), Offset(124, 80)]) {
      canvas.drawCircle(c, 7.5, ojo);
      canvas.drawCircle(c.translate(-2.2, -2.4), 2.6, luz);
    }
  }

  // ───────── accesorios ─────────

  void _accesorio(Canvas canvas) {
    switch (skin.accesorio) {
      case Accesorio.ninguno:
        break;
      case Accesorio.birrete:
        _birrete(canvas);
      case Accesorio.gorroChef:
        _gorroChef(canvas);
      case Accesorio.lentes:
        _lentes(canvas);
      case Accesorio.corona:
        _corona(canvas);
      case Accesorio.casco:
        _casco(canvas);
      case Accesorio.mago:
        _mago(canvas);
      case Accesorio.auriculares:
        _auriculares(canvas);
      case Accesorio.ninja:
        _ninja(canvas);
      case Accesorio.pirata:
        _pirata(canvas);
    }
  }

  void _birrete(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(68, 36, 132, 58),
        const Radius.circular(8),
      ),
      Paint()..color = colorVerdeTese,
    );
    final tablero =
        Path()
          ..moveTo(100, 12)
          ..lineTo(164, 32)
          ..lineTo(100, 52)
          ..lineTo(36, 32)
          ..close();
    canvas.drawPath(tablero, Paint()..color = colorVerdeOscuro);
    canvas.drawPath(
      tablero,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    final cordon =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = colorAmarilloTese;
    canvas.drawLine(const Offset(100, 32), const Offset(150, 38), cordon);
    canvas.drawLine(const Offset(150, 38), const Offset(150, 58), cordon);
    canvas.drawCircle(
      const Offset(100, 32),
      4,
      Paint()..color = colorAmarilloTese,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(150, 62), width: 8, height: 12),
        const Radius.circular(3),
      ),
      Paint()..color = colorAmarilloTese,
    );
  }

  void _gorroChef(Canvas canvas) {
    const centros = [Offset(72, 28), Offset(128, 28), Offset(100, 16)];
    const radios = [19.0, 19.0, 24.0];
    final banda = RRect.fromRectAndRadius(
      const Rect.fromLTRB(66, 34, 134, 54),
      const Radius.circular(8),
    );
    final trazo =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = const Color(0xFFD5DBE0);
    final blanco = Paint()..color = Colors.white;
    for (var i = 0; i < centros.length; i++) {
      canvas.drawCircle(centros[i], radios[i], trazo);
    }
    canvas.drawRRect(banda, trazo);
    for (var i = 0; i < centros.length; i++) {
      canvas.drawCircle(centros[i], radios[i], blanco);
    }
    canvas.drawRRect(banda, blanco);
  }

  void _lentes(Canvas canvas) {
    const negro = Color(0xFF14181B);
    final izq = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(76, 82), width: 38, height: 28),
      const Radius.circular(10),
    );
    final der = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(124, 82), width: 38, height: 28),
      const Radius.circular(10),
    );
    final armazon =
        Paint()
          ..color = negro
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(95, 80), const Offset(105, 80), armazon);
    canvas.drawLine(const Offset(57, 80), const Offset(40, 76), armazon);
    canvas.drawLine(const Offset(143, 80), const Offset(160, 76), armazon);
    canvas.drawRRect(izq, Paint()..color = negro);
    canvas.drawRRect(der, Paint()..color = negro);
    final destello =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(66, 75), const Offset(74, 71), destello);
    canvas.drawLine(const Offset(114, 75), const Offset(122, 71), destello);
  }

  void _corona(Canvas canvas) {
    final dorado =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE27A), Color(0xFFE5A800)],
          ).createShader(const Rect.fromLTWH(58, 4, 84, 46));
    final corona =
        Path()
          ..moveTo(60, 46)
          ..lineTo(58, 14)
          ..lineTo(80, 30)
          ..lineTo(100, 6)
          ..lineTo(120, 30)
          ..lineTo(142, 14)
          ..lineTo(140, 46)
          ..close();
    canvas.drawPath(corona, dorado);
    canvas.drawPath(
      corona,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFB37F00),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(60, 40, 140, 52),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFE5A800),
    );
    canvas.drawCircle(
      const Offset(100, 32),
      5,
      Paint()..color = const Color(0xFFFF4D6D),
    );
    canvas.drawCircle(
      const Offset(74, 46),
      3.5,
      Paint()..color = const Color(0xFF4DD0E1),
    );
    canvas.drawCircle(
      const Offset(126, 46),
      3.5,
      Paint()..color = const Color(0xFF4DD0E1),
    );
    final perla = Paint()..color = Colors.white;
    for (final p in const [Offset(58, 14), Offset(100, 6), Offset(142, 14)]) {
      canvas.drawCircle(p, 3.2, perla);
    }
  }

  void _casco(Canvas canvas) {
    const c = Offset(100, 80);
    canvas.drawCircle(
      c,
      68,
      Paint()..color = Colors.white.withValues(alpha: 0.14),
    );
    canvas.drawCircle(
      c,
      68,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.white.withValues(alpha: 0.75),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 56),
      math.pi * 1.1,
      math.pi * 0.35,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.85),
    );
    final collar = RRect.fromRectAndRadius(
      const Rect.fromLTRB(36, 128, 164, 150),
      const Radius.circular(10),
    );
    canvas.drawRRect(collar, Paint()..color = const Color(0xFFC9D3DB));
    canvas.drawRRect(
      collar,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFF8E9BA6),
    );
  }

  void _mago(Canvas canvas) {
    final cono =
        Path()
          ..moveTo(56, 46)
          ..quadraticBezierTo(84, 22, 104, 2)
          ..quadraticBezierTo(114, 22, 144, 46)
          ..close();
    canvas.drawPath(
      cono,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7B5CFF), Color(0xFF4B2FC0)],
        ).createShader(const Rect.fromLTWH(56, 2, 88, 44)),
    );
    final borde =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFF2E1C8A);
    canvas.drawPath(cono, borde);
    final ala = Rect.fromCenter(
      center: const Offset(100, 46),
      width: 124,
      height: 20,
    );
    canvas.drawOval(ala, Paint()..color = const Color(0xFF5B3FD0));
    canvas.drawOval(ala, borde);
    final estrella = Paint()..color = const Color(0xFFFFE066);
    canvas.drawCircle(const Offset(98, 28), 3, estrella);
    canvas.drawCircle(const Offset(116, 36), 2.5, estrella);
    canvas.drawCircle(const Offset(84, 38), 2, estrella);
  }

  void _auriculares(Canvas canvas) {
    final banda =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF2B2B35);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(100, 84), radius: 68),
      math.pi * 1.04,
      math.pi * 0.92,
      false,
      banda,
    );
    for (final x in const [32.0, 168.0]) {
      final copa = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, 90), width: 20, height: 44),
        const Radius.circular(9),
      );
      canvas.drawRRect(copa, Paint()..color = colorAmarilloTese);
      canvas.drawRRect(
        copa,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFF2B2B35),
      );
    }
  }

  void _ninja(Canvas canvas) {
    final rojo = Paint()..color = const Color(0xFFD62828);
    final cola1 =
        Path()
          ..moveTo(158, 54)
          ..lineTo(192, 44)
          ..lineTo(180, 62)
          ..close();
    final cola2 =
        Path()
          ..moveTo(158, 60)
          ..lineTo(190, 78)
          ..lineTo(172, 70)
          ..close();
    canvas.drawPath(cola1, rojo);
    canvas.drawPath(cola2, rojo);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(38, 48, 162, 66),
        const Radius.circular(6),
      ),
      rojo,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(100, 57), width: 36, height: 13),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFCFD8DC),
    );
  }

  void _pirata(Canvas canvas) {
    final negro = Paint()..color = const Color(0xFF1B1B22);
    final sombrero =
        Path()
          ..moveTo(26, 52)
          ..quadraticBezierTo(60, 26, 100, 4)
          ..quadraticBezierTo(140, 26, 174, 52)
          ..quadraticBezierTo(100, 40, 26, 52)
          ..close();
    canvas.drawPath(sombrero, negro);
    canvas.drawPath(
      sombrero,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = colorAmarilloTese,
    );
    canvas.drawCircle(const Offset(100, 28), 9, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(96.5, 27), 2.2, negro);
    canvas.drawCircle(const Offset(103.5, 27), 2.2, negro);
    canvas.drawLine(
      const Offset(40, 86),
      const Offset(160, 66),
      Paint()
        ..color = const Color(0xFF1B1B22)
        ..strokeWidth = 3,
    );
    canvas.drawCircle(const Offset(76, 80), 12, negro);
  }

  @override
  bool shouldRepaint(covariant _PintorPato oldDelegate) =>
      oldDelegate.skin != skin;
}

// ═════════════════════════ EL HUEVO Y LOS RAYOS ═════════════════════════

class _PintorHuevo extends CustomPainter {
  final double grietas; // 0 = entero, 1 = totalmente roto
  const _PintorHuevo(this.grietas);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final huevo =
        Path()
          ..moveTo(w * 0.5, 0)
          ..cubicTo(w * 0.98, h * 0.02, w * 1.02, h * 0.78, w * 0.5, h)
          ..cubicTo(w * -0.02, h * 0.78, w * 0.02, h * 0.02, w * 0.5, 0)
          ..close();

    canvas.drawPath(
      huevo,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 1.0,
          colors: [Color(0xFFFFFBEF), Color(0xFFFFE9B8), Color(0xFFFFC96B)],
        ).createShader(Offset.zero & size),
    );

    canvas.save();
    canvas.clipPath(huevo);
    final mancha = Paint()..color = colorSalvia.withValues(alpha: 0.45);
    canvas.drawCircle(Offset(w * 0.30, h * 0.36), w * 0.07, mancha);
    canvas.drawCircle(Offset(w * 0.70, h * 0.28), w * 0.05, mancha);
    canvas.drawCircle(Offset(w * 0.68, h * 0.62), w * 0.08, mancha);
    canvas.drawCircle(Offset(w * 0.26, h * 0.70), w * 0.05, mancha);
    canvas.drawCircle(Offset(w * 0.50, h * 0.84), w * 0.06, mancha);
    canvas.restore();

    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.13, h * 0.2),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      huevo,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white.withValues(alpha: 0.65),
    );

    if (grietas > 0) {
      _grieta(canvas, size, [
        Offset(w * 0.50, h * 0.28),
        Offset(w * 0.40, h * 0.38),
        Offset(w * 0.54, h * 0.46),
        Offset(w * 0.38, h * 0.57),
        Offset(w * 0.52, h * 0.66),
        Offset(w * 0.42, h * 0.78),
      ]);
      _grieta(canvas, size, [
        Offset(w * 0.54, h * 0.46),
        Offset(w * 0.68, h * 0.52),
        Offset(w * 0.62, h * 0.63),
      ]);
    }
  }

  void _grieta(Canvas canvas, Size size, List<Offset> puntos) {
    final tramos = puntos.length - 1;
    final avance = grietas * tramos;
    final completos = avance.floor();
    final camino = Path()..moveTo(puntos[0].dx, puntos[0].dy);
    for (var i = 1; i <= completos && i < puntos.length; i++) {
      camino.lineTo(puntos[i].dx, puntos[i].dy);
    }
    if (completos < tramos) {
      final a = puntos[completos];
      final b = puntos[completos + 1];
      final f = avance - completos;
      camino.lineTo(a.dx + (b.dx - a.dx) * f, a.dy + (b.dy - a.dy) * f);
    }
    canvas.drawPath(
      camino,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeJoin = StrokeJoin.round
        ..color = colorAmarilloTese.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      camino,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF8A5A00),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorHuevo oldDelegate) =>
      oldDelegate.grietas != grietas;
}

class _PintorRayos extends CustomPainter {
  final Color color;
  final double t;
  const _PintorRayos(this.color, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radio = size.width;
    const n = 12;
    final pintura = Paint()..color = color.withValues(alpha: 0.18);
    for (var i = 0; i < n; i++) {
      final a0 = t * 2 * math.pi + i * (2 * math.pi / n);
      final a1 = a0 + math.pi / n;
      final rayo =
          Path()
            ..moveTo(c.dx, c.dy)
            ..lineTo(c.dx + radio * math.cos(a0), c.dy + radio * math.sin(a0))
            ..lineTo(c.dx + radio * math.cos(a1), c.dy + radio * math.sin(a1))
            ..close();
      canvas.drawPath(rayo, pintura);
    }
    canvas.drawCircle(
      c,
      150,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: 150)),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorRayos oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

// ═══════════════════════ TARJETAS (ruleta y colección) ═══════════════════════

class _TarjetaCinta extends StatelessWidget {
  final PatoSkin skin;
  final Animation<double> reloj;
  final bool activa;
  const _TarjetaCinta({
    required this.skin,
    required this.reloj,
    required this.activa,
  });

  @override
  Widget build(BuildContext context) {
    final color = skin.rareza.color;
    return AnimatedScale(
      scale: activa ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1B3A33), color.withValues(alpha: 0.35)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: activa ? 1 : 0.55),
            width: activa ? 2.5 : 1.5,
          ),
          boxShadow:
              activa
                  ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 18,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PatoVista(skin: skin, reloj: reloj, tamano: 84),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                skin.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CeldaColeccion extends StatelessWidget {
  final PatoSkin skin;
  final int cantidad;
  final Animation<double> reloj;
  const _CeldaColeccion({
    required this.skin,
    required this.cantidad,
    required this.reloj,
  });

  @override
  Widget build(BuildContext context) {
    final tiene = cantidad > 0;
    final color = skin.rareza.color;
    final pato = PatoVista(skin: skin, reloj: reloj, tamano: 100);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tiene ? color : Colors.white12,
          width: tiene ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FittedBox(
                    child:
                        tiene
                            ? pato
                            : ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF0B1B17),
                                BlendMode.srcIn,
                              ),
                              child: pato,
                            ),
                  ),
                ),
                if (cantidad > 1)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x$cantidad',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: colorVerdeOscuro,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            tiene ? skin.nombre : '???',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            skin.rareza.nombre,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════ LA PANTALLA ═════════════════════════════

enum _Fase { reposo, abriendo, girando, revelado }

class PantallaGachapon extends StatefulWidget {
  /// Puntos con los que entra el usuario.
  final int puntos;

  /// Cuántos puntos cuesta abrir un huevo.
  final int costoTirada;

  /// Colección que ya tiene: id del pato -> cuántos tiene.
  final Map<String, int> coleccionInicial;

  /// Se llama con los puntos que quedan después de gastar.
  final ValueChanged<int>? onPuntosCambian;

  /// Se llama al salir un patito (y cuántos tiene ya de ese).
  final void Function(PatoSkin pato, int veces)? onPatoObtenido;

  const PantallaGachapon({
    super.key,
    required this.puntos,
    this.costoTirada = 100,
    this.coleccionInicial = const {},
    this.onPuntosCambian,
    this.onPatoObtenido,
  });

  @override
  State<PantallaGachapon> createState() => _PantallaGachaponState();
}

class _PantallaGachaponState extends State<PantallaGachapon>
    with TickerProviderStateMixin {
  static const double _anchoItem = 120;

  late int _puntos;
  late final Map<String, int> _coleccion;
  _Fase _fase = _Fase.reposo;
  final math.Random _azar = math.Random();

  late final AnimationController _reloj;
  late final AnimationController _huevoCtrl;
  late final AnimationController _destelloCtrl;
  late final ConfettiController _confeti;
  final ScrollController _cinta = ScrollController();
  final ValueNotifier<int> _indiceMarcador = ValueNotifier<int>(-1);

  List<PatoSkin> _itemsCinta = [];
  int _indiceGanador = 0;
  PatoSkin? _ganador;
  bool _esNuevo = false;
  double _anchoVista = 0;
  DateTime _ultimaVibracion = DateTime.now();

  @override
  void initState() {
    super.initState();
    _puntos = widget.puntos;
    _coleccion = Map<String, int>.from(widget.coleccionInicial);
    _reloj = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _huevoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _destelloCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _confeti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _reloj.dispose();
    _huevoCtrl.dispose();
    _destelloCtrl.dispose();
    _confeti.dispose();
    _cinta.dispose();
    _indiceMarcador.dispose();
    super.dispose();
  }

  // ───────── lógica del sorteo ─────────

  Rareza _sortearRareza() {
    final total = Rareza.values.fold<int>(0, (suma, r) => suma + r.peso);
    var tirada = _azar.nextInt(total);
    for (final r in Rareza.values) {
      if (tirada < r.peso) return r;
      tirada -= r.peso;
    }
    return Rareza.comun;
  }

  PatoSkin _sortearSkin() {
    final rareza = _sortearRareza();
    final lista = catalogoPatos.where((s) => s.rareza == rareza).toList();
    return lista[_azar.nextInt(lista.length)];
  }

  void _prepararCinta(PatoSkin ganador) {
    const total = 60;
    _indiceGanador = 50 + _azar.nextInt(4);
    _itemsCinta = List.generate(
      total,
      (i) => i == _indiceGanador ? ganador : _sortearSkin(),
    );
    _indiceMarcador.value = -1;
  }

  // ───────── secuencia de apertura ─────────

  Future<void> _abrirHuevo() async {
    if (_fase != _Fase.reposo || _puntos < widget.costoTirada) return;
    HapticFeedback.mediumImpact();

    // El resultado se decide y se guarda YA; la animación solo lo revela.
    final ganador = _sortearSkin();
    final veces = (_coleccion[ganador.id] ?? 0) + 1;
    _coleccion[ganador.id] = veces;
    _esNuevo = veces == 1;
    _prepararCinta(ganador);

    setState(() {
      _puntos -= widget.costoTirada;
      _ganador = ganador;
      _fase = _Fase.abriendo;
    });
    widget.onPuntosCambian?.call(_puntos);
    widget.onPatoObtenido?.call(ganador, veces);

    for (var i = 0; i < 5; i++) {
      Future.delayed(
        Duration(milliseconds: 260 * i),
        HapticFeedback.lightImpact,
      );
    }

    await _huevoCtrl.forward(from: 0);
    if (!mounted) return;
    await _destelloCtrl.forward(from: 0);
    if (!mounted) return;
    setState(() => _fase = _Fase.girando);
    _destelloCtrl.reverse();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _girarCinta();
  }

  Future<void> _girarCinta() async {
    if (_cinta.hasClients) _cinta.jumpTo(0);
    final vista =
        _anchoVista > 0 ? _anchoVista : MediaQuery.of(context).size.width;
    final jitter = (_azar.nextDouble() - 0.5) * _anchoItem * 0.7;
    final destino =
        _indiceGanador * _anchoItem + _anchoItem / 2 - vista / 2 + jitter;

    _cinta.addListener(_alMoverCinta);
    await _cinta.animateTo(
      destino,
      duration: const Duration(milliseconds: 7500),
      curve: Curves.easeOutQuart,
    );
    _cinta.removeListener(_alMoverCinta);
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    _revelar();
  }

  // "tic tic tic" cada vez que un patito pasa por la marca central
  void _alMoverCinta() {
    if (!_cinta.hasClients) return;
    final vista = _anchoVista > 0 ? _anchoVista : 360.0;
    final indice = ((_cinta.offset + vista / 2) / _anchoItem).floor();
    if (indice != _indiceMarcador.value) {
      _indiceMarcador.value = indice;
      final ahora = DateTime.now();
      if (ahora.difference(_ultimaVibracion).inMilliseconds > 45) {
        HapticFeedback.selectionClick();
        _ultimaVibracion = ahora;
      }
    }
  }

  void _revelar() {
    HapticFeedback.heavyImpact();
    if (_ganador?.rareza == Rareza.legendaria) HapticFeedback.vibrate();
    _confeti.play();
    setState(() => _fase = _Fase.revelado);
  }

  void _volverAlHuevo() {
    _huevoCtrl.value = 0;
    _destelloCtrl.value = 0;
    _indiceMarcador.value = -1;
    setState(() {
      _fase = _Fase.reposo;
      _ganador = null;
    });
  }

  void _mostrarColeccion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            height: MediaQuery.of(ctx).size.height * 0.78,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: const BoxDecoration(
              color: Color(0xFF16352E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Mi colección · ${_coleccion.length}/${catalogoPatos.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.78,
                        ),
                    itemCount: catalogoPatos.length,
                    itemBuilder:
                        (_, i) => _CeldaColeccion(
                          skin: catalogoPatos[i],
                          cantidad: _coleccion[catalogoPatos[i].id] ?? 0,
                          reloj: _reloj,
                        ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ───────── construcción de la pantalla ─────────

  @override
  Widget build(BuildContext context) {
    final glow =
        (_fase == _Fase.revelado && _ganador != null)
            ? _ganador!.rareza.color
            : colorSalvia;
    final puedeVerColeccion = _fase == _Fase.reposo || _fase == _Fase.revelado;
    final rareza = _ganador?.rareza;
    final particulas =
        rareza == Rareza.legendaria
            ? 70
            : (rareza != null && rareza.index >= 2 ? 40 : 22);

    return Scaffold(
      backgroundColor: colorVerdeOscuro,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Gachapón de Patitos',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions:
            puedeVerColeccion
                ? [
                  TextButton.icon(
                    onPressed: _mostrarColeccion,
                    icon: const Icon(
                      Icons.collections_bookmark_rounded,
                      color: colorAmarilloTese,
                      size: 20,
                    ),
                    label: Text(
                      '${_coleccion.length}/${catalogoPatos.length}',
                      style: GoogleFonts.poppins(
                        color: colorAmarilloTese,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
                : null,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.0,
                  colors: [glow.withValues(alpha: 0.28), colorVerdeOscuro],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _contenido(),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _destelloCtrl,
                builder:
                    (context, _) => Opacity(
                      opacity: _destelloCtrl.value,
                      child: Container(color: Colors.white),
                    ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.3),
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confeti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: particulas,
                gravity: 0.25,
                emissionFrequency: 0.05,
                colors: [
                  rareza?.color ?? colorAmarilloTese,
                  Colors.white,
                  colorAmarilloTese,
                  colorRosa,
                  colorSalvia,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    switch (_fase) {
      case _Fase.reposo:
      case _Fase.abriendo:
        return KeyedSubtree(key: const ValueKey('huevo'), child: _vistaHuevo());
      case _Fase.girando:
        return KeyedSubtree(key: const ValueKey('cinta'), child: _vistaCinta());
      case _Fase.revelado:
        return KeyedSubtree(
          key: const ValueKey('revelado'),
          child: _vistaRevelado(),
        );
    }
  }

  Widget _pildoraPuntos() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorAmarilloTese.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, color: colorAmarilloTese, size: 22),
          const SizedBox(width: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: _puntos, end: _puntos),
            duration: const Duration(milliseconds: 900),
            builder:
                (context, valor, _) => Text(
                  '$valor pts',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // ───────── fase 1: el huevo ─────────

  Widget _vistaHuevo() {
    final alcanza = _puntos >= widget.costoTirada;
    final reposo = _fase == _Fase.reposo;
    return Column(
      children: [
        const SizedBox(height: 10),
        _pildoraPuntos(),
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_reloj, _huevoCtrl]),
              builder: (context, _) {
                final t = _reloj.value;
                final s = Curves.easeIn.transform(_huevoCtrl.value);
                final flotar = math.sin(t * 2 * math.pi) * 8 * (1 - s);
                final giro =
                    math.sin(_huevoCtrl.value * math.pi * 16) * 0.24 * s +
                    math.sin(t * 4 * math.pi) * 0.03 * (1 - s);
                return Transform.translate(
                  offset: Offset(0, flotar),
                  child: Transform.rotate(
                    angle: giro,
                    child: Transform.scale(
                      scale: 1 + 0.12 * s,
                      child: _huevo(s),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final r in Rareza.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: r.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${r.nombre} ${r.peso}%',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: (reposo && alcanza) ? _abrirHuevo : null,
              icon: const Icon(Icons.egg_alt),
              label: Text(
                'Abrir huevo · ${widget.costoTirada} pts',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAmarilloTese,
                foregroundColor: colorVerdeOscuro,
                disabledBackgroundColor: Colors.white12,
                disabledForegroundColor: Colors.white38,
                elevation: 8,
                shadowColor: colorAmarilloTese.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          alcanza
              ? 'Cada pedido que haces suma puntos 🦆'
              : 'Te faltan ${widget.costoTirada - _puntos} puntos. ¡Sigue pidiendo!',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _huevo(double s) {
    return SizedBox(
      width: 230,
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorAmarilloTese.withValues(alpha: 0.30 + 0.35 * s),
                  blurRadius: 70 + 50 * s,
                  spreadRadius: 12 + 20 * s,
                ),
              ],
            ),
          ),
          CustomPaint(size: const Size(180, 235), painter: _PintorHuevo(s)),
          Text(
            '?',
            style: GoogleFonts.poppins(
              fontSize: 88,
              fontWeight: FontWeight.w900,
              color: colorVerdeTese.withValues(alpha: 0.35 * (1 - s)),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── fase 2: la ruleta ─────────

  Widget _desvanecido(bool izquierda) {
    return Container(
      width: 70,
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: izquierda ? Alignment.centerLeft : Alignment.centerRight,
          end: izquierda ? Alignment.centerRight : Alignment.centerLeft,
          colors: [colorVerdeOscuro, colorVerdeOscuro.withValues(alpha: 0)],
        ),
      ),
    );
  }

  Widget _vistaCinta() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pildoraPuntos(),
        const SizedBox(height: 28),
        Text(
          '¡Abriendo el huevo!',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¿Qué patito saldrá?',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          height: 190,
          child: LayoutBuilder(
            builder: (context, c) {
              _anchoVista = c.maxWidth;
              return Stack(
                children: [
                  ListView.builder(
                    controller: _cinta,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemExtent: _anchoItem,
                    itemCount: _itemsCinta.length,
                    itemBuilder:
                        (context, i) => ValueListenableBuilder<int>(
                          valueListenable: _indiceMarcador,
                          builder:
                              (context, activo, _) => _TarjetaCinta(
                                skin: _itemsCinta[i],
                                reloj: _reloj,
                                activa: activo == i,
                              ),
                        ),
                  ),
                  IgnorePointer(
                    child: Row(
                      children: [
                        _desvanecido(true),
                        const Spacer(),
                        _desvanecido(false),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 3,
                      height: 190,
                      decoration: BoxDecoration(
                        color: colorAmarilloTese,
                        boxShadow: [
                          BoxShadow(
                            color: colorAmarilloTese.withValues(alpha: 0.8),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 44,
                      color: colorAmarilloTese,
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      Icons.arrow_drop_up_rounded,
                      size: 44,
                      color: colorAmarilloTese,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ───────── fase 3: la revelación ─────────

  Widget _etiquetaRareza(PatoSkin pato) {
    final c = pato.rareza.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c, _ajustarLuz(c, 0.12)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 16)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i <= pato.rareza.index; i++)
            const Icon(Icons.star_rounded, size: 16, color: colorVerdeOscuro),
          const SizedBox(width: 6),
          Text(
            pato.rareza.nombre.toUpperCase(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 2,
              color: colorVerdeOscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vistaRevelado() {
    final pato = _ganador!;
    final color = pato.rareza.color;
    final alcanza = _puntos >= widget.costoTirada;
    final veces = _coleccion[pato.id] ?? 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _reloj,
                    builder:
                        (context, _) => CustomPaint(
                          painter: _PintorRayos(color, _reloj.value),
                        ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.elasticOut,
                  builder:
                      (context, v, child) =>
                          Transform.scale(scale: v, child: child),
                  child: AnimatedBuilder(
                    animation: _reloj,
                    builder:
                        (context, child) => Transform.translate(
                          offset: Offset(
                            0,
                            math.sin(_reloj.value * 2 * math.pi) * 9,
                          ),
                          child: child,
                        ),
                    child: PatoVista(skin: pato, reloj: _reloj, tamano: 230),
                  ),
                ),
              ],
            ),
          ),
          _etiquetaRareza(pato),
          const SizedBox(height: 12),
          Text(
            pato.nombre,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pato.frase,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color:
                  _esNuevo
                      ? colorAmarilloTese
                      : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _esNuevo ? '¡NUEVO EN TU COLECCIÓN!' : 'Ya lo tenías · x$veces',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _esNuevo ? colorVerdeOscuro : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _mostrarColeccion,
                  icon: const Icon(Icons.collections_bookmark_rounded),
                  label: Text(
                    'Colección',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _volverAlHuevo,
                  icon: const Icon(Icons.egg_alt),
                  label: Text(
                    alcanza ? 'Otro huevo' : 'Listo',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAmarilloTese,
                    foregroundColor: colorVerdeOscuro,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
