import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'colores.dart';

enum UniversoPato { tese, marvel, leyendas, especiales, temporal }

extension UniversoInfo on UniversoPato {
  String get nombre => switch (this) {
    UniversoPato.tese => 'Carreras TESE',
    UniversoPato.marvel => 'Héroes & Cómics',
    UniversoPato.leyendas => 'Anime & Ídolos',
    UniversoPato.especiales => 'Míticos & Clásicos',
    UniversoPato.temporal => 'Evento de Temporada',
  };

  String get emoji => switch (this) {
    UniversoPato.tese => '🎓',
    UniversoPato.marvel => '🕷️',
    UniversoPato.leyendas => '🎸',
    UniversoPato.especiales => '✨',
    UniversoPato.temporal => '🏵️',
  };

  Color get colorTema => switch (this) {
    UniversoPato.tese => const Color(0xFF00E5A3),
    UniversoPato.marvel => const Color(0xFFFF3864),
    UniversoPato.leyendas => const Color(0xFFFFB800),
    UniversoPato.especiales => const Color(0xFFB56BFF),
    UniversoPato.temporal => const Color(0xFFFF7A00),
  };
}

enum Rareza { comun, rara, epica, mitica, legendaria, jackpot }

extension RarezaInfo on Rareza {
  String get nombre => switch (this) {
    Rareza.comun => 'Común',
    Rareza.rara => 'Rara',
    Rareza.epica => 'Épica',
    Rareza.mitica => 'Mítica',
    Rareza.legendaria => 'Legendaria',
    Rareza.jackpot => 'Jackpot Lotería',
  };

  Color get color => switch (this) {
    Rareza.comun => const Color(0xFF7AE582),
    Rareza.rara => const Color(0xFF38B6FF),
    Rareza.epica => const Color(0xFFB56BFF),
    Rareza.mitica => const Color(0xFFFF4D8D),
    Rareza.legendaria => const Color(0xFFFFD13B),
    Rareza.jackpot => const Color(0xFF00F5D4),
  };

  double get pesoDecimal => switch (this) {
    Rareza.comun => 41.0,
    Rareza.rara => 28.0,
    Rareza.epica => 17.0,
    Rareza.mitica => 9.9,
    Rareza.legendaria => 4.09,
    Rareza.jackpot => 0.01, // 🎰 0.01% de probabilidad tipo Lotería
  };

  String get etiquetaPorcentaje => switch (this) {
    Rareza.comun => '41%',
    Rareza.rara => '28%',
    Rareza.epica => '17%',
    Rareza.mitica => '9.9%',
    Rareza.legendaria => '4.09%',
    Rareza.jackpot => '0.01% 🎰',
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
  catrinaMuertos,
  panDeMuerto,
  renoNavidad,
  santaNavidad,
}

enum EfectoCuerpo { ninguno, galaxia, arcoiris, oro, diamante, jackpotEfecto }

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
  final bool esTemporada;
  final int? mesInicio;
  final int? mesFin;

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
    this.esTemporada = false,
    this.mesInicio,
    this.mesFin,
  });

  bool get brilla =>
      efecto == EfectoCuerpo.oro ||
      efecto == EfectoCuerpo.diamante ||
      efecto == EfectoCuerpo.jackpotEfecto;

  bool get estaActivoPorTemporada {
    if (!esTemporada) return true;
    final mesActual = DateTime.now().month;
    if (mesInicio != null && mesFin != null) {
      if (mesInicio! <= mesFin!) {
        return mesActual >= mesInicio! && mesActual <= mesFin!;
      } else {
        return mesActual >= mesInicio! || mesActual <= mesFin!;
      }
    }
    return true;
  }
}

String obtenerNombreEventoActivo() {
  final mes = DateTime.now().month;
  if (mes == 10 || mes == 11) {
    return '🏵️ ¡EVENTO DÍA DE MUERTOS ACTIVO! Skins exclusivas disponibles';
  } else if (mes == 12) {
    return '🎄 ¡EVENTO DE NAVIDAD ACTIVO! Skins navideñas disponibles';
  }
  return '🎰 ¡LOTERÍA TESE ACTIVA! Busca el Pato Jackpot Cósmico (0.01%)';
}

