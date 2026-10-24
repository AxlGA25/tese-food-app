import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'colores.dart';
import 'pantalla_inicio.dart';
import 'pantalla_gachapon.dart';
import 'pantalla_menu.dart';

class PerfilEstudianteScreen extends StatefulWidget {
  const PerfilEstudianteScreen({super.key});

  @override
  State<PerfilEstudianteScreen> createState() => _PerfilEstudianteScreenState();
}

class _PerfilEstudianteScreenState extends State<PerfilEstudianteScreen> {
  static const int costoPorHuevo = 50;

  final User? _usuarioAuth = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  String alergiaActual = 'Sin restricciones alimentarias 😋';

  final List<String> opcionesAlergias = [
    'Sin restricciones alimentarias 😋',
    'Intolerante a la lactosa 🥛🚫',
    'Alérgico a los frutos secos/nueces 🥜🚫',
    'Alérgico al gluten (Celíaco) 🍞🚫',
    'Vegetariano / Vegano 🥗🌱',
    'Sensible al picante extremo 🌶️🚫',
  ];

  void _cambiarAlergia(String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferencia o Alergia Alimentaria',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
                Text(
                  'Se enviará automáticamente como nota de cuidado en tus pedidos.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colorTextoGris,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        opcionesAlergias
                            .map(
                              (opcion) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  opcion,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight:
                                        alergiaActual == opcion
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        alergiaActual == opcion
                                            ? colorVerdeTese
                                            : colorTextoOscuro,
                                  ),
                                ),
                                trailing:
                                    alergiaActual == opcion
                                        ? const Icon(
                                          Icons.check_circle,
                                          color: colorExito,
                                        )
                                        : null,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => alergiaActual = opcion);
                                  FirebaseFirestore.instance
                                      .collection('Usuarios')
                                      .doc(uid)
                                      .set({
                                        'alergia': opcion,
                                      }, SetOptions(merge: true));
                                  Navigator.pop(context);
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _subirFotoReal(String uid, ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(
        source: source,
        maxWidth: 450,
        maxHeight: 450,
        imageQuality: 60,
      );
      if (img != null) {
        final bytes = await img.readAsBytes();
        final String base64Str = base64Encode(bytes);

        await FirebaseFirestore.instance.collection('Usuarios').doc(uid).set({
          'fotoBase64': base64Str,
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('Usuarios_Perfil')
            .doc(uid)
            .set({'usarFotoReal': true}, SetOptions(merge: true));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Tu foto de perfil ha sido actualizada! 📸✨'),
            backgroundColor: colorExito,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cargar la foto.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _mostrarSelectorFotoOPatito(
    String uid,
    String patoActualId,
    Map<String, int> coleccion,
    String fotoBase64Actual,
    bool usandoFotoReal,
  ) {
    final patosDesbloqueados =
        catalogoPatos
            .where((p) => (coleccion[p.id] ?? 0) > 0 || p.id == 'estudiante')
            .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  const SizedBox(height: 14),
                  Text(
                    'Personalizar Imagen de Perfil',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorVerdeTese,
                    ),
                  ),
                  Text(
                    'Elige entre usar una foto tuya o equipar un Patito de tu colección:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colorTextoGris,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // OPCIÓN 1: FOTO REAL (SIN CORTAR TEXTO EN CÁMARA / GALERÍA)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorFondoCrema,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            usandoFotoReal
                                ? colorVerdeTese
                                : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.camera_alt_rounded,
                              color: colorVerdeTese,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Opción 1: Usar mi propia foto',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: colorTextoOscuro,
                                ),
                              ),
                            ),
                            if (usandoFotoReal)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorExito,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Activa',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorVerdeTese,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: colorVerdeTese,
                                    width: 1.3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _subirFotoReal(uid, ImageSource.camera);
                                },
                                icon: const Icon(
                                  Icons.photo_camera_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  'Cámara',
                                  maxLines: 1,
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
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: colorVerdeTese,
                                    width: 1.3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _subirFotoReal(uid, ImageSource.gallery);
                                },
                                icon: const Icon(
                                  Icons.photo_library_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  'Galería',
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (fotoBase64Actual.isNotEmpty && !usandoFotoReal) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorVerdeTese,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('Usuarios_Perfil')
                                    .doc(uid)
                                    .set({
                                      'usarFotoReal': true,
                                    }, SetOptions(merge: true));
                                Navigator.pop(ctx);
                              },
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 17,
                              ),
                              label: Text(
                                'Activar mi foto guardada',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // OPCIÓN 2: AVATAR DE PATITO (PROPORCIÓN CUADRADA SIN DEFORMAR)
                  Row(
                    children: [
                      const Text('🦆', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        'Opción 2: Usar un Avatar de Patito (${patosDesbloqueados.length})',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: colorTextoOscuro,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.40,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.86,
                          ),
                      itemCount: patosDesbloqueados.length,
                      itemBuilder: (_, i) {
                        final pato = patosDesbloqueados[i];
                        final bool equipado =
                            !usandoFotoReal && pato.id == patoActualId;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            FirebaseFirestore.instance
                                .collection('Usuarios_Perfil')
                                .doc(uid)
                                .set({
                                  'patoEquipadoId': pato.id,
                                  'usarFotoReal': false,
                                }, SetOptions(merge: true));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '¡Equipaste a ${pato.nombre} como tu avatar! 🦆✨',
                                ),
                                backgroundColor: colorVerdeTese,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  equipado
                                      ? const Color(0xFFE8F5E9)
                                      : colorFondoCrema,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color:
                                    equipado
                                        ? colorVerdeTese
                                        : Colors.grey.shade300,
                                width: equipado ? 2.2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 68,
                                  height: 68,
                                  child: PatoVista(skin: pato, tamano: 68),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  pato.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                                if (equipado)
                                  Text(
                                    'Equipado ✓',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: colorExito,
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
          ),
    );
  }

  void _confirmarCerrarSesion() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Cerrar sesión?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: colorTextoOscuro,
              ),
            ),
            content: Text(
              'Tendrás que volver a ingresar tu cuenta para hacer pedidos.',
              style: GoogleFonts.poppins(fontSize: 13.5, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancelar',
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
                onPressed: () async {
                  Navigator.pop(ctx);
                  await FirebaseAuth.instance.signOut();
                  try {
                    await GoogleSignIn().signOut();
                  } catch (_) {}
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (c) => const DecisionScreen()),
                    (route) => false,
                  );
                },
                child: Text(
                  'Salir',
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

  @override
  Widget build(BuildContext context) {
    final String uid = _usuarioAuth?.uid ?? 'anonimo';

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(uid)
              .snapshots(),
      builder: (context, userSnapshot) {
        String nombreAlumno = _usuarioAuth?.displayName ?? 'Estudiante TESE';
        String matricula = 'Sin matrícula';
        String carrera = 'Ing. en Computación';
        String rol = 'Estudiante';
        String fotoBase64 = '';
        int puntosCompensacion = 0;

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          nombreAlumno = userData['nombre_completo'] ?? nombreAlumno;
          matricula = userData['identificador'] ?? matricula;
          carrera = userData['carrera_area'] ?? carrera;
          rol = userData['rol'] ?? 'Estudiante';
          alergiaActual =
              userData['alergia'] ?? 'Sin restricciones alimentarias 😋';
          fotoBase64 = (userData['fotoBase64'] ?? '').toString();
          puntosCompensacion = (userData['puntosCompensacion'] ?? 0) as int;
        }

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('Pedidos')
                  .where('idAlumno', isEqualTo: uid)
                  .snapshots(),
          builder: (context, pedidosSnapshot) {
            int totalPedidosEntregados = 0;
            double totalGastado = 0.0;
            int puntosGanadosEnPedidos = 0;

            if (pedidosSnapshot.hasData) {
              for (var doc in pedidosSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                int estado = data['estado'] ?? 0;
                if (estado == 3) {
                  totalPedidosEntregados++;
                  totalGastado += (data['total'] ?? 0.0).toDouble();
                  int ptsPedido = data['puntosGanados'] ?? 10;
                  puntosGanadosEnPedidos += ptsPedido;
                }
              }
            }

            return StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Usuarios_Perfil')
                      .doc(uid)
                      .snapshots(),
              builder: (context, perfilSnapshot) {
                String patoEquipadoId = 'estudiante';
                bool usarFotoReal = false;
                Map<String, int> coleccionPatos = {'estudiante': 1};
                int puntosGastados = 0;

                if (perfilSnapshot.hasData && perfilSnapshot.data!.exists) {
                  final pData =
                      perfilSnapshot.data!.data() as Map<String, dynamic>;
                  patoEquipadoId = pData['patoEquipadoId'] ?? 'estudiante';
                  usarFotoReal = pData['usarFotoReal'] == true;
                  puntosGastados = pData['puntosGastadosEnGachapon'] ?? 0;
                  if (pData['coleccionPatos'] != null) {
                    coleccionPatos = Map<String, int>.from(
                      pData['coleccionPatos'],
                    );
                  }
                }

                int puntosDisponibles =
                    (puntosGanadosEnPedidos + puntosCompensacion) -
                    puntosGastados;
                if (puntosDisponibles < 0) puntosDisponibles = 0;

                final PatoSkin patoActual = catalogoPatos.firstWhere(
                  (p) => p.id == patoEquipadoId,
                  orElse: () => catalogoPatos[1],
                );

                final bool mostrarFotoReal =
                    usarFotoReal && fotoBase64.isNotEmpty;

                String nivelComelon = 'Novato del Receso 🍪';
                if (totalPedidosEntregados >= 5) {
                  nivelComelon = 'Comelón Frecuente 🍟';
                }
                if (totalPedidosEntregados >= 15) {
                  nivelComelon = 'Hambreado VIP 🥇';
                }

                return Scaffold(
                  backgroundColor: colorFondoCrema,
                  appBar: AppBar(
                    title: Text(
                      'Mi Perfil TESE',
                      style: GoogleFonts.poppins(
                        color: colorVerdeTese,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    actions: [
                      TextButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          mostrarMiniTutorialTese(
                            context,
                            nombreAlumno.split(' ').first,
                          );
                        },
                        icon: const Icon(
                          Icons.help_outline_rounded,
                          color: colorVerdeTese,
                          size: 18,
                        ),
                        label: Text(
                          'Guía',
                          style: GoogleFonts.poppins(
                            color: colorVerdeTese,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 115),
                    child: Column(
                      children: [
                        FadeInDown(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _mostrarSelectorFotoOPatito(
                                uid,
                                patoEquipadoId,
                                coleccionPatos,
                                fotoBase64,
                                mostrarFotoReal,
                              );
                            },
                            child: Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color:
                                            mostrarFotoReal
                                                ? colorVerdeTese
                                                : patoActual.rareza.color,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorVerdeTese.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child:
                                          mostrarFotoReal
                                              ? Image.memory(
                                                base64Decode(fotoBase64),
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                                errorBuilder:
                                                    (_, __, ___) => PatoVista(
                                                      skin: patoActual,
                                                      tamano: 96,
                                                    ),
                                              )
                                              : Center(
                                                child: PatoVista(
                                                  skin: patoActual,
                                                  tamano: 96,
                                                ),
                                              ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorVerdeTese,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.camera_alt_rounded,
                                          color: colorAmarilloTese,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Foto / Pato',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nombreAlumno,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorTextoOscuro,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          mostrarFotoReal
                              ? 'Foto de credencial activa  •  $nivelComelon'
                              : 'Avatar: ${patoActual.nombre}  •  $nivelComelon',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: colorVerdeTese,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),

                        // CREDENCIAL EN TONO PASTEL ELEGANTE Y SUAVE
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE8F5E9), Color(0xFFD7EFE0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colorVerdeTese.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorVerdeTese.withValues(alpha: 0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorVerdeTese,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'CREDENCIAL • ${rol.toUpperCase()}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: colorVerdeTese,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verificada',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: colorVerdeTese,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  carrera,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Matrícula / ID: $matricula',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: colorVerdeTese,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Divider(
                                  color: colorVerdeTese.withValues(alpha: 0.2),
                                  height: 26,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _ColumnaDatoCredencial(
                                      icono: Icons.stars_rounded,
                                      valor: '$puntosDisponibles pts',
                                      etiqueta: 'Disponibles',
                                      colorIcono: const Color(0xFFF59E0B),
                                    ),
                                    _ColumnaDatoCredencial(
                                      icono: Icons.receipt_long_rounded,
                                      valor: '$totalPedidosEntregados',
                                      etiqueta: 'Entregados',
                                      colorIcono: colorVerdeTese,
                                    ),
                                    _ColumnaDatoCredencial(
                                      icono: Icons.savings_outlined,
                                      valor:
                                          '\$${totalGastado.toStringAsFixed(0)}',
                                      etiqueta: 'Invertido',
                                      colorIcono: colorExito,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        FadeInUp(
                          delay: const Duration(milliseconds: 180),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PantallaGachapon(
                                        puntos: puntosDisponibles,
                                        costoTirada: costoPorHuevo,
                                        coleccionInicial: coleccionPatos,
                                        onPuntosCambian: (_) {
                                          FirebaseFirestore.instance
                                              .collection('Usuarios_Perfil')
                                              .doc(uid)
                                              .set({
                                                'puntosGastadosEnGachapon':
                                                    FieldValue.increment(
                                                      costoPorHuevo,
                                                    ),
                                              }, SetOptions(merge: true));
                                        },
                                        onPatoObtenido: (pato, veces) {
                                          coleccionPatos[pato.id] = veces;
                                          FirebaseFirestore.instance
                                              .collection('Usuarios_Perfil')
                                              .doc(uid)
                                              .set({
                                                'patoEquipadoId': pato.id,
                                                'usarFotoReal': false,
                                                'coleccionPatos':
                                                    coleccionPatos,
                                              }, SetOptions(merge: true));
                                        },
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF3C4),
                                    Color(0xFFFFE082),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorAmarilloTese,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.egg_rounded,
                                    size: 38,
                                    color: colorVerdeOscuro,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Multiverso Gachapón TESE 🦆',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: colorVerdeOscuro,
                                          ),
                                        ),
                                        Text(
                                          'Colección: ${coleccionPatos.length}/${catalogoPatos.length} patitos ($costoPorHuevo pts por cápsula)',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: colorVerdeOscuro.withValues(
                                              alpha: 0.85,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: colorVerdeOscuro,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        FadeInUp(
                          delay: const Duration(milliseconds: 260),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Salud y Personalización',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _TarjetaOpcionPerfil(
                                icono: Icons.medical_information_outlined,
                                titulo: 'Restricción o Alergia Alimentaria',
                                subtitulo: alergiaActual,
                                onTap: () => _cambiarAlergia(uid),
                              ),
                              const SizedBox(height: 10),
                              _TarjetaOpcionPerfil(
                                icono: Icons.camera_enhance_outlined,
                                titulo: 'Cambiar Foto Real o Avatar de Patito',
                                subtitulo:
                                    mostrarFotoReal
                                        ? 'Usando tu foto de cámara/galería'
                                        : 'Usando a ${patoActual.nombre} (${coleccionPatos.length} desbloqueados)',
                                onTap:
                                    () => _mostrarSelectorFotoOPatito(
                                      uid,
                                      patoEquipadoId,
                                      coleccionPatos,
                                      fotoBase64,
                                      mostrarFotoReal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        FadeInUp(
                          delay: const Duration(milliseconds: 350),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.redAccent,
                              ),
                              label: Text(
                                'Cerrar Sesión',
                                style: GoogleFonts.poppins(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: _confirmarCerrarSesion,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ColumnaDatoCredencial extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color colorIcono;

  const _ColumnaDatoCredencial({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: colorIcono, size: 18),
            const SizedBox(width: 4),
            Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: colorTextoOscuro,
              ),
            ),
          ],
        ),
        Text(
          etiqueta,
          style: GoogleFonts.poppins(fontSize: 11, color: colorTextoGris),
        ),
      ],
    );
  }
}

class _TarjetaOpcionPerfil extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _TarjetaOpcionPerfil({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorVerdeTese.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: colorVerdeTese),
        ),
        title: Text(
          titulo,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
            color: colorTextoOscuro,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: colorVerdeTese,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: colorTextoGris,
        ),
      ),
    );
  }
}
