import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'colores.dart';
import 'servicio_notificaciones.dart';

class PantallaBuzonQuejas extends StatefulWidget {
  const PantallaBuzonQuejas({super.key});

  @override
  State<PantallaBuzonQuejas> createState() => _PantallaBuzonQuejasState();
}

class _PantallaBuzonQuejasState extends State<PantallaBuzonQuejas>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final TextEditingController _descripcionCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _sucursalSeleccionada = 'Cafetería Central';
  String _categoriaSeleccionada = 'Tardanza excesiva';
  bool _esAnonimo = false;
  String _fotoBase64 = '';
  bool _enviando = false;

  String _nombreAlumno = 'Estudiante TESE';

  final List<String> _sucursales = [
    'Cafetería Central',
    'Kiosko Sistemas',
    'Kiosko Biblioteca',
    'General / App',
  ];

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Higiene', 'icono': Icons.cleaning_services_outlined},
    {'nombre': 'Mal trato', 'icono': Icons.sentiment_dissatisfied_rounded},
    {'nombre': 'Comida en mal estado', 'icono': Icons.no_food_outlined},
    {'nombre': 'Tardanza excesiva', 'icono': Icons.hourglass_bottom_rounded},
    {'nombre': 'Cobro incorrecto', 'icono': Icons.payments_outlined},
    {'nombre': 'Otro', 'icono': Icons.help_outline_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarNombreAlumno();
  }

  Future<void> _cargarNombreAlumno() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    _nombreAlumno = user.displayName ?? 'Estudiante TESE';
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(user.uid)
              .get();
      if (doc.exists && mounted) {
        setState(() {
          _nombreAlumno =
              (doc.data()?['nombre_completo'] ?? _nombreAlumno).toString();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto(ImageSource origen) async {
    final XFile? img = await _picker.pickImage(
      source: origen,
      maxWidth: 600,
      imageQuality: 55,
    );
    if (img != null) {
      final bytes = await img.readAsBytes();
      if (mounted) {
        setState(() {
          _fotoBase64 = base64Encode(bytes);
        });
      }
    }
  }

  Future<void> _enviarQueja() async {
    final String texto = _descripcionCtrl.text.trim();
    if (texto.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cuéntanos un poco más de detalle (al menos 10 caracteres).',
            style: GoogleFonts.poppins(fontSize: 12.5),
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    setState(() => _enviando = true);
    HapticFeedback.mediumImpact();

    try {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonimo';

      await FirebaseFirestore.instance.collection('Quejas_Buzon').add({
        'idAlumno': uid,
        'alumno': _nombreAlumno,
        'esAnonimo': _esAnonimo,
        'local': _sucursalSeleccionada,
        'categoria': _categoriaSeleccionada,
        'descripcion': texto,
        'fotoEvidencia': _fotoBase64,
        'estado': 'Pendiente',
        'respuestaAdmin': '',
        'fecha': FieldValue.serverTimestamp(),
      });

      await ServicioNotificaciones.sonarEfecto('sonidos/exito.mp3');

      if (!mounted) {
        return;
      }

      setState(() {
        _descripcionCtrl.clear();
        _fotoBase64 = '';
        _esAnonimo = false;
        _enviando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Tu reporte fue enviado al Buzón Administrativo.',
            style: GoogleFonts.poppins(fontSize: 12.5),
          ),
          backgroundColor: colorExito,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      // Cambia automáticamente a la pestaña de seguimiento
      _tabController.animateTo(1);
    } catch (_) {
      if (mounted) {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📡 No se pudo enviar tu reporte. Revisa tu conexión a Internet.',
              style: GoogleFonts.poppins(fontSize: 12.5),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Buzón de Quejas 📢',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // PESTAÑAS TIPO PÍLDORA
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                fontSize: 12.5,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
              tabs: const [
                Tab(text: '📝 Nuevo Reporte'),
                Tab(text: '📬 Mis Reportes'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _construirFormularioQueja(),
                _construirListaMisReportes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // PESTAÑA 1: FORMULARIO PARA LEVANTAR UNA QUEJA O SUGERENCIA
  // =========================================================================
  Widget _construirFormularioQueja() {
    Uint8List? previewBytes;
    if (_fotoBase64.isNotEmpty) {
      try {
        previewBytes = base64Decode(_fotoBase64);
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 220),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorVerdeTese.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: colorVerdeTese,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Este buzón va directo a la Administración del campus (es independiente de las reseñas públicas). Tu reporte nos ayuda a mejorar el servicio.',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: colorVerdeOscuro,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '1. ¿Sobre qué sucursal es tu reporte?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: colorTextoOscuro,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _sucursales.map((suc) {
                  final bool activo = _sucursalSeleccionada == suc;
                  return ChoiceChip(
                    label: Text(
                      suc,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
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
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _sucursalSeleccionada = suc);
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 18),

          Text(
            '2. Motivo principal',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: colorTextoOscuro,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _categorias.map((cat) {
                  final String nombre = cat['nombre'] as String;
                  final IconData icono = cat['icono'] as IconData;
                  final bool activo = _categoriaSeleccionada == nombre;

                  return ChoiceChip(
                    avatar: Icon(
                      icono,
                      size: 16,
                      color: activo ? Colors.white : colorVerdeTese,
                    ),
                    label: Text(
                      nombre,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: activo ? Colors.white : colorTextoOscuro,
                      ),
                    ),
                    selected: activo,
                    selectedColor: const Color(0xFFEA580C),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color:
                            activo
                                ? const Color(0xFFEA580C)
                                : Colors.grey.shade200,
                      ),
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _categoriaSeleccionada = nombre);
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 18),

          Text(
            '3. Cuéntanos qué pasó',
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
              controller: _descripcionCtrl,
              maxLines: 4,
              maxLength: 400,
              decoration: InputDecoration(
                hintText:
                    'Describe lo ocurrido (fecha aproximada, platillo o situación)...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: colorTextoGris,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Evidencia fotográfica opcional
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorVerdeTese,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: colorVerdeTese.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _seleccionarFoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: Text(
                    'Tomar foto',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorVerdeTese,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: colorVerdeTese.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _seleccionarFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(
                    'Galería',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (previewBytes != null) ...[
            const SizedBox(height: 10),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    previewBytes,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.65),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _fotoBase64 = ''),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Interruptor de Anonimato
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: colorVerdeTese,
              title: Text(
                'Enviar reporte como Anónimo 🕵️‍♂️',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colorTextoOscuro,
                ),
              ),
              subtitle: Text(
                _esAnonimo
                    ? 'Administración NO verá tu nombre, pero igual recibirás respuesta aquí.'
                    : 'Se enviará con tu nombre ($_nombreAlumno).',
                style: GoogleFonts.poppins(fontSize: 11, color: colorTextoGris),
              ),
              value: _esAnonimo,
              onChanged: (v) => setState(() => _esAnonimo = v),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorVerdeTese,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 2,
              ),
              onPressed: _enviando ? null : _enviarQueja,
              icon:
                  _enviando
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(
                _enviando ? 'Enviando reporte...' : 'Enviar al Buzón de Quejas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // PESTAÑA 2: SEGUIMIENTO Y RESPUESTAS DEL ADMINISTRATIVO
  // =========================================================================
  Widget _construirListaMisReportes() {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonimo';

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Quejas_Buzon')
              .where('idAlumno', isEqualTo: uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = (snapshot.data?.docs ?? []).toList();
        docs.sort((a, b) {
          final ta = (a.data() as Map<String, dynamic>)['fecha'] as Timestamp?;
          final tb = (b.data() as Map<String, dynamic>)['fecha'] as Timestamp?;
          return (tb?.millisecondsSinceEpoch ?? 0).compareTo(
            ta?.millisecondsSinceEpoch ?? 0,
          );
        });

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 48,
                      color: colorVerdeTese,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Aún no has enviado reportes',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cuando envíes una queja o sugerencia, aquí podrás ver su estatus y la respuesta de Administración.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: colorTextoGris,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 26),
          itemCount: docs.length,
          itemBuilder: (_, idx) {
            final data = docs[idx].data() as Map<String, dynamic>;
            final String estado = (data['estado'] ?? 'Pendiente').toString();
            final String local = (data['local'] ?? 'General').toString();
            final String categoria =
                (data['categoria'] ?? 'General').toString();
            final String descripcion = (data['descripcion'] ?? '').toString();
            final String respuesta = (data['respuestaAdmin'] ?? '').toString();
            final bool esAnonimo = (data['esAnonimo'] ?? false) as bool;
            final Timestamp? ts = data['fecha'] as Timestamp?;

            final Color colorEst =
                estado == 'Resuelta'
                    ? colorExito
                    : (estado == 'En Revisión'
                        ? const Color(0xFFF59E0B)
                        : Colors.redAccent);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorEst.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
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
                      if (esAnonimo)
                        const Tooltip(
                          message: 'Enviado como Anónimo',
                          child: Text('🕵️‍♂️', style: TextStyle(fontSize: 14)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: colorTextoOscuro,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enviado: ${_formatearFecha(ts)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: colorTextoGris,
                    ),
                  ),
                  if (respuesta.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorVerdeTese.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🛡️ Respuesta de Administración:',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: colorVerdeTese,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            respuesta,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: colorTextoOscuro,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatearFecha(Timestamp? ts) {
    if (ts == null) {
      return 'Hace un momento';
    }
    final dt = ts.toDate();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m $h:$min';
  }
}
