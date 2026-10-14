import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colores.dart';

// ═════════════════════════════ UNIVERSOS Y RAREZAS ═════════════════════════════

enum UniversoPato { tese, marvel, leyendas, especiales }

extension UniversoInfo on UniversoPato {
  String get nombre => switch (this) {
    UniversoPato.tese => 'Carreras TESE',
    UniversoPato.marvel => 'Héroes & Cómics',
    UniversoPato.leyendas => 'Anime & Ídolos',
    UniversoPato.especiales => 'Míticos & Clásicos',
  };

  String get emoji => switch (this) {
    UniversoPato.tese => '🎓',
    UniversoPato.marvel => '🕷️',
    UniversoPato.leyendas => '🎸',
    UniversoPato.especiales => '✨',
  };

  Color get colorTema => switch (this) {
    UniversoPato.tese => const Color(0xFF00E5A3),
    UniversoPato.marvel => const Color(0xFFFF3864),
    UniversoPato.leyendas => const Color(0xFFFFB800),
    UniversoPato.especiales => const Color(0xFFB56BFF),
  };
}

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
    Rareza.comun => const Color(0xFF7AE582),
    Rareza.rara => const Color(0xFF38B6FF),
    Rareza.epica => const Color(0xFFB56BFF),
    Rareza.mitica => const Color(0xFFFF4D8D),
    Rareza.legendaria => const Color(0xFFFFD13B),
  };

  int get peso => switch (this) {
    Rareza.comun => 42,
    Rareza.rara => 28,
    Rareza.epica => 16,
    Rareza.mitica => 9,
    Rareza.legendaria => 5,
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
  pilotoInsulini,
  spiderman,
  ironman,
  wolverine,
  deadpool,
  cascoIng,
  visorSistemas,
  visorMeca,
  lentesQuimica,
  bocchiRock,
  gojoAnime,
  saiyajin,
  venom,
  batman,
  streamerRgb,
}

enum EfectoCuerpo { ninguno, galaxia, arcoiris, oro, diamante }

class PatoSkin {
  final String id;
  final String nombre;
  final String frase;
  final Rareza rareza;
  final UniversoPato universo;
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
    this.universo = UniversoPato.especiales,
    required this.cuerpo,
    this.cuerpo2,
    this.pico = const Color(0xFFFF9F1C),
    this.efecto = EfectoCuerpo.ninguno,
    this.accesorio = Accesorio.ninguno,
  });

  bool get brilla =>
      efecto == EfectoCuerpo.oro || efecto == EfectoCuerpo.diamante;
}

// ═════════════════════════ CATÁLOGO DE 32 PATITOS HD ═════════════════════════

