import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math';
import 'dart:async';
import 'cafeteria.dart';

void main() {
  runApp(const TeseHambreadosApp());
}

const Color colorVerdeTese = Color(0xFF0F4C3A);
const Color colorAmarilloTese = Color(0xFFF9A826);
const Color colorExito = Color(0xFF00A650);

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
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const DecisionScreen(),
    );
  }
}

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
                child: Hero(
                  tag: 'logo_app',
                  child: Image.asset(
                    'assets/logo_app.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 50),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Atrás'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              const SizedBox(height: 20),
              ZoomIn(
                child: Image.asset(
                  'assets/patito_login.png',
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              FadeInLeft(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Matrícula',
                    prefixIcon: const Icon(Icons.badge),
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
                    prefixIcon: const Icon(Icons.lock),
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
                          builder:
                              (context) => const CatalogoEstudianteScreen(),
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
              const SizedBox(height: 10),
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
                  child: const Text(
                    '¿No tienes cuenta? Crear una',
                    style: TextStyle(
                      color: colorAmarilloTese,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creando tu cuenta... 🦆'),
        backgroundColor: colorAmarilloTese,
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CatalogoEstudianteScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nuevo Estudiante',
          style: TextStyle(color: colorVerdeTese, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
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
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: colorAmarilloTese,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FadeInLeft(
              delay: const Duration(milliseconds: 100),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: const Icon(Icons.text_fields),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            FadeInRight(
              delay: const Duration(milliseconds: 200),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Matrícula',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            FadeInLeft(
              delay: const Duration(milliseconds: 300),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Carrera',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                value: carreraSeleccionada,
                items:
                    carrerasTese
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (val) => setState(() => carreraSeleccionada = val),
              ),
            ),
            const SizedBox(height: 15),
            FadeInRight(
              delay: const Duration(milliseconds: 400),
              child: TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            FadeInLeft(
              delay: const Duration(milliseconds: 500),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Crear Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerdeTese,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _simularRegistro,
                child: const Text(
                  'Registrarme',
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
  ];

  void _agregarAlCarrito(Platillo p) {
    setState(() {
      carrito.add(p);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡${p.nombre} agregado! 😋',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorVerdeTese,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
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
            delay: Duration(milliseconds: 100 * index),
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
                    color: colorAmarilloTese.withValues(alpha: 0.2),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorVerdeTese,
        onPressed: () {
          if (carrito.isEmpty) return;
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

class CarritoScreen extends StatefulWidget {
  final List<Platillo> carrito;
  const CarritoScreen({super.key, required this.carrito});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  String metodoPago = 'Efectivo';

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
                          onDismissed:
                              (direction) => setState(() {
                                widget.carrito.removeAt(index);
                              }),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Método de pago al recoger:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap:
                                () => setState(() => metodoPago = 'Efectivo'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    metodoPago == 'Efectivo'
                                        ? colorVerdeTese.withValues(alpha: 0.1)
                                        : Colors.white,
                                border: Border.all(
                                  color:
                                      metodoPago == 'Efectivo'
                                          ? colorVerdeTese
                                          : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.payments,
                                    color:
                                        metodoPago == 'Efectivo'
                                            ? colorVerdeTese
                                            : Colors.grey,
                                  ),
                                  Text(
                                    'Efectivo',
                                    style: TextStyle(
                                      color:
                                          metodoPago == 'Efectivo'
                                              ? colorVerdeTese
                                              : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: InkWell(
                            onTap:
                                () => setState(
                                  () => metodoPago = 'Terminal Bancaria',
                                ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    metodoPago == 'Terminal Bancaria'
                                        ? colorVerdeTese.withValues(alpha: 0.1)
                                        : Colors.white,
                                border: Border.all(
                                  color:
                                      metodoPago == 'Terminal Bancaria'
                                          ? colorVerdeTese
                                          : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color:
                                        metodoPago == 'Terminal Bancaria'
                                            ? colorVerdeTese
                                            : Colors.grey,
                                  ),
                                  Text(
                                    'Tarjeta',
                                    style: TextStyle(
                                      color:
                                          metodoPago == 'Terminal Bancaria'
                                              ? colorVerdeTese
                                              : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
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
                                String codigoGenerado =
                                    '#TESE-${Random().nextInt(9000) + 1000}';
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

class SalaEsperaScreen extends StatefulWidget {
  final String codigoPedido;
  const SalaEsperaScreen({super.key, required this.codigoPedido});

  @override
  State<SalaEsperaScreen> createState() => _SalaEsperaScreenState();
}

class _SalaEsperaScreenState extends State<SalaEsperaScreen> {
  int estadoActual = 0;
  @override
  void initState() {
    super.initState();
    _simularAvancePedido();
  }

  void _simularAvancePedido() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => estadoActual = 1);
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => estadoActual = 2);
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
          style: TextStyle(
            color: colorTextoTop,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        color: colorFondo,
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: _construirPantallaPorEstado(estadoActual),
          ),
        ),
      ),
    );
  }

  Widget _construirPantallaPorEstado(int estado) {
    if (estado == 0) {
      return _PantallaEstadoFull(
        key: const ValueKey(0),
        titulo: 'Pedido Recibido',
        subtitulo: 'Esperando que la cafetería confirme tu orden...',
        cargando: true,
        imagenAsset: 'assets/patito_recibido.png',
        colorTextoTitulo: colorVerdeTese,
        colorTextoSub: Colors.grey,
      );
    } else if (estado == 1) {
      return _PantallaEstadoFull(
        key: const ValueKey(1),
        titulo: 'En Preparación',
        subtitulo: '¡El chef ya está preparando tus hambreados!',
        cargando: true,
        imagenAsset: 'assets/patito_chef.png',
        colorTextoTitulo: colorVerdeTese,
        colorTextoSub: Colors.grey,
      );
    } else {
      return _PantallaEstadoFull(
        key: const ValueKey(2),
        titulo: '¡Ya está listo!',
        subtitulo:
            'Acércate a la ventanilla y muestra tu código para recoger tu comida.',
        cargando: false,
        mostrarBoton: true,
        imagenAsset: 'assets/patito_listo.png',
        colorTextoTitulo: Colors.white,
        colorTextoSub: Colors.white70,
      );
    }
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
            Image.asset(imagenAsset, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 40),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: colorTextoTitulo,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: colorTextoSub),
            ),
            const SizedBox(height: 40),
            if (cargando)
              const CircularProgressIndicator(color: colorAmarilloTese),
            if (mostrarBoton)
              ZoomIn(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
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
                      color: colorExito,
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
