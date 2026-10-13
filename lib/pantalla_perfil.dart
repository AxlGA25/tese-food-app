import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'colores.dart';
import 'pantalla_inicio.dart';
import 'pantalla_gachapon.dart';

class PerfilEstudianteScreen extends StatefulWidget {
  const PerfilEstudianteScreen({super.key});

  @override
  State<PerfilEstudianteScreen> createState() => _PerfilEstudianteScreenState();
}

class _PerfilEstudianteScreenState extends State<PerfilEstudianteScreen> {
  final User? _usuarioAuth = FirebaseAuth.instance.currentUser;
  String _alergiaSeleccionada = 'Sin restricciones alimentarias 😋';

  final List<String> _opcionesAlergias = [
    'Sin restricciones alimentarias 😋',
    'Intolerante a la lactosa 🥛',
    'Alérgico a frutos secos / cacahuates 🥜',
    'Sensible al picante (Cero salsa) 🌶️',
    'Vegetariano (Sin carnes) 🌱',
    'Alérgico al marisco / pescado 🐟',
  ];

  final List<String> _carrerasTese = [
    'Ing. en Sistemas Computacionales',
    'Ing. Informática',
    'Ing. Mecatrónica',
    'Ing. Industrial',
    'Ing. Electrónica',
    'Ing. Mecánica',
    'Ing. Química',
    'Ing. Bioquímica',
    'Ing. en Gestión Empresarial',
    'Ing. Aeronáutica',
    'Lic. en Contaduría Pública',
    'Otra Área / Administrativo',
  ];