const List<PatoSkin> catalogoPatos = [
  // 0: Clásico
  PatoSkin(
    id: 'clasico',
    nombre: 'Patito Clásico',
    frase: 'El de toda la vida. Redondito, tierno y nunca falla en el receso.',
    rareza: Rareza.comun,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFFFD84D),
  ),
  // 1: Estudiante (Default inicial)
  PatoSkin(
    id: 'estudiante',
    nombre: 'Patito Estudiante TESE',
    frase: 'Se graduó con honores... pero de pedir tortas sin fila.',
    rareza: Rareza.comun,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFFFFD84D),
    accesorio: Accesorio.birrete,
  ),
  // 2: Matcha
  PatoSkin(
    id: 'matcha',
    nombre: 'Patito Matcha Latte',
    frase: 'Fresco, estético, zen y sin prisa para entrar al laboratorio.',
    rareza: Rareza.comun,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFB7E08C),
    cuerpo2: Color(0xFF86EFAC),
  ),
  // 3: Chicle
  PatoSkin(
    id: 'chicle',
    nombre: 'Patito Frappe Rosa',
    frase: 'Dulce, esponjoso y siempre pide postre después de comer.',
    rareza: Rareza.comun,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFFFB3D1),
    cuerpo2: Color(0xFFF472B6),
  ),
  // 4: Chef
  PatoSkin(
    id: 'chef',
    nombre: 'Master Chef Patito',
    frase: 'Sus chilaquiles del kiosko tienen estrella Michelin.',
    rareza: Rareza.rara,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFFFFF3D6),
    accesorio: Accesorio.gorroChef,
  ),
  // 5: Hielo
  PatoSkin(
    id: 'hielo',
    nombre: 'Patito Lo-Fi Beats',
    frase: 'Su playlist relaja hasta en semana de proyectos finales.',
    rareza: Rareza.rara,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFA8DCFF),
    cuerpo2: Color(0xFF60A5FA),
    accesorio: Accesorio.auriculares,
  ),
  // 6: Cool
  PatoSkin(
    id: 'cool',
    nombre: 'Patito Fachero',
    frase: 'Trae lentes oscuros hasta cuando está nublado en Ecatepec.',
    rareza: Rareza.rara,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFFFA94D),
    accesorio: Accesorio.lentes,
  ),
  // 7: Ninja
  PatoSkin(
    id: 'ninja',
    nombre: 'Patito Shinobi',
    frase: 'Usa el jutsu de clonación para no hacer fila en la cafetería.',
    rareza: Rareza.rara,
    universo: UniversoPato.leyendas,
    cuerpo: Color(0xFF3A3A48),
    accesorio: Accesorio.ninja,
  ),
  // 8: Pirata
  PatoSkin(
    id: 'pirata',
    nombre: 'Capitán Barba Pato',
    frase: 'Navega los siete mares buscando la última mesa con sombra.',
    rareza: Rareza.epica,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFE76F51),
    accesorio: Accesorio.pirata,
  ),
  // 9: Mago
  PatoSkin(
    id: 'mago',
    nombre: 'Patito Hechicero Supremo',
    frase: 'Hace aparecer sincronizadas y pasar Cálculo con 10.',
    rareza: Rareza.epica,
    universo: UniversoPato.leyendas,
    cuerpo: Color(0xFF9B7BFF),
    cuerpo2: Color(0xFF6D28D9),
    accesorio: Accesorio.mago,
  ),
  // 10: Patonauta
  PatoSkin(
    id: 'astronauta',
    nombre: 'Pato Ing. Aeronáutico',
    frase: 'Orgullo de Aeronáutica del TESE rumbo a la estratósfera.',
    rareza: Rareza.epica,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFFF1F5F9),
    cuerpo2: Color(0xFF94A3B8),
    accesorio: Accesorio.casco,
  ),
  // 11: Galaxia
  PatoSkin(
    id: 'galaxia',
    nombre: 'Pato Cósmico Nebulosa',
    frase: 'Forjado del polvo de estrellas a la hora del almuerzo.',
    rareza: Rareza.mitica,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFF2D1B69),
    cuerpo2: Color(0xFF7B4DE0),
    pico: Color(0xFFFFC857),
    efecto: EfectoCuerpo.galaxia,
  ),
  // 12: Arcoíris
  PatoSkin(
    id: 'arcoiris',
    nombre: 'Pato Chroma RGB',
    frase: 'Corre a 240Hz con iluminación dinámica en cada pluma.',
    rareza: Rareza.mitica,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFF6BC5FF),
    efecto: EfectoCuerpo.arcoiris,
    accesorio: Accesorio.lentes,
  ),
  // 13: Pato Dorado
  PatoSkin(
    id: 'oro',
    nombre: 'Emperador Pato Dorado',
    frase: 'Leyenda de 24 quilates del TESE. Da buena suerte en los exámenes.',
    rareza: Rareza.legendaria,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFFFD54A),
    cuerpo2: Color(0xFFE09A00),
    pico: Color(0xFFFF7A00),
    efecto: EfectoCuerpo.oro,
    accesorio: Accesorio.corona,
  ),
  // 14: Pato Diamante
  PatoSkin(
    id: 'diamante',
    nombre: 'Pato Diamante Celestial',
    frase: 'Brilla tanto que ilumina todo el edificio de Sistemas.',
    rareza: Rareza.legendaria,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFBDF3FF),
    cuerpo2: Color(0xFFFFC2F0),
    efecto: EfectoCuerpo.diamante,
    accesorio: Accesorio.casco,
  ),

  // ── LEYENDAS, ANIME & STREAMERS ──
  PatoSkin(
    id: 'insulini',
    nombre: 'Pato Insulini Piloto',
    frase:
        '¡Del TESE para el mundo! Con casco de aviador, goggles y cero miedo.',
    rareza: Rareza.legendaria,
    universo: UniversoPato.leyendas,
    cuerpo: Color(0xFFFFDF6B),
    cuerpo2: Color(0xFFF4A261),
    efecto: EfectoCuerpo.oro,
    accesorio: Accesorio.pilotoInsulini,
  ),
  PatoSkin(
    id: 'rockstar_rosa',
    nombre: 'Bocchi-Pato Guitarrista',
    frase:
        'Le da ansiedad hacer fila, por eso pide desde la app mientras toca un solo épico.',
    rareza: Rareza.legendaria,
    universo: UniversoPato.leyendas,
    cuerpo: Color(0xFFFF9EBB),
    cuerpo2: Color(0xFFFF6B9D),
    efecto: EfectoCuerpo.diamante,
    accesorio: Accesorio.bocchiRock,
  ),
  PatoSkin(
    id: 'gojo_pato',
    nombre: 'Pato Hechicero Infinito',
    frase: 'Expansión de Dominio: ¡Cafetería sin Filas Infinita! 🤞✨',
    rareza: Rareza.mitica,
    universo: UniversoPato.leyendas,
    cuerpo: Color(0xFF1E1B4B),
    cuerpo2: Color(0xFF312E81),
    pico: Color(0xFF38BDF8),
    efecto: EfectoCuerpo.galaxia,
    accesorio: Accesorio.gojoAnime,
  ),
  PatoSkin(
    id: 'saiyajin_pato',
    nombre: 'Pato Súper Saiyajin',
    frase:
        '¡Su nivel de hambre supera los 9,000 después de 4 horas de laboratorio!',
    rareza: Rareza.mitica,
    universo: UniversoPato.leyendas,
    cuerpo: Color(0xFFF97316),
    cuerpo2: Color(0xFF1D4ED8),
    efecto: EfectoCuerpo.oro,
    accesorio: Accesorio.saiyajin,
  ),
  PatoSkin(
    id: 'streamer_pato',
    nombre: 'Pato Streamer Pro',
    frase: 'Prende stream en Twitch mientras espera el ¡CUAC! de su pedido.',
    rareza: Rareza.epica,
    universo: UniversoPato.leyendas,
    cuerpo: Color(0xFF8B5CF6),
    cuerpo2: Color(0xFFEC4899),
    accesorio: Accesorio.streamerRgb,
  ),

  // ── UNIVERSO HÉROES & CÓMICS (MARVEL / DC) ──
  PatoSkin(
    id: 'spider_pato',
    nombre: 'Spidey-Pato',
    frase:
        'Tu vecino amigable del TESE. Atrapa su torta con telaraña desde el segundo piso.',
    rareza: Rareza.mitica,
    universo: UniversoPato.marvel,
    cuerpo: Color(0xFFE62429),
    cuerpo2: Color(0xFF1D4ED8),
    pico: Color(0xFFFFB703),
    accesorio: Accesorio.spiderman,
  ),
  PatoSkin(
    id: 'iron_pato',
    nombre: 'Iron-Pato Mark LXXXV',
    frase:
        'Genio, millonario y con Reactor Arc para mantener calientes sus chilaquiles.',
    rareza: Rareza.legendaria,
    universo: UniversoPato.marvel,
    cuerpo: Color(0xFFB91C1C),
    cuerpo2: Color(0xFFF59E0B),
    pico: Color(0xFFFBBF24),
    efecto: EfectoCuerpo.oro,
    accesorio: Accesorio.ironman,
  ),
  PatoSkin(
    id: 'venom_pato',
    nombre: 'Venom-Pato Simbionte',
    frase: '¡NOSOTROS TENEMOS HAMBRE! Y queremos unos tacos con todo.',
    rareza: Rareza.mitica,
    universo: UniversoPato.marvel,
    cuerpo: Color(0xFF18181B),
    cuerpo2: Color(0xFF3F3F46),
    pico: Color(0xFFF43F5E),
    accesorio: Accesorio.venom,
  ),
  PatoSkin(
    id: 'bati_pato',
    nombre: 'Bati-Pato Nocturno',
    frase:
        'Vigila el Kiosko de Sistemas desde las sombras. ¡Yo soy la venganza!',
    rareza: Rareza.epica,
    universo: UniversoPato.marvel,
    cuerpo: Color(0xFF1F2937),
    cuerpo2: Color(0xFF111827),
    pico: Color(0xFFFACC15),
    accesorio: Accesorio.batman,
  ),
  PatoSkin(
    id: 'wolverine_pato',
    nombre: 'Pato Wolverine X',
    frase: 'Garras de Adamantium listas para partir la milanesa, bub.',
    rareza: Rareza.epica,
    universo: UniversoPato.marvel,
    cuerpo: Color(0xFFFACC15),
    cuerpo2: Color(0xFF1E3A8A),
    accesorio: Accesorio.wolverine,
  ),
  PatoSkin(
    id: 'dead_pato',
    nombre: 'Dead-Pato Mercenario',
    frase:
        'Rompe la cuarta pared mientras pide unas chimichangas en la cafetería.',
    rareza: Rareza.epica,
    universo: UniversoPato.marvel,
    cuerpo: Color(0xFFDC2626),
    cuerpo2: Color(0xFF18181B),
    accesorio: Accesorio.deadpool,
  ),
  PatoSkin(
    id: 'hulk_pato',
    nombre: 'Hulk-Pato Radiactivo',
    frase: '¡PATO APLASTA EL HAMBRE! Siempre pide doble porción de arroz.',
    rareza: Rareza.rara,
    universo: UniversoPato.marvel,
    cuerpo: Color(0xFF4ADE80),
    cuerpo2: Color(0xFF7E22CE),
    accesorio: Accesorio.ninja,
  ),

  // ── UNIVERSO CARRERAS DEL TESE ──
  PatoSkin(
    id: 'ing_sistemas',
    nombre: 'Pato Ing. en Computación',
    frase:
        'Su código compila a la primera gracias a una torta y un café bien cargado.',
    rareza: Rareza.epica,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFF1E293B),
    cuerpo2: Color(0xFF0F172A),
    pico: Color(0xFF00F5D4),
    accesorio: Accesorio.visorSistemas,
  ),
  PatoSkin(
    id: 'ing_mecatronica',
    nombre: 'Pato Ing. Mecatrónico',
    frase: 'Mitad patito, mitad ESP32-S3 con sensores láser de proximidad.',
    rareza: Rareza.epica,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFF94A3B8),
    cuerpo2: Color(0xFF475569),
    pico: Color(0xFFFF6B35),
    accesorio: Accesorio.visorMeca,
  ),
  PatoSkin(
    id: 'ing_industrial',
    nombre: 'Pato Ing. Industrial',
    frase: 'Optimiza las filas del receso con Six Sigma y casco de seguridad.',
    rareza: Rareza.rara,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFF60A5FA),
    cuerpo2: Color(0xFF2563EB),
    accesorio: Accesorio.cascoIng,
  ),
  PatoSkin(
    id: 'ing_quimica',
    nombre: 'Pato Ing. Químico / Bioquímico',
    frase: 'Sintetizó en el laboratorio la fórmula de la salsa verde perfecta.',
    rareza: Rareza.rara,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFFA7F3D0),
    cuerpo2: Color(0xFF10B981),
    accesorio: Accesorio.lentesQuimica,
  ),
  PatoSkin(
    id: 'conta_gestion',
    nombre: 'Pato Ejecutivo / Gestión',
    frase: 'Administra sus puntos del Gachapón con mentalidad de tiburón.',
    rareza: Rareza.comun,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFFFDE047),
    cuerpo2: Color(0xFFEAB308),
    accesorio: Accesorio.lentes,
  ),
];