const List<PatoSkin> catalogoPatos = [
  // 0..14 Base compatible
  PatoSkin(
    id: 'clasico',
    nombre: 'Patito Clásico',
    frase: 'El de toda la vida. Redondito, tierno y nunca falla en el receso.',
    rareza: Rareza.comun,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFFFD84D),
  ),
  PatoSkin(
    id: 'estudiante',
    nombre: 'Patito Estudiante TESE',
    frase: 'Se graduó con honores... pero de pedir tortas sin fila.',
    rareza: Rareza.comun,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFFFFD84D),
    accesorio: Accesorio.birrete,
  ),
  PatoSkin(
    id: 'matcha',
    nombre: 'Patito Matcha Latte',
    frase: 'Fresco, estético, zen y sin prisa para entrar al laboratorio.',
    rareza: Rareza.comun,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFB7E08C),
    cuerpo2: Color(0xFF86EFAC),
  ),
  PatoSkin(
    id: 'chicle',
    nombre: 'Patito Frappe Rosa',
    frase: 'Dulce, esponjoso y siempre pide postre después de comer.',
    rareza: Rareza.comun,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFFFB3D1),
    cuerpo2: Color(0xFFF472B6),
  ),
  PatoSkin(
    id: 'chef',
    nombre: 'Master Chef Patito',
    frase: 'Sus chilaquiles del kiosko tienen estrella Michelin.',
    rareza: Rareza.rara,
    universo: UniversoPato.tese,
    cuerpo: Color(0xFFFFF3D6),
    accesorio: Accesorio.gorroChef,
  ),
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
  PatoSkin(
    id: 'cool',
    nombre: 'Patito Fachero',
    frase: 'Trae lentes oscuros hasta cuando está nublado en Ecatepec.',
    rareza: Rareza.rara,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFFFA94D),
    accesorio: Accesorio.lentes,
  ),
  PatoSkin(
    id: 'ninja',
    nombre: 'Patito Shinobi',
    frase: 'Usa el jutsu de clonación para no hacer fila en la cafetería.',
    rareza: Rareza.rara,
    universo: UniversoPato.leyendas,
    cuerpo: Color(0xFF3A3A48),
    accesorio: Accesorio.ninja,
  ),
  PatoSkin(
    id: 'pirata',
    nombre: 'Capitán Barba Pato',
    frase: 'Navega los siete mares buscando la última mesa con sombra.',
    rareza: Rareza.epica,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFFE76F51),
    accesorio: Accesorio.pirata,
  ),
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

  // ── UNIVERSO HÉROES & CÓMICS ──
  PatoSkin(
    id: 'spider_pato',
    nombre: 'Spidey-Pato',
    frase: 'Tu vecino amigable del TESE. Atrapa su torta con telaraña.',
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
    frase: 'Genio, millonario y con Reactor Arc para calentar sus chilaquiles.',
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

  // ── CARRERAS DEL TESE ──
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

  // ── 🏵️🎄 EXCLUSIVOS DE TEMPORADA (DÍA DE MUERTOS: OCT-NOV | NAVIDAD: DIC) ──
  PatoSkin(
    id: 'pato_catrina',
    nombre: 'Pato Catrina de Ofrenda',
    frase:
        'Exclusivo Día de Muertos: Llega entre pétalos de cempasúchil por su pan de muerto.',
    rareza: Rareza.legendaria,
    universo: UniversoPato.temporal,
    cuerpo: Color(0xFFF8FAFC),
    cuerpo2: Color(0xFFE2E8F0),
    pico: Color(0xFFFF7A00),
    efecto: EfectoCuerpo.oro,
    accesorio: Accesorio.catrinaMuertos,
    esTemporada: true,
    mesInicio: 10,
    mesFin: 11,
  ),
  PatoSkin(
    id: 'pato_pan_muerto',
    nombre: 'Patito Cempasúchil',
    frase:
        'Exclusivo Día de Muertos: Espolvoreado con azúcar rosita y aroma a tradición.',
    rareza: Rareza.mitica,
    universo: UniversoPato.temporal,
    cuerpo: Color(0xFFFF9F1C),
    cuerpo2: Color(0xFFD97706),
    pico: Color(0xFFEC4899),
    accesorio: Accesorio.panDeMuerto,
    esTemporada: true,
    mesInicio: 10,
    mesFin: 11,
  ),
  PatoSkin(
    id: 'pato_santa',
    nombre: 'Santa Patito Navideño',
    frase:
        'Exclusivo de Diciembre: Reparte tortas y ponche caliente en su trineo.',
    rareza: Rareza.legendaria,
    universo: UniversoPato.temporal,
    cuerpo: Color(0xFFEF4444),
    cuerpo2: Color(0xFFB91C1C),
    efecto: EfectoCuerpo.diamante,
    accesorio: Accesorio.santaNavidad,
    esTemporada: true,
    mesInicio: 12,
    mesFin: 12,
  ),
  PatoSkin(
    id: 'pato_reno',
    nombre: 'Patito Rodolfo el Reno',
    frase:
        'Exclusivo de Diciembre: Su piquito brilla en la neblina matutina del TESE.',
    rareza: Rareza.mitica,
    universo: UniversoPato.temporal,
    cuerpo: Color(0xFF92400E),
    cuerpo2: Color(0xFF78350F),
    pico: Color(0xFFEF4444),
    accesorio: Accesorio.renoNavidad,
    esTemporada: true,
    mesInicio: 12,
    mesFin: 12,
  ),

  // ── 🎰 EL JACKPOT SUPREMO (0.01% LOTERÍA TESE) ──
  PatoSkin(
    id: 'pato_jackpot_supremo',
    nombre: 'Pato Jackpot Lotería TESE',
    frase: '🎰 ¡PREMIO MAYOR (0.01%)! Eres una leyenda viviente del campus.',
    rareza: Rareza.jackpot,
    universo: UniversoPato.especiales,
    cuerpo: Color(0xFF00F5D4),
    cuerpo2: Color(0xFFFF007F),
    pico: Color(0xFFFFD700),
    efecto: EfectoCuerpo.jackpotEfecto,
    accesorio: Accesorio.corona,
  ),
];

