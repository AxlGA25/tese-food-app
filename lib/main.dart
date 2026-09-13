import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Letras bonitas
import 'package:animate_do/animate_do.dart';
import 'dart:math'; // NUEVO: Para generar el código aleatorio
import 'dart:async'; // Animaciones mágicas

void main() {
  runApp(const TeseHambreadosApp());
}

// ==========================================
// PALETA DE COLORES
// ==========================================
const Color colorVerdeTese = Color(0xFF0F4C3A);
const Color colorAmarilloTese = Color(0xFFF9A826);

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
        useMaterial3: true,
        // ¡Aplicamos la fuente Poppins a toda la app!
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const DecisionScreen(),
    );
  }
}

// ==========================================
// 1. PANTALLA DE DECISIÓN
// ==========================================
class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BounceInDown(
                // Animación de rebote al entrar
                child: const Icon(
                  Icons.fastfood,
                  size: 100,
                  color: colorVerdeTese,
                ),
              ),
              const SizedBox(height: 10),
              FadeIn(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'TESE Hambreados',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              FadeIn(
                delay: const Duration(milliseconds: 800),
                child: const Text(
                  'Sin filas, más receso.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 60),

              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.school, color: Colors.white),
                  label: const Text(
                    'Soy Estudiante',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAmarilloTese,
                    minimumSize: const Size(double.infinity, 60),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ), // Más redondeado
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
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 1200),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.storefront, color: colorVerdeTese),
                  label: const Text(
                    'Soy Cafetería / Local',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorVerdeTese,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    side: const BorderSide(color: colorVerdeTese, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. LOGIN ESTUDIANTE
// ==========================================
class LoginEstudianteScreen extends StatelessWidget {
  const LoginEstudianteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZoomIn(
              child: const Icon(Icons.person, size: 80, color: colorVerdeTese),
            ),
            const SizedBox(height: 30),
            FadeInLeft(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'No. Control',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerdeTese,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed:
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CatalogoEstudianteScreen(),
                      ),
                    ),
                child: const Text(
                  'Ingresar',
                  style: TextStyle(
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

// ==========================================
// ESTRUCTURA DE DATOS
// ==========================================
class Platillo {
  final String id;
  final String nombre;
  final String local;
  final double precio;

  Platillo({
    required this.id,
    required this.nombre,
    required this.local,
    required this.precio,
  });
}

// ==========================================
// 3. CATÁLOGO ESTUDIANTE (Interactivo y animado)
// ==========================================
class CatalogoEstudianteScreen extends StatefulWidget {
  const CatalogoEstudianteScreen({super.key});

  @override
  State<CatalogoEstudianteScreen> createState() =>
      _CatalogoEstudianteScreenState();
}

class _CatalogoEstudianteScreenState extends State<CatalogoEstudianteScreen> {
  List<Platillo> carrito = [];

  final List<Platillo> menuDisponibles = [
    Platillo(
      id: '1',
      nombre: 'Hamburguesa Clásica',
      local: 'Kiosko Sistemas',
      precio: 65.0,
    ),
    Platillo(
      id: '2',
      nombre: 'Chilaquiles Verdes',
      local: 'Cafetería Central',
      precio: 45.0,
    ),
    Platillo(
      id: '3',
      nombre: 'Orden de Tacos (4)',
      local: 'Cafetería Central',
      precio: 40.0,
    ),
    Platillo(
      id: '4',
      nombre: 'Jugo de Naranja',
      local: 'Jugos TESE',
      precio: 25.0,
    ),
    Platillo(
      id: '5',
      nombre: 'Papas a la Francesa',
      local: 'Kiosko Sistemas',
      precio: 30.0,
    ),
  ];

  void _agregarAlCarrito(Platillo p) {
    setState(() {
      carrito.add(p);
    });
    // Pequeña vibración visual (Feedback)
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡${p.nombre} agregado! 😋',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorVerdeTese,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating, // Flotante para verse moderno
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '¿Qué comeremos hoy?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: colorVerdeTese,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const DecisionScreen()),
                ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menuDisponibles.length,
        itemBuilder: (context, index) {
          final platillo = menuDisponibles[index];
          return FadeInUp(
            // <-- Animación de entrada en lista
            delay: Duration(milliseconds: 100 * index), // Escalado
            child: Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorAmarilloTese.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    color: colorAmarilloTese,
                    size: 30,
                  ),
                ),
                title: Text(
                  platillo.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  platillo.local,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${platillo.precio.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: colorVerdeTese,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: colorAmarilloTese,
                        size: 35,
                      ),
                      onPressed: () => _agregarAlCarrito(platillo),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // BOTÓN FLOTANTE CON BURBUJA DE NOTIFICACIÓN
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorVerdeTese,
        onPressed: () {
          if (carrito.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tu carrito está vacío')),
            );
            return;
          }
          // Navegar a la pantalla del carrito y actualizar al volver
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarritoScreen(carrito: carrito),
            ),
          ).then((_) => setState(() {}));
        },
        icon: Badge(
          isLabelVisible: carrito.isNotEmpty,
          label: Text(
            carrito.length.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          child: const Icon(Icons.shopping_cart, color: Colors.white),
        ),
        label: const Text(
          'Ver Pedido',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ==========================================
// 4. CARRITO (Modificado para generar código)
// ==========================================
class CarritoScreen extends StatefulWidget {
  final List<Platillo> carrito;
  const CarritoScreen({super.key, required this.carrito});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  @override
  Widget build(BuildContext context) {
    double total = widget.carrito.fold(0, (suma, item) => suma + item.precio);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Tu Orden',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorVerdeTese,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                widget.carrito.isEmpty
                    ? const Center(
                      child: Text(
                        'Carrito vacío',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: widget.carrito.length,
                      itemBuilder: (context, index) {
                        final item = widget.carrito[index];
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            setState(() {
                              widget.carrito.removeAt(index);
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                item.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                '\$${item.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a pagar:',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: colorVerdeTese,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAmarilloTese,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed:
                          widget.carrito.isEmpty
                              ? null
                              : () {
                                // 1. GENERAMOS EL CÓDIGO ALEATORIO AQUÍ
                                String codigoGenerado =
                                    '#TESE-${Random().nextInt(9000) + 1000}';

                                // 2. VIAJAMOS A LA SALA DE ESPERA MANDÁNDOLE EL CÓDIGO
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
                      child: const Text(
                        'Hacer Pedido',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

// ==========================================
// 5. SALA DE ESPERA (Simulador de Base de Datos)
// ==========================================
class SalaEsperaScreen extends StatefulWidget {
  final String codigoPedido; // Recibimos el código

  const SalaEsperaScreen({super.key, required this.codigoPedido});

  @override
  State<SalaEsperaScreen> createState() => _SalaEsperaScreenState();
}

class _SalaEsperaScreenState extends State<SalaEsperaScreen> {
  int estadoActual = 0; // 0: Recibido, 1: Cocinando, 2: Listo

  @override
  void initState() {
    super.initState();
    _simularAvancePedido();
  }

  // ¡Esto simula a Firebase! Cambia el estado cada 4 segundos mágicamente
  void _simularAvancePedido() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => estadoActual = 1); // Pasa a Preparando

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => estadoActual = 2); // Pasa a Listo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Rastreo de Pedido',
          style: TextStyle(color: colorVerdeTese, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // CÓDIGO DE ORDEN GIGANTE
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 40,
                ),
                decoration: BoxDecoration(
                  color: colorVerdeTese.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorVerdeTese, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TU CÓDIGO DE RECOLECCIÓN',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.codigoPedido,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: colorVerdeTese,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),

            // LÍNEA DE TIEMPO (ESTADOS)
            _construirEstado(
              titulo: 'Pedido Recibido',
              subtitulo: 'Esperando confirmación del local.',
              icono: Icons.receipt_long,
              estaActivo: estadoActual >= 0,
              estaCargando: estadoActual == 0,
            ),
            _construirLineaConectora(estaActivo: estadoActual >= 1),

            _construirEstado(
              titulo: 'En Preparación',
              subtitulo: '¡Tus hambreados se están cocinando!',
              icono: Icons.soup_kitchen,
              estaActivo: estadoActual >= 1,
              estaCargando: estadoActual == 1,
            ),
            _construirLineaConectora(estaActivo: estadoActual >= 2),

            _construirEstado(
              titulo: '¡Listo para recoger!',
              subtitulo: 'Muestra tu código en la ventanilla.',
              icono: Icons.check_circle,
              estaActivo: estadoActual >= 2,
              estaCargando: false,
            ),

            const Spacer(),

            // BOTÓN (Solo aparece cuando está listo)
            if (estadoActual == 2)
              ZoomIn(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAmarilloTese,
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
                              (context) => const CatalogoEstudianteScreen(),
                        ),
                      ),
                  child: const Text(
                    'Volver al Menú',
                    style: TextStyle(
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

  // WIDGETS AUXILIARES PARA DIBUJAR LA LÍNEA DE TIEMPO (TIMELINE)
  Widget _construirEstado({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required bool estaActivo,
    required bool estaCargando,
  }) {
    return Row(
      children: [
        // Circulito con ícono
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: estaActivo ? colorVerdeTese : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow:
                estaActivo
                    ? [
                      BoxShadow(
                        color: colorVerdeTese.withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ]
                    : [],
          ),
          child:
              estaCargando
                  ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  : Icon(icono, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 20),
        // Textos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: estaActivo ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                subtitulo,
                style: TextStyle(
                  fontSize: 14,
                  color: estaActivo ? Colors.black54 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirLineaConectora({required bool estaActivo}) {
    return Container(
      margin: const EdgeInsets.only(left: 28), // Alineado con el círculo
      height: 40,
      width: 4,
      color: estaActivo ? colorVerdeTese : Colors.grey[300],
      alignment: Alignment.centerLeft,
    );
  }
}
