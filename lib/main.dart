import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Letras bonitas
import 'package:animate_do/animate_do.dart'; // Animaciones mágicas

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
// 4. CARRITO (Con función "Swipe to Delete")
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
                        // WIDGET MÁGICO: Permite deslizar para borrar
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
          // Resumen de pago flotante
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
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const PedidoExitosoScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                      child: const Text(
                        'Confirmar Pedido',
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
// 5. PANTALLA DE ÉXITO (Súper satisfactoria)
// ==========================================
class PedidoExitosoScreen extends StatelessWidget {
  const PedidoExitosoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorVerdeTese,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElasticIn(
              // Rebote loco de éxito
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorAmarilloTese,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
                ),
                child: const Icon(Icons.check, size: 100, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: const Text(
                '¡Pedido Confirmado!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: const Text(
                'Tus hambreados favoritos\nestán siendo preparados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 50),
            FadeIn(
              delay: const Duration(milliseconds: 1000),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
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
                  'Volver al inicio',
                  style: TextStyle(
                    color: colorVerdeTese,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
