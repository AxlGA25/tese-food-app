import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_menu.dart';

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
          (context) => Container(
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
                  Icons.info_outline,
                  size: 60,
                  color: colorAmarilloTese,
                ),
                const SizedBox(height: 16),
                Text(
                  'Confirmar Compra',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorTextoOscuro,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Estás a punto de enviar tu pedido a la cafetería por un total de \$${total.toStringAsFixed(2)}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colorTextoGris,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.poppins(
                            color: colorTextoGris,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorExito,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          if (context.mounted) {
                            Navigator.pop(context);
                            widget.onVaciar();
                            Navigator.pop(context, {
                              'total': total,
                              'notas': _notasCtrl.text,
                            });
                          }
                        },
                        child: Text(
                          '¡Pagar!',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                          onDismissed: (direction) {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              widget.carrito.removeAt(index);
                            });
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
                    TextField(
                      controller: _notasCtrl,
                      decoration: InputDecoration(
                        hintText: 'Instrucciones especiales (ej. Sin cebolla)',
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
                    const SizedBox(height: 20),
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
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => metodoPago = 'Efectivo');
                            },
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
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => metodoPago = 'Terminal Bancaria');
                            },
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
                                : () => _mostrarConfirmacion(total),
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

class PedidoEnviadoScreen extends StatefulWidget {
  const PedidoEnviadoScreen({super.key});

  @override
  State<PedidoEnviadoScreen> createState() => _PedidoEnviadoScreenState();
}

class _PedidoEnviadoScreenState extends State<PedidoEnviadoScreen> {
  final AudioPlayer _audioPlayerExito = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _reproducirSonido();
  }

  void _reproducirSonido() async {
    try {
      await _audioPlayerExito.play(AssetSource('exito.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('Error reproduciendo sonido: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayerExito.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorVerdeTese,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BounceInDown(
                child: Image.asset(
                  'assets/compraHecha.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                child: Text(
                  '¡Pedido Enviado!',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Tu orden ya está en la cafetería.\nRevisa el menú de "Mis Pedidos" para ver el estado en tiempo real.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAmarilloTese,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Ir a mis pedidos',
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
      backgroundColor: colorFondo,
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
        iconTheme: IconThemeData(color: colorTextoTop),
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
        mostrarBoton: false,
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
          ],
        ),
      ),
    );
  }
}
