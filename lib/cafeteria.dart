import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'colores.dart';
import 'pantalla_acceso_qr.dart';

// ==========================================================
// 1. PUERTA DE ACCESO (CONECTADA A QR 1-DISPOSITIVO + ADMIN)
// ==========================================================
class LoginLocalScreen extends StatelessWidget {
  const LoginLocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaAccesoQR(
      onTerminalAutorizada: (docId, nombreSucursal, codigoSucursal) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => DashboardLocalScreen(
                  nombreLocal: nombreSucursal,
                  docIdLocal: docId,
                ),
          ),
        );
      },
    );
  }
}

// ==========================================================
// 2. TERMINAL DE COCINA (KDS) + CORTE DE CAJA INTERACTIVO
// ==========================================================
class DashboardLocalScreen extends StatefulWidget {
  final String nombreLocal;
  final String? docIdLocal;

  const DashboardLocalScreen({
    super.key,
    required this.nombreLocal,
    this.docIdLocal,
  });

  @override
  State<DashboardLocalScreen> createState() => _DashboardLocalScreenState();
}

class _DashboardLocalScreenState extends State<DashboardLocalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription<DocumentSnapshot>? _subSeguridadDispositivo;

  // Filtro Pestaña 1 (Comandas KDS): -1 = Todos, 0 = Nuevos, 1 = En Cocina, 2 = Listos
  int _filtroEstadoKds = -1;

  // Filtros Pestaña 2 (Historial y Corte de Caja Interactivo)
  // 'vendidos' | 'efectivo' | 'tarjeta' | 'cancelados'
  String _filtroCorte = 'vendidos';
  bool _soloHoyCorte = true;

  bool _localAbierto = true;
  String? _docIdResuelto;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _iniciarVigilanciaTerminal();
  }

  Future<void> _iniciarVigilanciaTerminal() async {
    try {
      String? docId = widget.docIdLocal;
      if (docId == null || docId.isEmpty) {
        final q =
            await FirebaseFirestore.instance
                .collection('Locales_Seguridad')
                .where('nombre', isEqualTo: widget.nombreLocal)
                .limit(1)
                .get();
        if (q.docs.isNotEmpty) {
          docId = q.docs.first.id;
        }
      }
      if (docId == null) return;
      _docIdResuelto = docId;

      final miDeviceId =
          await ServicioDispositivoTerminal.obtenerOCrearDeviceId();

      _subSeguridadDispositivo = FirebaseFirestore.instance
          .collection('Locales_Seguridad')
          .doc(docId)
          .snapshots()
          .listen((snap) {
            if (!snap.exists || !mounted) return;
            final data = snap.data()!;
            final bool abierto = (data['abierto'] ?? true) as bool;
            if (_localAbierto != abierto) {
              setState(() => _localAbierto = abierto);
            }

            // Si el Admin expulsó este dispositivo o vinculó otro, cerramos sesión en vivo
            final String? autorizadoEnNube =
                data['dispositivoAutorizadoId'] as String?;
            if (autorizadoEnNube != null && autorizadoEnNube != miDeviceId) {
              _expulsarPorRevocacion();
            } else if (autorizadoEnNube == null && widget.docIdLocal != null) {
              _expulsarPorRevocacion();
            }
          });
    } catch (_) {}
  }

  Future<void> _expulsarPorRevocacion() async {
    await _subSeguridadDispositivo?.cancel();
    await ServicioDispositivoTerminal.limpiarVinculacionLocal();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔒 Esta terminal fue desvinculada por Administración.',
          style: GoogleFonts.poppins(fontSize: 12.5),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _subSeguridadDispositivo?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _alternarEstadoLocal(bool nuevoValor) async {
    HapticFeedback.mediumImpact();
    setState(() => _localAbierto = nuevoValor);
    if (_docIdResuelto != null) {
      await FirebaseFirestore.instance
          .collection('Locales_Seguridad')
          .doc(_docIdResuelto)
          .set({'abierto': nuevoValor}, SetOptions(merge: true));
    }
  }

  Future<void> _confirmarBloqueoTerminal() async {
    final salir = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Bloquear Terminal?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.5,
                      color: colorTextoOscuro,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Saldrás de la pantalla de cocina de ${widget.nombreLocal}. Tu dispositivo seguirá vinculado para cuando vuelvas a entrar.',
              style: GoogleFonts.poppins(fontSize: 13, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Seguir en Cocina',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: colorTextoGris,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Bloquear',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (salir == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _cambiarEstadoPedido(String docId, int nuevoEstado) async {
    HapticFeedback.mediumImpact();
    await FirebaseFirestore.instance.collection('Pedidos').doc(docId).update({
      'estado': nuevoEstado,
      if (nuevoEstado == 3) 'horaEntrega': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _cancelarPedidoDesdeCocina(
    String docId,
    Map<String, dynamic> data,
  ) async {
    final TextEditingController motivoCtrl = TextEditingController(
      text: 'Sin existencias suficientes en cocina.',
    );

    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              'Cancelar Comanda',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                color: Colors.red.shade800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se devolverán las existencias al inventario y se abonarán +10 pts 🪙 de compensación al estudiante.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: colorTextoGris,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: motivoCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Motivo para el estudiante',
                    filled: true,
                    fillColor: colorFondoCrema,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Volver', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Confirmar Cancelación',
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
    HapticFeedback.heavyImpact();

    await FirebaseFirestore.instance.collection('Pedidos').doc(docId).update({
      'estado': 4,
      'canceladoPor': widget.nombreLocal,
      'motivoCancelacion':
          motivoCtrl.text.trim().isEmpty
              ? 'Sin existencias suficientes.'
              : motivoCtrl.text.trim(),
      'compensacionPts': 10,
    });

    // Devolver stock atómicamente
    final List<dynamic> ids = data['platillosIds'] ?? [];
    final Map<String, dynamic> cantidadesMap =
        (data['cantidadesPorPlatillo'] as Map<String, dynamic>?) ?? {};
    for (final idPlatillo in ids) {
      final String pid = idPlatillo.toString();
      final int cant = (cantidadesMap[pid] ?? 1) as int;
      await FirebaseFirestore.instance
          .collection('Menu_Platillos')
          .doc(pid)
          .update({'existencias': FieldValue.increment(cant)})
          .catchError((_) {});
    }

    // Abonar +10 pts al alumno
    final String idAlumno = (data['idAlumno'] ?? '').toString();
    if (idAlumno.isNotEmpty && idAlumno != 'anonimo') {
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(idAlumno)
          .set({
            'puntosCompensacion': FieldValue.increment(10),
          }, SetOptions(merge: true))
          .catchError((_) {});
    }
  }

  // Modal de detalle de comanda (sirve tanto para KDS como para Ticket del Historial)
  void _abrirDetalleComanda(
    String docId,
    Map<String, dynamic> data, {
    bool soloLectura = false,
  }) {
    final String codigo = (data['idPedido'] ?? '#TESE').toString();
    final String alumno = (data['alumno'] ?? 'Estudiante TESE').toString();
    final String idAlumno = (data['idAlumno'] ?? '').toString();
    final String detalle = (data['detalle'] ?? '').toString();
    final String notas = (data['notas'] ?? 'Sin notas adicionales').toString();
    final String metodoPago = (data['metodoPago'] ?? 'Efectivo').toString();
    final double total = (data['total'] ?? 0).toDouble();
    final int estado = (data['estado'] ?? 0) as int;
    final Timestamp? horaLlegada = data['horaLlegada'] as Timestamp?;
    final String motivoCancelacion =
        (data['motivoCancelacion'] ?? '').toString();

    final List<String> lineas =
        detalle
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 14,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              soloLectura
                                  ? 'Ticket de Transacción'
                                  : 'Ficha de Despacho',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: colorTextoGris,
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
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatearFechaHora(horaLlegada),
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: colorVerdeTese,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Credencial del estudiante (consulta Matrícula y Carrera en vivo)
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        idAlumno.isNotEmpty
                            ? FirebaseFirestore.instance
                                .collection('Usuarios')
                                .doc(idAlumno)
                                .get()
                            : null,
                    builder: (_, snapAlumno) {
                      String matricula = 'Sin matrícula';
                      String carrera = 'Estudiante TESE';
                      if (snapAlumno.hasData &&
                          snapAlumno.data != null &&
                          snapAlumno.data!.exists) {
                        final u =
                            snapAlumno.data!.data() as Map<String, dynamic>;
                        matricula =
                            (u['identificador'] ?? 'Sin matrícula').toString();
                        carrera =
                            (u['carrera_area'] ?? 'Estudiante TESE').toString();
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorVerdeTese.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: colorVerdeTese,
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alumno,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                  Text(
                                    '$matricula • $carrera',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: colorVerdeOscuro,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Platillos (${lineas.length}):',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...lineas.map((linea) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorFondoCrema,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        linea,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colorTextoOscuro,
                        ),
                      ),
                    );
                  }),

                  if (notas.isNotEmpty && notas != 'Sin notas adicionales') ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFD54F)),
                      ),
                      child: Text(
                        '📝 Notas / Alergias: $notas',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.brown.shade900,
                        ),
                      ),
                    ),
                  ],

                  if (estado == 4 && motivoCancelacion.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '❌ Motivo de cancelación: $motivoCancelacion',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),
                  // Fila de cobro sin desbordamiento (Expanded + píldora fija)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Método de pago:',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: colorTextoGris,
                                ),
                              ),
                              Text(
                                metodoPago,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: colorTextoOscuro,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorVerdeTese,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${total.toStringAsFixed(0)} MXN',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!soloLectura && estado < 3) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (estado < 2) ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(
                                color: Colors.redAccent,
                                width: 1.4,
                              ),
                              minimumSize: const Size(105, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _cancelarPedidoDesdeCocina(docId, data);
                            },
                            child: Text(
                              'Cancelar',
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    estado == 0
                                        ? const Color(0xFFEA580C)
                                        : (estado == 1
                                            ? colorExito
                                            : colorVerdeTese),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _cambiarEstadoPedido(docId, estado + 1);
                              },
                              icon: Icon(
                                estado == 0
                                    ? Icons.soup_kitchen_rounded
                                    : (estado == 1
                                        ? Icons.notifications_active_rounded
                                        : Icons.check_circle_rounded),
                                color: Colors.white,
                                size: 19,
                              ),
                              label: Text(
                                estado == 0
                                    ? 'Aceptar y Cocinar'
                                    : (estado == 1
                                        ? '¡Marcar Listo!'
                                        : 'Entregar Pedido'),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
    );
  }

  void _abrirModalNuevoPlatillo() {
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '20');
    final ingCtrl = TextEditingController();
    String categoria = 'Comida';
    String fotoBase64 = '';
    bool guardando = false;
    final ImagePicker picker = ImagePicker();

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
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 22,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agregar Platillo a ${widget.nombreLocal} 🍽️',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: colorVerdeTese,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nombreCtrl,
                        decoration: _decoracionCampo('Nombre del platillo'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: _decoracionCampo('Descripción breve'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: precioCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _decoracionCampo('Precio MXN'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _decoracionCampo('Existencias'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: categoria,
                        decoration: _decoracionCampo('Categoría'),
                        items:
                            ['Desayunos', 'Comida', 'Bebidas', 'Postres']
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) setStateModal(() => categoria = v);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: ingCtrl,
                        decoration: _decoracionCampo(
                          'Ingredientes personalizables (separados por coma)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final img = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 600,
                            imageQuality: 55,
                          );
                          if (img != null) {
                            final bytes = await img.readAsBytes();
                            setStateModal(
                              () => fotoBase64 = base64Encode(bytes),
                            );
                          }
                        },
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: Text(
                          fotoBase64.isEmpty
                              ? 'Subir fotografía del platillo'
                              : 'Fotografía lista ✓',
                          style: GoogleFonts.poppins(fontSize: 12.5),
                        ),
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
                              guardando
                                  ? null
                                  : () async {
                                    if (nombreCtrl.text.trim().isEmpty ||
                                        precioCtrl.text.trim().isEmpty) {
                                      return;
                                    }
                                    setStateModal(() => guardando = true);
                                    final double precio =
                                        double.tryParse(
                                          precioCtrl.text.trim(),
                                        ) ??
                                        0;
                                    final int stock =
                                        int.tryParse(stockCtrl.text.trim()) ??
                                        10;
                                    final List<String> ingredientes =
                                        ingCtrl.text
                                            .split(',')
                                            .map((e) => e.trim())
                                            .where((e) => e.isNotEmpty)
                                            .toList();

                                    await FirebaseFirestore.instance
                                        .collection('Menu_Platillos')
                                        .add({
                                          'nombre': nombreCtrl.text.trim(),
                                          'descripcion': descCtrl.text.trim(),
                                          'precio': precio,
                                          'existencias': stock,
                                          'categoria': categoria,
                                          'local': widget.nombreLocal,
                                          'puntos': (precio / 5).round().clamp(
                                            5,
                                            50,
                                          ),
                                          'ingredientes': ingredientes,
                                          'imagenBase64': fotoBase64,
                                        });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                          child: Text(
                            guardando ? 'Guardando...' : 'Publicar Platillo',
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
              );
            },
          ),
    );
  }

  InputDecoration _decoracionCampo(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12.5),
      filled: true,
      fillColor: colorFondoCrema,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmarBloqueoTerminal();
      },
      child: Scaffold(
        backgroundColor: colorFondoCrema,
        body: SafeArea(
          child: Column(
            children: [
              // ENCABEZADO KDS
              Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeTese.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: colorVerdeTese,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nombreLocal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: colorTextoOscuro,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      _localAbierto
                                          ? colorExito
                                          : Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _localAbierto
                                    ? 'Recibiendo pedidos'
                                    : 'Cerrado temporalmente',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _localAbierto
                                          ? colorExito
                                          : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _localAbierto,
                      activeColor: colorVerdeTese,
                      onChanged: _alternarEstadoLocal,
                    ),
                    IconButton(
                      tooltip: 'Bloquear Terminal',
                      onPressed: _confirmarBloqueoTerminal,
                      icon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),

              // PESTAÑAS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorVerdeTese.withValues(alpha: 0.3),
                    ),
                  ),
                  labelColor: colorVerdeTese,
                  unselectedLabelColor: colorTextoGris,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  tabs: const [
                    Tab(text: '🍳 Comandas'),
                    Tab(text: '💰 Historial / Corte'),
                    Tab(text: '🍔 Menú'),
                    Tab(text: '⭐ Opiniones'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _construirTabComandas(),
                    _construirTabHistorialInteractivo(),
                    _construirTabMenu(),
                    _construirTabOpiniones(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // PESTAÑA 1: COMANDAS ACTIVAS (KDS)
  // =========================================================================
  Widget _construirTabComandas() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Pedidos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs =
            (snapshot.data?.docs ?? []).where((d) {
              final data = d.data() as Map<String, dynamic>;
              final int est = (data['estado'] ?? 0) as int;
              return est >= 0 && est <= 2;
            }).toList();

        docs.sort((a, b) {
          final ta =
              (a.data() as Map<String, dynamic>)['horaLlegada'] as Timestamp?;
          final tb =
              (b.data() as Map<String, dynamic>)['horaLlegada'] as Timestamp?;
          return (ta?.millisecondsSinceEpoch ?? 0).compareTo(
            tb?.millisecondsSinceEpoch ?? 0,
          );
        });

        final int cNuevos =
            docs.where((d) => ((d.data() as Map)['estado'] ?? 0) == 0).length;
        final int cCocina =
            docs.where((d) => ((d.data() as Map)['estado'] ?? 0) == 1).length;
        final int cListos =
            docs.where((d) => ((d.data() as Map)['estado'] ?? 0) == 2).length;

        final filtrados =
            _filtroEstadoKds == -1
                ? docs
                : docs
                    .where(
                      (d) =>
                          ((d.data() as Map)['estado'] ?? 0) ==
                          _filtroEstadoKds,
                    )
                    .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _ChipContadorKds(
                    titulo: 'Todos',
                    cuenta: docs.length,
                    color: colorVerdeTese,
                    activo: _filtroEstadoKds == -1,
                    onTap: () => setState(() => _filtroEstadoKds = -1),
                  ),
                  const SizedBox(width: 6),
                  _ChipContadorKds(
                    titulo: 'Nuevos',
                    cuenta: cNuevos,
                    color: Colors.redAccent,
                    activo: _filtroEstadoKds == 0,
                    onTap: () => setState(() => _filtroEstadoKds = 0),
                  ),
                  const SizedBox(width: 6),
                  _ChipContadorKds(
                    titulo: 'Cocina',
                    cuenta: cCocina,
                    color: const Color(0xFFEA580C),
                    activo: _filtroEstadoKds == 1,
                    onTap: () => setState(() => _filtroEstadoKds = 1),
                  ),
                  const SizedBox(width: 6),
                  _ChipContadorKds(
                    titulo: 'Listos',
                    cuenta: cListos,
                    color: colorExito,
                    activo: _filtroEstadoKds == 2,
                    onTap: () => setState(() => _filtroEstadoKds = 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  filtrados.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 56,
                              color: colorVerdeTese,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Sin comandas pendientes',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorTextoOscuro,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtrados.length,
                        itemBuilder: (_, idx) {
                          final doc = filtrados[idx];
                          final data = doc.data() as Map<String, dynamic>;
                          final int est = (data['estado'] ?? 0) as int;
                          final String codigo =
                              (data['idPedido'] ?? '#TESE').toString();
                          final String alumno =
                              (data['alumno'] ?? 'Estudiante').toString();
                          final String detalle =
                              (data['detalle'] ?? '').toString();
                          final double total = (data['total'] ?? 0).toDouble();

                          final Color colorBorde =
                              est == 0
                                  ? Colors.redAccent
                                  : (est == 1
                                      ? const Color(0xFFEA580C)
                                      : colorExito);
                          final String etiqueta =
                              est == 0
                                  ? 'NUEVO'
                                  : (est == 1
                                      ? 'EN COCINA'
                                      : 'LISTO EN VENTANILLA');

                          return GestureDetector(
                            onTap: () => _abrirDetalleComanda(doc.id, data),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorBorde.withValues(alpha: 0.55),
                                  width: 1.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorBorde.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorBorde.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          etiqueta,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: colorBorde,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        codigo,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: colorTextoOscuro,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '\$${total.toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: colorVerdeTese,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    alumno,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detalle,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: colorTextoGris,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorBorde,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          () => _cambiarEstadoPedido(
                                            doc.id,
                                            est + 1,
                                          ),
                                      child: Text(
                                        est == 0
                                            ? 'Aceptar y Cocinar 🍳'
                                            : (est == 1
                                                ? '¡Marcar Listo! 🔔'
                                                : 'Entregar y Cobrar ✅'),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

  // =========================================================================
  // PESTAÑA 2: HISTORIAL Y CORTE DE CAJA INTERACTIVO (CON SUMA ACUMULADA)
  // =========================================================================
  Widget _construirTabHistorialInteractivo() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Pedidos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final ahora = DateTime.now();
        final todosDocs =
            (snapshot.data?.docs ?? []).where((d) {
              final data = d.data() as Map<String, dynamic>;
              final int est = (data['estado'] ?? 0) as int;
              // Solo historial cerrado (Entregado = 3 o Cancelado = 4)
              if (est != 3 && est != 4) return false;
              if (_soloHoyCorte) {
                final Timestamp? ts = data['horaLlegada'] as Timestamp?;
                if (ts == null) return true;
                final dt = ts.toDate();
                return dt.year == ahora.year &&
                    dt.month == ahora.month &&
                    dt.day == ahora.day;
              }
              return true;
            }).toList();

        // Orden cronológico ascendente para calcular la suma acumulada real (transacción 1 + 2 + 3...)
        todosDocs.sort((a, b) {
          final ta =
              (a.data() as Map<String, dynamic>)['horaLlegada'] as Timestamp?;
          final tb =
              (b.data() as Map<String, dynamic>)['horaLlegada'] as Timestamp?;
          return (ta?.millisecondsSinceEpoch ?? 0).compareTo(
            tb?.millisecondsSinceEpoch ?? 0,
          );
        });

        double totalVendido = 0;
        double totalEfectivo = 0;
        double totalTarjeta = 0;
        double totalCancelado = 0;
        int countVendidos = 0;
        int countEfectivo = 0;
        int countTarjeta = 0;
        int countCancelados = 0;

        for (final doc in todosDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final int est = (data['estado'] ?? 0) as int;
          final double monto = (data['total'] ?? 0).toDouble();
          final String metodo = (data['metodoPago'] ?? '').toString();

          if (est == 3) {
            totalVendido += monto;
            countVendidos++;
            if (metodo.contains('Tarjeta') || metodo.contains('Terminal')) {
              totalTarjeta += monto;
              countTarjeta++;
            } else {
              totalEfectivo += monto;
              countEfectivo++;
            }
          } else if (est == 4) {
            totalCancelado += monto;
            countCancelados++;
          }
        }

        // Filtramos la lista según la tarjeta que haya tocado el cajero
        final listaFiltrada =
            todosDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final int est = (data['estado'] ?? 0) as int;
              final String metodo = (data['metodoPago'] ?? '').toString();
              final bool esTarjeta =
                  metodo.contains('Tarjeta') || metodo.contains('Terminal');

              switch (_filtroCorte) {
                case 'efectivo':
                  return est == 3 && !esTarjeta;
                case 'tarjeta':
                  return est == 3 && esTarjeta;
                case 'cancelados':
                  return est == 4;
                case 'vendidos':
                default:
                  return est == 3;
              }
            }).toList();

        // Calculamos la suma acumulada progresiva en orden cronológico
        final List<double> acumulados = [];
        double sumaCorriente = 0;
        for (final doc in listaFiltrada) {
          final double monto =
              ((doc.data() as Map<String, dynamic>)['total'] ?? 0).toDouble();
          sumaCorriente += monto;
          acumulados.add(sumaCorriente);
        }

        // Mostramos las más recientes arriba pero conservando su acumulado exacto
        final int totalItems = listaFiltrada.length;

        String tituloLista = 'Desglose Total Vendido';
        if (_filtroCorte == 'efectivo') {
          tituloLista = 'Transacciones en Efectivo 💵';
        }
        if (_filtroCorte == 'tarjeta') {
          tituloLista = 'Transacciones con Tarjeta 💳';
        }
        if (_filtroCorte == 'cancelados') {
          tituloLista = 'Pedidos Cancelados ❌';
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
          children: [
            // Selector Hoy vs Todo el Historial
            Row(
              children: [
                Text(
                  'Corte de Caja Interactivo',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: colorTextoOscuro,
                  ),
                ),
                const Spacer(),
                ChoiceChip(
                  label: Text(
                    'Hoy',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: _soloHoyCorte ? Colors.white : colorTextoOscuro,
                    ),
                  ),
                  selected: _soloHoyCorte,
                  selectedColor: colorVerdeTese,
                  backgroundColor: Colors.white,
                  onSelected: (_) => setState(() => _soloHoyCorte = true),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: Text(
                    'Todo',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: !_soloHoyCorte ? Colors.white : colorTextoOscuro,
                    ),
                  ),
                  selected: !_soloHoyCorte,
                  selectedColor: colorVerdeTese,
                  backgroundColor: Colors.white,
                  onSelected: (_) => setState(() => _soloHoyCorte = false),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4 TARJETAS INTERACTIVAS DE CORTE DE CAJA
            FadeInDown(
              duration: const Duration(milliseconds: 220),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaCorteInteractiva(
                          titulo: 'Total Vendido',
                          monto: '\$${totalVendido.toStringAsFixed(0)}',
                          subtitulo: '$countVendidos órdenes',
                          icono: Icons.point_of_sale_rounded,
                          colorFondo: const Color(0xFFE8F5E9),
                          colorAcento: colorVerdeTese,
                          seleccionada: _filtroCorte == 'vendidos',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _filtroCorte = 'vendidos');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TarjetaCorteInteractiva(
                          titulo: 'Efectivo 💵',
                          monto: '\$${totalEfectivo.toStringAsFixed(0)}',
                          subtitulo: '$countEfectivo cobros',
                          icono: Icons.payments_outlined,
                          colorFondo: const Color(0xFFFFF8E1),
                          colorAcento: const Color(0xFFD97706),
                          seleccionada: _filtroCorte == 'efectivo',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _filtroCorte = 'efectivo');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaCorteInteractiva(
                          titulo: 'Tarjeta 💳',
                          monto: '\$${totalTarjeta.toStringAsFixed(0)}',
                          subtitulo: '$countTarjeta cobros',
                          icono: Icons.credit_card_rounded,
                          colorFondo: const Color(0xFFE0F2FE),
                          colorAcento: const Color(0xFF0284C7),
                          seleccionada: _filtroCorte == 'tarjeta',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _filtroCorte = 'tarjeta');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TarjetaCorteInteractiva(
                          titulo: 'Cancelados ❌',
                          monto: '$countCancelados ord.',
                          subtitulo:
                              '\$${totalCancelado.toStringAsFixed(0)} no cobrado',
                          icono: Icons.cancel_outlined,
                          colorFondo: const Color(0xFFFFEBEE),
                          colorAcento: Colors.redAccent,
                          seleccionada: _filtroCorte == 'cancelados',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _filtroCorte = 'cancelados');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Barra resumen de la categoría seleccionada
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$tituloLista ($totalItems)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: colorTextoOscuro,
                      ),
                    ),
                  ),
                  Text(
                    'Suma: \$${sumaCorriente.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color:
                          _filtroCorte == 'cancelados'
                              ? Colors.redAccent
                              : colorVerdeTese,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            if (totalItems == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 34),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 46,
                      color: colorTextoGris,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin transacciones en este filtro',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: colorTextoOscuro,
                      ),
                    ),
                    Text(
                      'Toca otra tarjeta arriba o cambia a "Todo".',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colorTextoGris,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(totalItems, (revIdx) {
                final int idx = totalItems - 1 - revIdx;
                final doc = listaFiltrada[idx];
                final data = doc.data() as Map<String, dynamic>;
                final String codigo = (data['idPedido'] ?? '#TESE').toString();
                final String alumno =
                    (data['alumno'] ?? 'Estudiante').toString();
                final String detalle = (data['detalle'] ?? '').toString();
                final String metodo = (data['metodoPago'] ?? '').toString();
                final double monto = (data['total'] ?? 0).toDouble();
                final double acumuladoAqui = acumulados[idx];
                final Timestamp? ts = data['horaLlegada'] as Timestamp?;
                final bool esCancelado = (data['estado'] ?? 0) == 4;
                final bool esTarjeta =
                    metodo.contains('Tarjeta') || metodo.contains('Terminal');

                return GestureDetector(
                  onTap:
                      () =>
                          _abrirDetalleComanda(doc.id, data, soloLectura: true),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            esCancelado
                                ? Colors.redAccent.withValues(alpha: 0.3)
                                : Colors.grey.shade100,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    esCancelado
                                        ? const Color(0xFFFFEBEE)
                                        : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${idx + 1} • $codigo',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color:
                                      esCancelado
                                          ? Colors.redAccent
                                          : colorVerdeTese,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatearFechaHora(ts),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: colorTextoGris,
                                ),
                              ),
                            ),
                            Text(
                              esCancelado
                                  ? '-\$${monto.toStringAsFixed(0)}'
                                  : '+\$${monto.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color:
                                    esCancelado ? Colors.redAccent : colorExito,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$alumno  •  ${esTarjeta ? '💳 Tarjeta' : '💵 Efectivo'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: colorTextoOscuro,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detalle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: colorTextoGris,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Línea de suma progresiva + acceso al ticket
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colorFondoCrema,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                '∑ Acumulado: \$${acumuladoAqui.toStringAsFixed(0)} MXN',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colorTextoOscuro,
                                ),
                              ),
                            ),
                            Text(
                              'Ver ticket →',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: colorVerdeTese,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // =========================================================================
  // PESTAÑA 3: MENÚ E INVENTARIO DE LA SUCURSAL
  // =========================================================================
  Widget _construirTabMenu() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Menu_Platillos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colorVerdeTese,
            onPressed: _abrirModalNuevoPlatillo,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'Nuevo Platillo',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body:
              docs.isEmpty
                  ? Center(
                    child: Text(
                      'Aún no hay platillos registrados en ${widget.nombreLocal}.',
                      style: GoogleFonts.poppins(color: colorTextoGris),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 84),
                    itemCount: docs.length,
                    itemBuilder: (_, idx) {
                      final doc = docs[idx];
                      final data = doc.data() as Map<String, dynamic>;
                      final String nombre =
                          (data['nombre'] ?? 'Platillo').toString();
                      final double precio = (data['precio'] ?? 0).toDouble();
                      final int stock = (data['existencias'] ?? 0) as int;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombre,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                  Text(
                                    '\$${precio.toStringAsFixed(0)} MXN  •  Stock: $stock',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          stock > 0
                                              ? colorVerdeTese
                                              : Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: colorFondoCrema,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed:
                                        stock > 0
                                            ? () => FirebaseFirestore.instance
                                                .collection('Menu_Platillos')
                                                .doc(doc.id)
                                                .update({
                                                  'existencias':
                                                      FieldValue.increment(-1),
                                                })
                                            : null,
                                    icon: const Icon(
                                      Icons.remove_rounded,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                  ),
                                  Text(
                                    '$stock',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed:
                                        () => FirebaseFirestore.instance
                                            .collection('Menu_Platillos')
                                            .doc(doc.id)
                                            .update({
                                              'existencias':
                                                  FieldValue.increment(1),
                                            }),
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
                    },
                  ),
        );
      },
    );
  }

  // =========================================================================
  // PESTAÑA 4: OPINIONES Y ESTRELLAS
  // =========================================================================
  Widget _construirTabOpiniones() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Resenas')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        double promedio = 0;
        if (docs.isNotEmpty) {
          final suma = docs.fold<int>(
            0,
            (acc, d) => acc + (((d.data() as Map)['estrellas'] ?? 5) as int),
          );
          promedio = suma / docs.length;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD54F)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docs.isEmpty
                            ? 'Sin calificaciones aún'
                            : '${promedio.toStringAsFixed(1)} / 5.0 Estrellas',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: colorTextoOscuro,
                        ),
                      ),
                      Text(
                        '${docs.length} opiniones de estudiantes',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorTextoGris,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final int estrellas = (data['estrellas'] ?? 5) as int;
              final bool esAnonimo = (data['esAnonimo'] ?? false) as bool;
              final String alumno =
                  esAnonimo
                      ? 'Estudiante Anónimo 🕵️‍♂️'
                      : (data['alumno'] ?? 'Estudiante TESE').toString();
              final String platillo =
                  (data['platilloNombre'] ?? 'Platillo').toString();
              final String comentario = (data['comentario'] ?? '').toString();
              final String fotoBase64 =
                  (data['fotoEvidencia'] ?? '').toString();

              Uint8List? bytesFoto;
              if (fotoBase64.isNotEmpty) {
                try {
                  bytesFoto = base64Decode(fotoBase64);
                } catch (_) {}
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alumno,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: colorTextoOscuro,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < estrellas
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 16,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      platillo,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colorVerdeTese,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comentario,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: colorTextoOscuro,
                      ),
                    ),
                    if (bytesFoto != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          bytesFoto,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _formatearFechaHora(Timestamp? ts) {
    if (ts == null) return 'Reciente';
    final dt = ts.toDate();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m $h:$min';
  }
}

class _ChipContadorKds extends StatelessWidget {
  final String titulo;
  final int cuenta;
  final Color color;
  final bool activo;
  final VoidCallback onTap;

  const _ChipContadorKds({
    required this.titulo,
    required this.cuenta,
    required this.color,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: activo ? color : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: activo ? color : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$cuenta',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: activo ? Colors.white : color,
                ),
              ),
              Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: activo ? Colors.white : colorTextoGris,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaCorteInteractiva extends StatelessWidget {
  final String titulo;
  final String monto;
  final String subtitulo;
  final IconData icono;
  final Color colorFondo;
  final Color colorAcento;
  final bool seleccionada;
  final VoidCallback onTap;

  const _TarjetaCorteInteractiva({
    required this.titulo,
    required this.monto,
    required this.subtitulo,
    required this.icono,
    required this.colorFondo,
    required this.colorAcento,
    required this.seleccionada,
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
          color: seleccionada ? colorFondo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionada ? colorAcento : Colors.grey.shade200,
            width: seleccionada ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  seleccionada
                      ? colorAcento.withValues(alpha: 0.14)
                      : Colors.black.withValues(alpha: 0.03),
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
                Icon(icono, color: colorAcento, size: 21),
                if (seleccionada)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colorAcento,
                    size: 17,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: colorTextoGris,
              ),
            ),
            Text(
              monto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: colorTextoOscuro,
              ),
            ),
            Text(
              subtitulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: colorAcento,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