Color _ajustarLuz(Color c, double delta) {
  final hsl = HSLColor.fromColor(c);
  final luz = math.max(0.0, math.min(1.0, hsl.lightness + delta));
  return hsl.withLightness(luz).toColor();
}

// ═════════════════════ EL PATITO HD CON ANIMACIÓN VIVA ═════════════════════

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
    Offset(24, 42),
    Offset(178, 56),
    Offset(18, 138),
    Offset(184, 148),
    Offset(100, 8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = reloj.value;
    final bool animado = reloj != kAlwaysCompleteAnimation;

    // 🦆 Animación orgánica de respiración (squash & stretch) y aleteo
    final double ondaResp = animado ? math.sin(t * 2 * math.pi) : 0.0;
    final double ondaAla = animado ? math.sin(t * 4 * math.pi) * 0.14 : 0.0;
    // Parpadeo suave cuando el ciclo pasa cerca de 0.92
    final bool parpadeando = animado && (t > 0.90 && t < 0.96);

    canvas.save();
    canvas.scale(size.width / 200, size.height / 200);
    const area = Rect.fromLTWH(0, 0, 200, 200);

    // 1. Pedestal holográfico + Sombra suave en el piso
    final colorRareza = skin.rareza.color;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 192),
        width: 128 - ondaResp * 6,
        height: 16,
      ),
      Paint()..color = colorRareza.withValues(alpha: 0.25),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 192),
        width: 112 - ondaResp * 4,
        height: 11,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );

    // 2. Patitas esculpidas con deditos
    final pataPaint = Paint()..color = skin.pico;
    final pataBorde =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = _ajustarLuz(skin.pico, -0.2);
    for (final px in const [74.0, 126.0]) {
      final rectPata = Rect.fromCenter(
        center: Offset(px, 187),
        width: 32,
        height: 15,
      );
      canvas.drawOval(rectPata, pataPaint);
      canvas.drawOval(rectPata, pataBorde);
    }

    // Aplicamos el rebote de respiración al cuerpo y cabeza
    canvas.save();
    canvas.translate(0, -ondaResp * 2.8);

    final relleno = _relleno(area, t);
    final contorno =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..color = _ajustarLuz(skin.cuerpo, -0.25);
    final alaPintura = Paint()..color = _ajustarLuz(skin.cuerpo, -0.05);

    canvas.saveLayer(area, Paint());

    // 3. Cuerpo redondito + Pancita suave 3D
    final cuerpo = Rect.fromCenter(
      center: const Offset(100, 140),
      width: 142 + ondaResp * 2,
      height: 100 - ondaResp * 1.5,
    );
    canvas.drawOval(cuerpo, relleno);

    // Parche de pancita más clarito para darle volumen kawaii
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 147), width: 92, height: 66),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.drawOval(cuerpo, contorno);

    // 4. Alitas con aleteo vivo
    _ala(canvas, const Offset(39, 141), -0.45 + ondaAla, alaPintura, contorno);
    _ala(canvas, const Offset(161, 141), 0.45 - ondaAla, alaPintura, contorno);

    // 5. Cabeza + Brillo especular tipo figura de colección
    final cabeza = Rect.fromCircle(center: const Offset(100, 82), radius: 62);
    canvas.drawOval(cabeza, relleno);

    // Brillo suave en la frente izquierda
    canvas.save();
    canvas.translate(74, 46);
    canvas.rotate(-0.45);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 34, height: 16),
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );
    canvas.restore();

    canvas.drawOval(cabeza, contorno);

    // 6. Mechón despeinado doble
    final mechon =
        Path()
          ..moveTo(94, 22)
          ..quadraticBezierTo(86, 3, 107, 4)
          ..quadraticBezierTo(102, 12, 108, 22)
          ..quadraticBezierTo(116, 8, 122, 14)
          ..quadraticBezierTo(114, 20, 106, 25)
          ..close();
    canvas.drawPath(mechon, relleno);
    canvas.drawPath(mechon, contorno);

    if (skin.efecto == EfectoCuerpo.galaxia) _estrellasCuerpo(canvas, t);
    if (skin.brilla) _brilloBarrido(canvas, t);
    canvas.restore();

    // 7. Cara kawaii (con parpadeo) + Accesorios temáticos
    _cara(canvas, parpadeando);
    _accesorio(canvas, t);

    canvas.restore(); // Fin de transformación de respiración

    if (skin.rareza == Rareza.legendaria || skin.rareza == Rareza.mitica) {
      _destellos(canvas, t);
    }
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
        colors: [_ajustarLuz(skin.cuerpo, 0.08), skin.cuerpo, skin.cuerpo2!],
      ).createShader(area);
    } else {
      p.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _ajustarLuz(skin.cuerpo, 0.12),
          skin.cuerpo,
          _ajustarLuz(skin.cuerpo, -0.10),
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
    final r = Rect.fromCenter(center: Offset.zero, width: 32, height: 58);
    canvas.drawOval(r, relleno);
    canvas.drawOval(r, contorno);
    canvas.restore();
  }

  void _brilloBarrido(Canvas canvas, double t) {
    final x = -70 + 340 * t;
    final banda =
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + 38, 0)
          ..lineTo(x - 22, 200)
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
        1.8 + (i % 3) * 0.7,
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

  void _cara(Canvas canvas, bool parpadeando) {
    // Chapetes rositas kawaii con brillito
    final rubor =
        Paint()..color = const Color(0xFFFF7597).withValues(alpha: 0.55);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(56, 99), width: 22, height: 13),
      rubor,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(144, 99), width: 22, height: 13),
      rubor,
    );

    // Ojos expresivos estilo anime (o cerrados felices al parpadear)
    final ojoNegro = Paint()..color = const Color(0xFF14141F);
    final luzBlanca = Paint()..color = Colors.white;
    for (final c in const [Offset(74, 80), Offset(126, 80)]) {
      if (parpadeando) {
        final arcoOjo =
            Paint()
              ..color = const Color(0xFF14141F)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5
              ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCenter(center: c, width: 16, height: 10),
          math.pi,
          math.pi,
          false,
          arcoOjo,
        );
      } else {
        canvas.drawCircle(c, 8.8, ojoNegro);
        // Brillo principal grande + brillo secundario abajo
        canvas.drawCircle(c.translate(-2.6, -2.8), 3.2, luzBlanca);
        canvas.drawCircle(c.translate(2.4, 2.6), 1.5, luzBlanca);
      }
    }

    // Pico 3D con sonrisa tierna y brillito superior
    final picoInf = Rect.fromCenter(
      center: const Offset(100, 104),
      width: 34,
      height: 18,
    );
    canvas.drawOval(picoInf, Paint()..color = _ajustarLuz(skin.pico, -0.12));

    final picoSup = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(100, 98), width: 48, height: 22),
      const Radius.circular(12),
    );
    canvas.drawRRect(picoSup, Paint()..color = skin.pico);
    canvas.drawRRect(
      picoSup,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _ajustarLuz(skin.pico, -0.20),
    );
    // Brillo en la punta del pico
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(95, 92), width: 18, height: 5),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  void _accesorio(Canvas canvas, double t) {
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
      case Accesorio.pilotoInsulini:
        _pilotoInsulini(canvas);
      case Accesorio.spiderman:
        _spiderman(canvas);
      case Accesorio.ironman:
        _ironman(canvas);
      case Accesorio.wolverine:
        _wolverine(canvas);
      case Accesorio.deadpool:
        _deadpool(canvas);
      case Accesorio.cascoIng:
        _cascoIng(canvas);
      case Accesorio.visorSistemas:
        _visorSistemas(canvas);
      case Accesorio.visorMeca:
        _visorMeca(canvas);
      case Accesorio.lentesQuimica:
        _lentesQuimica(canvas);
      case Accesorio.bocchiRock:
        _bocchiRock(canvas);
      case Accesorio.gojoAnime:
        _gojoAnime(canvas);
      case Accesorio.saiyajin:
        _saiyajin(canvas);
      case Accesorio.venom:
        _venom(canvas);
      case Accesorio.batman:
        _batman(canvas);
      case Accesorio.streamerRgb:
        _streamerRgb(canvas, t);
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
      Rect.fromCenter(center: const Offset(74, 80), width: 40, height: 28),
      const Radius.circular(9),
    );
    final der = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(126, 80), width: 40, height: 28),
      const Radius.circular(9),
    );
    final armazon =
        Paint()
          ..color = negro
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(94, 78), const Offset(106, 78), armazon);
    canvas.drawLine(const Offset(54, 78), const Offset(38, 74), armazon);
    canvas.drawLine(const Offset(146, 78), const Offset(162, 74), armazon);
    canvas.drawRRect(izq, Paint()..color = negro);
    canvas.drawRRect(der, Paint()..color = negro);
    final destello =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(62, 73), const Offset(72, 69), destello);
    canvas.drawLine(const Offset(114, 73), const Offset(124, 69), destello);
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
          ..lineTo(56, 12)
          ..lineTo(80, 30)
          ..lineTo(100, 4)
          ..lineTo(120, 30)
          ..lineTo(144, 12)
          ..lineTo(140, 46)
          ..close();
    canvas.drawPath(corona, dorado);
    canvas.drawCircle(
      const Offset(100, 32),
      5.5,
      Paint()..color = const Color(0xFFFF4D6D),
    );
    canvas.drawCircle(
      const Offset(76, 38),
      4,
      Paint()..color = const Color(0xFF38BDF8),
    );
    canvas.drawCircle(
      const Offset(124, 38),
      4,
      Paint()..color = const Color(0xFF38BDF8),
    );
  }

  void _casco(Canvas canvas) {
    const c = Offset(100, 80);
    canvas.drawCircle(
      c,
      68,
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      c,
      68,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.white.withValues(alpha: 0.8),
    );
    final collar = RRect.fromRectAndRadius(
      const Rect.fromLTRB(36, 128, 164, 150),
      const Radius.circular(10),
    );
    canvas.drawRRect(collar, Paint()..color = const Color(0xFFC9D3DB));
  }

  void _mago(Canvas canvas) {
    final cono =
        Path()
          ..moveTo(56, 46)
          ..quadraticBezierTo(84, 22, 104, 2)
          ..quadraticBezierTo(114, 22, 144, 46)
          ..close();
    canvas.drawPath(cono, Paint()..color = const Color(0xFF5B3FD0));
    final ala = Rect.fromCenter(
      center: const Offset(100, 46),
      width: 128,
      height: 20,
    );
    canvas.drawOval(ala, Paint()..color = const Color(0xFF4B2FC0));
    canvas.drawCircle(
      const Offset(96, 26),
      3.5,
      Paint()..color = const Color(0xFFFFD13B),
    );
    canvas.drawCircle(
      const Offset(112, 35),
      2.5,
      Paint()..color = const Color(0xFFFFD13B),
    );
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
    }
  }

  void _ninja(Canvas canvas) {
    final rojo = Paint()..color = const Color(0xFFD62828);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(38, 48, 162, 66),
        const Radius.circular(6),
      ),
      rojo,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(100, 57), width: 38, height: 13),
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
    canvas.drawCircle(const Offset(74, 80), 12, negro);
  }

  void _pilotoInsulini(Canvas canvas) {
    final cuero = Paint()..color = const Color(0xFF6B3E26);
    final cueroOsc = Paint()..color = const Color(0xFF4A2816);
    final borrega = Paint()..color = const Color(0xFFF5EBE1);

    canvas.drawArc(
      Rect.fromCircle(center: const Offset(100, 74), radius: 64),
      math.pi * 1.02,
      math.pi * 0.96,
      true,
      cuero,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(34, 58, 52, 108),
        const Radius.circular(10),
      ),
      cueroOsc,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(148, 58, 166, 108),
        const Radius.circular(10),
      ),
      cueroOsc,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(50, 38, 150, 56),
        const Radius.circular(8),
      ),
      borrega,
    );
    canvas.drawRect(const Rect.fromLTRB(40, 42, 160, 50), cueroOsc);
    for (final x in const [76.0, 124.0]) {
      canvas.drawCircle(
        Offset(x, 45),
        16,
        Paint()..color = const Color(0xFFD97706),
      );
      canvas.drawCircle(
        Offset(x, 45),
        12,
        Paint()..color = const Color(0xFF38BDF8),
      );
      canvas.drawCircle(Offset(x - 4, 41), 3.5, Paint()..color = Colors.white);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(56, 118, 144, 134),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white,
    );
  }

  void _spiderman(Canvas canvas) {
    // Líneas sutiles de telaraña en la frente
    final redPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(100, 22), const Offset(100, 75), redPaint);
    canvas.drawLine(const Offset(60, 35), const Offset(140, 75), redPaint);
    canvas.drawLine(const Offset(140, 35), const Offset(60, 75), redPaint);

    final negro =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeJoin = StrokeJoin.round;
    final blanco = Paint()..color = Colors.white;

    final ojoIzq =
        Path()
          ..moveTo(50, 66)
          ..quadraticBezierTo(72, 58, 90, 82)
          ..quadraticBezierTo(66, 98, 50, 66)
          ..close();
    final ojoDer =
        Path()
          ..moveTo(150, 66)
          ..quadraticBezierTo(128, 58, 110, 82)
          ..quadraticBezierTo(134, 98, 150, 66)
          ..close();

    canvas.drawPath(ojoIzq, blanco);
    canvas.drawPath(ojoIzq, negro);
    canvas.drawPath(ojoDer, blanco);
    canvas.drawPath(ojoDer, negro);
  }

  void _ironman(Canvas canvas) {
    final placa = RRect.fromRectAndRadius(
      const Rect.fromLTRB(58, 42, 142, 92),
      const Radius.circular(14),
    );
    canvas.drawRRect(placa, Paint()..color = const Color(0xFFFBBF24));
    final luzAzul = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(64, 72, 89, 81),
        const Radius.circular(3),
      ),
      luzAzul,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(111, 72, 136, 81),
        const Radius.circular(3),
      ),
      luzAzul,
    );
    // Reactor Arc brillante en el pecho
    canvas.drawCircle(
      const Offset(100, 145),
      18,
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.4),
    );
    canvas.drawCircle(
      const Offset(100, 145),
      13,
      Paint()..color = const Color(0xFF0284C7),
    );
    canvas.drawCircle(const Offset(100, 145), 9, Paint()..color = Colors.white);
  }

  void _wolverine(Canvas canvas) {
    final negro = Paint()..color = const Color(0xFF111827);
    final aletaIzq =
        Path()
          ..moveTo(68, 86)
          ..lineTo(26, 36)
          ..lineTo(54, 60)
          ..lineTo(86, 80)
          ..close();
    final aletaDer =
        Path()
          ..moveTo(132, 86)
          ..lineTo(174, 36)
          ..lineTo(146, 60)
          ..lineTo(114, 80)
          ..close();
    canvas.drawPath(aletaIzq, negro);
    canvas.drawPath(aletaDer, negro);
  }

  void _deadpool(Canvas canvas) {
    final negro = Paint()..color = const Color(0xFF18181B);
    final blanco = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(74, 78), width: 32, height: 42),
      negro,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(126, 78), width: 32, height: 42),
      negro,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(74, 78), width: 14, height: 10),
      blanco,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(126, 78), width: 14, height: 12),
      blanco,
    );
  }

  void _cascoIng(Canvas canvas) {
    final amarillo = Paint()..color = const Color(0xFFFACC15);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(100, 56), radius: 52),
      math.pi,
      math.pi,
      true,
      amarillo,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(40, 48, 160, 58),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFEAB308),
    );
  }

  void _visorSistemas(Canvas canvas) {
    final verdeNeon =
        Paint()..color = const Color(0xFF00F5D4).withValues(alpha: 0.88);
    final marco = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(48, 66, 152, 92),
        const Radius.circular(10),
      ),
      marco,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(52, 70, 148, 88),
        const Radius.circular(8),
      ),
      verdeNeon,
    );
    _auriculares(canvas);
  }

  void _visorMeca(Canvas canvas) {
    final metal = Paint()..color = const Color(0xFF64748B);
    canvas.drawRect(const Rect.fromLTRB(97, 4, 103, 26), metal);
    canvas.drawCircle(
      const Offset(100, 6),
      6.5,
      Paint()..color = const Color(0xFFEF4444),
    );
    canvas.drawCircle(const Offset(126, 80), 17, metal);
    canvas.drawCircle(
      const Offset(126, 80),
      11,
      Paint()..color = const Color(0xFFEF4444),
    );
    canvas.drawCircle(
      const Offset(123, 77),
      3.5,
      Paint()..color = Colors.white,
    );
  }

  void _lentesQuimica(Canvas canvas) {
    final cristal =
        Paint()..color = const Color(0xFF6EE7B7).withValues(alpha: 0.55);
    final borde =
        Paint()
          ..color = const Color(0xFF059669)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTRB(52, 66, 148, 94),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, cristal);
    canvas.drawRRect(rect, borde);
  }

  // ── NUEVOS ACCESORIOS SUPREMOS ──

  void _bocchiRock(Canvas canvas) {
    // 1. Cubitos azul y amarillo en el cabello (lado derecho)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(134, 40, 154, 60),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF38BDF8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(146, 54, 166, 74),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFACC15),
    );
    // 2. Gotita de sudor de ansiedad social en la sien izquierda
    final gota =
        Path()
          ..moveTo(48, 52)
          ..quadraticBezierTo(40, 66, 48, 72)
          ..quadraticBezierTo(56, 66, 48, 52)
          ..close();
    canvas.drawPath(gota, Paint()..color = const Color(0xFF7DD3FC));

    // 3. Guitarra eléctrica Les Paul negra con dorado cruzada en el pecho
    canvas.save();
    canvas.translate(105, 148);
    canvas.rotate(-0.35);
    // Mástil
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-55, -5, 15, 5),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF78350F),
    );
    // Cuerpo de la guitarra
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(18, 0), width: 42, height: 32),
      Paint()..color = const Color(0xFF18181B),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(18, 0), width: 42, height: 32),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFFFBBF24),
    );
    canvas.restore();
  }

  void _gojoAnime(Canvas canvas) {
    // Cabello blanco en picos hacia arriba + venda negra de Gojo Satoru
    final peloBlanco = Paint()..color = const Color(0xFFF8FAFC);
    final picos =
        Path()
          ..moveTo(46, 52)
          ..lineTo(34, 22)
          ..lineTo(66, 34)
          ..lineTo(78, 8)
          ..lineTo(100, 28)
          ..lineTo(122, 6)
          ..lineTo(134, 34)
          ..lineTo(166, 22)
          ..lineTo(154, 52)
          ..close();
    canvas.drawPath(picos, peloBlanco);

    // Venda negra cubriendo los ojos
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(40, 62, 160, 88),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
  }

  void _saiyajin(Canvas canvas) {
    // Cabellera dorada puntiaguda de Súper Saiyajin
    final oroHair =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF08A), Color(0xFFFACC15), Color(0xFFEAB308)],
          ).createShader(const Rect.fromLTWH(20, 0, 160, 65));

    final pelo =
        Path()
          ..moveTo(44, 56)
          ..lineTo(18, 28)
          ..lineTo(56, 34)
          ..lineTo(48, 6)
          ..lineTo(84, 26)
          ..lineTo(100, 0)
          ..lineTo(116, 26)
          ..lineTo(152, 6)
          ..lineTo(144, 34)
          ..lineTo(182, 28)
          ..lineTo(156, 56)
          ..close();
    canvas.drawPath(pelo, oroHair);
    canvas.drawPath(
      pelo,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFB45309),
    );
  }

  void _venom(Canvas canvas) {
    // Ojos blancos gigantes y afilados de Venom + lengua larga roja
    final blanco = Paint()..color = Colors.white;
    final ojoIzq =
        Path()
          ..moveTo(46, 56)
          ..quadraticBezierTo(68, 52, 92, 82)
          ..quadraticBezierTo(62, 92, 46, 56)
          ..close();
    final ojoDer =
        Path()
          ..moveTo(154, 56)
          ..quadraticBezierTo(132, 52, 108, 82)
          ..quadraticBezierTo(138, 92, 154, 56)
          ..close();
    canvas.drawPath(ojoIzq, blanco);
    canvas.drawPath(ojoDer, blanco);

    // Símbolo de araña blanca en el pecho
    final arana =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    canvas.drawCircle(const Offset(100, 145), 8, Paint()..color = Colors.white);
    canvas.drawLine(const Offset(75, 135), const Offset(125, 155), arana);
    canvas.drawLine(const Offset(125, 135), const Offset(75, 155), arana);
  }

  void _batman(Canvas canvas) {
    // Orejas puntiagudas de murciélago + ojos blancos angulares + Bati-logo en el pecho
    final negro = Paint()..color = const Color(0xFF090D16);
    final orejas =
        Path()
          ..moveTo(48, 56)
          ..lineTo(52, 8)
          ..lineTo(78, 38)
          ..lineTo(122, 38)
          ..lineTo(148, 8)
          ..lineTo(152, 56)
          ..close();
    canvas.drawPath(orejas, negro);

    // Ojos blancos de detective
    final blanco = Paint()..color = Colors.white;
    canvas.drawPolygon(const [
      Offset(58, 74),
      Offset(86, 80),
      Offset(64, 86),
    ], blanco);
    canvas.drawPolygon(const [
      Offset(142, 74),
      Offset(114, 80),
      Offset(136, 86),
    ], blanco);

    // Bati-elipse amarilla en el pecho
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 144), width: 46, height: 24),
      Paint()..color = const Color(0xFFFACC15),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 144), width: 34, height: 14),
      negro,
    );
  }

  void _streamerRgb(Canvas canvas, double t) {
    final colorRgb =
        HSLColor.fromAHSL(1.0, (t * 360) % 360, 0.9, 0.6).toColor();
    final banda =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF1E1B4B);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(100, 84), radius: 68),
      math.pi * 1.04,
      math.pi * 0.92,
      false,
      banda,
    );
    for (final x in const [32.0, 168.0]) {
      final copa = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, 90), width: 22, height: 46),
        const Radius.circular(10),
      );
      canvas.drawRRect(copa, Paint()..color = const Color(0xFF1E1B4B));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 90), width: 14, height: 34),
          const Radius.circular(6),
        ),
        Paint()..color = colorRgb,
      );
    }
    // Micrófono gamer hacia el pico
    canvas.drawLine(
      const Offset(34, 104),
      const Offset(76, 108),
      Paint()
        ..color = const Color(0xFF1E1B4B)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(78, 108), 5.5, Paint()..color = colorRgb);
  }

  @override
  bool shouldRepaint(covariant _PintorPato oldDelegate) => true;
}

