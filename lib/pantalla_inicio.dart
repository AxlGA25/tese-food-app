import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'colores.dart';
import 'pantalla_login.dart';
import 'cafeteria.dart';

// Fondo compartido entre Splash y Decisión: degradado pastel claro con
// dos "ondas" pintadas a mano en las esquinas, como en la imagen de
// referencia (en vez de blobs difuminados).
class FondoOndasPremium extends StatelessWidget {
  final Widget child;
  const FondoOndasPremium({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [colorPastelOscuro, colorPastelClaro],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -40,
              child: CustomPaint(
                size: const Size(300, 360),
                painter: _PintorOnda(colorVerdeSuave.withValues(alpha: 0.85)),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -40,
              child: Transform.rotate(
                angle: math.pi,
                child: CustomPaint(
                  size: const Size(300, 360),
                  painter: _PintorOnda(colorSalvia.withValues(alpha: 0.55)),
                ),
              ),
            ),
            Positioned(
              top: 70,
              right: 24,
              child: Icon(
                Icons.local_pizza,
                size: 46,
                color: colorVerdeSuave.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              top: 150,
              left: 18,
              child: Icon(
                Icons.icecream,
                size: 38,
                color: colorVerdeSuave.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: 90,
              right: 40,
              child: Icon(
                Icons.local_cafe,
                size: 40,
                color: colorVerdeSuave.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: 170,
              left: 30,
              child: Icon(
                Icons.bakery_dining,
                size: 34,
                color: colorVerdeSuave.withValues(alpha: 0.16),
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

// Dibuja la "ondita" de la esquina: una forma orgánica con una línea
// dorada delgada trazando su borde, como en la imagen de referencia.
class _PintorOnda extends CustomPainter {
  final Color color;
  const _PintorOnda(this.color);

  Path _forma(Size size) {
    return Path()
      ..moveTo(0, size.height * 0.08)
      ..quadraticBezierTo(
        size.width * 0.62,
        -size.height * 0.05,
        size.width,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.58,
        size.height * 0.52,
        size.width * 0.18,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        -size.width * 0.05,
        size.height * 0.95,
        0,
        size.height * 0.55,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_forma(size), Paint()..color = color);

    final trazoDorado =
        Paint()
          ..color = colorAmarilloTese.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    final bordeSuperior =
        Path()
          ..moveTo(0, size.height * 0.08)
          ..quadraticBezierTo(
            size.width * 0.62,
            -size.height * 0.05,
            size.width,
            size.height * 0.3,
          );
    canvas.drawPath(bordeSuperior, trazoDorado);
  }

  @override
  bool shouldRepaint(covariant _PintorOnda oldDelegate) =>
      oldDelegate.color != color;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const DecisionScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
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
              duration: const Duration(milliseconds: 1500),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.55),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeSuave.withValues(alpha: 0.18),
                      blurRadius: 50,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'logo_app',
                  child: Image.asset(
                    'assets/logo_tesehambreado.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: Text(
                'TESE Hambreados',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: colorVerdeTese,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeInUp(
              delay: const Duration(milliseconds: 1200),
              child: Text(
                'Preparando tu pedido...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: colorVerdeSuave,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeIn(
              delay: const Duration(milliseconds: 1500),
              child: const CircularProgressIndicator(
                color: colorVerdeSuave,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FondoOndasPremium(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo_app',
                child: Image.asset(
                  'assets/logo_tesehambreado.png',
                  height: 170,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'TESE Hambreados',
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: colorVerdeTese,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sin filas, más receso.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: colorVerdeSuave,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 46),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.school, color: Colors.white),
                  label: Text(
                    'Soy Estudiante',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorVerdeSuave,
                    elevation: 4,
                    shadowColor: colorVerdeSuave.withValues(alpha: 0.4),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginEstudianteScreen(),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.storefront, color: colorVerdeSuave),
                  label: Text(
                    'Soy Cafetería / Local',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: colorVerdeSuave,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    side: const BorderSide(color: colorVerdeSuave, width: 1.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginLocalScreen(),
                        ),
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
