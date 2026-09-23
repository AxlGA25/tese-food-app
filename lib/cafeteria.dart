import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'main.dart';

class LoginLocalScreen extends StatelessWidget {
  const LoginLocalScreen({super.key});

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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                child: Image.asset(
                  'assets/pedidoParaEntregar.png',
                  height: 170,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              FadeInDown(
                child: Text(
                  'Acceso a Locales',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeInDown(
                child: Text(
                  'Ingresa tu código único de cafetería',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorTextoGris,
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                    FadeInUp(
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: colorTextoOscuro,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ej. CAFE-9999',
                          prefixIcon: const Icon(
                            Icons.key,
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
                    const SizedBox(height: 22),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
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
                                      (context) =>
                                          const DashboardNavegacionLocal(),
                                ),
                              ),
                          child: Text(
                            'Abrir Panel de Pedidos',
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

  // El amarillo de marca es claro: sobre ese fondo se usa texto verde oscuro
  // para mantener buen contraste; en rojo/verde el texto blanco ya se lee bien.
  Color _colorTextoSobre(Color fondo) {
    return fondo == colorAmarilloTese ? colorVerdeOscuro : Colors.white;
  }

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
    String imagenPatito = 'assets/pedidoPendiente.png';
    if (comanda.estado == 1) imagenPatito = 'assets/listoParaRecoger.png';
    if (comanda.estado == 2) imagenPatito = 'assets/disfrutaTuComida.png';

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

                Center(
                  child: BounceInDown(
                    child: Image.asset(
                      imagenPatito,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comanda.idPedido,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: colorEstado,
                      ),
                    ),
                    Text(
                      '\$${comanda.total.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorVerdeTese,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: colorVerdeTese,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      comanda.alumno,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorTextoOscuro,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Text(
                  'Artículos:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorTextoGris,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  comanda.detalle,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colorTextoOscuro,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorAmarilloTese.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorAmarilloTese.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notas del cliente:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: colorAmarilloTese,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comanda.notas,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorTextoOscuro,
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
                      color: colorVerdeTese,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pago con: ${comanda.metodoPago}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorTextoOscuro,
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
                      elevation: 3,
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
                      style: GoogleFonts.poppins(
                        color: _colorTextoSobre(colorEstado),
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
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Kiosko Sistemas',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorVerdeTese,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) => setState(() => _indiceActual = index),
          selectedItemColor: colorVerdeTese,
          unselectedItemColor: colorTextoGris,
          backgroundColor: Colors.white,
          elevation: 0,
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
      ),
    );
  }

  Widget _vistaPedidos() {
    if (pedidosActivos.isEmpty) {
      return Center(
        key: const ValueKey('sinPedidos'),
        child: FadeInUp(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/esperandoPedido.png',
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                'No hay pedidos activos',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorVerdeTese,
                ),
              ),
              Text(
                'La cafetería está al día.',
                style: GoogleFonts.poppins(fontSize: 15, color: colorTextoGris),
              ),
            ],
          ),
        ),
      );
    }

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
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 5, color: colorEstado),
                      Expanded(
                        child: _contenidoTarjetaPedido(
                          comanda,
                          iconoEstado,
                          colorEstado,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _contenidoTarjetaPedido(
    ComandaDummy comanda,
    IconData iconoEstado,
    Color colorEstado,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comanda.idPedido,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colorEstado,
                ),
              ),
              Chip(
                avatar: Icon(
                  iconoEstado,
                  color: _colorTextoSobre(colorEstado),
                  size: 18,
                ),
                label: Text(
                  comanda.estado == 0
                      ? 'NUEVO'
                      : (comanda.estado == 1 ? 'PREPARANDO' : 'LISTO'),
                ),
                backgroundColor: colorEstado,
                labelStyle: GoogleFonts.poppins(
                  color: _colorTextoSobre(colorEstado),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(),
          Text(
            'Alumno: ${comanda.alumno}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorTextoOscuro,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            comanda.detalle,
            style: GoogleFonts.poppins(fontSize: 14.5, color: colorTextoOscuro),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                comanda.metodoPago == 'Efectivo'
                    ? Icons.payments
                    : Icons.credit_card,
                size: 16,
                color: colorTextoGris,
              ),
              const SizedBox(width: 5),
              Text(
                comanda.metodoPago,
                style: GoogleFonts.poppins(
                  color: colorTextoGris,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Toca la tarjeta para ver detalles y procesar',
              style: GoogleFonts.poppins(
                color: colorVerdeTese,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorVerdeTese.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fastfood, color: colorVerdeTese),
                ),
                title: Text(
                  platillo.nombre,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: colorTextoOscuro,
                  ),
                ),
                subtitle: Text(
                  '\$${platillo.precio.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    color: colorExito,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
        elevation: 6,
        icon: const Icon(Icons.add, color: colorVerdeOscuro),
        label: Text(
          'Nuevo Platillo',
          style: GoogleFonts.poppins(
            color: colorVerdeOscuro,
            fontWeight: FontWeight.bold,
          ),
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

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  void _guardarPlatillo() {
    if (_nombreCtrl.text.isEmpty || _precioCtrl.text.isEmpty) return;
    final nuevoPlatillo = PlatilloLocal(
      _nombreCtrl.text,
      double.parse(_precioCtrl.text),
      true,
    );
    Navigator.pop(context, nuevoPlatillo);
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
          'Agregar Platillo',
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
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorVerdeTese.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorVerdeTese.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 44,
                      color: colorVerdeTese.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Subir foto del platillo',
                      style: GoogleFonts.poppins(
                        color: colorTextoGris,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
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
                    child: TextField(
                      controller: _nombreCtrl,
                      decoration: _decoracionCampo(
                        'Nombre del Platillo',
                        Icons.restaurant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInRight(
                    child: TextField(
                      controller: _precioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _decoracionCampo(
                        'Precio (\$)',
                        Icons.attach_money,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAmarilloTese,
                    elevation: 4,
                    shadowColor: colorAmarilloTese.withValues(alpha: 0.5),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _guardarPlatillo,
                  child: Text(
                    'Guardar en el Menú',
                    style: GoogleFonts.poppins(
                      color: colorVerdeOscuro,
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