  // ✏️ EDITAR NOMBRE, MATRÍCULA Y CARRERA EN VIVO
  void _editarPerfil(
    String uid,
    String nombreActual,
    String matriculaActual,
    String carreraActual,
  ) {
    final TextEditingController nombreCtrl = TextEditingController(
      text: nombreActual,
    );
    final TextEditingController matriculaCtrl = TextEditingController(
      text: matriculaActual == 'Sin Matrícula' ? '' : matriculaActual,
    );
    String carreraElegida =
        _carrerasTese.contains(carreraActual)
            ? carreraActual
            : _carrerasTese[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextModal, setStateModal) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 20,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalizar Perfil Estudiantil',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Actualiza tus datos para tus pedidos en la cafetería.',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: colorTextoGris,
                        ),
                      ),
                      const Divider(height: 20),
                      TextField(
                        controller: nombreCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: colorVerdeTese,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: matriculaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Matrícula del TESE',
                          hintText: 'Ej. 20240001',
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: colorVerdeTese,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: carreraElegida,
                        decoration: InputDecoration(
                          labelText: 'Carrera',
                          prefixIcon: const Icon(
                            Icons.school_outlined,
                            color: colorVerdeTese,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
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
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setStateModal(() => carreraElegida = val!),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorVerdeTese,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('Usuarios')
                                .doc(uid)
                                .set({
                                  'nombre_completo':
                                      nombreCtrl.text.trim().isEmpty
                                          ? nombreActual
                                          : nombreCtrl.text.trim(),
                                  'identificador':
                                      matriculaCtrl.text.trim().isEmpty
                                          ? 'Sin Matrícula'
                                          : matriculaCtrl.text.trim(),
                                  'carrera_area': carreraElegida,
                                }, SetOptions(merge: true));

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '¡Datos del perfil actualizados! 🎓✨',
                                ),
                                backgroundColor: colorExito,
                              ),
                            );
                          },
                          child: Text(
                            'Guardar Datos',
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
                ),
              );
            },
          ),
    );
  }

  void _cambiarAlergia(String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.medical_information_outlined,
                      color: colorVerdeTese,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alergias y Preferencias',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colorTextoOscuro,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Esta información se notificará a la cocina al pedir tus alimentos.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: colorTextoGris,
                  ),
                ),
                const Divider(height: 24),
                ..._opcionesAlergias.map(
                  (opcion) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _alergiaSeleccionada == opcion
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color:
                          _alergiaSeleccionada == opcion
                              ? colorVerdeTese
                              : colorTextoGris,
                    ),
                    title: Text(
                      opcion,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorTextoOscuro,
                      ),
                    ),
                    onTap: () {
                      setState(() => _alergiaSeleccionada = opcion);
                      FirebaseFirestore.instance
                          .collection('Usuarios')
                          .doc(uid)
                          .set({'alergia': opcion}, SetOptions(merge: true));
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _abrirGachapon(
    String uid,
    int puntosDisponibles,
    Map<String, int> coleccionActual,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PantallaGachapon(
              puntos: puntosDisponibles,
              costoTirada: 50,
              coleccionInicial: coleccionActual,
              onPuntosCambian: (puntosRestantes) {
                FirebaseFirestore.instance
                    .collection('Usuarios_Perfil')
                    .doc(uid)
                    .set({
                      'puntosGastadosEnGachapon': FieldValue.increment(
                        puntosDisponibles - puntosRestantes,
                      ),
                    }, SetOptions(merge: true));
              },
              onPatoObtenido: (pato, veces) {
                FirebaseFirestore.instance
                    .collection('Usuarios_Perfil')
                    .doc(uid)
                    .set({
                      'patoEquipadoId': pato.id,
                      'coleccionPatos': {...coleccionActual, pato.id: veces},
                    }, SetOptions(merge: true));
              },
            ),
      ),
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
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
              'Tendrás que volver a ingresar con tu cuenta para pedir comida.',
              style: GoogleFonts.poppins(color: colorTextoGris, fontSize: 13.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(
                    color: colorTextoGris,
                    fontWeight: FontWeight.bold,
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
                  await GoogleSignIn()
                      .signOut(); // Cierra sesión de Google también
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DecisionScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
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
  }

  @override
  Widget build(BuildContext context) {
    final String uid = _usuarioAuth?.uid ?? 'anonimo';
    final String correoAuth = _usuarioAuth?.email ?? 'alumno@tese.edu.mx';

    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Usuarios')
                .doc(uid)
                .snapshots(),
        builder: (context, userSnap) {
          final userData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
          final String nombreReal =
              userData['nombre_completo'] ??
              (_usuarioAuth?.displayName ?? 'Estudiante TESE');
          final String matriculaReal =
              userData['identificador'] ?? 'Sin Matrícula';
          final String carreraReal =
              userData['carrera_area'] ?? 'Ing. en Sistemas Computacionales';
          final String rolReal = userData['rol'] ?? 'Estudiante';
          final String alergiaReal =
              userData['alergia'] ?? _alergiaSeleccionada;

          return StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('Usuarios_Perfil')
                    .doc(uid)
                    .snapshots(),
            builder: (context, gachaSnap) {
              final gachaData =
                  gachaSnap.data?.data() as Map<String, dynamic>? ?? {};
              final String patoEquipadoId =
                  gachaData['patoEquipadoId'] ?? 'estudiante';
              final Map<String, int> coleccionPatos = Map<String, int>.from(
                gachaData['coleccionPatos'] ?? {'estudiante': 1},
              );
              final int puntosGastados =
                  gachaData['puntosGastadosEnGachapon'] ?? 0;

              final PatoSkin patoEquipado = catalogoPatos.firstWhere(
                (p) => p.id == patoEquipadoId,
                orElse: () => catalogoPatos[1],
              );

              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Pedidos')
                        .where('idAlumno', isEqualTo: uid)
                        .snapshots(),
                builder: (context, pedidosSnap) {
                  int totalPedidos = 0;
                  int pedidosSistemas = 0;
                  int pedidosBiblioteca = 0;
                  int pedidosCentral = 0;
                  int puntosGanadosAcumulados = 0;

                  if (pedidosSnap.hasData) {
                    final docs = pedidosSnap.data!.docs;
                    totalPedidos = docs.length;

                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String local = data['local']?.toString() ?? '';
                      final int estado = data['estado'] ?? 0;
                      final int puntosOrden = data['puntosGanados'] ?? 10;

                      if (estado >= 3) {
                        puntosGanadosAcumulados += puntosOrden;
                      }

                      if (local.contains('Sistemas')) {
                        pedidosSistemas++;
                      } else if (local.contains('Biblioteca')) {
                        pedidosBiblioteca++;
                      } else {
                        pedidosCentral++;
                      }
                    }
                  }

                  int puntosDisponibles =
                      puntosGanadosAcumulados - puntosGastados;
                  if (puntosDisponibles < 0) {
                    puntosDisponibles = 0;
                  }

                  String rangoHambreado = 'Novato del Receso 🍪';
                  if (totalPedidos >= 5) {
                    rangoHambreado = 'Comelón Frecuente 🍟';
                  }
                  if (totalPedidos >= 15) {
                    rangoHambreado = 'Hambreado VIP 🥇';
                  }

                  String sucursalFavorita = 'Kiosko Sistemas';
                  if (pedidosBiblioteca > pedidosSistemas &&
                      pedidosBiblioteca > pedidosCentral) {
                    sucursalFavorita = 'Kiosko Biblioteca';
                  } else if (pedidosCentral > pedidosSistemas &&
                      pedidosCentral > pedidosBiblioteca) {
                    sucursalFavorita = 'Cafetería Central';
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    child: Column(
                      children: [
                        FadeInDown(
                          child: Center(
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: patoEquipado.rareza.color,
                                          width: 3.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: patoEquipado.rareza.color
                                                .withValues(alpha: 0.35),
                                            blurRadius: 14,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 52,
                                        backgroundColor: const Color(
                                          0xFF16352E,
                                        ),
                                        child: ClipOval(
                                          child: PatoVista(
                                            skin: patoEquipado,
                                            tamano: 92,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: patoEquipado.rareza.color,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        patoEquipado.rareza.nombre,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: colorVerdeOscuro,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  nombreReal,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: colorVerdeTese,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorVerdeTese.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$rolReal TESE',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colorVerdeTese,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        FadeInUp(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [colorVerdeTese, Color(0xFF1B3D37)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colorVerdeTese.withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Rango Estudiantil',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          rangoHambreado,
                                          style: GoogleFonts.poppins(
                                            color: colorAmarilloTese,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            color: colorAmarilloTese,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '$puntosDisponibles Pts',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.white24,
                                  height: 22,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _itemEstadistica(
                                      'Pedidos',
                                      '$totalPedidos',
                                      Icons.receipt_long,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 32,
                                      color: Colors.white24,
                                    ),
                                    _itemEstadistica(
                                      'Puntos',
                                      '$puntosDisponibles',
                                      Icons.monetization_on_outlined,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 32,
                                      color: Colors.white24,
                                    ),
                                    _itemEstadistica(
                                      'Patitos',
                                      '${coleccionPatos.length}/${catalogoPatos.length}',
                                      Icons.egg_alt,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.egg_alt_rounded,
                                      color: colorVerdeOscuro,
                                      size: 22,
                                    ),
                                    label: Text(
                                      'Gachapón de Patitos 🦆 (Tirar Huevo)',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: colorVerdeOscuro,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorAmarilloTese,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed:
                                        () => _abrirGachapon(
                                          uid,
                                          puntosDisponibles,
                                          coleccionPatos,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: _contenedorTarjeta(
                            titulo: 'Historial por Sucursal',
                            hijos: [
                              _FilaSucursal(
                                icono: Icons.computer,
                                nombre: 'Kiosko Sistemas',
                                pedidos: pedidosSistemas,
                                esFavorito:
                                    sucursalFavorita == 'Kiosko Sistemas',
                              ),
                              const Divider(height: 1),
                              _FilaSucursal(
                                icono: Icons.menu_book,
                                nombre: 'Kiosko Biblioteca',
                                pedidos: pedidosBiblioteca,
                                esFavorito:
                                    sucursalFavorita == 'Kiosko Biblioteca',
                              ),
                              const Divider(height: 1),
                              _FilaSucursal(
                                icono: Icons.storefront,
                                nombre: 'Cafetería Central',
                                pedidos: pedidosCentral,
                                esFavorito:
                                    sucursalFavorita == 'Cafetería Central',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ALERGIAS
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: colorVerdeTese.withValues(alpha: 0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
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
                                    Text(
                                      'Restricciones y Alergias',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colorVerdeTese,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _cambiarAlergia(uid),
                                      child: Text(
                                        'Cambiar',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: colorAmarilloTese,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
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
                                    children: [
                                      const Icon(
                                        Icons.health_and_safety_outlined,
                                        color: colorVerdeTese,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          alergiaReal,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
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
                        ),
                        const SizedBox(height: 18),

                        // 🎓 CREDENCIAL CON BOTÓN EDITAR ✏️
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: colorVerdeTese.withValues(alpha: 0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
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
                                    Text(
                                      'Credencial Institucional TESE',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colorVerdeTese,
                                      ),
                                    ),
                                    InkWell(
                                      onTap:
                                          () => _editarPerfil(
                                            uid,
                                            nombreReal,
                                            matriculaReal,
                                            carreraReal,
                                          ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: colorAmarilloTese,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Editar',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: colorAmarilloTese,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _FilaInfoPerfil(
                                  icono: Icons.badge_outlined,
                                  etiqueta: 'Matrícula',
                                  valor: matriculaReal,
                                ),
                                const Divider(height: 1),
                                _FilaInfoPerfil(
                                  icono: Icons.school_outlined,
                                  etiqueta: 'Carrera',
                                  valor: carreraReal,
                                ),
                                const Divider(height: 1),
                                _FilaInfoPerfil(
                                  icono: Icons.email_outlined,
                                  etiqueta: 'Correo',
                                  valor: correoAuth,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // CERRAR SESIÓN
                        FadeInUp(
                          delay: const Duration(milliseconds: 350),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _confirmarCerrarSesion(context),
                              icon: const Icon(Icons.logout, size: 20),
                              label: Text(
                                'Cerrar Sesión',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
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
    );
  }

  Widget _itemEstadistica(String label, String valor, IconData icono) {
    return Column(
      children: [
        Icon(icono, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          valor,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10.5),
        ),
      ],
    );
  }

  Widget _contenedorTarjeta({
    required String titulo,
    required List<Widget> hijos,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorVerdeTese.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorVerdeTese,
            ),
          ),
          const SizedBox(height: 10),
          ...hijos,
        ],
      ),
    );
  }
}

class _FilaSucursal extends StatelessWidget {
  final IconData icono;
  final String nombre;
  final int pedidos;
  final bool esFavorito;

  const _FilaSucursal({
    required this.icono,
    required this.nombre,
    required this.pedidos,
    required this.esFavorito,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icono, color: colorVerdeTese, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  nombre,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorTextoOscuro,
                  ),
                ),
                if (esFavorito && pedidos > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorAmarilloTese.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Favorito 👑',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: colorVerdeOscuro,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$pedidos pedidos',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: colorTextoGris,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaInfoPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _FilaInfoPerfil({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icono, color: colorVerdeTese, size: 19),
          const SizedBox(width: 10),
          Text(
            etiqueta,
            style: GoogleFonts.poppins(color: colorTextoGris, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: colorTextoOscuro,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
