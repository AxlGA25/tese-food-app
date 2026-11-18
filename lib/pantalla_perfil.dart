import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'colores.dart';
import 'pantalla_gachapon.dart';
import 'pantalla_buzon_quejas.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final ImagePicker _picker = ImagePicker();

  final List<String> _opcionesAlergia = [
    'Sin restricciones alimentarias 😋',
    'Intolerante a la lactosa 🥛',
    'Alérgico al cacahuate / nueces 🥜',
    'Alérgico al gluten / celíaco 🌾',
    'Alérgico a mariscos 🦐',
    'Vegetariano 🥗',
    'Vegano 🌱',
  ];

  final List<String> _carrerasTese = [
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería en Computación',
    'Ingeniería en Informática',
    'Ingeniería Industrial',
    'Ingeniería Mecatrónica',
    'Ingeniería Electrónica',
    'Ingeniería Química',
    'Ingeniería Bioquímica',
    'Ingeniería Aeronáutica',
    'Ingeniería en Gestión Empresarial',
    'Licenciatura en Contaduría',
  ];

  Future<void> _subirFotoPerfil(String uid, ImageSource origen) async {
    final XFile? img = await _picker.pickImage(
      source: origen,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 60,
    );
    if (img == null) {
      return;
    }

    final bytes = await img.readAsBytes();
    final String b64 = base64Encode(bytes);

    await FirebaseFirestore.instance.collection('Usuarios').doc(uid).set({
      'fotoPerfilBase64': b64,
      'usarFotoReal': true,
    }, SetOptions(merge: true));

    HapticFeedback.mediumImpact();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📸 Foto de perfil actualizada.',
          style: GoogleFonts.poppins(fontSize: 12.5),
        ),
        backgroundColor: colorExito,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _abrirSelectorAvatar(
    String uid,
    Map<String, dynamic> perfilGacha,
    String patoEquipadoId,
    bool usarFotoReal,
  ) {
    final Map<String, dynamic> coleccion =
        (perfilGacha['coleccionPatos'] as Map<String, dynamic>?) ??
        {'estudiante': 1};

    final List<PatoSkin> patosDesbloqueados =
        catalogoPatos.where((p) {
          if (p.id == 'estudiante') {
            return true;
          }
          final cant = (coleccion[p.id] ?? 0) as int;
          return cant > 0;
        }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
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
                Text(
                  'Personaliza tu Avatar 🦆📸',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: colorTextoOscuro,
                  ),
                ),
                Text(
                  'Usa tu fotografía real o equipa un Patito del Multiverso Gachapón.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colorTextoGris,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorVerdeTese,
                          side: const BorderSide(color: colorVerdeTese),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _subirFotoPerfil(uid, ImageSource.camera);
                        },
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: Text(
                          'Cámara',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorVerdeTese,
                          side: const BorderSide(color: colorVerdeTese),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _subirFotoPerfil(uid, ImageSource.gallery);
                        },
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: Text(
                          'Galería',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tus Patitos Desbloqueados (${patosDesbloqueados.length}/${catalogoPatos.length})',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: colorTextoOscuro,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 230,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: patosDesbloqueados.length,
                    itemBuilder: (_, idx) {
                      final skin = patosDesbloqueados[idx];
                      final bool equipado =
                          !usarFotoReal && skin.id == patoEquipadoId;

                      return GestureDetector(
                        onTap: () async {
                          HapticFeedback.selectionClick();
                          await FirebaseFirestore.instance
                              .collection('Usuarios_Perfil')
                              .doc(uid)
                              .set({
                                'patoEquipadoId': skin.id,
                              }, SetOptions(merge: true));

                          await FirebaseFirestore.instance
                              .collection('Usuarios')
                              .doc(uid)
                              .set({
                                'usarFotoReal': false,
                              }, SetOptions(merge: true));

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                equipado
                                    ? const Color(0xFFE8F5E9)
                                    : colorFondoCrema,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  equipado
                                      ? colorVerdeTese
                                      : Colors.grey.shade200,
                              width: equipado ? 2.2 : 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: PatoVista(skin: skin, tamano: 60),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                skin.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight:
                                      equipado
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                  color: colorTextoOscuro,
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
            ),
          ),
    );
  }

  void _abrirSelectorAlergia(String uid, String alergiaActual) {
    String seleccion =
        _opcionesAlergia.contains(alergiaActual)
            ? alergiaActual
            : _opcionesAlergia.first;
    final TextEditingController otraCtrl = TextEditingController(
      text: _opcionesAlergia.contains(alergiaActual) ? '' : alergiaActual,
    );

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
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nota Médica y Alergias 🩺',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: colorTextoOscuro,
                        ),
                      ),
                      Text(
                        'Esta alerta se adjunta automáticamente en tus pedidos para avisar al chef.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorTextoGris,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _opcionesAlergia.map((op) {
                              final bool activo =
                                  seleccion == op &&
                                  otraCtrl.text.trim().isEmpty;
                              return ChoiceChip(
                                label: Text(
                                  op,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        activo
                                            ? Colors.white
                                            : colorTextoOscuro,
                                  ),
                                ),
                                selected: activo,
                                selectedColor: colorVerdeTese,
                                backgroundColor: colorFondoCrema,
                                onSelected: (_) {
                                  setStateModal(() {
                                    seleccion = op;
                                    otraCtrl.clear();
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: otraCtrl,
                        onChanged: (_) => setStateModal(() {}),
                        decoration: InputDecoration(
                          labelText: '¿Otra alergia específica? (Opcional)',
                          hintText: 'Ej. Alérgico a la fresa o al aguacate',
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
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
                          onPressed: () async {
                            final String valorFinal =
                                otraCtrl.text.trim().isNotEmpty
                                    ? otraCtrl.text.trim()
                                    : seleccion;
                            await FirebaseFirestore.instance
                                .collection('Usuarios')
                                .doc(uid)
                                .set({
                                  'alergia': valorFinal,
                                }, SetOptions(merge: true));
                            HapticFeedback.mediumImpact();
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          },
                          child: Text(
                            'Guardar Preferencia',
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

  void _abrirEditarDatosAcademicos(
    String uid,
    String nombreActual,
    String matriculaActual,
    String carreraActual,
  ) {
    final nombreCtrl = TextEditingController(text: nombreActual);
    final matriculaCtrl = TextEditingController(text: matriculaActual);
    String carreraSel =
        _carrerasTese.contains(carreraActual)
            ? carreraActual
            : _carrerasTese.first;
    bool guardando = false;

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
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar Credencial TESE 🎓',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nombreCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: matriculaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Matrícula TESE',
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: carreraSel,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Carrera',
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items:
                            _carrerasTese
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setStateModal(() => carreraSel = v);
                          }
                        },
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
                                    if (nombreCtrl.text.trim().isEmpty) {
                                      return;
                                    }
                                    setStateModal(() => guardando = true);
                                    await FirebaseFirestore.instance
                                        .collection('Usuarios')
                                        .doc(uid)
                                        .set({
                                          'nombre_completo':
                                              nombreCtrl.text.trim(),
                                          'identificador':
                                              matriculaCtrl.text.trim(),
                                          'carrera_area': carreraSel,
                                        }, SetOptions(merge: true));

                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                  },
                          child: Text(
                            guardando ? 'Guardando...' : 'Guardar Cambios',
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

  Future<void> _confirmarCerrarSesion() async {
    final salir = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              '¿Cerrar sesión?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
            ),
            content: Text(
              'Tus puntos, historial y colección de patitos seguirán guardados de forma segura en tu cuenta.',
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
                  'Cerrar Sesión',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (salir == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: colorFondoCrema,
        body: Center(
          child: Text(
            'Inicia sesión para ver tu perfil.',
            style: GoogleFonts.poppins(color: colorTextoGris),
          ),
        ),
      );
    }

    final String uid = user.uid;

    return Scaffold(
      backgroundColor: colorFondoCrema,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('Usuarios')
                  .doc(uid)
                  .snapshots(),
          builder: (context, snapUsuario) {
            final Map<String, dynamic> uData =
                (snapUsuario.data?.data() as Map<String, dynamic>?) ?? {};
            final String nombre =
                (uData['nombre_completo'] ??
                        user.displayName ??
                        'Estudiante TESE')
                    .toString();
            final String matricula =
                (uData['identificador'] ?? 'Sin matrícula').toString();
            final String carrera =
                (uData['carrera_area'] ??
                        'Tecnológico de Estudios Superiores de Ecatepec')
                    .toString();
            final String correo =
                (uData['correo'] ?? user.email ?? '').toString();
            final String alergia =
                (uData['alergia'] ?? 'Sin restricciones alimentarias 😋')
                    .toString();
            final int ptsCompensacion =
                (uData['puntosCompensacion'] ?? 0) as int;
            final String fotoB64 = (uData['fotoPerfilBase64'] ?? '').toString();
            final bool usarFotoReal =
                (uData['usarFotoReal'] ?? false) as bool && fotoB64.isNotEmpty;

            Uint8List? bytesFoto;
            if (usarFotoReal) {
              try {
                bytesFoto = base64Decode(fotoB64);
              } catch (_) {}
            }

            return StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Usuarios_Perfil')
                      .doc(uid)
                      .snapshots(),
              builder: (context, snapPerfil) {
                final Map<String, dynamic> pData =
                    (snapPerfil.data?.data() as Map<String, dynamic>?) ?? {};
                final String patoId =
                    (pData['patoEquipadoId'] ?? 'estudiante').toString();
                final int ptsGastados = (pData['puntosGastados'] ?? 0) as int;
                final Map<String, dynamic> coleccion =
                    (pData['coleccionPatos'] as Map<String, dynamic>?) ??
                    {'estudiante': 1};

                final PatoSkin patoEquipado = catalogoPatos.firstWhere(
                  (p) => p.id == patoId,
                  orElse: () => catalogoPatos.first,
                );
                final int totalPatosUnicos = coleccion.entries
                    .where((e) => (e.value as int? ?? 0) > 0)
                    .length
                    .clamp(1, catalogoPatos.length);

                return StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Pedidos')
                          .where('idAlumno', isEqualTo: uid)
                          .where('estado', isEqualTo: 3)
                          .snapshots(),
                  builder: (context, snapPedidos) {
                    int ptsGanadosPedidos = 0;
                    final docsPedidos = snapPedidos.data?.docs ?? [];
                    for (final d in docsPedidos) {
                      final m = d.data() as Map<String, dynamic>;
                      ptsGanadosPedidos += (m['puntosGanados'] ?? 0) as int;
                    }
                    final int saldoPuntos = (ptsGanadosPedidos +
                            ptsCompensacion -
                            ptsGastados)
                        .clamp(0, 999999);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TÍTULO SUPERIOR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mi Perfil TESE 🎓',
                                style: GoogleFonts.poppins(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  color: colorVerdeTese,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Editar credencial',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed:
                                    () => _abrirEditarDatosAcademicos(
                                      uid,
                                      nombre,
                                      matricula,
                                      carrera,
                                    ),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: colorVerdeTese,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // CREDENCIAL DIGITAL ESTUDIANTIL
                          FadeInDown(
                            duration: const Duration(milliseconds: 260),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1B5E20),
                                    Color(0xFF2E7D32),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorVerdeTese.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // AVATAR 1:1 CON BOTÓN DE EDICIÓN
                                      GestureDetector(
                                        onTap:
                                            () => _abrirSelectorAvatar(
                                              uid,
                                              pData,
                                              patoId,
                                              usarFotoReal,
                                            ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 78,
                                              height: 78,
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: colorAmarilloTese,
                                                  width: 2.8,
                                                ),
                                              ),
                                              child: ClipOval(
                                                child:
                                                    bytesFoto != null
                                                        ? Image.memory(
                                                          bytesFoto,
                                                          fit: BoxFit.cover,
                                                        )
                                                        : AspectRatio(
                                                          aspectRatio: 1.0,
                                                          child: PatoVista(
                                                            skin: patoEquipado,
                                                            tamano: 68,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: colorAmarilloTese,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt_rounded,
                                                  size: 14,
                                                  color: colorVerdeOscuro,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.18,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'MATRÍCULA: $matricula',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: colorAmarilloTese,
                                                  letterSpacing: 0.6,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              nombre,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              carrera,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                color: Colors.white.withValues(
                                                  alpha: 0.85,
                                                ),
                                              ),
                                            ),
                                            if (correo.isNotEmpty)
                                              Text(
                                                correo,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10.5,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // ESTADÍSTICAS RÁPIDAS DENTRO DE LA CREDENCIAL
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MiniStatCredencial(
                                          icono: Icons.stars_rounded,
                                          valor: '$saldoPuntos pts',
                                          etiqueta: 'Saldo Gachapón',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _MiniStatCredencial(
                                          icono: Icons.catching_pokemon_rounded,
                                          valor:
                                              '$totalPatosUnicos/${catalogoPatos.length}',
                                          etiqueta: 'Patitos',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _MiniStatCredencial(
                                          icono: Icons.fastfood_rounded,
                                          valor: '${docsPedidos.length}',
                                          etiqueta: 'Pedidos',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // TARJETA DE ALERGIA / NOTA MÉDICA
                          Text(
                            'Preferencias Alimentarias',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: colorTextoOscuro,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _abrirSelectorAlergia(uid, alergia),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    alergia.startsWith('Sin restricciones')
                                        ? Colors.white
                                        : const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      alergia.startsWith('Sin restricciones')
                                          ? Colors.grey.shade200
                                          : const Color(0xFFFFD54F),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          alergia.startsWith(
                                                'Sin restricciones',
                                              )
                                              ? const Color(0xFFE8F5E9)
                                              : Colors.orange.withValues(
                                                alpha: 0.16,
                                              ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.medical_information_rounded,
                                      color:
                                          alergia.startsWith(
                                                'Sin restricciones',
                                              )
                                              ? colorVerdeTese
                                              : Colors.orange.shade800,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Alerta para la cocina',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            color: colorTextoGris,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          alergia,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: colorTextoOscuro,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit_rounded,
                                    size: 18,
                                    color: colorVerdeTese,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ATENCIÓN AL ESTUDIANTE Y ACCESOS
                          Text(
                            'Atención y Cuenta',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: colorTextoOscuro,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // BOTÓN DEL BUZÓN DE QUEJAS CON INSIGNIA DE RESPUESTAS
                          StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('Quejas_Buzon')
                                    .where('idAlumno', isEqualTo: uid)
                                    .snapshots(),
                            builder: (_, snapQuejas) {
                              final qDocs = snapQuejas.data?.docs ?? [];
                              final int respondidas =
                                  qDocs.where((d) {
                                    final m = d.data() as Map<String, dynamic>;
                                    return (m['respuestaAdmin'] ?? '')
                                        .toString()
                                        .trim()
                                        .isNotEmpty;
                                  }).length;

                              return _TarjetaOpcionPerfil(
                                icono: Icons.campaign_rounded,
                                colorFondoIcono: const Color(0xFFFFF8E1),
                                colorIcono: const Color(0xFFD97706),
                                titulo: 'Buzón de Quejas y Sugerencias',
                                subtitulo:
                                    respondidas > 0
                                        ? 'Tienes $respondidas respuesta(s) de Administración'
                                        : 'Reporta incidencias directo a Administración',
                                badgeTexto:
                                    respondidas > 0 ? '$respondidas' : null,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const PantallaBuzonQuejas(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          _TarjetaOpcionPerfil(
                            icono: Icons.face_retouching_natural_rounded,
                            colorFondoIcono: const Color(0xFFE8F5E9),
                            colorIcono: colorVerdeTese,
                            titulo: 'Cambiar Foto o Patito Compañero',
                            subtitulo:
                                usarFotoReal
                                    ? 'Usando fotografía real'
                                    : 'Equipado: ${patoEquipado.nombre}',
                            onTap:
                                () => _abrirSelectorAvatar(
                                  uid,
                                  pData,
                                  patoId,
                                  usarFotoReal,
                                ),
                          ),
                          const SizedBox(height: 10),

                          _TarjetaOpcionPerfil(
                            icono: Icons.badge_outlined,
                            colorFondoIcono: const Color(0xFFE0F2FE),
                            colorIcono: const Color(0xFF0284C7),
                            titulo: 'Editar Nombre, Matrícula o Carrera',
                            subtitulo: 'Mantén actualizada tu ficha de entrega',
                            onTap:
                                () => _abrirEditarDatosAcademicos(
                                  uid,
                                  nombre,
                                  matricula,
                                  carrera,
                                ),
                          ),
                          const SizedBox(height: 22),

                          // BOTÓN CERRAR SESIÓN
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _confirmarCerrarSesion,
                              icon: const Icon(Icons.logout_rounded, size: 20),
                              label: Text(
                                'Cerrar Sesión',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MiniStatCredencial extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;

  const _MiniStatCredencial({
    required this.icono,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icono, color: colorAmarilloTese, size: 18),
          const SizedBox(height: 3),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          Text(
            etiqueta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaOpcionPerfil extends StatelessWidget {
  final IconData icono;
  final Color colorFondoIcono;
  final Color colorIcono;
  final String titulo;
  final String subtitulo;
  final String? badgeTexto;
  final VoidCallback onTap;

  const _TarjetaOpcionPerfil({
    required this.icono,
    required this.colorFondoIcono,
    required this.colorIcono,
    required this.titulo,
    required this.subtitulo,
    this.badgeTexto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorFondoIcono,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: colorIcono, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: colorTextoOscuro,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: colorTextoGris,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeTexto != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorExito,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeTexto!,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, color: colorTextoGris),
          ],
        ),
      ),
    );
  }
}

typedef PerfilEstudianteScreen = PantallaPerfil;
