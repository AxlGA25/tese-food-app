import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'main.dart';

class LoginLocalScreen extends StatelessWidget {
  const LoginLocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Atrás', style: TextStyle(color: Colors.blueGrey)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: const Icon(
                  Icons.storefront,
                  size: 100,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 20),
              FadeInDown(
                child: Text(
                  'Acceso a Locales',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                child: const Text(
                  'Ingresa tu código único de cafetería',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                child: TextField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej. CAFE-9999',
                    prefixIcon: const Icon(Icons.key, color: Colors.blueGrey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
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
                              (context) => const DashboardNavegacionLocal(),
                        ),
                      ),
                  child: const Text(
                    'Abrir Panel de Pedidos',
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
      ),
    );
  }
}

class ComandaDummy {
  final String idPedido;
  final String alumno;
  final String detalle;
  final String metodoPago;
  final String notas;
  final double total;
  int estado;
  ComandaDummy(
    this.idPedido,
    this.alumno,
    this.detalle,
    this.metodoPago,
    this.notas,
    this.total,
    this.estado,
  );
}

class PlatilloLocal {
  final String nombre;
  final double precio;
  final bool disponible;
  PlatilloLocal(this.nombre, this.precio, this.disponible);
}

class DashboardNavegacionLocal extends StatefulWidget {
  const DashboardNavegacionLocal({super.key});

  @override
  State<DashboardNavegacionLocal> createState() =>
      _DashboardNavegacionLocalState();
}

class _DashboardNavegacionLocalState extends State<DashboardNavegacionLocal> {
  int _indiceActual = 0;

  final List<ComandaDummy> pedidosActivos = [
    ComandaDummy(
      '#TESE-4029',
      'Axel Guerrero',
      '1x Hamb. Clásica\n1x Jugo Naranja',
      'Terminal Bancaria',
      'Sin cebolla ni tomate',
      90.0,
      0,
    ),
    ComandaDummy(
      '#TESE-8112',
      'Dana Patricia',
      '2x Chilaquiles Verdes',
      'Efectivo',
      'Con extra queso',
      90.0,
      1,
    ),
    ComandaDummy(
      '#TESE-1993',
      'Profe. Informática',
      '1x Orden Tacos',
      'Efectivo',
      'Salsa aparte',
      40.0,
      2,
    ),
  ];

  final List<PlatilloLocal> miMenu = [
    PlatilloLocal('Hamburguesa Clásica', 65.0, true),
    PlatilloLocal('Papas a la Francesa', 30.0, true),
    PlatilloLocal('Jugo de Naranja', 25.0, false),
  ];

  void _agregarNuevoPlatillo(PlatilloLocal nuevoPlatillo) {
    setState(() {
      miMenu.add(nuevoPlatillo);
    });
  }

  void _mostrarDetallePedido(
    ComandaDummy comanda,
    int index,
    Color colorEstado,
    String textoBoton,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comanda.idPedido,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colorEstado,
                      ),
                    ),
                    Text(
                      '\$${comanda.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      comanda.alumno,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                const Text(
                  'Artículos:',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  comanda.detalle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notas del cliente:',
                        style: TextStyle(fontSize: 14, color: Colors.amber),
                      ),
                      Text(
                        comanda.notas,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      comanda.metodoPago == 'Efectivo'
                          ? Icons.payments
                          : Icons.credit_card,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pago con: ${comanda.metodoPago}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorEstado,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        if (comanda.estado < 2) {
                          comanda.estado++;
                        } else {
                          pedidosActivos.removeAt(index);
                        }
                      });
                    },
                    child: Text(
                      textoBoton,
                      style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Kiosko Sistemas',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _indiceActual == 0 ? _vistaPedidos() : _vistaMenu(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) => setState(() => _indiceActual = index),
        selectedItemColor: colorAmarilloTese,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Mi Menú',
          ),
        ],
      ),
    );
  }

  Widget _vistaPedidos() {
    return ListView.builder(
      key: const ValueKey('pedidos'),
      padding: const EdgeInsets.all(16),
      itemCount: pedidosActivos.length,
      itemBuilder: (context, index) {
        final comanda = pedidosActivos[index];
        Color colorEstado = Colors.grey;
        String textoBoton = '';
        IconData iconoEstado = Icons.receipt;

        if (comanda.estado == 0) {
          colorEstado = Colors.redAccent;
          textoBoton = 'Empezar a Preparar';
          iconoEstado = Icons.notifications_active;
        } else if (comanda.estado == 1) {
          colorEstado = colorAmarilloTese;
          textoBoton = '¡Marcar como Listo!';
          iconoEstado = Icons.soup_kitchen;
        } else {
          colorEstado = colorExito;
          textoBoton = 'Entregado (Quitar de lista)';
          iconoEstado = Icons.check_circle;
        }

        return FadeInUp(
          child: GestureDetector(
            onTap:
                () => _mostrarDetallePedido(
                  comanda,
                  index,
                  colorEstado,
                  textoBoton,
                ),
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: colorEstado, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comanda.idPedido,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: colorEstado,
                          ),
                        ),
                        Chip(
                          avatar: Icon(
                            iconoEstado,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            comanda.estado == 0
                                ? 'NUEVO'
                                : (comanda.estado == 1
                                    ? 'PREPARANDO'
                                    : 'LISTO'),
                          ),
                          backgroundColor: colorEstado,
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      'Alumno: ${comanda.alumno}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      comanda.detalle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          comanda.metodoPago == 'Efectivo'
                              ? Icons.payments
                              : Icons.credit_card,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          comanda.metodoPago,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Toca la tarjeta para ver detalles y procesar',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _vistaMenu() {
    return Scaffold(
      key: const ValueKey('menu'),
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: miMenu.length,
        itemBuilder: (context, index) {
          final platillo = miMenu[index];
          return FadeInUp(
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fastfood, color: Colors.blueGrey),
                ),
                title: Text(
                  platillo.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  '\$${platillo.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: colorExito,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: Switch(
                  value: platillo.disponible,
                  activeColor: colorExito,
                  onChanged: (val) {
                    setState(() {
                      miMenu[index] = PlatilloLocal(
                        platillo.nombre,
                        platillo.precio,
                        val,
                      );
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorAmarilloTese,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Platillo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final PlatilloLocal? nuevo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarPlatilloScreen(),
            ),
          );
          if (nuevo != null) {
            _agregarNuevoPlatillo(nuevo);
          }
        },
      ),
    );
  }
}

class AgregarPlatilloScreen extends StatefulWidget {
  const AgregarPlatilloScreen({super.key});

  @override
  State<AgregarPlatilloScreen> createState() => _AgregarPlatilloScreenState();
}

class _AgregarPlatilloScreenState extends State<AgregarPlatilloScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();

  void _guardarPlatillo() {
    if (_nombreCtrl.text.isEmpty || _precioCtrl.text.isEmpty) return;
    final nuevoPlatillo = PlatilloLocal(
      _nombreCtrl.text,
      double.parse(_precioCtrl.text),
      true,
    );
    Navigator.pop(context, nuevoPlatillo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Agregar Platillo',
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            FadeInDown(
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'Subir foto del platillo',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeInLeft(
              child: TextField(
                controller: _nombreCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre del Platillo',
                  prefixIcon: const Icon(Icons.restaurant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInRight(
              child: TextField(
                controller: _precioCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Precio (\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAmarilloTese,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _guardarPlatillo,
                child: const Text(
                  'Guardar en el Menú',
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