Color ajustarLuzPato(Color c, double delta) {
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
    return Center(
      child: SizedBox(
        width: tamano,
        height: tamano,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: CustomPaint(
            painter: _PintorPato(skin, reloj ?? kAlwaysCompleteAnimation),
          ),
        ),
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

    final double ondaResp = animado ? math.sin(t * 2 * math.pi) : 0.0;
    final double ondaAla = animado ? math.sin(t * 4 * math.pi) * 0.14 : 0.0;
    final bool parpadeando = animado && (t > 0.90 && t < 0.96);

    canvas.save();
    canvas.scale(size.width / 200, size.height / 200);
    const area = Rect.fromLTWH(0, 0, 200, 200);

    final colorRareza = skin.rareza.color;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 192),
        width: 128 - ondaResp * 6,
        height: 16,
      ),
      Paint()..color = colorRareza.withValues(alpha: 0.28),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 192),
        width: 112 - ondaResp * 4,
        height: 11,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );

    final pataPaint = Paint()..color = skin.pico;
    final pataBorde =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = ajustarLuzPato(skin.pico, -0.2);
    for (final px in const [74.0, 126.0]) {
      final rectPata = Rect.fromCenter(
        center: Offset(px, 187),
        width: 32,
        height: 15,
      );
      canvas.drawOval(rectPata, pataPaint);
      canvas.drawOval(rectPata, pataBorde);
    }

    canvas.save();
    canvas.translate(0, -ondaResp * 2.8);

    final relleno = _relleno(area, t);
    final contorno =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..color = ajustarLuzPato(skin.cuerpo, -0.25);
    final alaPintura = Paint()..color = ajustarLuzPato(skin.cuerpo, -0.05);

    canvas.saveLayer(area, Paint());

    final cuerpo = Rect.fromCenter(
      center: const Offset(100, 140),
      width: 142 + ondaResp * 2,
      height: 100 - ondaResp * 1.5,
    );
    canvas.drawOval(cuerpo, relleno);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 147), width: 92, height: 66),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.drawOval(cuerpo, contorno);

    _ala(canvas, const Offset(39, 141), -0.45 + ondaAla, alaPintura, contorno);
    _ala(canvas, const Offset(161, 141), 0.45 - ondaAla, alaPintura, contorno);

    final cabeza = Rect.fromCircle(center: const Offset(100, 82), radius: 62);
    canvas.drawOval(cabeza, relleno);

    canvas.save();
    canvas.translate(74, 46);
    canvas.rotate(-0.45);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 34, height: 16),
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );
    canvas.restore();

    canvas.drawOval(cabeza, contorno);

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

    if (skin.efecto == EfectoCuerpo.galaxia ||
        skin.efecto == EfectoCuerpo.jackpotEfecto) {
      _estrellasCuerpo(canvas, t);
    }
    if (skin.brilla) _brilloBarrido(canvas, t);
    canvas.restore();

    _cara(canvas, parpadeando);
    _accesorio(canvas, t);

    canvas.restore();

    if (skin.rareza.index >= Rareza.mitica.index) {
      _destellos(canvas, t);
    }
    canvas.restore();
  }

  Paint _relleno(Rect area, double t) {
    final p = Paint();
    if (skin.efecto == EfectoCuerpo.arcoiris ||
        skin.efecto == EfectoCuerpo.jackpotEfecto) {
      p.shader = SweepGradient(
        colors: const [
          Color(0xFFFF007F),
          Color(0xFFFFD700),
          Color(0xFF00F5D4),
          Color(0xFF38B6FF),
          Color(0xFFB56BFF),
          Color(0xFFFF007F),
        ],
        transform: GradientRotation(t * 2 * math.pi),
      ).createShader(area);
    } else if (skin.cuerpo2 != null) {
      p.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [ajustarLuzPato(skin.cuerpo, 0.08), skin.cuerpo, skin.cuerpo2!],
      ).createShader(area);
    } else {
      p.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ajustarLuzPato(skin.cuerpo, 0.12),
          skin.cuerpo,
          ajustarLuzPato(skin.cuerpo, -0.10),
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
        canvas.drawCircle(c.translate(-2.6, -2.8), 3.2, luzBlanca);
        canvas.drawCircle(c.translate(2.4, 2.6), 1.5, luzBlanca);
      }
    }

    final picoInf = Rect.fromCenter(
      center: const Offset(100, 104),
      width: 34,
      height: 18,
    );
    canvas.drawOval(picoInf, Paint()..color = ajustarLuzPato(skin.pico, -0.12));

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
        ..color = ajustarLuzPato(skin.pico, -0.20),
    );
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
      case Accesorio.catrinaMuertos:
        _catrinaMuertos(canvas);
      case Accesorio.panDeMuerto:
        _panDeMuerto(canvas);
      case Accesorio.renoNavidad:
        _renoNavidad(canvas);
      case Accesorio.santaNavidad:
        _santaNavidad(canvas);
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
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 46), width: 128, height: 20),
      Paint()..color = const Color(0xFF4B2FC0),
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
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 90), width: 20, height: 44),
          const Radius.circular(9),
        ),
        Paint()..color = colorAmarilloTese,
      );
    }
  }

  void _ninja(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(38, 48, 162, 66),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFD62828),
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
      Paint()..color = const Color(0xFFF5EBE1),
    );
    for (final x in const [76.0, 124.0]) {
      canvas.drawCircle(
        Offset(x, 45),
        15,
        Paint()..color = const Color(0xFFD97706),
      );
      canvas.drawCircle(
        Offset(x, 45),
        11,
        Paint()..color = const Color(0xFF38BDF8),
      );
    }
  }

  void _spiderman(Canvas canvas) {
    final negro =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(58, 42, 142, 92),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFFFBBF24),
    );
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
    canvas.drawCircle(
      const Offset(100, 145),
      13,
      Paint()..color = const Color(0xFF0284C7),
    );
    canvas.drawCircle(const Offset(100, 145), 8, Paint()..color = Colors.white);
  }

  void _wolverine(Canvas canvas) {
    final negro = Paint()..color = const Color(0xFF111827);
    canvas.drawPath(
      Path()
        ..moveTo(68, 86)
        ..lineTo(26, 36)
        ..lineTo(54, 60)
        ..lineTo(86, 80)
        ..close(),
      negro,
    );
    canvas.drawPath(
      Path()
        ..moveTo(132, 86)
        ..lineTo(174, 36)
        ..lineTo(146, 60)
        ..lineTo(114, 80)
        ..close(),
      negro,
    );
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
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(100, 56), radius: 52),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFFFACC15),
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(48, 66, 152, 92),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(52, 70, 148, 88),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF00F5D4).withValues(alpha: 0.88),
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
  }

  void _lentesQuimica(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTRB(52, 66, 148, 94),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF6EE7B7).withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFF059669)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _bocchiRock(Canvas canvas) {
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
    canvas.save();
    canvas.translate(105, 148);
    canvas.rotate(-0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-55, -5, 15, 5),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(18, 0), width: 42, height: 32),
      Paint()..color = const Color(0xFF18181B),
    );
    canvas.restore();
  }

  void _gojoAnime(Canvas canvas) {
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
    canvas.drawPath(picos, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(40, 62, 160, 88),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
  }

  void _saiyajin(Canvas canvas) {
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
    canvas.drawPath(pelo, Paint()..color = const Color(0xFFFACC15));
  }

  void _venom(Canvas canvas) {
    final blanco = Paint()..color = Colors.white;
    canvas.drawPath(
      Path()
        ..moveTo(46, 56)
        ..quadraticBezierTo(68, 52, 92, 82)
        ..quadraticBezierTo(62, 92, 46, 56)
        ..close(),
      blanco,
    );
    canvas.drawPath(
      Path()
        ..moveTo(154, 56)
        ..quadraticBezierTo(132, 52, 108, 82)
        ..quadraticBezierTo(138, 92, 154, 56)
        ..close(),
      blanco,
    );
  }

  void _batman(Canvas canvas) {
    final negro = Paint()..color = const Color(0xFF090D16);
    canvas.drawPath(
      Path()
        ..moveTo(48, 56)
        ..lineTo(52, 8)
        ..lineTo(78, 38)
        ..lineTo(122, 38)
        ..lineTo(148, 8)
        ..lineTo(152, 56)
        ..close(),
      negro,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 144), width: 44, height: 22),
      Paint()..color = const Color(0xFFFACC15),
    );
  }

  void _streamerRgb(Canvas canvas, double t) {
    final colorRgb =
        HSLColor.fromAHSL(1.0, (t * 360) % 360, 0.9, 0.6).toColor();
    _auriculares(canvas);
    canvas.drawCircle(const Offset(78, 108), 6, Paint()..color = colorRgb);
  }

  void _catrinaMuertos(Canvas canvas) {
    // Corona de flores de cempasúchil y maquillaje de calavera mexicana
    final coloresFlor = [
      const Color(0xFFFF7A00),
      const Color(0xFFFFB703),
      const Color(0xFFEC4899),
    ];
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(56.0 + i * 22.0, 32),
        11,
        Paint()..color = coloresFlor[i % 3],
      );
    }
    final morado =
        Paint()
          ..color = const Color(0xFF7E22CE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    canvas.drawCircle(const Offset(74, 80), 15, morado);
    canvas.drawCircle(const Offset(126, 80), 15, morado);
  }

  void _panDeMuerto(Canvas canvas) {
    // Huesitos de pan de muerto espolvoreados arriba de la cabecita
    final pan = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(const Offset(100, 22), 11, pan);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(65, 22, 135, 34),
        const Radius.circular(6),
      ),
      pan,
    );
  }

  void _renoNavidad(Canvas canvas) {
    // Astas de reno navideño
    final asta =
        Paint()
          ..color = const Color(0xFF78350F)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(70, 32), const Offset(50, 6), asta);
    canvas.drawLine(const Offset(130, 32), const Offset(150, 6), asta);
  }

  void _santaNavidad(Canvas canvas) {
    // Gorrito rojo de Santa Claus con pompón blanco
    final rojo = Paint()..color = const Color(0xFFDC2626);
    final blanco = Paint()..color = Colors.white;
    canvas.drawPath(
      Path()
        ..moveTo(52, 42)
        ..quadraticBezierTo(100, -4, 152, 34)
        ..lineTo(140, 46)
        ..close(),
      rojo,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(48, 36, 146, 52),
        const Radius.circular(10),
      ),
      blanco,
    );
    canvas.drawCircle(const Offset(154, 34), 11, blanco);
  }

  @override
  bool shouldRepaint(covariant _PintorPato oldDelegate) => true;
}
