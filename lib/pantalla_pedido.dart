import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colores.dart';
import 'modelos.dart';

final AudioPlayer reproductorGlobal = AudioPlayer();

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
  final TextEditingController _notasCtrl = TextEditingController();
  bool _estaCargando = false;

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  void _mostrarConfirmacion(double total) {
    HapticFeedback.heavyImpact();
    final String localDestino =
        widget.carrito.isNotEmpty
            ? widget.carrito.first.local
            : 'Cafetería Central';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateModal) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  top: 24,
                  left: 24,
                  right: 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 18),
                    const Icon(
                      Icons.storefront,
                      size: 50,
                      color: colorVerdeTese,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Confirmar Compra',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorVerdeTese.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '📍 Recogerás en: $localDestino',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorVerdeTese,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total de la orden: \$${total.toStringAsFixed(2)}\nPagarás con $metodoPago al recoger en ventanilla.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: colorTextoGris,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            onPressed:
                                _estaCargando
                                    ? null
                                    : () => Navigator.pop(context),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.poppins(
                                color: colorTextoGris,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorExito,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed:
                                _estaCargando
                                    ? null
                                    : () async {
                                      HapticFeedback.heavyImpact();
                                      setStateModal(() => _estaCargando = true);

                                      try {
                                        String codigoUnico =
                                            '#TESE-${Random().nextInt(90000) + 10000}';

                                        String detallesCocina = widget.carrito
                                            .map((p) {
                                              String personalizacion =
                                                  p.personalizacion.isNotEmpty
                                                      ? '\n  • ${p.personalizacion.join('\n  • ')}'
                                                      : '';
                                              return '1x ${p.nombre}$personalizacion';
                                            })
                                            .join('\n\n');

                                        String notasAdicionales =
                                            _notasCtrl.text.trim();
                                        if (notasAdicionales.isNotEmpty) {
                                          detallesCocina +=
                                              '\n\nNOTAS: $notasAdicionales';
                                        }

                                        List<Map<String, dynamic>>
                                        itemsParaResena =
                                            widget.carrito
                                                .map(
                                                  (p) => {
                                                    'id': p.id,
                                                    'nombre': p.nombre,
                                                  },
                                                )
                                                .toList();

                                        // 📍 Guardamos el local exacto donde se hizo la compra
                                        await FirebaseFirestore.instance
                                            .collection('Pedidos')
                                            .doc(codigoUnico)
                                            .set({
                                              'idPedido': codigoUnico,
                                              'alumno': 'Axel Guerrero',
                                              'local': localDestino,
                                              'detalle': detallesCocina,
                                              'metodoPago': metodoPago,
                                              'notas': notasAdicionales,
                                              'total': total,
                                              'estado': 0,
                                              'calificado': false,
                                              'items': itemsParaResena,
                                              'horaLlegada':
                                                  FieldValue.serverTimestamp(),
                                            });

                                        try {
                                          reproductorGlobal.play(
                                            AssetSource('exito.mp3'),
                                            volume: 1.0,
                                          );
                                        } catch (_) {}

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          widget.onVaciar();

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      PantallaPedidoExitoso(
                                                        codigoPedido:
                                                            codigoUnico,
                                                        total: total,
                                                        local: localDestino,
                                                      ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setStateModal(
                                          () => _estaCargando = false,
                                        );
                                      }
                                    },
                            child:
                                _estaCargando
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      '¡Confirmar!',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

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
        iconTheme: const IconThemeData(color: Colors.white),
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
                          onDismissed: (direction) {
                            HapticFeedback.mediumImpact();
                            setState(() => widget.carrito.removeAt(index));
                          },
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
                              vertical: 10,
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📍 ${item.local}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: colorVerdeTese,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.personalizacion.isNotEmpty)
                                    Text(
                                      item.personalizacion.join(' • '),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
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
                    TextField(
                      controller: _notasCtrl,
                      decoration: InputDecoration(
                        hintText: 'Instrucciones opcionales extras',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: colorTextoGris,
                        ),
                        prefixIcon: const Icon(
                          Icons.edit_note,
                          color: colorAmarilloTese,
                        ),
                        filled: true,
                        fillColor: colorFondoCrema,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Método de pago al recoger:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => metodoPago = 'Efectivo');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => metodoPago = 'Terminal Bancaria');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total estimado:',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: colorTextoGris,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colorVerdeTese,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAmarilloTese,
                          elevation: 4,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed:
                            widget.carrito.isEmpty
                                ? null
                                : () => _mostrarConfirmacion(total),
                        child: Text(
                          'Confirmar Pedido',
                          style: GoogleFonts.poppins(
                            color: colorVerdeOscuro,
                            fontSize: 17,
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

// ==========================================================
// 🦆 PANTALLA ÉXITO CON LUGAR DE ENTREGA CLARO
// ==========================================================
class PantallaPedidoExitoso extends StatelessWidget {
  final String codigoPedido;
  final double total;
  final String local;
  const PantallaPedidoExitoso({
    super.key,
    required this.codigoPedido,
    required this.total,
    required this.local,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              BounceInDown(
                child: Image.asset(
                  'assets/patito_listo.png',
                  height: 170,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                child: Text(
                  '¡Pedido Enviado!',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  'Tu orden se está procesando en la cocina.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorTextoGris,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // TARJETA DE RECOLECCIÓN
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorVerdeTese.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            codigoPedido,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorVerdeTese,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorTextoOscuro,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Recoger en: $local',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorTextoOscuro,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorVerdeTese,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SalaEsperaScreen(codigoPedido: codigoPedido),
                        ),
                      );
                    },
                    label: Text(
                      'Rastrear y Ver Detalles',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: colorVerdeTese, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Volver al Menú',
                      style: GoogleFonts.poppins(
                        color: colorVerdeTese,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 🔍 SALA DE ESPERA ULTRA-DETALLADA ESTILO UBER/DIDI
// ==========================================================
class SalaEsperaScreen extends StatefulWidget {
  final String codigoPedido;
  const SalaEsperaScreen({super.key, required this.codigoPedido});

  @override
  State<SalaEsperaScreen> createState() => _SalaEsperaScreenState();
}

class _SalaEsperaScreenState extends State<SalaEsperaScreen> {
  late final ConfettiController _confettiController;
  int _ultimoEstadoLeido = -1;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Pedidos')
              .doc(widget.codigoPedido)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            backgroundColor: colorFondoCrema,
            body: Center(
              child: CircularProgressIndicator(color: colorVerdeTese),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        int estadoActual = data['estado'] ?? 0;
        String local = data['local'] ?? 'Cafetería Central';
        String detalle = data['detalle'] ?? '';
        String metodoPago = data['metodoPago'] ?? 'Efectivo';
        double total = (data['total'] ?? 0).toDouble();

        if (estadoActual == 2 && _ultimoEstadoLeido != 2) {
          _confettiController.play();
          _ultimoEstadoLeido = 2;
        }

        Color colorEstado;
        String tituloEstado;
        String subtituloEstado;
        String patitoAsset;

        if (estadoActual == 0) {
          colorEstado = Colors.grey[700]!;
          tituloEstado = 'Confirmando en cocina';
          subtituloEstado = 'El kiosko está validando tu orden para comenzar.';
          patitoAsset = 'assets/patito_recibido.png';
        } else if (estadoActual == 1) {
          colorEstado = colorAmarilloTese;
          tituloEstado = '¡Cocinando tus alimentos!';
          subtituloEstado = 'El chef ya está preparando tu comida al momento.';
          patitoAsset = 'assets/patito_chef.png';
        } else if (estadoActual == 2) {
          colorEstado = colorExito;
          tituloEstado = '¡Listo para recoger!';
          subtituloEstado =
              'Acude a la ventanilla del kiosko y muestra tu ticket.';
          patitoAsset = 'assets/patito_listo.png';
        } else {
          colorEstado = colorTextoGris;
          tituloEstado = 'Pedido Entregado';
          subtituloEstado = '¡Buen provecho! Gracias por tu compra.';
          patitoAsset = 'assets/disfrutaTuComida.png';
        }

        return Scaffold(
          backgroundColor: colorFondoCrema,
          appBar: AppBar(
            title: Text(
              'Seguimiento de Orden',
              style: GoogleFonts.poppins(
                color: colorVerdeTese,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TARJETA DE ESTADO CON MASCOTA
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorEstado.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorVerdeTese.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            patitoAsset,
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            tituloEstado,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: colorTextoOscuro,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtituloEstado,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: colorTextoGris,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _BarraProgresoPedido(
                            estadoActual: estadoActual,
                            colorTexto: colorVerdeTese,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 📍 TARJETA DE DÓNDE RECOGER (SÚPER CLARA)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorVerdeTese.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorVerdeTese.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Punto de Entrega:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorTextoGris,
                                      ),
                                    ),
                                    Text(
                                      local,
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: colorTextoOscuro,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorFondoCrema,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: colorTextoGris,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Muestra tu ticket en la ventanilla al recoger.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 🧾 DESGLOSE COMPLETO DE LA ORDEN
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorVerdeTese.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                                'Ticket de Compra',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              Text(
                                widget.codigoPedido,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: colorVerdeTese,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            'Artículos pedidos:',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorTextoGris,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            detalle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorTextoOscuro,
                              height: 1.4,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Método de pago:',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  color: colorTextoGris,
                                ),
                              ),
                              Text(
                                metodoPago,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: colorTextoOscuro,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total a liquidar:',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: colorVerdeTese,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // CONFETI EXPLOSIVO
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
      },
    );
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
    final etiquetas = ['Recibido', 'Preparando', '¡Listo!'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(etiquetas.length * 2 - 1, (i) {
          if (i.isOdd) {
            final indiceSegmento = (i - 1) ~/ 2;
            final activo = estadoActual > indiceSegmento;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: activo ? colorExito : Colors.grey[300],
              ),
            );
          }
          final indicePaso = i ~/ 2;
          final activo = estadoActual >= indicePaso;
          Color colorCirculo =
              activo
                  ? (indicePaso == 2 ? colorExito : colorVerdeTese)
                  : Colors.grey[300]!;

          return Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activo ? colorCirculo : Colors.transparent,
                  border: Border.all(color: colorCirculo, width: 2),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                etiquetas[indicePaso],
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: activo ? colorTextoOscuro : colorTextoGris,
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

// ==========================================================
// ⭐️ PANTALLA RESEÑA POR COMIDA
// ==========================================================
class PantallaResena extends StatefulWidget {
  final String codigoPedido;
  const PantallaResena({super.key, required this.codigoPedido});

  @override
  State<PantallaResena> createState() => _PantallaResenaState();
}

class _PantallaResenaState extends State<PantallaResena> {
  int estrellasSeleccionadas = 0;
  final TextEditingController _comentarioCtrl = TextEditingController();
  bool _enviando = false;
  bool _cargandoPedido = true;

  List<Map<String, dynamic>> itemsDelPedido = [];
  String? itemSeleccionadoId;
  String? itemSeleccionadoNombre;

  @override
  void initState() {
    super.initState();
    _cargarItemsDelPedido();
  }

  void _cargarItemsDelPedido() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Pedidos')
              .doc(widget.codigoPedido)
              .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List rawItems = data['items'] ?? [];
        setState(() {
          itemsDelPedido =
              rawItems.map((e) => Map<String, dynamic>.from(e)).toList();
          if (itemsDelPedido.isNotEmpty) {
            itemSeleccionadoId = itemsDelPedido.first['id'];
            itemSeleccionadoNombre = itemsDelPedido.first['nombre'];
          }
          _cargandoPedido = false;
        });
      } else {
        setState(() => _cargandoPedido = false);
      }
    } catch (_) {
      setState(() => _cargandoPedido = false);
    }
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  void _guardarResena() async {
    if (estrellasSeleccionadas == 0 || itemSeleccionadoId == null) {
      return;
    }
    setState(() => _enviando = true);
    HapticFeedback.heavyImpact();

    try {
      await FirebaseFirestore.instance.collection('Resenas').add({
        'codigoPedido': widget.codigoPedido,
        'platilloId': itemSeleccionadoId,
        'platilloNombre': itemSeleccionadoNombre ?? 'Comida',
        'estrellas': estrellasSeleccionadas,
        'comentario': _comentarioCtrl.text.trim(),
        'alumno': 'Axel Guerrero',
        'fecha': FieldValue.serverTimestamp(),
      });

      final platilloRef = FirebaseFirestore.instance
          .collection('Menu_Platillos')
          .doc(itemSeleccionadoId);
      final platilloSnap = await platilloRef.get();

      if (platilloSnap.exists) {
        final pData = platilloSnap.data() as Map<String, dynamic>;
        double califActual = (pData['calificacion'] ?? 0.0).toDouble();
        int totalVotos = (pData['numCalificaciones'] ?? 0) as int;

        double nuevoPromedio =
            ((califActual * totalVotos) + estrellasSeleccionadas) /
            (totalVotos + 1);
        nuevoPromedio = double.parse(nuevoPromedio.toStringAsFixed(1));

        await platilloRef.update({
          'calificacion': nuevoPromedio,
          'numCalificaciones': totalVotos + 1,
        });
      }

      await FirebaseFirestore.instance
          .collection('Pedidos')
          .doc(widget.codigoPedido)
          .update({'calificado': true});

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Reseña enviada! Gracias por ayudar a mejorar la comida. ⭐',
            ),
            backgroundColor: colorExito,
          ),
        );
      }
    } catch (e) {
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Calificar Comida',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: colorVerdeTese),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Omitir',
              style: GoogleFonts.poppins(
                color: colorTextoGris,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body:
          _cargandoPedido
              ? const Center(
                child: CircularProgressIndicator(color: colorVerdeTese),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    BounceInDown(
                      child: Image.asset(
                        'assets/disfrutaTuComida.png',
                        height: 140,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¿Qué tal estuvo tu comida?',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colorVerdeTese,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu opinión cambia el ranking del platillo en el menú',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: colorTextoGris,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (itemsDelPedido.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selecciona el platillo a calificar:',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorTextoOscuro,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: itemSeleccionadoId,
                            items:
                                itemsDelPedido.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item['id'] as String,
                                    child: Text(
                                      item['nombre'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              final elegido = itemsDelPedido.firstWhere(
                                (e) => e['id'] == val,
                              );
                              setState(() {
                                itemSeleccionadoId = val;
                                itemSeleccionadoNombre = elegido['nombre'];
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            setState(() => estrellasSeleccionadas = index + 1);
                          },
                          child: Icon(
                            index < estrellasSeleccionadas
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color:
                                index < estrellasSeleccionadas
                                    ? colorAmarilloTese
                                    : Colors.grey[300],
                            size: 50,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _comentarioCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Cuéntanos qué tal estuvo la preparación...',
                        hintStyle: GoogleFonts.poppins(
                          color: colorTextoGris,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed:
                            estrellasSeleccionadas == 0 || _enviando
                                ? null
                                : _guardarResena,
                        child:
                            _enviando
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  'Publicar Opinión',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'En otro momento',
                        style: GoogleFonts.poppins(
                          color: colorTextoGris,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
