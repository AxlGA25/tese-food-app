import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colores.dart';
import 'pantalla_inicio.dart';

Widget _botonStock(IconData icono, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorFondoCrema,
        shape: BoxShape.circle,
        border: Border.all(color: colorTextoGris.withValues(alpha: 0.3)),
      ),
      child: Icon(icono, size: 18, color: colorTextoOscuro),
    ),
  );
}

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

class DashboardNavegacionLocal extends StatefulWidget {
  const DashboardNavegacionLocal({super.key});

  @override
  State<DashboardNavegacionLocal> createState() =>
      _DashboardNavegacionLocalState();
}

class _DashboardNavegacionLocalState extends State<DashboardNavegacionLocal> {
  int _indiceActual = 0;

  Color _colorTextoSobre(Color fondo) =>
      fondo == colorAmarilloTese ? colorVerdeOscuro : Colors.white;

  int _minutosEspera(Timestamp? hora) {
    if (hora == null) return 0;
    return DateTime.now().difference(hora.toDate()).inMinutes;
  }

  void _cambiarEstadoPedido(String idDoc, int estadoActual) {
    HapticFeedback.heavyImpact();
    int nuevoEstado = estadoActual + 1;
    FirebaseFirestore.instance.collection('Pedidos').doc(idDoc).update({
      'estado': nuevoEstado,
    });
  }

  void _ajustarExistencias(String idDoc, int existenciasActuales, int cambio) {
    int nuevaCantidad = (existenciasActuales + cambio).clamp(0, 999).toInt();
    FirebaseFirestore.instance.collection('Menu_Platillos').doc(idDoc).update({
      'existencias': nuevaCantidad,
    });
  }

