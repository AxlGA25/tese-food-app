import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colores.dart';
import 'pantalla_login.dart';
import 'pantalla_menu.dart';
import 'cafeteria.dart';

// ==========================================================
// 🌊 FONDO MINIMALISTA PASTEL CON ONDAS ANIMADAS Y COMIDA
// ==========================================================
class FondoOndasPremium extends StatefulWidget {
  final Widget child;
  const FondoOndasPremium({super.key, required this.child});

  @override
  State<FondoOndasPremium> createState() => _FondoOndasPremiumState();
}

class _FondoOndasPremiumState extends State<FondoOndasPremium>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ondaCtrl;

  @override
  void initState() {
    super.initState();
    _ondaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ondaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorFondoBienvenidaArriba,
              colorFondoBienvenidaMedio,
              colorFondoBienvenidaAbajo,
              colorFondoCrema,
            ],
            stops: [0.0, 0.35, 0.72, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ONDAS ORGÁNICAS MULTICAPA EN MOVIMIENTO SUAVE
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ondaCtrl,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _PintorOndasMulticapa(_ondaCtrl.value),
                  );
                },
              ),
            ),

            // CÁPSULAS MINIMALISTAS DE COMIDA LEVITANDO
            _BurbujaComidaFlotante(
              reloj: _ondaCtrl,
              top: 56,
              left: 22,
              fase: 0.0,
              icono: Icons.lunch_dining_rounded,
              etiqueta: 'Burger',
            ),
            _BurbujaComidaFlotante(
              reloj: _ondaCtrl,
              top: 78,
              right: 22,
              fase: 1.4,
              icono: Icons.local_cafe_rounded,
              etiqueta: 'Café',
            ),
            _BurbujaComidaFlotante(
              reloj: _ondaCtrl,
              top: 230,
              left: 16,
              fase: 2.6,
              icono: Icons.local_pizza_rounded,
              etiqueta: 'Antojo',
            ),
            _BurbujaComidaFlotante(
              reloj: _ondaCtrl,
              top: 250,
              right: 18,
              fase: 3.8,
              icono: Icons.icecream_rounded,
              etiqueta: 'Postre',
            ),
            _BurbujaComidaFlotante(
              reloj: _ondaCtrl,
              bottom: 65,
              left: 28,
              fase: 4.9,
              icono: Icons.bakery_dining_rounded,
              etiqueta: 'Panadería',
            ),
            _BurbujaComidaFlotante(
              reloj: _ondaCtrl,
              bottom: 48,
              right: 28,
              fase: 5.5,
              icono: Icons.ramen_dining_rounded,
              etiqueta: 'Receso',
            ),

            SafeArea(child: widget.child),
          ],
        ),
      ),
    );
  }
}

class _BurbujaComidaFlotante extends StatelessWidget {
  final Animation<double> reloj;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double fase;
  final IconData icono;
  final String etiqueta;

