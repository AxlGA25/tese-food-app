import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'package:image_picker/image_picker.dart';
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_login.dart';
import 'pantalla_gachapon.dart';
import 'servicio_notificaciones.dart';

class _GrupoCarrito {
  final Platillo platilloBase;
  final List<int> indicesOriginales;
  int get cantidad => indicesOriginales.length;
  double get subtotal => platilloBase.precio * cantidad;

  _GrupoCarrito({required this.platilloBase, required this.indicesOriginales});
}

// ==========================================================
// 1. PANTALLA DE REVISIÓN DE CARRITO Y ENVÍO DE PEDIDO
// ==========================================================
class CarritoScreen extends StatefulWidget {
  final List<Platillo> carrito;
  const CarritoScreen({super.key, required this.carrito});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  String metodoPagoSeleccionado = 'Efectivo en ventanilla 💵';
  final TextEditingController _notasCtrl = TextEditingController();
  bool _enviandoPedido = false;
  String _alergiaPerfil = 'Sin restricciones alimentarias 😋';
  String _nombreEstudiante = 'Estudiante TESE';

  @override
  void initState() {
    super.initState();
    _cargarDatosAlumno();
  }

  Future<void> _cargarDatosAlumno() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _nombreEstudiante = user.displayName ?? 'Estudiante TESE';
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(user.uid)
              .get();
      if (doc.exists && mounted) {
        final d = doc.data()!;
        setState(() {
          _nombreEstudiante = d['nombre_completo'] ?? _nombreEstudiante;
          _alergiaPerfil = d['alergia'] ?? 'Sin restricciones alimentarias 😋';
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  List<_GrupoCarrito> _agruparCarrito() {
    final Map<String, _GrupoCarrito> mapa = {};
    for (int i = 0; i < widget.carrito.length; i++) {
      final p = widget.carrito[i];
      final clave = '${p.id}__${p.nombre}__${p.personalizacion.join(',')}';
      if (!mapa.containsKey(clave)) {
        mapa[clave] = _GrupoCarrito(platilloBase: p, indicesOriginales: [i]);
      } else {
        mapa[clave]!.indicesOriginales.add(i);
      }
    }
    return mapa.values.toList();
  }

  double get _totalPagar =>
      widget.carrito.fold(0.0, (acc, item) => acc + item.precio);

  int get _puntosTotales =>
      widget.carrito.fold(0, (acc, item) => acc + item.puntos);

  void _incrementarPlatillo(_GrupoCarrito grupo) {
    final totalDeEseIdEnCarrito =
        widget.carrito.where((p) => p.id == grupo.platilloBase.id).length;

    if (totalDeEseIdEnCarrito >= grupo.platilloBase.existencias) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock máximo alcanzado (${grupo.platilloBase.existencias} disponibles).',
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      widget.carrito.add(grupo.platilloBase);
    });
  }

  void _decrementarPlatillo(_GrupoCarrito grupo) {
    HapticFeedback.selectionClick();
    setState(() {
      widget.carrito.removeAt(grupo.indicesOriginales.last);
    });
  }

  Future<void> _confirmarYEnviarPedido() async {
    if (widget.carrito.isEmpty || _enviandoPedido) return;

    setState(() => _enviandoPedido = true);
    HapticFeedback.mediumImpact();

    final bool hayRed = await verificarConexionInternet();
    if (!hayRed) {
      if (mounted) {
        setState(() => _enviandoPedido = false);
        _mostrarAlertaError(
          '📡 No tienes conexión a Internet. Conéctate a una red Wi-Fi o activa tus datos móviles para enviar tu pedido.',
        );
      }
      return;
    }

    final String sucursalDestino = widget.carrito.first.local;

    try {
      final snapLocal = await FirebaseFirestore.instance
          .collection('Locales_Seguridad')
          .where('nombre', isEqualTo: sucursalDestino)
          .get()
          .timeout(const Duration(seconds: 6));

      if (snapLocal.docs.isNotEmpty) {
        final datosLocal = snapLocal.docs.first.data();
        final bool abierto = datosLocal['abierto'] ?? true;
        if (!abierto) {
          if (mounted) {
            setState(() => _enviandoPedido = false);
            _mostrarAlertaError(
              '🔒 Lo sentimos, $sucursalDestino acaba de cerrar su recepción de pedidos por hoy.',
            );
          }
          return;
        }
      }

      final grupos = _agruparCarrito();
      final List<String> lineasDetalle = [];
      final List<String> platillosIds = [];
      final List<String> platillosNombres = [];
      final Map<String, int> cantidadesPorPlatillo = {};

      for (final g in grupos) {
        final String extraPers =
            g.platilloBase.personalizacion.isNotEmpty
                ? ' (${g.platilloBase.personalizacion.join(', ')})'
                : '';
        lineasDetalle.add('${g.cantidad}x ${g.platilloBase.nombre}$extraPers');
        if (!platillosIds.contains(g.platilloBase.id)) {
          platillosIds.add(g.platilloBase.id);
          platillosNombres.add(g.platilloBase.nombre);
        }
        cantidadesPorPlatillo[g.platilloBase.id] =
            (cantidadesPorPlatillo[g.platilloBase.id] ?? 0) + g.cantidad;
      }

      final List<String> notasFinales = [];
      if (!_alergiaPerfil.startsWith('Sin restricciones')) {
        notasFinales.add('ALERTA ALERGIA: $_alergiaPerfil');
      }
      if (_notasCtrl.text.trim().isNotEmpty) {
        notasFinales.add(_notasCtrl.text.trim());
      }
      final String textoNotas =
          notasFinales.isEmpty
              ? 'Sin notas adicionales'
              : notasFinales.join(' | ');

      final String codigoOrden = '#TESE-${10000 + Random().nextInt(89999)}';
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonimo';
      final double totalFinal = _totalPagar;
      final int puntosFinales = _puntosTotales;

      final docRef = await FirebaseFirestore.instance
          .collection('Pedidos')
          .add({
            'idPedido': codigoOrden,
            'idAlumno': uid,
            'alumno': _nombreEstudiante,
            'local': sucursalDestino,
            'detalle': lineasDetalle.join('\n'),
            'notas': textoNotas,
            'metodoPago': metodoPagoSeleccionado,
            'total': totalFinal,
            'puntosGanados': puntosFinales,
            'estado': 0,
            'ocultoParaAlumno': false,
            'platillosIds': platillosIds,
            'platillosNombres': platillosNombres,
            'cantidadesPorPlatillo': cantidadesPorPlatillo,
            'horaLlegada': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));

      for (final entry in cantidadesPorPlatillo.entries) {
        if (entry.key.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('Menu_Platillos')
              .doc(entry.key)
              .update({'existencias': FieldValue.increment(-entry.value)})
              .catchError((_) {});
        }
      }

      // 1️⃣ AL CONFIRMAR EL PEDIDO: Suena 'sonidos/exito.mp3' y sale notificación
      await ServicioNotificaciones.mostrarNotificacionOrden(
        id: docRef.id.hashCode,
        titulo: '✅ ¡Pedido $codigoOrden confirmado!',
        cuerpo:
            'Tu orden fue enviada a $sucursalDestino. Sonará un ¡CUAC! cuando entre a cocina.',
        enCurso: true,
        esPedidoListo: false,
        sonido: 'sonidos/exito.mp3',
      );

      if (!mounted) return;
      widget.carrito.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => SalaEsperaPedidoScreen(
                pedidoDocId: docRef.id,
                codigoInicial: codigoOrden,
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _enviandoPedido = false);
        _mostrarAlertaError(
          '📡 Tu conexión a Internet es inestable y no se pudo confirmar el pedido. Intenta nuevamente.',
        );
      }
    }
  }