  void _mostrarDetallePedido(
    DocumentSnapshot comanda,
    int numeroTicket,
    Color colorEstado,
    String textoBoton,
  ) {
    int estado = comanda['estado'];
    String imagenPatito = 'assets/pedidoPendiente.png';
    if (estado == 1) imagenPatito = 'assets/listoParaRecoger.png';
    if (estado == 2) imagenPatito = 'assets/disfrutaTuComida.png';

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
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorVerdeTese.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ticket #$numeroTicket · hace ${_minutosEspera(comanda['horaLlegada'] as Timestamp?)} min',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorVerdeTese,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comanda['idPedido'],
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: colorEstado,
                      ),
                    ),
                    Text(
                      '\$${comanda['total'].toStringAsFixed(2)}',
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
                      comanda['alumno'],
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
                  comanda['detalle'],
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colorTextoOscuro,
                  ),
                ),
                const SizedBox(height: 20),
                if (comanda['notas'].toString().isNotEmpty)
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
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: colorAmarilloTese,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Notas y personalización:',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: colorAmarilloTese,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          comanda['notas'],
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
                      comanda['metodoPago'] == 'Efectivo'
                          ? Icons.payments
                          : Icons.credit_card,
                      color: colorVerdeTese,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pago con: ${comanda['metodoPago']}',
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
                      _cambiarEstadoPedido(comanda.id, estado);
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
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Pedidos')
              .where('estado', isLessThan: 3)
              .orderBy('estado')
              .orderBy('horaLlegada')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final pedidos = snapshot.data!.docs;

        if (pedidos.isEmpty) {
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
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: colorTextoGris,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          key: const ValueKey('pedidos'),
          padding: const EdgeInsets.all(16),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final comanda = pedidos[index];
            final int estado = comanda['estado'];
            final numeroTicket = index + 1;

            Color colorEstado = Colors.grey;
            String textoBoton = '';
            IconData iconoEstado = Icons.receipt;
            if (estado == 0) {
              colorEstado = Colors.redAccent;
              textoBoton = 'Empezar a Preparar';
              iconoEstado = Icons.notifications_active;
            } else if (estado == 1) {
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
                onTap: () {
                  HapticFeedback.selectionClick();
                  _mostrarDetallePedido(
                    comanda,
                    numeroTicket,
                    colorEstado,
                    textoBoton,
                  );
                },
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
                              numeroTicket,
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
      },
    );
  }

  Widget _contenidoTarjetaPedido(
    DocumentSnapshot comanda,
    int numeroTicket,
    IconData iconoEstado,
    Color colorEstado,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorVerdeTese.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Ticket #$numeroTicket · hace ${_minutosEspera(comanda['horaLlegada'] as Timestamp?)} min',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorVerdeTese,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comanda['idPedido'],
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
                  comanda['estado'] == 0
                      ? 'NUEVO'
                      : (comanda['estado'] == 1 ? 'PREPARANDO' : 'LISTO'),
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
            'Alumno: ${comanda['alumno']}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorTextoOscuro,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            comanda['detalle'],
            style: GoogleFonts.poppins(fontSize: 14.5, color: colorTextoOscuro),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                comanda['metodoPago'] == 'Efectivo'
                    ? Icons.payments
                    : Icons.credit_card,
                size: 16,
                color: colorTextoGris,
              ),
              const SizedBox(width: 5),
              Text(
                comanda['metodoPago'],
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
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('Menu_Platillos').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }
        final miMenu = snapshot.data!.docs;

        return Scaffold(
          key: const ValueKey('menu'),
          backgroundColor: Colors.transparent,
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: miMenu.length,
            itemBuilder: (context, index) {
              final platillo = miMenu[index];
              final int existencias = platillo['existencias'] ?? 0;
              final bool agotado = existencias == 0;
              final List ingredientes = platillo['ingredientes'] ?? [];

              return FadeInUp(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorVerdeTese.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.fastfood,
                              color: colorVerdeTese,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        platillo['nombre'],
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: colorTextoOscuro,
                                        ),
                                      ),
                                    ),
                                    if (agotado) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Agotado',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  '\$${platillo['precio']}',
                                  style: GoogleFonts.poppins(
                                    color: colorExito,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (ingredientes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              ingredientes.map((ing) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorSalvia.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    ing.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Existencias',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: colorTextoGris,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _botonStock(
                                Icons.remove,
                                () => _ajustarExistencias(
                                  platillo.id,
                                  existencias,
                                  -1,
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '$existencias',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                              ),
                              _botonStock(
                                Icons.add,
                                () => _ajustarExistencias(
                                  platillo.id,
                                  existencias,
                                  1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AgregarPlatilloScreen(),
                ),
              );
            },
          ),
        );
      },
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
  final TextEditingController _ingredienteCtrl = TextEditingController();
  final List<String> _ingredientesPersonalizados = [];
  int _existencias = 10;
  bool _estaCargando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _ingredienteCtrl.dispose();
    super.dispose();
  }

  void _guardarPlatillo() async {
    if (_nombreCtrl.text.isEmpty || _precioCtrl.text.isEmpty) return;
    setState(() => _estaCargando = true);

    try {
      await FirebaseFirestore.instance.collection('Menu_Platillos').add({
        'nombre': _nombreCtrl.text,
        'precio': double.parse(_precioCtrl.text),
        'local': 'Kiosko Sistemas',
        'categoria': 'Comida',
        'descripcion': 'Platillo agregado desde la app del local',
        'tiempoPrep': '15 min',
        'calificacion': 5.0,
        'popular': true,
        'ingredientes': _ingredientesPersonalizados,
        'existencias': _existencias,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Platillo subido a la nube! ☁️🍔'),
            backgroundColor: colorExito,
          ),
        );
      }
    } catch (e) {
      setState(() => _estaCargando = false);
    }
  }

  void _agregarIngrediente(String valor) {
    if (valor.isNotEmpty && !_ingredientesPersonalizados.contains(valor)) {
      setState(() {
        _ingredientesPersonalizados.add(valor);
        _ingredienteCtrl.clear();
      });
    }
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
        backgroundColor: Colors.white,
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
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredientes personalizables',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Escribe un ingrediente y presiona "+" o "Enter".',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: colorTextoGris,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredienteCtrl,
                          onSubmitted: _agregarIngrediente,
                          decoration: InputDecoration(
                            hintText: 'Ej. Aguacate, Cebolla...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: colorTextoGris,
                            ),
                            filled: true,
                            fillColor: colorFondoCrema,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: colorVerdeTese,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed:
                              () => _agregarIngrediente(_ingredienteCtrl.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_ingredientesPersonalizados.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _ingredientesPersonalizados.map((ing) {
                            return Chip(
                              label: Text(
                                ing,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorVerdeTese,
                                ),
                              ),
                              backgroundColor: colorVerdeTese.withValues(
                                alpha: 0.1,
                              ),
                              deleteIcon: const Icon(
                                Icons.cancel,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _ingredientesPersonalizados.remove(ing);
                                });
                              },
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          }).toList(),
                    ),
                  const SizedBox(height: 22),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Existencias iniciales',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_existencias > 0) setState(() => _existencias--);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorFondoCrema,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorTextoGris.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(Icons.remove, size: 18),
                        ),
                      ),
                      SizedBox(
                        width: 56,
                        child: Text(
                          '$_existencias',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: colorTextoOscuro,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _existencias++);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorFondoCrema,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorTextoGris.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
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
                  onPressed: _estaCargando ? null : _guardarPlatillo,
                  child:
                      _estaCargando
                          ? const CircularProgressIndicator(
                            color: colorVerdeOscuro,
                          )
                          : Text(
                            'Guardar en la Nube',
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
