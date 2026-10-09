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
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.receipt_long,
                      size: 55,
                      color: colorVerdeTese,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '¿Confirmar tu pedido?',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se enviará tu orden a cocina por un total de \$${total.toStringAsFixed(2)}.\nRecuerda que pagarás con $metodoPago al recoger en ventanilla.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: colorTextoGris,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 26),
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

                                        await FirebaseFirestore.instance
                                            .collection('Pedidos')
                                            .doc(codigoUnico)
                                            .set({
                                              'idPedido': codigoUnico,
                                              'alumno': 'Axel Guerrero',
                                              'detalle': detallesCocina,
                                              'metodoPago': metodoPago,
                                              'notas': notasAdicionales,
                                              'total': total,
                                              'estado': 0,
                                              'calificado': false,
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
                                          Navigator.pop(
                                            context,
                                          ); // Cierra modal
                                          widget.onVaciar(); // Vacía carrito

                                          // Navegamos a la pantalla de éxito del patito verde
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      PantallaPedidoExitoso(
                                                        codigoPedido:
                                                            codigoUnico,
                                                        total: total,
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
                              subtitle:
                                  item.personalizacion.isNotEmpty
                                      ? Text(
                                        item.personalizacion.join(' • '),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                      : null,
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
// 🦆 NUEVA PANTALLA DE ÉXITO CON PATITO VERDE Y BOTONES
// ==========================================================
class PantallaPedidoExitoso extends StatelessWidget {
  final String codigoPedido;
  final double total;
  const PantallaPedidoExitoso({
    super.key,
    required this.codigoPedido,
    required this.total,
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
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                child: Text(
                  '¡Pedido Confirmado!',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  'Tu orden ya está en la fila de la cocina.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorTextoGris,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorExito.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        codigoPedido,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorExito,
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
                ),
              ),
              const Spacer(),
              // BOTÓN 1: RASTREAR PEDIDO
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.timer_outlined, color: Colors.white),
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
                      'Ver Estado en Vivo',
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
              // BOTÓN 2: VOLVER AL MENÚ
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
// SALA DE ESPERA CON CONFETI
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
            backgroundColor: colorVerdeTese,
            body: Center(
              child: CircularProgressIndicator(color: colorAmarilloTese),
            ),
          );
        }

        int estadoActual = snapshot.data!.get('estado') ?? 0;

        if (estadoActual == 2 && _ultimoEstadoLeido != 2) {
          _confettiController.play();
          _ultimoEstadoLeido = 2;
        }

        Color colorFondo = estadoActual == 2 ? colorExito : Colors.white;
        Color colorTextoTop = estadoActual == 2 ? Colors.white : colorVerdeTese;

        return Scaffold(
          backgroundColor: colorFondo,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Orden: ${widget.codigoPedido}',
              style: GoogleFonts.poppins(
                color: colorTextoTop,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: colorTextoTop),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
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
                      const SizedBox(height: 70),
                      _BarraProgresoPedido(
                        estadoActual: estadoActual,
                        colorTexto: colorTextoTop,
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
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
      },
    );
  }

  Widget _construirPantallaPorEstado(int estado) {
    if (estado == 0) {
      return const _PantallaEstadoFull(
        key: ValueKey(0),
        titulo: 'Pedido Recibido',
        subtitulo: 'Esperando confirmación de la cafetería...',
        cargando: true,
        imagenAsset: 'assets/patito_recibido.png',
        colorTextoTitulo: colorVerdeTese,
        colorTextoSub: colorTextoGris,
      );
    } else if (estado == 1) {
      return const _PantallaEstadoFull(
        key: ValueKey(1),
        titulo: 'En Preparación',
        subtitulo: '¡El Chef está cocinando tus hambreados!',
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
        accionBoton: () => Navigator.pop(context),
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
  final VoidCallback? accionBoton;
  final Color colorTextoTitulo, colorTextoSub;
  const _PantallaEstadoFull({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.cargando,
    this.mostrarBoton = false,
    this.accionBoton,
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
            Image.asset(imagenAsset, height: 210, fit: BoxFit.contain),
            const SizedBox(height: 28),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: colorTextoTitulo,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: colorTextoSub),
            ),
            const SizedBox(height: 32),
            if (cargando)
              const CircularProgressIndicator(
                color: colorAmarilloTese,
                strokeWidth: 2.6,
              ),
            if (mostrarBoton)
              ZoomIn(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: accionBoton,
                  child: const Text(
                    'Volver al Menú',
                    style: TextStyle(
                      color: colorExito,
                      fontSize: 17,
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

// ==========================================================
// ⭐️ PANTALLA RESEÑA CON GUARDADO EN FIREBASE Y BOTÓN OMITIR
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

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  void _guardarResena() async {
    setState(() => _enviando = true);
    HapticFeedback.heavyImpact();

    try {
      // 1. Guardamos la reseña en una colección real en Firebase
      await FirebaseFirestore.instance.collection('Resenas').add({
        'codigoPedido': widget.codigoPedido,
        'estrellas': estrellasSeleccionadas,
        'comentario': _comentarioCtrl.text.trim(),
        'alumno': 'Axel Guerrero',
        'fecha': FieldValue.serverTimestamp(),
      });

      // 2. Marcamos el pedido como calificado para no pedir reseña de nuevo
      await FirebaseFirestore.instance
          .collection('Pedidos')
          .doc(widget.codigoPedido)
          .update({'calificado': true});

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Gracias por tu opinión! 💛 Tu reseña fue guardada.',
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
          'Calificar Orden',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            BounceInDown(
              child: Image.asset('assets/disfrutaTuComida.png', height: 160),
            ),
            const SizedBox(height: 20),
            Text(
              '¿Qué te pareció?',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: colorVerdeTese,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tu opinión ayuda a mejorar la comida de la cafetería',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: colorTextoGris),
            ),
            const SizedBox(height: 30),
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
                    size: 52,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _comentarioCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Cuéntanos qué tal estuvo la comida... (Opcional)',
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
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerdeTese,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed:
                    estrellasSeleccionadas == 0 || _enviando
                        ? null
                        : _guardarResena,
                child:
                    _enviando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Enviar Reseña',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 12),
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
