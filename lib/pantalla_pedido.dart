import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colores.dart';
import 'modelos.dart';

final AudioPlayer reproductorGlobal = AudioPlayer();

class _GrupoCarrito {
  final Platillo platillo;
  final int cantidad;
  final String clave;

  const _GrupoCarrito({
    required this.platillo,
    required this.cantidad,
    required this.clave,
  });
}

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
  final User? _usuarioAuth = FirebaseAuth.instance.currentUser;
  String _nombreAlumno = 'Estudiante TESE';
  String _alergiaAlumno = 'Sin restricciones alimentarias 😋';

  String metodoPago = 'Efectivo';
  final TextEditingController _notasCtrl = TextEditingController();
  bool _estaCargando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosAlumno();
  }

  Future<void> _cargarDatosAlumno() async {
    if (_usuarioAuth != null) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('Usuarios')
                .doc(_usuarioAuth.uid)
                .get();
        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nombreAlumno = data['nombre_completo'] ?? 'Estudiante TESE';
            _alergiaAlumno =
                data['alergia'] ?? 'Sin restricciones alimentarias 😋';
          });
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  String _clavePlatillo(Platillo p) => '${p.id}|${p.personalizacion.join(',')}';

  List<_GrupoCarrito> _agruparCarrito() {
    final Map<String, List<Platillo>> mapa = {};
    for (final p in widget.carrito) {
      final k = _clavePlatillo(p);
      mapa.putIfAbsent(k, () => []).add(p);
    }
    return mapa.entries
        .map(
          (e) => _GrupoCarrito(
            platillo: e.value.first,
            cantidad: e.value.length,
            clave: e.key,
          ),
        )
        .toList();
  }

  void _incrementarGrupo(_GrupoCarrito grupo) {
    final int stockMax =
        grupo.platillo.existencias > 0 ? grupo.platillo.existencias : 99;
    if (grupo.cantidad >= stockMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo hay $stockMax disponibles de ${grupo.platillo.nombre}.',
          ),
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => widget.carrito.add(grupo.platillo));
  }

  void _decrementarGrupo(_GrupoCarrito grupo) {
    HapticFeedback.selectionClick();
    final idx = widget.carrito.indexWhere(
      (p) => _clavePlatillo(p) == grupo.clave,
    );
    if (idx != -1) {
      setState(() => widget.carrito.removeAt(idx));
    }
  }

  void _eliminarGrupoCompleto(_GrupoCarrito grupo) {
    HapticFeedback.mediumImpact();
    setState(
      () => widget.carrito.removeWhere((p) => _clavePlatillo(p) == grupo.clave),
    );
  }

  void _mostrarConfirmacion(double total) {
    HapticFeedback.heavyImpact();
    final String localDestino =
        widget.carrito.isNotEmpty
            ? widget.carrito.first.local
            : 'Cafetería Central';
    final int puntosTotales = widget.carrito.fold<int>(
      0,
      (acumulado, p) => acumulado + p.puntos,
    );
    final grupos = _agruparCarrito();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (ctxModal) => StatefulBuilder(
            builder: (contextModal, setStateModal) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 24,
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
                      'Confirmar tu Orden',
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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorAmarilloTese.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🪙 Ganarás: +$puntosTotales pts al recoger',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: colorVerdeOscuro,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total a pagar: \$${total.toStringAsFixed(2)}\nPagarás con $metodoPago directo en ventanilla.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: colorTextoGris,
                        fontSize: 13,
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
                                    : () => Navigator.pop(ctxModal),
                            child: Text(
                              'Revisar',
                              style: GoogleFonts.poppins(
                                color: colorTextoGris,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorExito,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon:
                                _estaCargando
                                    ? const SizedBox.shrink()
                                    : const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 20,
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

                                        String detallesCocina = grupos
                                            .map((g) {
                                              String personalizacion =
                                                  g
                                                          .platillo
                                                          .personalizacion
                                                          .isNotEmpty
                                                      ? '\n  • ${g.platillo.personalizacion.join('\n  • ')}'
                                                      : '';
                                              return '${g.cantidad}x ${g.platillo.nombre}$personalizacion';
                                            })
                                            .join('\n\n');

                                        String notasAdicionales =
                                            _notasCtrl.text.trim();

                                        if (_alergiaAlumno !=
                                            'Sin restricciones alimentarias 😋') {
                                          if (notasAdicionales.isNotEmpty) {
                                            notasAdicionales +=
                                                ' | ALERGIA: $_alergiaAlumno';
                                          } else {
                                            notasAdicionales =
                                                'ALERGIA: $_alergiaAlumno';
                                          }
                                        }

                                        if (notasAdicionales.isNotEmpty) {
                                          detallesCocina +=
                                              '\n\nNOTAS: $notasAdicionales';
                                        }

                                        final Map<String, String>
                                        unicosParaResena = {};
                                        for (var p in widget.carrito) {
                                          unicosParaResena[p.id] = p.nombre;
                                        }
                                        List<Map<String, dynamic>>
                                        itemsParaResena =
                                            unicosParaResena.entries
                                                .map(
                                                  (e) => {
                                                    'id': e.key,
                                                    'nombre': e.value,
                                                  },
                                                )
                                                .toList();

                                        await FirebaseFirestore.instance
                                            .collection('Pedidos')
                                            .doc(codigoUnico)
                                            .set({
                                              'idPedido': codigoUnico,
                                              'alumno': _nombreAlumno,
                                              'idAlumno':
                                                  _usuarioAuth?.uid ??
                                                  'anonimo',
                                              'local': localDestino,
                                              'detalle': detallesCocina,
                                              'metodoPago': metodoPago,
                                              'notas': notasAdicionales,
                                              'total': total,
                                              'estado': 0,
                                              'calificado': false,
                                              'items': itemsParaResena,
                                              'puntosGanados': puntosTotales,
                                              'puntosAcreditados': false,
                                              'horaLlegada':
                                                  FieldValue.serverTimestamp(),
                                            });

                                        for (var g in grupos) {
                                          FirebaseFirestore.instance
                                              .collection('Menu_Platillos')
                                              .doc(g.platillo.id)
                                              .update({
                                                'existencias':
                                                    FieldValue.increment(
                                                      -g.cantidad,
                                                    ),
                                              });
                                        }

                                        try {
                                          reproductorGlobal.play(
                                            AssetSource('exito.mp3'),
                                            volume: 1.0,
                                          );
                                        } catch (_) {}

                                        if (!ctxModal.mounted) return;
                                        Navigator.pop(ctxModal);
                                        widget.onVaciar();

                                        if (!mounted) return;
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    PantallaPedidoExitoso(
                                                      codigoPedido: codigoUnico,
                                                      total: total,
                                                      local: localDestino,
                                                    ),
                                          ),
                                        );
                                      } catch (e) {
                                        setStateModal(
                                          () => _estaCargando = false,
                                        );
                                      }
                                    },
                            label:
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
                                      '¡Enviar a Cocina!',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.5,
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
    final double total = widget.carrito.fold(
      0,
      (acumulado, item) => acumulado + item.precio,
    );
    final int puntosTotales = widget.carrito.fold<int>(
      0,
      (acumulado, item) => acumulado + item.puntos,
    );
    final grupos = _agruparCarrito();
    final bool tieneAlergia =
        _alergiaAlumno != 'Sin restricciones alimentarias 😋';

    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Tu Orden (${widget.carrito.length})',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: colorVerdeTese,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.carrito.isNotEmpty)
            IconButton(
              tooltip: 'Vaciar carrito',
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() => widget.carrito.clear());
                widget.onVaciar();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                grupos.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: 76,
                              color: colorTextoGris.withValues(alpha: 0.5),
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
                              'Regresa al menú para elegir tus alimentos favoritos.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: colorTextoGris,
                              ),
                            ),
                            const SizedBox(height: 18),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorVerdeTese,
                                side: const BorderSide(color: colorVerdeTese),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: Text(
                                'Ir al Menú',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: grupos.length,
                      itemBuilder: (context, index) {
                        final grupo = grupos[index];
                        final item = grupo.platillo;
                        final double subtotal = item.precio * grupo.cantidad;

                        return Dismissible(
                          key: ValueKey(grupo.clave),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _eliminarGrupoCompleto(grupo),
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: colorVerdeTese.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nombre,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: colorTextoOscuro,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            '📍 ${item.local}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11.5,
                                              color: colorVerdeTese,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '🪙 +${item.puntos * grupo.cantidad} pts',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: colorAmarilloTese,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.personalizacion.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
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
                                            item.personalizacion.join(' • '),
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Text(
                                        '\$${subtotal.toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15.5,
                                          color: colorVerdeTese,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Controles interactivos [-] cantidad [+]
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorFondoCrema,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: colorVerdeTese.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: Icon(
                                          grupo.cantidad == 1
                                              ? Icons.delete_outline
                                              : Icons.remove,
                                          size: 18,
                                          color:
                                              grupo.cantidad == 1
                                                  ? Colors.redAccent
                                                  : colorTextoOscuro,
                                        ),
                                        onPressed:
                                            () => _decrementarGrupo(grupo),
                                      ),
                                      Text(
                                        '${grupo.cantidad}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: colorTextoOscuro,
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(
                                          Icons.add,
                                          size: 18,
                                          color: colorVerdeTese,
                                        ),
                                        onPressed:
                                            () => _incrementarGrupo(grupo),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          if (widget.carrito.isNotEmpty)
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
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
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tieneAlergia) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorAmarilloTese.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorAmarilloTese.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.health_and_safety,
                                size: 18,
                                color: colorVerdeTese,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Se notificará a cocina: $_alergiaAlumno',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      TextField(
                        controller: _notasCtrl,
                        decoration: InputDecoration(
                          hintText:
                              'Notas para el chef (ej. bien doradito, poca sal...)',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: colorTextoGris,
                          ),
                          prefixIcon: const Icon(
                            Icons.edit_note,
                            color: colorAmarilloTese,
                          ),
                          filled: true,
                          fillColor: colorFondoCrema,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '¿Cómo pagarás al recoger en ventanilla?',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      metodoPago == 'Efectivo'
                                          ? colorVerdeTese.withValues(
                                            alpha: 0.1,
                                          )
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.payments_outlined,
                                      size: 20,
                                      color:
                                          metodoPago == 'Efectivo'
                                              ? colorVerdeTese
                                              : colorTextoGris,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Efectivo',
                                      style: GoogleFonts.poppins(
                                        color:
                                            metodoPago == 'Efectivo'
                                                ? colorVerdeTese
                                                : colorTextoGris,
                                        fontWeight: FontWeight.bold,
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
                                setState(
                                  () => metodoPago = 'Terminal Bancaria',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      metodoPago == 'Terminal Bancaria'
                                          ? colorVerdeTese.withValues(
                                            alpha: 0.1,
                                          )
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.credit_card_outlined,
                                      size: 20,
                                      color:
                                          metodoPago == 'Terminal Bancaria'
                                              ? colorVerdeTese
                                              : colorTextoGris,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tarjeta',
                                      style: GoogleFonts.poppins(
                                        color:
                                            metodoPago == 'Terminal Bancaria'
                                                ? colorVerdeTese
                                                : colorTextoGris,
                                        fontWeight: FontWeight.bold,
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
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total de tu orden:',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: colorTextoGris,
                                ),
                              ),
                              Text(
                                '🪙 Ganarás +$puntosTotales puntos',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: colorVerdeTese,
                                ),
                              ),
                            ],
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
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorAmarilloTese,
                            elevation: 4,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => _mostrarConfirmacion(total),
                          icon: const Icon(
                            Icons.send_rounded,
                            color: colorVerdeOscuro,
                            size: 20,
                          ),
                          label: Text(
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
                  '¡Pedido Enviado! 🦆',
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
                  'Tu orden ya llegó a la pantalla de cocina. Te avisaremos con un ¡CUAC! cuando esté lista.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: colorTextoGris,
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                    icon: const Icon(Icons.radar_rounded, color: Colors.white),
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
                      'Ver Seguimiento en Vivo',
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
        int puntos = data['puntosGanados'] ?? 10;
        bool yaCalificado = data['calificado'] ?? false;

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
          subtituloEstado = 'El kiosko recibió tu orden y está por comenzar.';
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
              'Acude a la ventanilla de $local y muestra este ticket.';
          patitoAsset = 'assets/patito_listo.png';
        } else {
          colorEstado = colorVerdeTese;
          tituloEstado = '¡Pedido Entregado!';
          subtituloEstado =
              '¡Buen provecho! Ganaste +$puntos puntos 🪙 con esta compra.';
          patitoAsset = 'assets/disfrutaTuComida.png';
        }

        return Scaffold(
          backgroundColor: colorFondoCrema,
          appBar: AppBar(
            title: Text(
              'Seguimiento en Vivo',
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
                          if ((estadoActual == 2 || estadoActual >= 3) &&
                              !yaCalificado) ...[
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorAmarilloTese,
                                  foregroundColor: colorVerdeOscuro,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.star_rounded, size: 20),
                                label: Text(
                                  'Calificar qué tal estuvo mi comida ⭐',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => PantallaResena(
                                            codigoPedido: widget.codigoPedido,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
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
                                    'Muestra este código en ventanilla para recoger sin fila.',
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
                                'Ticket Digital',
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
// ⭐️ PANTALLA RESEÑA VINCULADA AL LOCAL Y PLATILLO
// ==========================================================
class PantallaResena extends StatefulWidget {
  final String codigoPedido;
  const PantallaResena({super.key, required this.codigoPedido});

  @override
  State<PantallaResena> createState() => _PantallaResenaState();
}

class _PantallaResenaState extends State<PantallaResena> {
  final User? _usuarioAuth = FirebaseAuth.instance.currentUser;
  String _nombreAutor = 'Estudiante TESE';
  String _localPedido = 'Cafetería Central';

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
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      if (_usuarioAuth != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('Usuarios')
                .doc(_usuarioAuth.uid)
                .get();
        if (userDoc.exists) {
          _nombreAutor =
              (userDoc.data() as Map)['nombre_completo'] ?? 'Estudiante TESE';
        }
      }

      final doc =
          await FirebaseFirestore.instance
              .collection('Pedidos')
              .doc(widget.codigoPedido)
              .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _localPedido = data['local'] ?? 'Cafetería Central';
        final List rawItems = data['items'] ?? [];
        if (!mounted) return;
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
        if (mounted) setState(() => _cargandoPedido = false);
      }
    } catch (_) {
      if (mounted) setState(() => _cargandoPedido = false);
    }
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarResena() async {
    if (estrellasSeleccionadas == 0 || itemSeleccionadoId == null) return;
    setState(() => _enviando = true);
    HapticFeedback.heavyImpact();

    try {
      await FirebaseFirestore.instance.collection('Resenas').add({
        'codigoPedido': widget.codigoPedido,
        'local': _localPedido,
        'platilloId': itemSeleccionadoId,
        'platilloNombre': itemSeleccionadoNombre ?? 'Comida',
        'estrellas': estrellasSeleccionadas,
        'comentario': _comentarioCtrl.text.trim(),
        'alumno': _nombreAutor,
        'idAlumno': _usuarioAuth?.uid ?? 'anonimo',
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

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Reseña enviada! Gracias por ayudar a mejorar la comida del TESE ⭐',
          ),
          backgroundColor: colorExito,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _enviando = false);
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
                      'Tu opinión actualiza las estrellas del platillo en $_localPedido',
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
                        hintText:
                            'Cuéntanos qué tal estuvo el sabor y la porción...',
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
                    const SizedBox(height: 28),
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
                                ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
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
                  ],
                ),
              ),
    );
  }
}