extension _CanvasPolygon on Canvas {
  void drawPolygon(List<Offset> points, Paint paint) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    drawPath(path, paint);
  }
}

// ═════════════════════ EL HUEVO AL DERECHO Y LOS RAYOS ═════════════════════

class _PintorHuevo extends CustomPainter {
  final double grietas;
  final Color colorAcento;
  const _PintorHuevo(this.grietas, this.colorAcento);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final huevo =
        Path()
          ..moveTo(w * 0.5, 0)
          ..cubicTo(w * 0.78, 0, w * 1.0, h * 0.38, w * 1.0, h * 0.65)
          ..cubicTo(w * 1.0, h * 0.88, w * 0.78, h, w * 0.5, h)
          ..cubicTo(w * 0.22, h, 0, h * 0.88, 0, h * 0.65)
          ..cubicTo(0, h * 0.38, w * 0.22, 0, w * 0.5, 0)
          ..close();

    canvas.drawPath(
      huevo,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.35),
          radius: 1.05,
          colors: [
            const Color(0xFFFFFFFF),
            const Color(0xFFFFF3D1),
            colorAcento.withValues(alpha: 0.60),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.save();
    canvas.clipPath(huevo);
    final mancha = Paint()..color = colorAcento.withValues(alpha: 0.38);
    canvas.drawCircle(Offset(w * 0.32, h * 0.42), w * 0.08, mancha);
    canvas.drawCircle(Offset(w * 0.68, h * 0.32), w * 0.06, mancha);
    canvas.drawCircle(Offset(w * 0.70, h * 0.66), w * 0.09, mancha);
    canvas.drawCircle(Offset(w * 0.26, h * 0.72), w * 0.06, mancha);
    canvas.drawCircle(Offset(w * 0.50, h * 0.85), w * 0.07, mancha);
    canvas.restore();

    canvas.drawOval(
      Rect.fromLTWH(w * 0.24, h * 0.14, w * 0.14, h * 0.22),
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
    canvas.drawPath(
      huevo,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white.withValues(alpha: 0.88),
    );

    if (grietas > 0) {
      _grieta(canvas, size, [
        Offset(w * 0.50, h * 0.24),
        Offset(w * 0.40, h * 0.36),
        Offset(w * 0.55, h * 0.46),
        Offset(w * 0.38, h * 0.58),
        Offset(w * 0.52, h * 0.68),
        Offset(w * 0.42, h * 0.80),
      ]);
      _grieta(canvas, size, [
        Offset(w * 0.55, h * 0.46),
        Offset(w * 0.70, h * 0.52),
        Offset(w * 0.62, h * 0.65),
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
        ..strokeWidth = 3.2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF5A2D0C),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorHuevo oldDelegate) =>
      oldDelegate.grietas != grietas || oldDelegate.colorAcento != colorAcento;
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
    final pintura = Paint()..color = color.withValues(alpha: 0.22);
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
          colors: [color.withValues(alpha: 0.6), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: 150)),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorRayos oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

class _PintorParticulasFondo extends CustomPainter {
  final double t;
  final Color color;
  const _PintorParticulasFondo(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 18; i++) {
      final dx = ((i * 73) % 100) / 100 * size.width;
      final progreso = ((t + i * 0.13) % 1.0);
      final dy = size.height * (1.0 - progreso);
      final radio = 1.5 + (i % 4) * 1.2;
      final opacidad = math.sin(progreso * math.pi) * 0.45;
      canvas.drawCircle(
        Offset(dx, dy),
        radio,
        Paint()
          ..color = (i.isEven ? color : Colors.white).withValues(
            alpha: opacidad,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorParticulasFondo oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

// ═══════════════════════ TARJETAS (RULETA Y COLECCIÓN) ═══════════════════════

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
      scale: activa ? 1.09 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF2B195C), color.withValues(alpha: 0.45)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: activa ? 1 : 0.6),
            width: activa ? 2.8 : 1.5,
          ),
          boxShadow:
              activa
                  ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.85),
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
  final VoidCallback onTap;

  const _CeldaColeccion({
    required this.skin,
    required this.cantidad,
    required this.reloj,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tiene = cantidad > 0;
    final color = skin.rareza.color;
    final pato = PatoVista(skin: skin, reloj: reloj, tamano: 96);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: tiene ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(18),
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
                                  Color(0xFF12092B),
                                  BlendMode.srcIn,
                                ),
                                child: pato,
                              ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Text(
                      skin.universo.emoji,
                      style: const TextStyle(fontSize: 12),
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
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A0F3B),
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
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════ LA PANTALLA ARCADE ═════════════════════════════

enum _Fase { reposo, abriendo, girando, revelado }

class PantallaGachapon extends StatefulWidget {
  final int puntos;
  final int costoTirada;
  final Map<String, int> coleccionInicial;
  final ValueChanged<int>? onPuntosCambian;
  final void Function(PatoSkin pato, int veces)? onPatoObtenido;

  const PantallaGachapon({
    super.key,
    required this.puntos,
    this.costoTirada = 50,
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

  static const Color _fondoArcadeArriba = Color(0xFF2E1760);
  static const Color _fondoArcadeAbajo = Color(0xFF150A30);

  late int _puntos;
  late final Map<String, int> _coleccion;
  _Fase _fase = _Fase.reposo;
  UniversoPato? _universoFiltro;
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

  List<PatoSkin> get _poolDisponible {
    if (_universoFiltro == null) return catalogoPatos;
    final filtrados =
        catalogoPatos.where((p) => p.universo == _universoFiltro).toList();
    return filtrados.isNotEmpty ? filtrados : catalogoPatos;
  }

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
    final pool = _poolDisponible;
    final rareza = _sortearRareza();
    final candidatos = pool.where((s) => s.rareza == rareza).toList();
    if (candidatos.isNotEmpty) {
      return candidatos[_azar.nextInt(candidatos.length)];
    }
    return pool[_azar.nextInt(pool.length)];
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

  Future<void> _abrirHuevo() async {
    if (_fase != _Fase.reposo || _puntos < widget.costoTirada) return;
    HapticFeedback.mediumImpact();

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
      duration: const Duration(milliseconds: 6500),
      curve: Curves.easeOutQuart,
    );
    _cinta.removeListener(_alMoverCinta);
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _revelar();
  }

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

  // 🔍 TARJETA DE INSPECCIÓN HOLOGRÁFICA AL TOCAR UN PATO DE TU COLECCIÓN
  void _inspeccionarPato(PatoSkin skin, int cantidad) {
    if (cantidad <= 0) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🔒 Pato misterioso de "${skin.universo.nombre}". ¡Sigue abriendo cápsulas!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2B195C),
                    const Color(0xFF150A30),
                    skin.rareza.color.withValues(alpha: 0.35),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: skin.rareza.color, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: skin.rareza.color.withValues(alpha: 0.45),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${skin.universo.emoji} ${skin.universo.nombre}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: skin.rareza.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tienes x$cantidad',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF150A30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PatoVista(skin: skin, reloj: _reloj, tamano: 185),
                  const SizedBox(height: 10),
                  _etiquetaRareza(skin),
                  const SizedBox(height: 10),
                  Text(
                    skin.nombre,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    skin.frase,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: skin.rareza.color,
                        foregroundColor: const Color(0xFF150A30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cerrar Inspección',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _mostrarColeccion() {
    UniversoPato? filtroModal;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextModal, setStateModal) {
              final listaMostrar =
                  filtroModal == null
                      ? catalogoPatos
                      : catalogoPatos
                          .where((p) => p.universo == filtroModal)
                          .toList();

              return Container(
                height: MediaQuery.of(ctx).size.height * 0.84,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_fondoArcadeArriba, _fondoArcadeAbajo],
                  ),
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
                    const SizedBox(height: 10),
                    Text(
                      'Multiverso de Patitos · ${_coleccion.length}/${catalogoPatos.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Toca cualquier patito desbloqueado para verlo en grande ✨',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('🌌 Todos (32)'),
                            selected: filtroModal == null,
                            selectedColor: colorAmarilloTese,
                            backgroundColor: Colors.white12,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color:
                                  filtroModal == null
                                      ? const Color(0xFF150A30)
                                      : Colors.white,
                            ),
                            onSelected:
                                (_) => setStateModal(() => filtroModal = null),
                          ),
                          const SizedBox(width: 6),
                          ...UniversoPato.values.map((u) {
                            final sel = filtroModal == u;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text('${u.emoji} ${u.nombre}'),
                                selected: sel,
                                selectedColor: u.colorTema,
                                backgroundColor: Colors.white12,
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      sel
                                          ? const Color(0xFF150A30)
                                          : Colors.white,
                                ),
                                onSelected:
                                    (_) => setStateModal(() => filtroModal = u),
                              ),
                            );
                          }),
                        ],
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
                              childAspectRatio: 0.76,
                            ),
                        itemCount: listaMostrar.length,
                        itemBuilder: (_, i) {
                          final pato = listaMostrar[i];
                          final cant = _coleccion[pato.id] ?? 0;
                          return _CeldaColeccion(
                            skin: pato,
                            cantidad: cant,
                            reloj: _reloj,
                            onTap: () => _inspeccionarPato(pato, cant),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color colorAcento =
        (_fase == _Fase.revelado && _ganador != null)
            ? _ganador!.rareza.color
            : (_universoFiltro?.colorTema ?? const Color(0xFFFFB800));
    final puedeVerColeccion = _fase == _Fase.reposo || _fase == _Fase.revelado;
    final rareza = _ganador?.rareza;
    final particulas =
        rareza == Rareza.legendaria
            ? 75
            : (rareza != null && rareza.index >= 2 ? 45 : 25);

    return Scaffold(
      backgroundColor: _fondoArcadeAbajo,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Multiverso Gachapón 🦆',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w800,
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
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 1.1,
                  colors: [
                    colorAcento.withValues(alpha: 0.42),
                    _fondoArcadeArriba,
                    _fondoArcadeAbajo,
                  ],
                ),
              ),
            ),
          ),
          // Partículas luminosas flotando en vivo
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _reloj,
                builder:
                    (context, _) => CustomPaint(
                      painter: _PintorParticulasFondo(
                        _reloj.value,
                        colorAcento,
                      ),
                    ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight - 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _contenido(colorAcento),
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
                  const Color(0xFF38B6FF),
                  const Color(0xFFFF4D8D),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido(Color colorAcento) {
    switch (_fase) {
      case _Fase.reposo:
      case _Fase.abriendo:
        return KeyedSubtree(
          key: const ValueKey('huevo'),
          child: _vistaHuevo(colorAcento),
        );
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorAmarilloTese.withValues(alpha: 0.8),
          width: 1.5,
        ),
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
                  '$valor pts disponibles',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _vistaHuevo(Color colorAcento) {
    final alcanza = _puntos >= widget.costoTirada;
    final reposo = _fase == _Fase.reposo;
    return Column(
      children: [
        _pildoraPuntos(),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _chipUniverso(null, '🌌 Todos (32)', const Color(0xFFFFB800)),
              ...UniversoPato.values.map(
                (u) => _chipUniverso(u, '${u.emoji} ${u.nombre}', u.colorTema),
              ),
            ],
          ),
        ),
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
                      child: _huevo(s, colorAcento),
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
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: (reposo && alcanza) ? _abrirHuevo : null,
              icon: const Icon(Icons.egg_alt_rounded, size: 24),
              label: Text(
                'Abrir Cápsula · ${widget.costoTirada} pts',
                style: GoogleFonts.poppins(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAcento,
                foregroundColor: const Color(0xFF150A30),
                disabledBackgroundColor: Colors.white12,
                disabledForegroundColor: Colors.white38,
                elevation: 10,
                shadowColor: colorAcento.withValues(alpha: 0.6),
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
              ? (_universoFiltro == null
                  ? 'Tirando de TODOS los universos (32 patitos HD) 🦆'
                  : 'Tirando cápsula de: ${_universoFiltro!.nombre} ${_universoFiltro!.emoji}')
              : 'Te faltan ${widget.costoTirada - _puntos} puntos. ¡Pide en la cafetería para ganar más!',
          style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.white70),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _chipUniverso(UniversoPato? u, String texto, Color color) {
    final bool activo = _universoFiltro == u;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          if (_fase != _Fase.reposo) return;
          HapticFeedback.selectionClick();
          setState(() => _universoFiltro = u);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: activo ? color : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activo ? Colors.white : color.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow:
                activo
                    ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ]
                    : null,
          ),
          child: Text(
            texto,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: activo ? const Color(0xFF150A30) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _huevo(double s, Color colorAcento) {
    return SizedBox(
      width: 230,
      height: 275,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorAcento.withValues(alpha: 0.35 + 0.35 * s),
                  blurRadius: 65 + 45 * s,
                  spreadRadius: 12 + 18 * s,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(175, 225),
            painter: _PintorHuevo(s, colorAcento),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Text(
              _universoFiltro?.emoji ?? '?',
              style: GoogleFonts.poppins(
                fontSize: _universoFiltro == null ? 80 : 58,
                fontWeight: FontWeight.w900,
                color: const Color(
                  0xFF2E1760,
                ).withValues(alpha: 0.45 * (1 - s)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desvanecido(bool izquierda) {
    return Container(
      width: 65,
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: izquierda ? Alignment.centerLeft : Alignment.centerRight,
          end: izquierda ? Alignment.centerRight : Alignment.centerLeft,
          colors: [_fondoArcadeAbajo, _fondoArcadeAbajo.withValues(alpha: 0)],
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
          '¡Girando el Multiverso!',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¿Qué patito saldrá de la cápsula?',
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

  Widget _etiquetaRareza(PatoSkin pato) {
    final c = pato.rareza.color;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c, _ajustarLuz(c, 0.12)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 16),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i <= pato.rareza.index; i++)
                const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: Color(0xFF150A30),
                ),
              const SizedBox(width: 5),
              Text(
                pato.rareza.nombre.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: const Color(0xFF150A30),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30),
          ),
          child: Text(
            '${pato.universo.emoji} ${pato.universo.nombre}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
            height: 290,
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
              fontSize: 26,
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
                      : Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _esNuevo
                  ? '¡NUEVO EN TU COLECCIÓN Y EQUIPADO!'
                  : 'Ya lo tenías · x$veces',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _esNuevo ? const Color(0xFF150A30) : Colors.white,
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
                    'Colección (32)',
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
                  icon: const Icon(Icons.egg_alt_rounded),
                  label: Text(
                    alcanza ? 'Otra cápsula' : 'Listo',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAmarilloTese,
                    foregroundColor: const Color(0xFF150A30),
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
