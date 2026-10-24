import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colores.dart';
import 'catalogo_patos.dart';

export 'catalogo_patos.dart';

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

  // Solo entran a la máquina los patitos permanentes + los del evento del mes actual
  List<PatoSkin> get _catalogoActivoEnMaquina {
    return catalogoPatos.where((p) => p.estaActivoPorTemporada).toList();
  }

  // En el armario/colección se muestran los activos + cualquier pato de evento que ya hayas ganado antes
  List<PatoSkin> get _catalogoVisibleEnColeccion {
    return catalogoPatos.where((p) {
      return p.estaActivoPorTemporada || (_coleccion[p.id] ?? 0) > 0;
    }).toList();
  }

  List<PatoSkin> get _poolDisponible {
    final base = _catalogoActivoEnMaquina;
    if (_universoFiltro == null) return base;
    final filtrados = base.where((p) => p.universo == _universoFiltro).toList();
    return filtrados.isNotEmpty ? filtrados : base;
  }

  // 🎰 SORTEO CON DECIMALES DE ALTA PRECISIÓN (SOPORTA 0.01% JACKPOT)
  Rareza _sortearRareza() {
    final double total = Rareza.values.fold<double>(
      0.0,
      (acumulado, r) => acumulado + r.pesoDecimal,
    );
    double tirada = _azar.nextDouble() * total;
    for (final r in Rareza.values) {
      if (tirada < r.pesoDecimal) return r;
      tirada -= r.pesoDecimal;
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
    if (_ganador?.rareza == Rareza.legendaria ||
        _ganador?.rareza == Rareza.jackpot) {
      HapticFeedback.vibrate();
    }
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
    final listaBase = _catalogoVisibleEnColeccion;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextModal, setStateModal) {
              final listaMostrar =
                  filtroModal == null
                      ? listaBase
                      : listaBase
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
                      'Multiverso de Patitos · ${_coleccion.length}/${listaBase.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Toca cualquier patito desbloqueado para verlo en alta definición ✨',
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
                            label: Text('🌌 Todos (${listaBase.length})'),
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
        (rareza == Rareza.legendaria || rareza == Rareza.jackpot)
            ? 90
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
                      '${_coleccion.length}/${_catalogoVisibleEnColeccion.length}',
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
              padding: const EdgeInsets.only(top: kToolbarHeight - 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          const Icon(Icons.stars_rounded, color: colorAmarilloTese, size: 20),
          const SizedBox(width: 8),
          Text(
            '$_puntos pts disponibles',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vistaHuevo(Color colorAcento) {
    final alcanza = _puntos >= widget.costoTirada;
    final reposo = _fase == _Fase.reposo;
    final totalEnMaquina = _catalogoActivoEnMaquina.length;

    return Column(
      children: [
        _pildoraPuntos(),
        const SizedBox(height: 8),
        // 🏵️🎄 BANNER AUTOMÁTICO DE TEMPORADA / LOTERÍA
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A00), Color(0xFFFF007F)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            obtenerNombreEventoActivo(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _chipUniverso(
                null,
                '🌌 Todos ($totalEnMaquina)',
                const Color(0xFFFFB800),
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 5,
            children: [
              for (final r in Rareza.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: r.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${r.nombre} ${r.etiquetaPorcentaje}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight:
                            r == Rareza.jackpot
                                ? FontWeight.w800
                                : FontWeight.normal,
                        color:
                            r == Rareza.jackpot
                                ? colorAmarilloTese
                                : Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: (reposo && alcanza) ? _abrirHuevo : null,
              icon: const Icon(Icons.egg_alt_rounded, size: 24),
              label: Text(
                'Abrir Cápsula · ${widget.costoTirada} pts',
                style: GoogleFonts.poppins(
                  fontSize: 16,
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
        const SizedBox(height: 6),
        Text(
          alcanza
              ? (_universoFiltro == null
                  ? 'Tirando de TODOS los universos activos 🦆'
                  : 'Tirando cápsula de: ${_universoFiltro!.nombre} ${_universoFiltro!.emoji}')
              : 'Te faltan ${widget.costoTirada - _puntos} puntos. ¡Pide en la cafetería para ganar más!',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
        ),
        const SizedBox(height: 14),
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
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: activo ? color : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activo ? Colors.white : color.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            texto,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
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
      width: 215,
      height: 255,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
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
            size: const Size(165, 215),
            painter: _PintorHuevo(s, colorAcento),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Text(
              _universoFiltro?.emoji ?? '?',
              style: GoogleFonts.poppins(
                fontSize: _universoFiltro == null ? 74 : 54,
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
          '¿Saldrá el Jackpot de la Lotería TESE?',
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
            gradient: LinearGradient(colors: [c, ajustarLuzPato(c, 0.12)]),
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
