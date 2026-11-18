import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'colores.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Filtros Pestaña 1 (Ventas)
  String _filtroSucursalVentas = 'Todas';

  // Filtros Pestaña 2 (Quejas)
  String _filtroEstadoQuejas = 'Todas';

  // Buscador Pestaña 4 (Alumnos)
  final TextEditingController _busquedaAlumnoCtrl = TextEditingController();
  String _queryAlumno = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaAlumnoCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarSalidaAdmin() async {
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
                    Icons.shield_outlined,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Bloquear Panel Admin?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: colorTextoOscuro,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Se cerrará la sesión administrativa y tendrás que volver a autenticarte para gestionar terminales QR o el buzón de quejas.',
              style: GoogleFonts.poppins(fontSize: 13, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Permanecer',
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
                  'Cerrar Panel',
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

  String _generarTokenSeguro() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789abcdefghjkmnpqrstuvwxyz';
    final rnd = Random.secure();
    return List.generate(28, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _generarYMostrarQR(
    String docId,
    String nombreSucursal,
    String codigoSucursal,
  ) async {
    HapticFeedback.mediumImpact();
    final String token = _generarTokenSeguro();
    final DateTime expiraEn = DateTime.now().add(const Duration(minutes: 5));

    await FirebaseFirestore.instance
        .collection('Locales_Seguridad')
        .doc(docId)
        .set({
          'qrTokenTemporal': token,
          'qrExpiraEn': Timestamp.fromDate(expiraEn),
          'qrUsado': false,
        }, SetOptions(merge: true));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => _DialogoQRVinculacion(
            docId: docId,
            nombreSucursal: nombreSucursal,
            codigoSucursal: codigoSucursal,
            token: token,
            expiraEn: expiraEn,
          ),
    );
  }

  Future<void> _desvincularTerminal(String docId, String nombreSucursal) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              '¿Expulsar dispositivo?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                color: Colors.red.shade800,
                fontSize: 17,
              ),
            ),
            content: Text(
              'La terminal vinculada en $nombreSucursal perderá acceso inmediato y se invalidará cualquier QR anterior. Tendrás que generar un nuevo QR para autorizar otro equipo.',
              style: GoogleFonts.poppins(fontSize: 13, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancelar', style: GoogleFonts.poppins()),
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
                  'Sí, expulsar',
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

    await FirebaseFirestore.instance
        .collection('Locales_Seguridad')
        .doc(docId)
        .set({
          'dispositivoAutorizadoId': FieldValue.delete(),
          'dispositivoNombre': FieldValue.delete(),
          'vinculadoEn': FieldValue.delete(),
          'qrTokenTemporal': FieldValue.delete(),
          'qrUsado': true,
        }, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔒 Terminal de $nombreSucursal desvinculada con éxito.',
          style: GoogleFonts.poppins(fontSize: 12.5),
        ),
        backgroundColor: colorVerdeTese,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _abrirDetalleQueja(String docId, Map<String, dynamic> data) {
    String estadoSeleccionado = (data['estado'] ?? 'Pendiente').toString();
    final TextEditingController respuestaCtrl = TextEditingController(
      text: (data['respuestaAdmin'] ?? '').toString(),
    );
    bool guardando = false;

    final String local = (data['local'] ?? 'General').toString();
    final String categoria = (data['categoria'] ?? 'General').toString();
    final String descripcion = (data['descripcion'] ?? '').toString();
    final bool esAnonimo = (data['esAnonimo'] ?? false) as bool;
    final String alumno =
        esAnonimo
            ? 'Estudiante Anónimo 🕵️‍♂️'
            : (data['alumno'] ?? 'Estudiante TESE').toString();
    final String fotoBase64 = (data['fotoEvidencia'] ?? '').toString();

    Uint8List? bytesFoto;
    if (fotoBase64.isNotEmpty) {
      try {
        bytesFoto = base64Decode(fotoBase64);
      } catch (_) {}
    }

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
                  top: 16,
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 22,
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
                            child: Text(
                              'Atender Reporte del Buzón',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: colorTextoOscuro,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              local,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: colorVerdeTese,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reportado por: $alumno  •  Motivo: $categoria',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorTextoGris,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorFondoCrema,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          descripcion.isEmpty
                              ? 'Sin descripción detallada.'
                              : descripcion,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: colorTextoOscuro,
                            height: 1.45,
                          ),
                        ),
                      ),
                      if (bytesFoto != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Evidencia adjunta:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorTextoGris,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            bytesFoto,
                            height: 170,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Actualizar Estatus:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ['Pendiente', 'En Revisión', 'Resuelta'].map((e) {
                              final bool activo = estadoSeleccionado == e;
                              final Color colorPill =
                                  e == 'Resuelta'
                                      ? colorExito
                                      : (e == 'En Revisión'
                                          ? const Color(0xFFF59E0B)
                                          : Colors.redAccent);
                              return ChoiceChip(
                                label: Text(
                                  e,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        activo
                                            ? Colors.white
                                            : colorTextoOscuro,
                                  ),
                                ),
                                selected: activo,
                                selectedColor: colorPill,
                                backgroundColor: colorFondoCrema,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color:
                                        activo
                                            ? colorPill
                                            : Colors.grey.shade300,
                                  ),
                                ),
                                onSelected:
                                    (_) => setStateModal(
                                      () => estadoSeleccionado = e,
                                    ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Respuesta oficial para el estudiante:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: respuestaCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Ej. Gracias por reportarlo, ya hablamos con el encargado de la sucursal...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: colorTextoGris,
                          ),
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorVerdeTese,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              guardando
                                  ? null
                                  : () async {
                                    setStateModal(() => guardando = true);
                                    await FirebaseFirestore.instance
                                        .collection('Quejas_Buzon')
                                        .doc(docId)
                                        .update({
                                          'estado': estadoSeleccionado,
                                          'respuestaAdmin':
                                              respuestaCtrl.text.trim(),
                                          'fechaRespuesta':
                                              FieldValue.serverTimestamp(),
                                        });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '✅ Queja actualizada a "$estadoSeleccionado".',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        backgroundColor: colorExito,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                          icon: const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            guardando ? 'Guardando...' : 'Guardar Resolución',
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmarSalidaAdmin();
      },
      child: Scaffold(
        backgroundColor: colorFondoCrema,
        body: SafeArea(
          child: Column(
            children: [
              // ENCABEZADO ADMINISTRATIVO PASTEL
              Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeTese.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: colorAmarilloTese,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorAmarilloTese.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'CONTROL GENERAL TESE',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: colorAmarilloTese,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Panel Administrativo',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Bloquear Panel',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                      ),
                      onPressed: _confirmarSalidaAdmin,
                      icon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ),

              // BARRA DE PESTAÑAS TIPO PÍLDORA
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
                      color: colorVerdeTese.withValues(alpha: 0.35),
                    ),
                  ),
                  labelColor: colorVerdeTese,
                  unselectedLabelColor: colorTextoGris,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  tabs: const [
                    Tab(text: '📊 Ventas'),
                    Tab(text: '📢 Quejas'),
                    Tab(text: '🔐 Terminales QR'),
                    Tab(text: '🎓 Alumnos'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // CONTENIDO DE LAS 4 PESTAÑAS
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _construirTabVentas(),
                    _construirTabQuejas(),
                    _construirTabTerminalesQR(),
                    _construirTabAlumnos(),
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
  // PESTAÑA 1: RESUMEN GLOBAL Y TRANSACCIONES
  // =========================================================================
  Widget _construirTabVentas() {
    final List<String> sucursales = [
      'Todas',
      'Cafetería Central',
      'Kiosko Sistemas',
      'Kiosko Biblioteca',
    ];

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Pedidos')
              .orderBy('horaLlegada', descending: true)
              .limit(150)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final filtrados =
            docs.where((d) {
              if (_filtroSucursalVentas == 'Todas') return true;
              final data = d.data() as Map<String, dynamic>;
              return (data['local'] ?? '') == _filtroSucursalVentas;
            }).toList();

        double totalIngresos = 0;
        double totalEfectivo = 0;
        double totalTarjeta = 0;
        int entregados = 0;
        int enCurso = 0;
        int cancelados = 0;

        for (final doc in filtrados) {
          final data = doc.data() as Map<String, dynamic>;
          final int estado = (data['estado'] ?? 0) as int;
          final double total = (data['total'] ?? 0).toDouble();
          final String metodo = (data['metodoPago'] ?? '').toString();

          if (estado == 4) {
            cancelados++;
          } else {
            if (estado == 3) {
              entregados++;
            } else {
              enCurso++;
            }
            totalIngresos += total;
            if (metodo.contains('Tarjeta') || metodo.contains('Terminal')) {
              totalTarjeta += total;
            } else {
              totalEfectivo += total;
            }
          }
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // Chips filtro sucursal
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sucursales.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  final s = sucursales[idx];
                  final activo = _filtroSucursalVentas == s;
                  return ChoiceChip(
                    label: Text(
                      s,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: activo ? Colors.white : colorTextoOscuro,
                      ),
                    ),
                    selected: activo,
                    selectedColor: colorVerdeTese,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: activo ? colorVerdeTese : Colors.grey.shade200,
                      ),
                    ),
                    onSelected:
                        (_) => setState(() => _filtroSucursalVentas = s),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Tarjetas KPI
            FadeInDown(
              duration: const Duration(milliseconds: 220),
              child: Row(
                children: [
                  Expanded(
                    child: _TarjetaKPI(
                      titulo: 'Ventas Activas/Entreg.',
                      valor: '\$${totalIngresos.toStringAsFixed(0)}',
                      subtitulo: '$entregados entregados • $enCurso en curso',
                      colorFondo: const Color(0xFFE8F5E9),
                      colorAcento: colorVerdeTese,
                      icono: Icons.account_balance_wallet_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TarjetaKPI(
                      titulo: 'Desglose de Cobro',
                      valor: '💵 \$${totalEfectivo.toStringAsFixed(0)}',
                      subtitulo:
                          '💳 \$${totalTarjeta.toStringAsFixed(0)} • ❌ $cancelados canc.',
                      colorFondo: const Color(0xFFFFF8E1),
                      colorAcento: const Color(0xFFD97706),
                      icono: Icons.receipt_long_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Historial de Transacciones (${filtrados.length})',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: colorTextoOscuro,
              ),
            ),
            const SizedBox(height: 8),

            if (filtrados.isEmpty)
              _EstadoVacioPastel(
                icono: Icons.receipt_outlined,
                titulo: 'Sin movimientos registrados',
                subtitulo:
                    'Aquí aparecerán todos los pedidos realizados en esta sucursal.',
              )
            else
              ...filtrados.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final int estado = (data['estado'] ?? 0) as int;
                final String codigo = (data['idPedido'] ?? '#TESE').toString();
                final String alumno =
                    (data['alumno'] ?? 'Estudiante').toString();
                final String local = (data['local'] ?? 'Cafetería').toString();
                final String detalle = (data['detalle'] ?? '').toString();
                final String metodo = (data['metodoPago'] ?? '').toString();
                final double total = (data['total'] ?? 0).toDouble();
                final Timestamp? ts = data['horaLlegada'] as Timestamp?;

                final String textoEstado =
                    [
                      'Recibido',
                      'En Cocina',
                      'Listo',
                      'Entregado',
                      'Cancelado',
                    ][estado.clamp(0, 4)];

                final Color colorEstado =
                    estado == 3
                        ? colorExito
                        : (estado == 4
                            ? Colors.redAccent
                            : (estado == 2
                                ? const Color(0xFF0284C7)
                                : const Color(0xFFF59E0B)));

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade100),
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
                          Text(
                            codigo,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              color: colorVerdeTese,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '• $local',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: colorTextoGris,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorEstado.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              textoEstado,
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: colorEstado,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Alumno: $alumno',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        detalle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: colorTextoGris,
                        ),
                      ),
                      const Divider(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_formatearFecha(ts)}  •  $metodo',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: colorTextoGris,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${total.toStringAsFixed(0)} MXN',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: colorTextoOscuro,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // =========================================================================
  // PESTAÑA 2: BUZÓN DE QUEJAS INDEPENDIENTE
  // =========================================================================
  Widget _construirTabQuejas() {
    final estados = ['Todas', 'Pendiente', 'En Revisión', 'Resuelta'];

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Quejas_Buzon')
              .orderBy('fecha', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final filtradas =
            docs.where((d) {
              if (_filtroEstadoQuejas == 'Todas') return true;
              final data = d.data() as Map<String, dynamic>;
              return (data['estado'] ?? 'Pendiente') == _filtroEstadoQuejas;
            }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: estados.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  final est = estados[idx];
                  final activo = _filtroEstadoQuejas == est;
                  return ChoiceChip(
                    label: Text(
                      est,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: activo ? Colors.white : colorTextoOscuro,
                      ),
                    ),
                    selected: activo,
                    selectedColor: colorVerdeTese,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: activo ? colorVerdeTese : Colors.grey.shade200,
                      ),
                    ),
                    onSelected:
                        (_) => setState(() => _filtroEstadoQuejas = est),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (filtradas.isEmpty)
              _EstadoVacioPastel(
                icono: Icons.mark_email_read_outlined,
                titulo: 'Buzón limpio',
                subtitulo:
                    'No hay quejas registradas en la categoría "$_filtroEstadoQuejas".',
              )
            else
              ...filtradas.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String estado =
                    (data['estado'] ?? 'Pendiente').toString();
                final String local = (data['local'] ?? 'General').toString();
                final String categoria =
                    (data['categoria'] ?? 'General').toString();
                final String desc = (data['descripcion'] ?? '').toString();
                final bool esAnonimo = (data['esAnonimo'] ?? false) as bool;
                final String alumno =
                    esAnonimo
                        ? 'Estudiante Anónimo 🕵️‍♂️'
                        : (data['alumno'] ?? 'Estudiante TESE').toString();
                final bool tieneFoto =
                    (data['fotoEvidencia'] ?? '').toString().isNotEmpty;
                final Timestamp? ts = data['fecha'] as Timestamp?;

                final Color colorEst =
                    estado == 'Resuelta'
                        ? colorExito
                        : (estado == 'En Revisión'
                            ? const Color(0xFFF59E0B)
                            : Colors.redAccent);

                return GestureDetector(
                  onTap: () => _abrirDetalleQueja(doc.id, data),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorEst.withValues(alpha: 0.35),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
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
                                color: colorEst.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                estado.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: colorEst,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$categoria • $local',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: colorTextoOscuro,
                                ),
                              ),
                            ),
                            if (tieneFoto)
                              const Icon(
                                Icons.photo_camera_outlined,
                                size: 17,
                                color: colorVerdeTese,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          desc,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: colorTextoOscuro,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$alumno • ${_formatearFecha(ts)}',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: colorTextoGris,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              'Responder →',
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
  // PESTAÑA 3: SEGURIDAD DE TERMINALES (QR DE 1 SOLO USO + 1 DISPOSITIVO)
  // =========================================================================
  Widget _construirTabTerminalesQR() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Locales_Seguridad')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD54F)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFFD97706),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Política de 1 sola terminal por sucursal: Cada QR caduca en 5 minutos o en cuanto se escanea. Si vinculas un equipo nuevo, el anterior queda expulsado automáticamente.',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.brown.shade900,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (docs.isEmpty)
              _EstadoVacioPastel(
                icono: Icons.storefront_outlined,
                titulo: 'Sin sucursales configuradas',
                subtitulo:
                    'Registra tus sucursales en la colección Locales_Seguridad de Firestore.',
              )
            else
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String nombre = (data['nombre'] ?? doc.id).toString();
                final String codigo = (data['codigo'] ?? doc.id).toString();
                final bool abierto = (data['abierto'] ?? true) as bool;
                final String? deviceId =
                    data['dispositivoAutorizadoId'] as String?;
                final String deviceNombre =
                    (data['dispositivoNombre'] ?? 'Dispositivo Android')
                        .toString();
                final Timestamp? vinculadoEn =
                    data['vinculadoEn'] as Timestamp?;
                final bool tieneDispositivo =
                    deviceId != null && deviceId.trim().isNotEmpty;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color:
                          tieneDispositivo
                              ? colorVerdeTese.withValues(alpha: 0.3)
                              : Colors.grey.shade200,
                      width: 1.5,
                    ),
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
                              size: 22,
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
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                                Text(
                                  'ID: $codigo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: colorTextoGris,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  abierto
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              abierto ? 'Abierto' : 'Cerrado',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: abierto ? colorExito : Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              tieneDispositivo
                                  ? const Color(0xFFF1F8E9)
                                  : colorFondoCrema,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              tieneDispositivo
                                  ? Icons.phonelink_lock_rounded
                                  : Icons.phonelink_off_rounded,
                              color:
                                  tieneDispositivo
                                      ? colorVerdeTese
                                      : colorTextoGris,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tieneDispositivo
                                        ? 'Terminal Vinculada: $deviceNombre'
                                        : 'Sin dispositivo autorizado',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color:
                                          tieneDispositivo
                                              ? colorVerdeTese
                                              : colorTextoGris,
                                    ),
                                  ),
                                  if (tieneDispositivo)
                                    Text(
                                      'Huella: ${deviceId.length > 10 ? deviceId.substring(0, 10) : deviceId}... • ${_formatearFecha(vinculadoEn)}',
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorVerdeTese,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed:
                                  () => _generarYMostrarQR(
                                    doc.id,
                                    nombre,
                                    codigo,
                                  ),
                              icon: const Icon(
                                Icons.qr_code_2_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                              label: Text(
                                'Generar QR',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                          if (tieneDispositivo) ...[
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed:
                                  () => _desvincularTerminal(doc.id, nombre),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: Text(
                                'Expulsar',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // =========================================================================
  // PESTAÑA 4: DIRECTORIO DE CUENTAS DE ESTUDIANTES
  // =========================================================================
  Widget _construirTabAlumnos() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Usuarios').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final q = _queryAlumno.trim().toLowerCase();

        final filtrados =
            docs.where((d) {
              if (q.isEmpty) return true;
              final data = d.data() as Map<String, dynamic>;
              final nombre =
                  (data['nombre_completo'] ?? '').toString().toLowerCase();
              final mat =
                  (data['identificador'] ?? '').toString().toLowerCase();
              final carrera =
                  (data['carrera_area'] ?? '').toString().toLowerCase();
              return nombre.contains(q) ||
                  mat.contains(q) ||
                  carrera.contains(q);
            }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _busquedaAlumnoCtrl,
                  onChanged: (v) => setState(() => _queryAlumno = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, matrícula o carrera...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: colorTextoGris,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: colorVerdeTese,
                    ),
                    suffixIcon:
                        _queryAlumno.isNotEmpty
                            ? IconButton(
                              onPressed: () {
                                _busquedaAlumnoCtrl.clear();
                                setState(() => _queryAlumno = '');
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  filtrados.isEmpty
                      ? _EstadoVacioPastel(
                        icono: Icons.school_outlined,
                        titulo: 'No se encontraron cuentas',
                        subtitulo:
                            'Prueba con otra matrícula o nombre de estudiante.',
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtrados.length,
                        itemBuilder: (_, idx) {
                          final data =
                              filtrados[idx].data() as Map<String, dynamic>;
                          final String nombre =
                              (data['nombre_completo'] ?? 'Estudiante TESE')
                                  .toString();
                          final String matricula =
                              (data['identificador'] ?? 'Sin matrícula')
                                  .toString();
                          final String carrera =
                              (data['carrera_area'] ?? 'Carrera no registrada')
                                  .toString();
                          final String alergia =
                              (data['alergia'] ??
                                      'Sin restricciones alimentarias 😋')
                                  .toString();
                          final bool tieneAlergia =
                              !alergia.startsWith('Sin restricciones');
                          final String inicial =
                              nombre.isNotEmpty ? nombre[0].toUpperCase() : 'E';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  child: Text(
                                    inicial,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w900,
                                      color: colorVerdeTese,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                          color: colorTextoOscuro,
                                        ),
                                      ),
                                      Text(
                                        '$matricula • $carrera',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          color: colorTextoGris,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (tieneAlergia) ...[
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF8E1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFFFD54F),
                                            ),
                                          ),
                                          child: Text(
                                            '⚠️ $alergia',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.brown.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
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

  String _formatearFecha(Timestamp? ts) {
    if (ts == null) return 'Reciente';
    final dt = ts.toDate();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m $h:$min';
  }
}

// =========================================================================
// DIÁLOGO DE QR EFÍMERO DE 1 SOLO USO CON TEMPORIZADOR Y DETECCIÓN EN VIVO
// =========================================================================
class _DialogoQRVinculacion extends StatefulWidget {
  final String docId;
  final String nombreSucursal;
  final String codigoSucursal;
  final String token;
  final DateTime expiraEn;

  const _DialogoQRVinculacion({
    required this.docId,
    required this.nombreSucursal,
    required this.codigoSucursal,
    required this.token,
    required this.expiraEn,
  });

  @override
  State<_DialogoQRVinculacion> createState() => _DialogoQRVinculacionState();
}

class _DialogoQRVinculacionState extends State<_DialogoQRVinculacion> {
  Timer? _timer;
  Duration _restante = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _actualizarRestante();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _actualizarRestante();
    });
  }

  void _actualizarRestante() {
    final diff = widget.expiraEn.difference(DateTime.now());
    if (mounted) {
      setState(() {
        _restante = diff.isNegative ? Duration.zero : diff;
      });
    }
    if (diff.isNegative) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String payloadQR = jsonEncode({
      'app': 'TESE_HAMBREADOS_KDS',
      'docId': widget.docId,
      'local': widget.nombreSucursal,
      'token': widget.token,
    });

    final String minStr = _restante.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final String segStr = _restante.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final bool expirado = _restante == Duration.zero;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Locales_Seguridad')
              .doc(widget.docId)
              .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final bool yaFueUsado = (data?['qrUsado'] ?? false) as bool;

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Llave QR de 1 Solo Uso 🔐',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: colorTextoOscuro,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.nombreSucursal,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorVerdeTese,
                  ),
                ),
                const SizedBox(height: 14),
                if (yaFueUsado) ...[
                  ZoomIn(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 64,
                        color: colorExito,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¡Terminal vinculada con éxito!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: colorVerdeTese,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Este código QR fue destruido automáticamente y ya no puede volver a usarse.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colorTextoGris,
                    ),
                  ),
                ] else if (expirado) ...[
                  const Icon(
                    Icons.timer_off_rounded,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Este código QR ha expirado.',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorVerdeTese.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: QrImageView(
                      data: payloadQR,
                      version: QrVersions.auto,
                      size: 210,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⏳ Caduca en $minStr:$segStr',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: colorVerdeTese,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '⚠️ Aviso de Seguridad: Este QR vincula únicamente 1 dispositivo oficial. Tengan extremo cuidado en no filtrarlo ni permitir fotografías ajenas; cualquier mal uso es responsabilidad de la sucursal.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade900,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorVerdeTese,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      yaFueUsado ? 'Listo' : 'Cerrar',
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
    );
  }
}

class _TarjetaKPI extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final Color colorFondo;
  final Color colorAcento;
  final IconData icono;

  const _TarjetaKPI({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.colorFondo,
    required this.colorAcento,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorAcento.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: colorAcento, size: 22),
          const SizedBox(height: 8),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colorTextoGris,
            ),
          ),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colorTextoOscuro,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorAcento,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVacioPastel extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;

  const _EstadoVacioPastel({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 42, color: colorVerdeTese),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: colorTextoOscuro,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: colorTextoGris),
          ),
        ],
      ),
    );
  }
}