  void _mostrarAlertaError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 12.5)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _agruparCarrito();
    final String sucursal =
        widget.carrito.isNotEmpty ? widget.carrito.first.local : 'Cafetería';

    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorVerdeTese,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmar tu Pedido 🛒',
              style: GoogleFonts.poppins(
                color: colorVerdeTese,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              'Sucursal: $sucursal',
              style: GoogleFonts.poppins(
                color: colorTextoGris,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
      body:
          widget.carrito.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 60,
                        color: colorVerdeTese,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tu carrito está vacío',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Agrega tus platillos favoritos del menú para pedir.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: colorTextoGris,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorVerdeTese,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Explorar Menú',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_alergiaPerfil.startsWith('Sin restricciones'))
                      FadeInDown(
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFFD54F)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.medical_information_rounded,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Nota médica activa: $_alergiaPerfil',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Text(
                      'Resumen de Platillos (${widget.carrito.length})',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...grupos.map((g) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: colorVerdeTese.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.fastfood_rounded,
                                color: colorVerdeTese,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.platilloBase.nombre,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                  if (g.platilloBase.personalizacion.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        g.platilloBase.personalizacion.join(
                                          ' • ',
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: colorTextoGris,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${g.platilloBase.precio.toStringAsFixed(0)} c/u  •  Subtotal: \$${g.subtotal.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: colorVerdeTese,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: colorFondoCrema,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _decrementarPlatillo(g),
                                    icon: const Icon(
                                      Icons.remove_rounded,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                  ),
                                  Text(
                                    '${g.cantidad}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _incrementarPlatillo(g),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      color: colorVerdeTese,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Text(
                      'Instrucciones extra para el chef (Opcional)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _notasCtrl,
                        decoration: InputDecoration(
                          hintText: 'Ej. Salsa aparte, servilletas extra...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: colorTextoGris,
                          ),
                          prefixIcon: const Icon(
                            Icons.edit_note_rounded,
                            color: colorVerdeTese,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '¿Cómo pagarás al recoger en ventanilla?',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TarjetaMetodoPago(
                            titulo: 'Efectivo',
                            subtitulo: 'En ventanilla',
                            icono: Icons.payments_outlined,
                            seleccionado: metodoPagoSeleccionado.contains(
                              'Efectivo',
                            ),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                metodoPagoSeleccionado =
                                    'Efectivo en ventanilla 💵';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TarjetaMetodoPago(
                            titulo: 'Tarjeta',
                            subtitulo: 'Terminal física',
                            icono: Icons.credit_card_rounded,
                            seleccionado: metodoPagoSeleccionado.contains(
                              'Terminal',
                            ),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                metodoPagoSeleccionado =
                                    'Terminal Bancaria / Tarjeta 💳';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F5E9), Color(0xFFD7EFE0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorVerdeTese.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.stars_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Puntos para el Gachapón:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3C4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+$_puntosTotales pts 🪙',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: colorVerdeTese.withValues(alpha: 0.2),
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total a Pagar:',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              Text(
                                '\$${_totalPagar.toStringAsFixed(0)} MXN',
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
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 3,
                        ),
                        onPressed:
                            _enviandoPedido ? null : _confirmarYEnviarPedido,
                        icon:
                            _enviandoPedido
                                ? const SizedBox.shrink()
                                : const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                ),
                        label:
                            _enviandoPedido
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Enviando tu orden a cocina...',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                                : Text(
                                  'Confirmar Pedido 🍔',
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
}

class _TarjetaMetodoPago extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const _TarjetaMetodoPago({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: seleccionado ? colorVerdeTese : Colors.grey.shade200,
            width: seleccionado ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: seleccionado ? colorVerdeTese : colorFondoCrema,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                color: seleccionado ? Colors.white : colorVerdeTese,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: colorTextoOscuro,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: colorTextoGris,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 2. SALA DE ESPERA EN VIVO (CON STEPPER VISUAL DE 4 ETAPAS)
// ==========================================================
class SalaEsperaPedidoScreen extends StatefulWidget {
  final String pedidoDocId;
  final String codigoInicial;

  const SalaEsperaPedidoScreen({
    super.key,
    required this.pedidoDocId,
    required this.codigoInicial,
  });

  @override
  State<SalaEsperaPedidoScreen> createState() => _SalaEsperaPedidoScreenState();
}

class _SalaEsperaPedidoScreenState extends State<SalaEsperaPedidoScreen> {
  late final ConfettiController _confettiCtrl;
  int _ultimoEstadoVisto = -1;
  bool _cancelandoPorAlumno = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  // 2️⃣ CUANDO LA COCINA ACTUALIZA A "PREPARANDO" (1) O "LISTO" (2): Suena 'sonidos/cuac.mp3'
  void _verificarEfectosEstado(int nuevoEstado, String codigo, String local) {
    if (_ultimoEstadoVisto != -1 && _ultimoEstadoVisto != nuevoEstado) {
      if (nuevoEstado == 1) {
        ServicioNotificaciones.mostrarNotificacionOrden(
          id: widget.pedidoDocId.hashCode,
          titulo: '🦆 ¡CUAC! Tu orden $codigo se está preparando 🍳',
          cuerpo: 'El chef de $local ya comenzó a cocinar tus alimentos.',
          enCurso: true,
          esPedidoListo: false,
          sonido: 'sonidos/cuac.mp3',
        );
      } else if (nuevoEstado == 2) {
        _confettiCtrl.play();
        ServicioNotificaciones.mostrarNotificacionOrden(
          id: widget.pedidoDocId.hashCode,
          titulo: '🦆 ¡CUAC! ¡Tu pedido $codigo está LISTO! 🎉',
          cuerpo: 'Pasa a la ventanilla de $local a recoger tus alimentos.',
          enCurso: false,
          esPedidoListo: true,
          sonido: 'sonidos/cuac.mp3',
        );
      } else if (nuevoEstado == 4) {
        HapticFeedback.vibrate();
        ServicioNotificaciones.sonarEfecto('sonidos/exito.mp3');
      }
    }
    _ultimoEstadoVisto = nuevoEstado;
  }

  Future<void> _cancelarMiOrdenComoAlumno(Map<String, dynamic> pData) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              '¿Cancelar tu pedido?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Como la cocina aún no comienza a prepararlo, puedes cancelarlo sin costo y devolveremos los platillos al inventario.',
              style: GoogleFonts.poppins(fontSize: 13, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('No, esperar', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Sí, cancelar orden',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmar != true) return;
    setState(() => _cancelandoPorAlumno = true);

    if (!await verificarConexionInternet()) {
      setState(() => _cancelandoPorAlumno = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📡 Sin conexión a Internet para cancelar.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Pedidos')
          .doc(widget.pedidoDocId)
          .update({
            'estado': 4,
            'canceladoPor': 'Estudiante',
            'motivoCancelacion':
                'Cancelado voluntariamente antes de iniciar preparación.',
          });

      final List<dynamic> ids = pData['platillosIds'] ?? [];
      final Map<String, dynamic> cantidadesMap =
          (pData['cantidadesPorPlatillo'] as Map<String, dynamic>?) ?? {};

      for (var idPlatillo in ids) {
        final String pid = idPlatillo.toString();
        final int cantDevuelta = (cantidadesMap[pid] ?? 1) as int;
        await FirebaseFirestore.instance
            .collection('Menu_Platillos')
            .doc(pid)
            .update({'existencias': FieldValue.increment(cantDevuelta)})
            .catchError((_) {});
      }
    } finally {
      if (mounted) setState(() => _cancelandoPorAlumno = false);
    }
  }

  void _abrirModalResena(Map<String, dynamic> pedidoData) {
    int estrellas = 5;
    bool esAnonimo = false;
    final TextEditingController comentarioCtrl = TextEditingController();
    String? fotoBase64;
    bool enviandoResena = false;
    final ImagePicker picker = ImagePicker();

    final List<dynamic> ids = pedidoData['platillosIds'] ?? [];
    final List<dynamic> nombres = pedidoData['platillosNombres'] ?? [];
    final String primerId = ids.isNotEmpty ? ids.first.toString() : '';
    final String primerNombre =
        nombres.isNotEmpty ? nombres.first.toString() : 'Pedido TESE';
    final String nombreAlumnoReal =
        (pedidoData['alumno'] ?? 'Estudiante TESE').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextModal, setStateModal) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 22,
                  right: 22,
                  top: 20,
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 22,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Califica tu experiencia ⭐',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorVerdeTese,
                      ),
                    ),
                    Text(
                      primerNombre,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: colorTextoGris,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          iconSize: 36,
                          icon: Icon(
                            index < estrellas
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: colorAmarilloTese,
                          ),
                          onPressed:
                              () => setStateModal(() => estrellas = index + 1),
                        );
                      }),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: colorVerdeTese,
                      title: Text(
                        'Publicar opinión como Anónimo 🕵️‍♂️',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        esAnonimo
                            ? 'Se mostrará como "Estudiante Anónimo"'
                            : 'Se mostrará tu nombre ($nombreAlumnoReal)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: colorTextoGris,
                        ),
                      ),
                      value: esAnonimo,
                      onChanged: (v) => setStateModal(() => esAnonimo = v),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: comentarioCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: '¿Qué te pareció el sabor y la rapidez?',
                        filled: true,
                        fillColor: colorFondoCrema,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final XFile? img = await picker.pickImage(
                              source: ImageSource.camera,
                              maxWidth: 500,
                              imageQuality: 55,
                            );
                            if (img != null) {
                              final b = await img.readAsBytes();
                              setStateModal(() => fotoBase64 = base64Encode(b));
                            }
                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: Text(
                            fotoBase64 == null
                                ? 'Subir foto'
                                : 'Foto adjunta ✓',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed:
                            enviandoResena
                                ? null
                                : () async {
                                  setStateModal(() => enviandoResena = true);
                                  await FirebaseFirestore.instance
                                      .collection('Resenas')
                                      .add({
                                        'codigoPedido': pedidoData['idPedido'],
                                        'local': pedidoData['local'],
                                        'platilloId': primerId,
                                        'platilloNombre': primerNombre,
                                        'alumno':
                                            esAnonimo
                                                ? 'Estudiante Anónimo'
                                                : nombreAlumnoReal,
                                        'esAnonimo': esAnonimo,
                                        'estrellas': estrellas,
                                        'comentario':
                                            comentarioCtrl.text.trim().isEmpty
                                                ? '¡Excelente servicio!'
                                                : comentarioCtrl.text.trim(),
                                        'fotoEvidencia': fotoBase64 ?? '',
                                        'fecha': FieldValue.serverTimestamp(),
                                      });
                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '¡Gracias por tu reseña! ⭐',
                                      ),
                                      backgroundColor: colorExito,
                                    ),
                                  );
                                },
                        child: Text(
                          'Publicar Reseña',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Pedidos')
          .doc(widget.pedidoDocId)
          .snapshots(includeMetadataChanges: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: colorFondoCrema,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: colorVerdeTese),
                  const SizedBox(height: 14),
                  Text(
                    'Conectando con la terminal de cocina...',
                    style: GoogleFonts.poppins(color: colorTextoGris),
                  ),
                ],
              ),
            ),
          );
        }

        final docSnap = snapshot.data!;
        final bool pendienteDeSubir = docSnap.metadata.hasPendingWrites;
        final data = docSnap.data() as Map<String, dynamic>;
        final int estado = data['estado'] ?? 0;
        final String codigo = data['idPedido'] ?? widget.codigoInicial;
        final String local = data['local'] ?? 'Cafetería TESE';
        final String detalle = data['detalle'] ?? '';
        final String metodoPago = data['metodoPago'] ?? 'Efectivo';
        final int puntosGanados = (data['puntosGanados'] ?? 10) as int;
        final double total = (data['total'] ?? 0.0).toDouble();
        final String motivoCancelacion =
            (data['motivoCancelacion'] ?? 'Sin existencias suficientes.')
                .toString();
        final String canceladoPor =
            (data['canceladoPor'] ?? 'Cafetería').toString();
        final int compensacionPts = (data['compensacionPts'] ?? 0) as int;

        _verificarEfectosEstado(estado, codigo, local);

        if (estado == 4) {
          final PatoSkin patoTriste = catalogoPatos.firstWhere(
            (p) => p.id == 'rockstar_rosa',
            orElse: () => catalogoPatos.first,
          );

          return Scaffold(
            backgroundColor: const Color(0xFFFFF5F5),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.red.shade800,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Orden $codigo',
                style: GoogleFonts.poppins(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ZoomIn(
                      child: Container(
                        width: 145,
                        height: 145,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.35),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: PatoVista(skin: patoTriste, tamano: 110),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ORDEN CANCELADA',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '¡Una disculpa! Tu pedido no pudo completarse 🥺💔',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cancelado por: $canceladoPor',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorTextoGris,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Motivo reportado:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            motivoCancelacion,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorTextoOscuro,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (compensacionPts > 0) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFFD54F)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: Color(0xFFF59E0B),
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Te abonamos +$compensacionPts pts 🪙 de compensación para abrir cápsulas en el Gachapón.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Volver al Menú',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
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

        String tituloEstado = '¡Tu pedido fue recibido!';
        String subtituloEstado =
            'Tu comanda ya está en la pantalla de $local. En breve iniciarán la preparación.';
        String assetPatito = 'assets/patito_recibido.png';
        Color colorAcentoEtapa = const Color(0xFFF59E0B);
        Color colorCirculoPastel = const Color(0xFFFFF8E1);

        if (pendienteDeSubir) {
          tituloEstado = 'Sincronizando con la red... 📡';
          subtituloEstado = 'Enviando tu comanda al servidor de la cafetería.';
        } else if (estado == 1) {
          tituloEstado = '¡El chef está cocinando! 🍳';
          subtituloEstado =
              '$local está preparando tus alimentos calientitos al momento.';
          assetPatito = 'assets/patito_cocinando.png';
          colorAcentoEtapa = const Color(0xFFEA580C);
          colorCirculoPastel = const Color(0xFFFFF0E6);
        } else if (estado == 2) {
          tituloEstado = '¡Tu comida está LISTA! 🎉';
          subtituloEstado =
              'Pasa a la ventanilla de $local sin hacer fila y muestra tu código $codigo.';
          assetPatito = 'assets/patito_listo.png';
          colorAcentoEtapa = colorExito;
          colorCirculoPastel = const Color(0xFFE8F5E9);
        } else if (estado == 3) {
          tituloEstado = '¡Pedido Entregado! 😋';
          subtituloEstado =
              '¡Buen provecho! Sumamos +$puntosGanados pts a tu credencial digital.';
          assetPatito = 'assets/patito_feliz.png';
          colorAcentoEtapa = colorVerdeTese;
          colorCirculoPastel = const Color(0xFFE8F5E9);
        }

        return Scaffold(
          backgroundColor: colorFondoCrema,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorVerdeTese,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Seguimiento en Vivo',
              style: GoogleFonts.poppins(
                color: colorVerdeTese,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                child: Column(
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: colorAcentoEtapa.withValues(alpha: 0.35),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorAcentoEtapa.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CÓDIGO PARA VENTANILLA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: colorTextoGris,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  codigo,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: colorVerdeTese,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorCirculoPastel,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorAcentoEtapa.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.storefront_rounded,
                                    size: 15,
                                    color: colorAcentoEtapa,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    local,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ZoomIn(
                      key: ValueKey<int>(estado),
                      duration: const Duration(milliseconds: 350),
                      child: Container(
                        width: 155,
                        height: 155,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorCirculoPastel,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorAcentoEtapa.withValues(alpha: 0.35),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorAcentoEtapa.withValues(alpha: 0.14),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          assetPatito,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) => Icon(
                                Icons.fastfood_rounded,
                                size: 80,
                                color: colorAcentoEtapa,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      tituloEstado,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        subtituloEstado,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: colorTextoGris,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _TarjetaEtapasPedido(
                        estadoActual: estado,
                        colorActivo: colorAcentoEtapa,
                        local: local,
                        codigo: codigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 180),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
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
                                Text(
                                  'Resumen de tu Orden',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w800,
                                    color: colorTextoOscuro,
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+$puntosGanados pts 🪙',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Text(
                              detalle,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: colorTextoOscuro,
                              ),
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  metodoPago,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: colorTextoGris,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Total: \$${total.toStringAsFixed(0)} MXN',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w900,
                                    color: colorVerdeTese,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (estado == 0 && !pendienteDeSubir) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.redAccent,
                              width: 1.4,
                            ),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              _cancelandoPorAlumno
                                  ? null
                                  : () => _cancelarMiOrdenComoAlumno(data),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: Text(
                            'Cancelar mi orden (Aún no entra a cocina)',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (estado == 3) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorAmarilloTese,
                            foregroundColor: colorVerdeOscuro,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _abrirModalResena(data),
                          icon: const Icon(Icons.star_rate_rounded),
                          label: Text(
                            'Calificar Platillo y Dejar Reseña',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'Volver al Menú Principal',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ConfettiWidget(
                confettiController: _confettiCtrl,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================================
// WIDGET DE ETAPAS DEL PEDIDO (STEPPER VISUAL ANIMADO)
// ==========================================================
class _TarjetaEtapasPedido extends StatelessWidget {
  final int estadoActual;
  final Color colorActivo;
  final String local;
  final String codigo;

  const _TarjetaEtapasPedido({
    required this.estadoActual,
    required this.colorActivo,
    required this.local,
    required this.codigo,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> etapas = [
      {
        'paso': 0,
        'titulo': '1. Orden Recibida',
        'sub': 'Comanda registrada en $local',
        'icono': Icons.receipt_long_rounded,
      },
      {
        'paso': 1,
        'titulo': '2. En Preparación',
        'sub': 'El chef está cocinando tus alimentos',
        'icono': Icons.soup_kitchen_rounded,
      },
      {
        'paso': 2,
        'titulo': '3. ¡Listo en Ventanilla!',
        'sub': 'Pasa a recoger mostrando tu folio $codigo',
        'icono': Icons.notifications_active_rounded,
      },
      {
        'paso': 3,
        'titulo': '4. Entregado y Puntos Sumados',
        'sub': 'Orden finalizada con éxito',
        'icono': Icons.verified_rounded,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
              Text(
                'Progreso de tu Pedido',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: colorTextoOscuro,
                ),
              ),
              Text(
                'Etapa ${estadoActual + 1} de 4',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                  color: colorActivo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(4, (index) {
              final bool completado = estadoActual >= index;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 7,
                  margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: completado ? colorActivo : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          ...etapas.map((e) {
            final int paso = e['paso'] as int;
            final bool yaPaso = estadoActual > paso;
            final bool esActual = estadoActual == paso;
            final bool futuro = estadoActual < paso;

            Color colorCirculo = Colors.grey.shade200;
            Color colorIcono = Colors.grey.shade500;
            if (yaPaso) {
              colorCirculo = const Color(0xFFE8F5E9);
              colorIcono = colorExito;
            } else if (esActual) {
              colorCirculo = colorActivo;
              colorIcono = Colors.white;
            }

            return Padding(
              padding: EdgeInsets.only(bottom: paso < 3 ? 12 : 0),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorCirculo,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      yaPaso ? Icons.check_rounded : (e['icono'] as IconData),
                      color: colorIcono,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e['titulo'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight:
                                esActual
                                    ? FontWeight.w900
                                    : (yaPaso
                                        ? FontWeight.w700
                                        : FontWeight.w500),
                            color: futuro ? colorTextoGris : colorTextoOscuro,
                          ),
                        ),
                        Text(
                          e['sub'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: esActual ? colorActivo : colorTextoGris,
                            fontWeight:
                                esActual ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (esActual)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorActivo.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Actual',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: colorActivo,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
