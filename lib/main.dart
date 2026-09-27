import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'cafeteria.dart';

void main() {
  runApp(const TeseHambreadosApp());
}

// Paleta de marca original (se conservan los nombres: cafeteria.dart los usa)
const Color colorVerdeTese = Color(0xFF0F4C3A);
const Color colorAmarilloTese = Color(0xFFF9A826);
const Color colorExito = Color(0xFF00A650);

// Tokens de apoyo nuevos, solo para dar más calidez y jerarquía visual
const Color colorVerdeOscuro = Color(0xFF08261D);
const Color colorFondoCrema = Color(0xFFFBF6EE);
const Color colorTextoOscuro = Color(0xFF1E2B26);
const Color colorTextoGris = Color(0xFF7C8B85);

class TeseHambreadosApp extends StatelessWidget {
  const TeseHambreadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TESE Hambreados',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorVerdeTese,
          primary: colorVerdeTese,
          secondary: colorAmarilloTese,
        ),
        scaffoldBackgroundColor: colorFondoCrema,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}

class FondoOndasPremium extends StatelessWidget {
  final Widget child;
  const FondoOndasPremium({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorVerdeOscuro,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: const BoxDecoration(
                color: colorVerdeTese,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFF1A7A5E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                color: colorVerdeTese,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorAmarilloTese.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: 70,
            right: 24,
            child: Icon(
              Icons.local_pizza,
              size: 46,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 150,
            left: 18,
            child: Icon(
              Icons.icecream,
              size: 38,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 40,
            child: Icon(
              Icons.local_cafe,
              size: 40,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: 170,
            left: 30,
            child: Icon(
              Icons.bakery_dining,
              size: 34,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
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
                  color: Colors.white.withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: colorAmarilloTese.withValues(alpha: 0.25),
                      blurRadius: 60,
                      spreadRadius: 10,
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
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeInUp(
              delay: const Duration(milliseconds: 1200),
              child: Text(
                'Preparando la cocina...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: colorAmarilloTese,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeIn(
              delay: const Duration(milliseconds: 1500),
              child: const CircularProgressIndicator(
                color: Colors.white,
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sin filas, más receso.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 46),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.school, color: colorVerdeOscuro),
                  label: Text(
                    'Soy Estudiante',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: colorVerdeOscuro,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAmarilloTese,
                    elevation: 6,
                    shadowColor: Colors.black.withValues(alpha: 0.4),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
                  icon: const Icon(Icons.storefront, color: Colors.white),
                  label: Text(
                    'Soy Cafetería / Local',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    side: const BorderSide(color: Colors.white, width: 1.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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

class LoginEstudianteScreen extends StatelessWidget {
  const LoginEstudianteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: colorVerdeTese),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Text(
                  'Inicio de Sesión',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Entra y pide sin hacer fila',
                style: GoogleFonts.poppins(fontSize: 14, color: colorTextoGris),
              ),
              const SizedBox(height: 16),
              ZoomIn(
                child: Image.asset(
                  'assets/patito_login.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeTese.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    FadeInLeft(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Matrícula',
                          prefixIcon: const Icon(
                            Icons.badge,
                            color: colorVerdeTese,
                          ),
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInRight(
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: colorVerdeTese,
                          ),
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    FadeInUp(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorVerdeTese,
                            elevation: 4,
                            shadowColor: colorVerdeTese.withValues(alpha: 0.5),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed:
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const NavegacionEstudiante(),
                                ),
                              ),
                          child: Text(
                            'Ingresar',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const RegistroEstudianteScreen(),
                        ),
                      ),
                  child: Text(
                    '¿No tienes cuenta? Crear una',
                    style: GoogleFonts.poppins(
                      color: colorAmarilloTese,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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

class RegistroEstudianteScreen extends StatefulWidget {
  const RegistroEstudianteScreen({super.key});

  @override
  State<RegistroEstudianteScreen> createState() =>
      _RegistroEstudianteScreenState();
}

class _RegistroEstudianteScreenState extends State<RegistroEstudianteScreen> {
  String? carreraSeleccionada;
  final List<String> carrerasTese = [
    'Ing. en Sistemas Computacionales',
    'Ing. Informática',
    'Ing. Electrónica',
    'Arquitectura',
    'Contaduría',
    'Otra',
  ];

  void _simularRegistro() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const NavegacionEstudiante()),
      (route) => false,
    );
  }

  InputDecoration _decoracionCampo(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: colorVerdeTese),
      filled: true,
      fillColor: colorFondoCrema,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Nuevo Estudiante',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: colorVerdeTese),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            FadeInDown(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorAmarilloTese, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: colorVerdeTese.withValues(alpha: 0.08),
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: colorVerdeTese,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorAmarilloTese,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorAmarilloTese.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  FadeInLeft(
                    delay: const Duration(milliseconds: 100),
                    child: TextField(
                      decoration: _decoracionCampo(
                        'Nombre Completo',
                        Icons.text_fields,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInRight(
                    delay: const Duration(milliseconds: 200),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: _decoracionCampo('Matrícula', Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 300),
                    child: DropdownButtonFormField<String>(
                      decoration: _decoracionCampo('Carrera', Icons.school),
                      value: carreraSeleccionada,
                      items:
                          carrerasTese
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() => carreraSeleccionada = val),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInRight(
                    delay: const Duration(milliseconds: 400),
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: _decoracionCampo('Teléfono', Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 500),
                    child: TextField(
                      obscureText: true,
                      decoration: _decoracionCampo(
                        'Crear Contraseña',
                        Icons.lock,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerdeTese,
                  elevation: 4,
                  shadowColor: colorVerdeTese.withValues(alpha: 0.5),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _simularRegistro,
                child: Text(
                  'Registrarme',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Platillo {
  final String id;
  final String nombre;
  final String local;
  final double precio;
  final String categoria;
  final IconData icono;
  Platillo({
    required this.id,
    required this.nombre,
    required this.local,
    required this.precio,
    this.categoria = 'Comida',
    this.icono = Icons.fastfood,
  });
}

class NavegacionEstudiante extends StatefulWidget {
  const NavegacionEstudiante({super.key});

  @override
  State<NavegacionEstudiante> createState() => _NavegacionEstudianteState();
}

class _NavegacionEstudianteState extends State<NavegacionEstudiante> {
  int _indiceActual = 0;
  List<Platillo> carritoGlobal = [];

  void _actualizarCarrito(Platillo p) {
    setState(() {
      carritoGlobal.add(p);
    });
  }

  void _limpiarCarrito() {
    setState(() {
      carritoGlobal.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      CatalogoEstudianteScreen(
        carrito: carritoGlobal,
        onAgregar: _actualizarCarrito,
      ),
      const PerfilEstudianteScreen(),
    ];

    return Scaffold(
      backgroundColor: colorFondoCrema,
      extendBody: true,
      body: pantallas[_indiceActual],
      bottomNavigationBar: CurvedNavigationBar(
        index: _indiceActual,
        height: 58,
        backgroundColor: Colors.transparent,
        color: colorVerdeTese,
        buttonBackgroundColor: colorAmarilloTese,
        animationDuration: const Duration(milliseconds: 400),
        animationCurve: Curves.easeOutBack,
        items: [
          Icon(
            Icons.fastfood,
            size: 26,
            color: _indiceActual == 0 ? colorVerdeOscuro : Colors.white,
          ),
          Icon(
            Icons.person,
            size: 26,
            color: _indiceActual == 1 ? colorVerdeOscuro : Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
      ),
      floatingActionButton:
          _indiceActual == 0
              ? FloatingActionButton.extended(
                backgroundColor: colorAmarilloTese,
                elevation: 6,
                onPressed: () {
                  if (carritoGlobal.isEmpty) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CarritoScreen(
                            carrito: carritoGlobal,
                            onVaciar: _limpiarCarrito,
                          ),
                    ),
                  ).then((_) => setState(() {}));
                },
                icon: Badge(
                  isLabelVisible: carritoGlobal.isNotEmpty,
                  label: Text(
                    carritoGlobal.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: colorExito,
                  child: const Icon(Icons.shopping_cart, color: Colors.white),
                ),
                label: Text(
                  'Ver Pedido',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
    );
  }
}

class CatalogoEstudianteScreen extends StatefulWidget {
  final List<Platillo> carrito;
  final Function(Platillo) onAgregar;
  const CatalogoEstudianteScreen({
    super.key,
    required this.carrito,
    required this.onAgregar,
  });

  @override
  State<CatalogoEstudianteScreen> createState() =>
      _CatalogoEstudianteScreenState();
}

class _CatalogoEstudianteScreenState extends State<CatalogoEstudianteScreen> {
  final List<Platillo> menuDisponibles = [
    Platillo(
      id: '1',
      nombre: 'Chilaquiles Verdes',
      local: 'Cafetería Central',
      precio: 45.0,
      categoria: 'Desayunos',
      icono: Icons.breakfast_dining,
    ),
    Platillo(
      id: '2',
      nombre: 'Hot Cakes con Miel',
      local: 'Cafetería Central',
      precio: 35.0,
      categoria: 'Desayunos',
      icono: Icons.bakery_dining,
    ),
    Platillo(
      id: '3',
      nombre: 'Licuado de Fresa',
      local: 'Jugos TESE',
      precio: 30.0,
      categoria: 'Desayunos',
      icono: Icons.local_drink,
    ),
    Platillo(
      id: '4',
      nombre: 'Hamburguesa Clásica',
      local: 'Kiosko Sistemas',
      precio: 65.0,
      categoria: 'Comida',
      icono: Icons.lunch_dining,
    ),
    Platillo(
      id: '5',
      nombre: 'Orden de Tacos (4)',
      local: 'Cafetería Central',
      precio: 40.0,
      categoria: 'Comida',
      icono: Icons.dinner_dining,
    ),
    Platillo(
      id: '6',
      nombre: 'Torta de Milanesa',
      local: 'Kiosko Sistemas',
      precio: 55.0,
      categoria: 'Comida',
      icono: Icons.fastfood,
    ),
    Platillo(
      id: '7',
      nombre: 'Arroz con Pollo',
      local: 'Cafetería Central',
      precio: 50.0,
      categoria: 'Comida',
      icono: Icons.rice_bowl,
    ),
    Platillo(
      id: '8',
      nombre: 'Jugo de Naranja',
      local: 'Jugos TESE',
      precio: 25.0,
      categoria: 'Bebidas',
      icono: Icons.emoji_food_beverage,
    ),
    Platillo(
      id: '9',
      nombre: 'Café Americano',
      local: 'Cafetería Central',
      precio: 20.0,
      categoria: 'Bebidas',
      icono: Icons.coffee,
    ),
    Platillo(
      id: '10',
      nombre: 'Gelatina de Mosaico',
      local: 'Cafetería Central',
      precio: 15.0,
      categoria: 'Postres',
      icono: Icons.icecream,
    ),
    Platillo(
      id: '11',
      nombre: 'Pay de Queso',
      local: 'Kiosko Sistemas',
      precio: 30.0,
      categoria: 'Postres',
      icono: Icons.cake,
    ),
  ];

  final List<String> _categorias = const [
    'Todos',
    'Desayunos',
    'Comida',
    'Bebidas',
    'Postres',
  ];
  String _categoriaSeleccionada = 'Todos';

  final TextEditingController _busquedaCtrl = TextEditingController();
  String _terminoBusqueda = '';

  int _promoIndex = 0;
  final List<String> promociones = [
    '¡2x1 en Chilaquiles hoy!',
    'Combo Godín a solo \$50',
    'Postre gratis en compras > \$100',
  ];

  List<Platillo> get _platillosFiltrados {
    return menuDisponibles.where((p) {
      final coincideCategoria =
          _categoriaSeleccionada == 'Todos' ||
          p.categoria == _categoriaSeleccionada;
      final coincideBusqueda =
          _terminoBusqueda.isEmpty ||
          p.nombre.toLowerCase().contains(_terminoBusqueda.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _mostrarAlertaExito(String nombre) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: '¡Añadido!',
        message: 'Has agregado $nombre a tu carrito 😋',
        contentType: ContentType.success,
        color: colorExito,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final platillosFiltrados = _platillosFiltrados;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorVerdeTese, colorFondoCrema],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  '¿Qué comeremos hoy?',
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Text(
                  'Ordena y recógelo directo en el receso',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _busquedaCtrl,
                  onChanged:
                      (valor) => setState(() => _terminoBusqueda = valor),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorTextoOscuro,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Busca tu antojo...',
                    hintStyle: GoogleFonts.poppins(
                      color: colorTextoGris,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: colorVerdeTese),
                    suffixIcon:
                        _terminoBusqueda.isEmpty
                            ? null
                            : IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: colorTextoGris,
                                size: 18,
                              ),
                              onPressed: () {
                                _busquedaCtrl.clear();
                                setState(() => _terminoBusqueda = '');
                              },
                            ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categorias.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];
                    final seleccionada = categoria == _categoriaSeleccionada;
                    return GestureDetector(
                      onTap:
                          () => setState(
                            () => _categoriaSeleccionada = categoria,
                          ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: seleccionada ? colorVerdeTese : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow:
                              seleccionada
                                  ? []
                                  : [
                                    BoxShadow(
                                      color: colorVerdeTese.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                        ),
                        child: Text(
                          categoria,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: seleccionada ? Colors.white : colorTextoGris,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              CarouselSlider(
                options: CarouselOptions(
                  height: 130.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  onPageChanged:
                      (index, reason) => setState(() => _promoIndex = index),
                ),
                items:
                    promociones.map((texto) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [colorAmarilloTese, Color(0xFFF07B1D)],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: 46,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      texto,
                                      style: GoogleFonts.poppins(
                                        fontSize: 17.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 8),
              Center(
                child: AnimatedSmoothIndicator(
                  activeIndex: _promoIndex,
                  count: promociones.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    activeDotColor: colorVerdeTese,
                    dotColor: colorVerdeTese.withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    platillosFiltrados.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 52,
                                color: colorTextoGris.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No encontramos nada con eso',
                                style: GoogleFonts.poppins(
                                  color: colorTextoGris,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          itemCount: platillosFiltrados.length,
                          itemBuilder: (context, index) {
                            final platillo = platillosFiltrados[index];
                            return FadeInUp(
                              delay: Duration(milliseconds: 70 * index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorVerdeTese.withValues(
                                        alpha: 0.07,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: colorVerdeTese.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        platillo.icono,
                                        color: colorVerdeTese,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            platillo.nombre,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.5,
                                              color: colorTextoOscuro,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            platillo.local,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.5,
                                              color: colorTextoGris,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorVerdeTese.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              '\$${platillo.precio.toInt()}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                color: colorVerdeTese,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: colorAmarilloTese,
                                        size: 36,
                                      ),
                                      onPressed: () {
                                        widget.onAgregar(platillo);
                                        _mostrarAlertaExito(platillo.nombre);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PerfilEstudianteScreen extends StatelessWidget {
  const PerfilEstudianteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorAmarilloTese, width: 3),
              ),
              child: const CircleAvatar(
                radius: 56,
                backgroundColor: colorVerdeTese,
                child: Icon(Icons.person, size: 68, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Axel Guerrero',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorVerdeTese,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _FilaInfoPerfil(
                    icono: Icons.badge_outlined,
                    etiqueta: 'Matrícula',
                    valor: '20240001',
                  ),
                  const Divider(height: 1),
                  _FilaInfoPerfil(
                    icono: Icons.school_outlined,
                    etiqueta: 'Carrera',
                    valor: 'Ing. en Sistemas Computacionales',
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed:
                    () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DecisionScreen(),
                      ),
                      (route) => false,
                    ),
                icon: const Icon(Icons.logout),
                label: Text(
                  'Cerrar Sesión',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FilaInfoPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _FilaInfoPerfil({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icono, color: colorVerdeTese, size: 20),
          const SizedBox(width: 12),
          Text(
            etiqueta,
            style: GoogleFonts.poppins(color: colorTextoGris, fontSize: 13.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: colorTextoOscuro,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CarritoScreen extends StatefulWidget {
  final List<Platillo> carrito;
  final VoidCallback onVaciar;
  const CarritoScreen({
    super.key,
    required this.carrito,
    required this.onVaciar,
  });

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  String metodoPago = 'Efectivo';

  @override
  Widget build(BuildContext context) {
    double total = widget.carrito.fold(0, (suma, item) => suma + item.precio);

    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Tu Orden',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorVerdeTese,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                widget.carrito.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 72,
                            color: colorTextoGris.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Tu carrito está vacío',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: colorTextoGris,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Agrega algo rico desde el menú',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: colorTextoGris.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.carrito.length,
                      itemBuilder: (context, index) {
                        final item = widget.carrito[index];
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          onDismissed:
                              (direction) => setState(() {
                                widget.carrito.removeAt(index);
                              }),
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colorVerdeTese.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.nombre,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              trailing: Text(
                                '\$${item.precio.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: colorVerdeTese,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Método de pago al recoger:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap:
                                () => setState(() => metodoPago = 'Efectivo'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color:
                                    metodoPago == 'Efectivo'
                                        ? colorVerdeTese.withValues(alpha: 0.1)
                                        : colorFondoCrema,
                                border: Border.all(
                                  color:
                                      metodoPago == 'Efectivo'
                                          ? colorVerdeTese
                                          : Colors.transparent,
                                  width: 1.4,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.payments,
                                    color:
                                        metodoPago == 'Efectivo'
                                            ? colorVerdeTese
                                            : colorTextoGris,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Efectivo',
                                    style: GoogleFonts.poppins(
                                      color:
                                          metodoPago == 'Efectivo'
                                              ? colorVerdeTese
                                              : colorTextoGris,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap:
                                () => setState(
                                  () => metodoPago = 'Terminal Bancaria',
                                ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color:
                                    metodoPago == 'Terminal Bancaria'
                                        ? colorVerdeTese.withValues(alpha: 0.1)
                                        : colorFondoCrema,
                                border: Border.all(
                                  color:
                                      metodoPago == 'Terminal Bancaria'
                                          ? colorVerdeTese
                                          : Colors.transparent,
                                  width: 1.4,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color:
                                        metodoPago == 'Terminal Bancaria'
                                            ? colorVerdeTese
                                            : colorTextoGris,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tarjeta',
                                    style: GoogleFonts.poppins(
                                      color:
                                          metodoPago == 'Terminal Bancaria'
                                              ? colorVerdeTese
                                              : colorTextoGris,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total a pagar:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: colorTextoGris,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: colorVerdeTese,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAmarilloTese,
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 4,
                          shadowColor: colorAmarilloTese.withValues(alpha: 0.5),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed:
                            widget.carrito.isEmpty
                                ? null
                                : () {
                                  String codigoGenerado =
                                      '#TESE-${Random().nextInt(9000) + 1000}';
                                  widget.onVaciar();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SalaEsperaScreen(
                                            codigoPedido: codigoGenerado,
                                          ),
                                    ),
                                    (route) => false,
                                  );
                                },
                        child: Text(
                          'Confirmar Pedido',
                          style: GoogleFonts.poppins(
                            color: colorVerdeOscuro,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SalaEsperaScreen extends StatefulWidget {
  final String codigoPedido;
  const SalaEsperaScreen({super.key, required this.codigoPedido});

  @override
  State<SalaEsperaScreen> createState() => _SalaEsperaScreenState();
}

class _SalaEsperaScreenState extends State<SalaEsperaScreen> {
  int estadoActual = 0;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _simularAvancePedido();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _simularAvancePedido() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => estadoActual = 1);
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() => estadoActual = 2);
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color colorFondo = estadoActual == 2 ? colorExito : Colors.white;
    Color colorTextoTop = estadoActual == 2 ? Colors.white : colorVerdeTese;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Orden: ${widget.codigoPedido}',
          style: GoogleFonts.poppins(
            color: colorTextoTop,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            color: colorFondo,
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  _BarraProgresoPedido(
                    estadoActual: estadoActual,
                    colorTexto: colorTextoTop,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: _construirPantallaPorEstado(estadoActual),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 24,
              gravity: 0.25,
              colors: const [
                colorAmarilloTese,
                colorExito,
                Colors.white,
                colorVerdeTese,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirPantallaPorEstado(int estado) {
    if (estado == 0) {
      return _PantallaEstadoFull(
        key: const ValueKey(0),
        titulo: 'Pedido Recibido',
        subtitulo: 'Esperando confirmación...',
        cargando: true,
        imagenAsset: 'assets/patito_recibido.png',
        colorTextoTitulo: colorVerdeTese,
        colorTextoSub: colorTextoGris,
      );
    } else if (estado == 1) {
      return _PantallaEstadoFull(
        key: const ValueKey(1),
        titulo: 'En Preparación',
        subtitulo: '¡Preparando tus hambreados!',
        cargando: true,
        imagenAsset: 'assets/patito_chef.png',
        colorTextoTitulo: colorVerdeTese,
        colorTextoSub: colorTextoGris,
      );
    } else {
      return _PantallaEstadoFull(
        key: const ValueKey(2),
        titulo: '¡Ya está listo!',
        subtitulo: 'Muestra tu código para recoger tu comida.',
        cargando: false,
        mostrarBoton: true,
        imagenAsset: 'assets/patito_listo.png',
        colorTextoTitulo: Colors.white,
        colorTextoSub: Colors.white70,
      );
    }
  }
}

class _BarraProgresoPedido extends StatelessWidget {
  final int estadoActual;
  final Color colorTexto;
  const _BarraProgresoPedido({
    required this.estadoActual,
    required this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    final etiquetas = ['Recibido', 'Preparando', 'Listo'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: List.generate(etiquetas.length * 2 - 1, (i) {
          if (i.isOdd) {
            final indiceSegmento = (i - 1) ~/ 2;
            final activo = estadoActual > indiceSegmento;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color:
                    activo
                        ? colorTexto.withValues(alpha: 0.9)
                        : colorTexto.withValues(alpha: 0.25),
              ),
            );
          }
          final indicePaso = i ~/ 2;
          final activo = estadoActual >= indicePaso;
          return Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activo ? colorTexto : Colors.transparent,
                  border: Border.all(color: colorTexto, width: 2),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                etiquetas[indicePaso],
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: colorTexto,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PantallaEstadoFull extends StatelessWidget {
  final String titulo, subtitulo, imagenAsset;
  final bool cargando, mostrarBoton;
  final Color colorTextoTitulo, colorTextoSub;
  const _PantallaEstadoFull({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.cargando,
    this.mostrarBoton = false,
    required this.imagenAsset,
    required this.colorTextoTitulo,
    required this.colorTextoSub,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagenAsset, height: 230, fit: BoxFit.contain),
            const SizedBox(height: 32),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: colorTextoTitulo,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: colorTextoSub),
            ),
            const SizedBox(height: 36),
            if (cargando)
              const CircularProgressIndicator(
                color: colorAmarilloTese,
                strokeWidth: 2.6,
              ),
            if (mostrarBoton)
              ZoomIn(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 4,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed:
                        () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavegacionEstudiante(),
                          ),
                          (route) => false,
                        ),
                    child: Text(
                      'Volver al Menú',
                      style: GoogleFonts.poppins(
                        color: colorExito,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