  const _BurbujaComidaFlotante({
    required this.reloj,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.fase,
    required this.icono,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: reloj,
          builder: (context, child) {
            final dy = math.sin(reloj.value * 2 * math.pi + fase) * 6.0;
            final rot = math.cos(reloj.value * 2 * math.pi + fase) * 0.04;
            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.rotate(angle: rot, child: child),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorVerdeSuave.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icono,
                  size: 16,
                  color: colorVerdeTese.withValues(alpha: 0.75),
                ),
                const SizedBox(width: 5),
                Text(
                  etiqueta,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colorVerdeTese.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PintorOndasMulticapa extends CustomPainter {
  final double t;
  const _PintorOndasMulticapa(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final desfase = math.sin(t * 2 * math.pi) * 14.0;
    final desfase2 = math.cos(t * 2 * math.pi) * 12.0;

    // 1. Onda superior suave (Salvia clara)
    final ondaSup1 =
        Path()
          ..moveTo(0, 0)
          ..lineTo(0, h * 0.22 + desfase)
          ..quadraticBezierTo(
            w * 0.28,
            h * 0.28 - desfase,
            w * 0.58,
            h * 0.19 + desfase2,
          )
          ..quadraticBezierTo(
            w * 0.85,
            h * 0.11 - desfase2,
            w,
            h * 0.17 + desfase,
          )
          ..lineTo(w, 0)
          ..close();
    canvas.drawPath(
      ondaSup1,
      Paint()..color = colorOndaClara.withValues(alpha: 0.55),
    );

    // 2. Onda superior principal (Verde salvia medio)
    final ondaSup2 =
        Path()
          ..moveTo(0, 0)
          ..lineTo(0, h * 0.15 - desfase2)
          ..quadraticBezierTo(
            w * 0.35,
            h * 0.21 + desfase,
            w * 0.72,
            h * 0.11 - desfase,
          )
          ..quadraticBezierTo(w * 0.9, h * 0.06 + desfase2, w, h * 0.10)
          ..lineTo(w, 0)
          ..close();
    canvas.drawPath(
      ondaSup2,
      Paint()..color = colorOndaMediaSuperior.withValues(alpha: 0.65),
    );

    // Línea dorada minimalista acompañando la onda superior
    final hiloDoradoSup =
        Path()
          ..moveTo(0, h * 0.155 - desfase2)
          ..quadraticBezierTo(
            w * 0.35,
            h * 0.215 + desfase,
            w * 0.72,
            h * 0.115 - desfase,
          )
          ..quadraticBezierTo(w * 0.9, h * 0.065 + desfase2, w, h * 0.105);
    canvas.drawPath(
      hiloDoradoSup,
      Paint()
        ..color = colorDorado.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // 3. Onda inferior de fondo (Salvia medio)
    final ondaInf1 =
        Path()
          ..moveTo(0, h)
          ..lineTo(0, h * 0.82 + desfase2)
          ..quadraticBezierTo(
            w * 0.32,
            h * 0.74 - desfase,
            w * 0.65,
            h * 0.83 + desfase,
          )
          ..quadraticBezierTo(
            w * 0.88,
            h * 0.89 - desfase2,
            w,
            h * 0.80 + desfase2,
          )
          ..lineTo(w, h)
          ..close();
    canvas.drawPath(
      ondaInf1,
      Paint()..color = colorOndaMedia.withValues(alpha: 0.38),
    );

    // 4. Onda inferior frontal (Verde suave orgánico)
    final ondaInf2 =
        Path()
          ..moveTo(0, h)
          ..lineTo(0, h * 0.89 - desfase)
          ..quadraticBezierTo(
            w * 0.26,
            h * 0.94 + desfase2,
            w * 0.56,
            h * 0.87 - desfase2,
          )
          ..quadraticBezierTo(
            w * 0.82,
            h * 0.81 + desfase,
            w,
            h * 0.87 - desfase,
          )
          ..lineTo(w, h)
          ..close();
    canvas.drawPath(
      ondaInf2,
      Paint()..color = colorOndaOscura.withValues(alpha: 0.48),
    );

    // Línea dorada minimalista en la base
    final hiloDoradoInf =
        Path()
          ..moveTo(0, h * 0.888 - desfase)
          ..quadraticBezierTo(
            w * 0.26,
            h * 0.938 + desfase2,
            w * 0.56,
            h * 0.868 - desfase2,
          )
          ..quadraticBezierTo(
            w * 0.82,
            h * 0.808 + desfase,
            w,
            h * 0.868 - desfase,
          );
    canvas.drawPath(
      hiloDoradoInf,
      Paint()
        ..color = colorDorado.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorOndasMulticapa oldDelegate) =>
      oldDelegate.t != t;
}

// ==========================================================
// SPLASH SCREEN CON SESIÓN PERSISTENTE Y ESTÉTICA PASTEL
// ==========================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesionYRedirigir();
  }

  void _verificarSesionYRedirigir() {
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (!mounted) return;

      final User? usuarioActual = FirebaseAuth.instance.currentUser;

      if (usuarioActual != null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const NavegacionEstudiante(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const DecisionScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FondoOndasPremium(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElasticIn(
              duration: const Duration(milliseconds: 1400),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.78),
                  border: Border.all(
                    color: colorDorado.withValues(alpha: 0.8),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeSuave.withValues(alpha: 0.16),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'logo_app',
                  child: Image.asset(
                    'assets/logo_tesehambreado.png',
                    height: 190,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🍴 CAFETERÍAS Y KIOSKOS DEL CAMPUS',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: colorVerdeSuave,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: Text(
                'TESE Hambreados',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: colorVerdeTese,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FadeInUp(
              delay: const Duration(milliseconds: 1000),
              child: Text(
                'Sin filas, más receso para ti.',
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  color: colorVerdeSuave,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 36),
            FadeIn(
              delay: const Duration(milliseconds: 1300),
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: colorVerdeTese.withValues(alpha: 0.8),
                  strokeWidth: 2.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// PANTALLA DE BIENVENIDA MINIMALISTA Y ATRACTIVA
// ==========================================================
class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  Widget _chipBeneficio(String emoji, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorVerdeSuave.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            texto,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: colorVerdeTese,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FondoOndasPremium(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Halo minimalista con el patito / logo oficial
              ZoomIn(
                duration: const Duration(milliseconds: 700),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.82),
                    border: Border.all(
                      color: colorDorado.withValues(alpha: 0.85),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorVerdeSuave.withValues(alpha: 0.14),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'logo_app',
                    child: Image.asset(
                      'assets/logo_tesehambreado.png',
                      height: 135,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Título y eslogan cálido
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'TESE Hambreados',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: colorVerdeTese,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeInDown(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'Pide desde tu salón, recoge sin hacer fila,\n por un TESE sin hambre.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: colorVerdeSuave,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Píldoras minimalistas de características
              FadeIn(
                delay: const Duration(milliseconds: 250),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chipBeneficio('⚡', 'Cero filas'),
                    _chipBeneficio('🍔', 'A tu gusto'),
                    _chipBeneficio('🦆', 'Ruleta TESE'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // TARJETA 1: ESTUDIANTE / COMUNIDAD TESE (Principal)
              FadeInUp(
                delay: const Duration(milliseconds: 320),
                child: _TarjetaAccesoMinimalista(
                  titulo: 'Soy Estudiante / TESE',
                  subtitulo: 'Explora el menú, pide a cocina y gana puntos',
                  etiquetaSuperior: '🍔 ¡Tengo hambre!',
                  icono: Icons.school_rounded,
                  esPrincipal: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginEstudianteScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // TARJETA 2: CAFETERÍA / KIOSKO (Secundaria minimalista)
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: _TarjetaAccesoMinimalista(
                  titulo: 'Soy Cafetería / Kiosko',
                  subtitulo: 'Terminal de cocina, comandas y existencias',
                  etiquetaSuperior: '👨‍🍳 Personal autorizado',
                  icono: Icons.storefront_rounded,
                  esPrincipal: false,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginLocalScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              FadeIn(
                delay: const Duration(milliseconds: 650),
                child: Text(
                  'Tecnológico de Estudios Superiores de Ecatepec',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorVerdeTese.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaAccesoMinimalista extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String etiquetaSuperior;
  final IconData icono;
  final bool esPrincipal;
  final VoidCallback onTap;

  const _TarjetaAccesoMinimalista({
    required this.titulo,
    required this.subtitulo,
    required this.etiquetaSuperior,
    required this.icono,
    required this.esPrincipal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fondo =
        esPrincipal ? colorVerdeSuave : Colors.white.withValues(alpha: 0.88);
    final Color colorTexto = esPrincipal ? Colors.white : colorVerdeTese;
    final Color colorSub =
        esPrincipal ? Colors.white.withValues(alpha: 0.85) : colorTextoGris;

    return Container(
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color:
              esPrincipal
                  ? colorDorado.withValues(alpha: 0.65)
                  : colorVerdeSuave.withValues(alpha: 0.35),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: colorVerdeSuave.withValues(alpha: esPrincipal ? 0.28 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color:
                        esPrincipal
                            ? Colors.white.withValues(alpha: 0.18)
                            : colorPastelClaro,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    icono,
                    size: 28,
                    color: esPrincipal ? colorDorado : colorVerdeSuave,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              esPrincipal
                                  ? colorDorado.withValues(alpha: 0.22)
                                  : colorVerdeSuave.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          etiquetaSuperior,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: esPrincipal ? colorDorado : colorVerdeSuave,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        titulo,
                        style: GoogleFonts.poppins(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: colorTexto,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colorSub,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        esPrincipal
                            ? Colors.white.withValues(alpha: 0.2)
                            : colorVerdeSuave.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: colorTexto,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
