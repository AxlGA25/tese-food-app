import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'colores.dart';
import 'pantalla_inicio.dart';

Widget _botonStock(IconData icono, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: colorFondoCrema,
        shape: BoxShape.circle,
        border: Border.all(color: colorTextoGris.withValues(alpha: 0.25)),
      ),
      child: Icon(icono, size: 16, color: colorTextoOscuro),
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: colorVerdeTese,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                child: Image.asset(
                  'assets/pedidoParaEntregar.png',
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              FadeInDown(
                child: Text(
                  'Panel de Cocina',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeInDown(
                child: Text(
                  'Gestión de comandas y menú en tiempo real',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: colorTextoGris,
                  ),
                ),
              ),
              const SizedBox(height: 28),
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
                    TextField(
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: colorTextoOscuro,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ej. KIOSKO-SISTEMAS',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          letterSpacing: 1,
                          color: colorTextoGris,
                        ),
                        prefixIcon: const Icon(
                          Icons.storefront,
                          color: colorVerdeTese,
                        ),
                        filled: true,
                        fillColor: colorFondoCrema,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.soup_kitchen,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          elevation: 3,
                          minimumSize: const Size(double.infinity, 54),
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
                        label: Text(
                          'Abrir KDS de Cocina',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
  int _filtroEstado = -1;

  int _minutosEspera(Timestamp? hora) {
    if (hora == null) {
      return 0;
    }
    return DateTime.now().difference(hora.toDate()).inMinutes;
  }

  void _cambiarEstadoPedido(String idDoc, int estadoActual) {
    HapticFeedback.heavyImpact();
    FirebaseFirestore.instance.collection('Pedidos').doc(idDoc).update({
      'estado': estadoActual + 1,
    });
  }

  void _ajustarExistencias(String idDoc, int existenciasActuales, int cambio) {
    int nuevaCantidad = (existenciasActuales + cambio).clamp(0, 999).toInt();
    FirebaseFirestore.instance.collection('Menu_Platillos').doc(idDoc).update({
      'existencias': nuevaCantidad,
    });
  }

  void _confirmarCierreSesion() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Cerrar turno?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: colorTextoOscuro,
              ),
            ),
            content: Text(
              'Se cerrará la sesión de la cocina en este dispositivo.',
              style: GoogleFonts.poppins(color: colorTextoGris, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Seguir cocinando',
                  style: GoogleFonts.poppins(
                    color: colorTextoGris,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (c) => const DecisionScreen()),
                  );
                },
                child: Text(
                  'Cerrar Turno',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _mostrarDetallePedido(
    DocumentSnapshot comanda,
    int numeroTicket,
    Color colorEstado,
    String textoBoton,
    int estado,
  ) {
    final data = comanda.data() as Map<String, dynamic>? ?? {};
    String idPedido = data['idPedido'] ?? comanda.id;
    double total = (data['total'] ?? 0).toDouble();
    String alumno = data['alumno'] ?? 'Alumno';
    String detalle = data['detalle'] ?? '';
    String notas = data['notas']?.toString() ?? '';
    String metodoPago = data['metodoPago'] ?? 'Efectivo';
    Timestamp? horaLlegada = data['horaLlegada'] as Timestamp?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket #$numeroTicket',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorTextoGris,
                          ),
                        ),
                        Text(
                          idPedido,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colorVerdeTese,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorVerdeTese.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorVerdeTese,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colorVerdeTese.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.person,
                        color: colorVerdeTese,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        alumno,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                    ),
                    Text(
                      'hace ${_minutosEspera(horaLlegada)}m',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Comanda:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorTextoGris,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorFondoCrema,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    detalle,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorTextoOscuro,
                      height: 1.4,
                    ),
                  ),
                ),
                if (notas.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nota especial: $notas',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      metodoPago == 'Efectivo'
                          ? Icons.payments_outlined
                          : Icons.credit_card_outlined,
                      color: colorTextoGris,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Método: $metodoPago',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorTextoGris,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorEstado,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _cambiarEstadoPedido(comanda.id, estado);
                    },
                    child: Text(
                      textoBoton,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
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
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: colorVerdeTese.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.storefront,
                color: colorVerdeTese,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kiosko Sistemas',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorTextoOscuro,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: colorExito,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Cocina en Servicio',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorExito,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar Turno',
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            onPressed: _confirmarCierreSesion,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child:
            _indiceActual == 0
                ? _vistaPedidosDidi()
                : (_indiceActual == 1 ? _vistaMenuDidi() : _vistaResenasDidi()),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
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
              label: 'Comandas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Existencias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_rate_rounded),
              label: 'Opiniones',
            ),
          ],
        ),
      ),
    );
  }

  Widget _vistaPedidosDidi() {
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

        final todosPedidos = snapshot.data!.docs;

        int cantNuevos =
            todosPedidos.where((d) => (d.data() as Map)['estado'] == 0).length;
        int cantCocina =
            todosPedidos.where((d) => (d.data() as Map)['estado'] == 1).length;
        int cantListos =
            todosPedidos.where((d) => (d.data() as Map)['estado'] == 2).length;

        final pedidos =
            _filtroEstado == -1
                ? todosPedidos
                : todosPedidos
                    .where((d) => (d.data() as Map)['estado'] == _filtroEstado)
                    .toList();

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chipFiltro(
                      'Todos (${todosPedidos.length})',
                      -1,
                      colorVerdeTese,
                    ),
                    const SizedBox(width: 8),
                    _chipFiltro('Nuevos ($cantNuevos)', 0, Colors.redAccent),
                    const SizedBox(width: 8),
                    _chipFiltro(
                      'En Cocina ($cantCocina)',
                      1,
                      colorAmarilloTese,
                    ),
                    const SizedBox(width: 8),
                    _chipFiltro('Listos ($cantListos)', 2, colorExito),
                  ],
                ),
              ),
            ),
            Expanded(
              child:
                  pedidos.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 70,
                              color: colorVerdeTese.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Todo al día en cocina',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorVerdeTese,
                              ),
                            ),
                            Text(
                              'No hay comandas pendientes en esta sección.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: colorTextoGris,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final comanda = pedidos[index];
                          final data =
                              comanda.data() as Map<String, dynamic>? ?? {};
                          final int estado = data['estado'] ?? 0;
                          final numeroTicket = index + 1;
                          final int minutos = _minutosEspera(
                            data['horaLlegada'] as Timestamp?,
                          );

                          Color colorEstado;
                          String textoBoton;
                          String labelEstado;
                          IconData iconoAccion;

                          if (estado == 0) {
                            colorEstado = Colors.redAccent;
                            textoBoton = 'Aceptar y Cocinar';
                            labelEstado = 'NUEVO';
                            iconoAccion = Icons.soup_kitchen;
                          } else if (estado == 1) {
                            colorEstado = colorAmarilloTese;
                            textoBoton = '¡Marcar Listo!';
                            labelEstado = 'EN COCINA';
                            iconoAccion = Icons.check_circle_outline;
                          } else {
                            colorEstado = colorExito;
                            textoBoton = 'Entregar a Alumno';
                            labelEstado = 'POR ENTREGAR';
                            iconoAccion = Icons.task_alt;
                          }

                          return FadeInUp(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: colorEstado.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorVerdeTese.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap:
                                    () => _mostrarDetallePedido(
                                      comanda,
                                      numeroTicket,
                                      colorEstado,
                                      textoBoton,
                                      estado,
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 9,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorEstado,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  labelEstado,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Ticket #$numeroTicket',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorTextoGris,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 15,
                                                color:
                                                    minutos >= 15
                                                        ? Colors.redAccent
                                                        : colorTextoGris,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                'hace ${minutos}m',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      minutos >= 15
                                                          ? Colors.redAccent
                                                          : colorTextoGris,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data['idPedido'] ?? comanda.id,
                                            style: GoogleFonts.poppins(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w900,
                                              color: colorTextoOscuro,
                                            ),
                                          ),
                                          Text(
                                            data['alumno'] ?? 'Alumno',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: colorVerdeTese,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 18),
                                      Text(
                                        data['detalle'] ?? '',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorTextoOscuro,
                                        ),
                                      ),
                                      if ((data['notas'] ?? '')
                                          .toString()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '⚠️ ${data['notas']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 46,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colorEstado,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: Icon(
                                            iconoAccion,
                                            color: Colors.white,
                                            size: 19,
                                          ),
                                          label: Text(
                                            textoBoton,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.5,
                                            ),
                                          ),
                                          onPressed:
                                              () => _cambiarEstadoPedido(
                                                comanda.id,
                                                estado,
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
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _chipFiltro(String titulo, int estado, Color colorAcento) {
    bool activo = _filtroEstado == estado;
    return ChoiceChip(
      label: Text(titulo),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: activo ? Colors.white : colorTextoOscuro,
      ),
      selected: activo,
      selectedColor: colorAcento,
      backgroundColor: colorFondoCrema,
      side: BorderSide(color: activo ? colorAcento : Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) => setState(() => _filtroEstado = val ? estado : -1),
    );
  }

  Widget _vistaMenuDidi() {
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
          backgroundColor: Colors.transparent,
          body: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: miMenu.length,
            itemBuilder: (context, index) {
              final platillo = miMenu[index];
              final data = platillo.data() as Map<String, dynamic>? ?? {};

              final int existencias = data['existencias'] ?? 0;
              final bool agotado = existencias == 0;
              final String nombre = data['nombre'] ?? 'Sin nombre';
              final dynamic precio = data['precio'] ?? 0;
              final double calif = (data['calificacion'] ?? 0.0).toDouble();
              final List fotos = data['fotos'] ?? [];

              return FadeInUp(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorVerdeTese.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 📸 FOTO REAL DEL PLATILLO O ÍCONO
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              agotado
                                  ? Colors.grey.withValues(alpha: 0.1)
                                  : colorVerdeTese.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              fotos.isNotEmpty
                                  ? Image.memory(
                                    base64Decode(fotos[0]),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Icon(
                                          Icons.fastfood,
                                          color:
                                              agotado
                                                  ? colorTextoGris
                                                  : colorVerdeTese,
                                        ),
                                  )
                                  : Icon(
                                    Icons.fastfood,
                                    color:
                                        agotado
                                            ? colorTextoGris
                                            : colorVerdeTese,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color:
                                    agotado ? colorTextoGris : colorTextoOscuro,
                                decoration:
                                    agotado ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '\$$precio',
                                  style: GoogleFonts.poppins(
                                    color: colorExito,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (calif > 0) ...[
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: colorAmarilloTese,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${calif.toStringAsFixed(1)} ★',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    'Nuevo ✨',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: colorExito,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
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
                            width: 36,
                            child: Text(
                              '$existencias',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
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
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colorAmarilloTese,
            elevation: 4,
            icon: const Icon(Icons.add, color: colorVerdeOscuro),
            label: Text(
              'Agregar Platillo',
              style: GoogleFonts.poppins(
                color: colorVerdeOscuro,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgregarPlatilloScreen(),
                  ),
                ),
          ),
        );
      },
    );
  }

  Widget _vistaResenasDidi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Resenas').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final resenasDocs = List<DocumentSnapshot>.from(snapshot.data!.docs);
        resenasDocs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final Timestamp? tA = aData['fecha'] as Timestamp?;
          final Timestamp? tB = bData['fecha'] as Timestamp?;
          if (tA == null) {
            return -1;
          }
          if (tB == null) {
            return 1;
          }
          return tB.compareTo(tA);
        });

        if (resenasDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 70,
                  color: colorVerdeTese.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sin opiniones todavía',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
                Text(
                  'Cuando los alumnos califiquen su comida, verás sus críticas aquí.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: colorTextoGris,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resenasDocs.length,
          itemBuilder: (context, index) {
            final resena = resenasDocs[index];
            final data = resena.data() as Map<String, dynamic>;
            final String platillo = data['platilloNombre'] ?? 'Comida';
            final int estrellas = data['estrellas'] ?? 5;
            final String comentario = data['comentario'] ?? '';
            final String alumno = data['alumno'] ?? 'Alumno';

            return FadeInUp(
              delay: Duration(milliseconds: 50 * index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeTese.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            platillo,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorTextoOscuro,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < estrellas
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color:
                                  starIndex < estrellas
                                      ? colorAmarilloTese
                                      : Colors.grey[300],
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (comentario.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorFondoCrema,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '« $comentario »',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontStyle: FontStyle.italic,
                            color: colorTextoOscuro,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Por: $alumno',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorTextoGris,
                          ),
                        ),
                        Text(
                          'Calificación: $estrellas/5',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorVerdeTese,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================================
// 📸 AGREGAR PLATILLO CON HASTA 3 FOTOS AUTÓNOMAS
// ==========================================================
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
  final List<String> _fotosBase64 = []; // 📸 Lista de 1 a 3 fotos
  final ImagePicker _picker = ImagePicker();

  int _existencias = 10;
  bool _estaCargando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _ingredienteCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto(ImageSource source) async {
    if (_fotosBase64.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo se permiten hasta 3 fotos por platillo.'),
        ),
      );
      return;
    }

    try {
      // 💡 REDUCTOR AUTÓNOMO: Máximo 600x600 y calidad al 50% (Pesa ~25 KB)
      final XFile? imagen = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 50,
      );

      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        final String base64String = base64Encode(bytes);
        setState(() {
          _fotosBase64.add(base64String);
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la imagen.')),
      );
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: colorVerdeTese),
                  title: Text(
                    'Tomar foto con cámara',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _seleccionarFoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: colorVerdeTese,
                  ),
                  title: Text(
                    'Elegir de galería',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _seleccionarFoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _guardarPlatillo() async {
    if (_nombreCtrl.text.isEmpty || _precioCtrl.text.isEmpty) {
      return;
    }
    setState(() => _estaCargando = true);

    try {
      await FirebaseFirestore.instance.collection('Menu_Platillos').add({
        'nombre': _nombreCtrl.text,
        'precio': double.parse(_precioCtrl.text),
        'local': 'Kiosko Sistemas',
        'categoria': 'Comida',
        'descripcion': 'Platillo agregado desde la app del local',
        'tiempoPrep': '15 min',
        'calificacion': 0.0,
        'numCalificaciones': 0,
        'popular': true,
        'ingredientes': _ingredientesPersonalizados,
        'existencias': _existencias,
        'fotos': _fotosBase64, // 📸 Guardamos la lista de 1 a 3 fotos
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Platillo subido a la nube con fotos! ☁️🍔'),
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
          'Nuevo Platillo',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: colorVerdeTese,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            // ==========================================
            // 📸 SECCIÓN DE FOTOS (1 A 3 FOTOS)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fotos del platillo (${_fotosBase64.length}/3)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                      if (_fotosBase64.length < 3)
                        TextButton.icon(
                          onPressed: _mostrarOpcionesFoto,
                          icon: const Icon(
                            Icons.add_a_photo,
                            size: 18,
                            color: colorVerdeTese,
                          ),
                          label: Text(
                            'Agregar',
                            style: GoogleFonts.poppins(
                              color: colorVerdeTese,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_fotosBase64.isEmpty)
                    GestureDetector(
                      onTap: _mostrarOpcionesFoto,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorVerdeTese.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorVerdeTese.withValues(alpha: 0.25),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: colorVerdeTese.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca para tomar foto de la comida',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: colorTextoGris,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 105,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fotosBase64.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colorVerdeTese.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.memory(
                                    base64Decode(_fotosBase64[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _fotosBase64.removeAt(index),
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FORMULARIO NOMBRE Y PRECIO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nombreCtrl,
                    decoration: _decoracionCampo(
                      'Nombre del Platillo',
                      Icons.restaurant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _precioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _decoracionCampo(
                      'Precio (\$)',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // INGREDIENTES
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredienteCtrl,
                          onSubmitted: _agregarIngrediente,
                          decoration: InputDecoration(
                            hintText: 'Ej. Queso, Cebolla...',
                            filled: true,
                            fillColor: colorFondoCrema,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed:
                            () => _agregarIngrediente(_ingredienteCtrl.text),
                      ),
                    ],
                  ),
                  if (_ingredientesPersonalizados.isNotEmpty) ...[
                    const SizedBox(height: 14),
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
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              onDeleted:
                                  () => setState(
                                    () =>
                                        _ingredientesPersonalizados.remove(ing),
                                  ),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Existencias iniciales',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                      Row(
                        children: [
                          _botonStock(Icons.remove, () {
                            if (_existencias > 0) {
                              setState(() => _existencias--);
                            }
                          }),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '$_existencias',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _botonStock(
                            Icons.add,
                            () => setState(() => _existencias++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAmarilloTese,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _estaCargando ? null : _guardarPlatillo,
                child:
                    _estaCargando
                        ? const CircularProgressIndicator(
                          color: colorVerdeOscuro,
                        )
                        : Text(
                          'Publicar Platillo',
                          style: GoogleFonts.poppins(
                            color: colorVerdeOscuro,
                            fontSize: 16,
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
