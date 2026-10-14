import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_perfil.dart';
import 'pantalla_pedido.dart';
import 'pantalla_detalle_platillo.dart';
import 'pantalla_gachapon.dart';
import 'servicio_notificaciones.dart';

const Map<String, Color> colorPorCategoria = {
  'Todos': colorVerdeTese,
  'Desayunos': colorAmarilloTese,
  'Comida': colorVerdeTese,
  'Bebidas': colorSalvia,
  'Postres': colorRosa,
};

Color acentoDeCategoria(String categoria) =>
    colorPorCategoria[categoria] ?? colorVerdeTese;
Color colorTextoSobreAcento(Color fondo) =>
    fondo == colorVerdeTese ? Colors.white : colorVerdeOscuro;

void mostrarMiniTutorialTese(BuildContext context) {
  int paginaActual = 0;
  final PageController pageCtrl = PageController();
  final List<Map<String, dynamic>> pasos = [
    {
      'skin': catalogoPatos[1],
      'titulo': '1. Elige tu Kiosko favorito 🏪',
      'desc':
          'Selecciona entre Cafetería Central, Kiosko Sistemas o Biblioteca. ¡Ves en vivo cuántos platillos quedan disponibles!',
      'tip': 'Tip: Cada orden se pide a un mismo kiosko para que salga rápido.',
      'color': colorVerdeTese,
    },
    {
      'skin': catalogoPatos[4],
      'titulo': '2. Personaliza a tu gusto 🍔',
      'desc':
          '¿Sin cebolla o con extra queso? Toca cualquier platillo y presiona sus ingredientes para cambiarlos entre Normal, Sin o Extra.',
      'tip':
          'Tip: Tus alergias configuradas en Perfil se avisan automático al chef.',
      'color': colorAmarilloTese,
    },
    {
      'skin': catalogoPatos[6],
      'titulo': '3. Espera el ¡CUAC! sin filas 🦆',
      'desc':
          'Quédate en tu salón o en el pasto. Cuando el chef cocine y cuando tu orden esté lista en ventanilla, tu celular sonará ¡CUAC!',
      'tip':
          'Tip: Pagas directo en ventanilla (efectivo o tarjeta) al recoger.',
      'color': colorExito,
    },
    {
      'skin': catalogoPatos[13],
      'titulo': '4. Gana Puntos y Patitos 🥚',
      'desc':
          'Cada compra entregada te da puntos 🪙. Úsalos en tu Perfil para abrir Huevos en el Gachapón y coleccionar los 15 Patitos TESE.',
      'tip': 'Tip: ¡Toca tu foto en Mi Perfil para equiparte cualquier patito!',
      'color': const Color(0xFFA06BFF),
    },
  ];

  showDialog(
    context: context,
    builder:
        (ctx) => StatefulBuilder(
          builder: (contextModal, setStateModal) {
            final paso = pasos[paginaActual];
            final bool esUltimo = paginaActual == pasos.length - 1;
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorVerdeTese.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Guía Rápida • ${paginaActual + 1}/${pasos.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: colorVerdeTese,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close, color: colorTextoGris),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 290,
                      child: PageView.builder(
                        controller: pageCtrl,
                        itemCount: pasos.length,
                        onPageChanged: (i) {
                          HapticFeedback.selectionClick();
                          setStateModal(() => paginaActual = i);
                        },
                        itemBuilder: (_, index) {
                          final item = pasos[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorFondoCrema,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (item['color'] as Color).withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: PatoVista(
                                  skin: item['skin'] as PatoSkin,
                                  tamano: 86,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                item['titulo'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.bold,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['desc'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.8,
                                  color: colorTextoGris,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: colorFondoCrema,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['tip'],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorVerdeTese,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pasos.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: paginaActual == i ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                paginaActual == i
                                    ? (paso['color'] as Color)
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (paginaActual > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed:
                                  () => pageCtrl.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  ),
                              child: Text(
                                'Anterior',
                                style: GoogleFonts.poppins(
                                  color: colorTextoGris,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  esUltimo ? colorAmarilloTese : colorVerdeTese,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              if (!esUltimo) {
                                pageCtrl.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              } else {
                                Navigator.pop(ctx);
                              }
                            },
                            child: Text(
                              esUltimo
                                  ? '¡Entendido, a comer! 😋'
                                  : 'Siguiente ➔',
                              style: GoogleFonts.poppins(
                                color:
                                    esUltimo ? colorVerdeOscuro : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
          },
        ),
  );
}

class NavegacionEstudiante extends StatefulWidget {
  const NavegacionEstudiante({super.key});
  @override
  State<NavegacionEstudiante> createState() => _NavegacionEstudianteState();
}

class _NavegacionEstudianteState extends State<NavegacionEstudiante> {
  int _indiceActual = 0;
  List<Platillo> carritoGlobal = [];
  StreamSubscription<QuerySnapshot>? _pedidosSub;

  @override
  void initState() {
    super.initState();
    ServicioNotificaciones.inicializar();
    _iniciarVigilanteDePedidos();
    _verificarBienvenidaInicial();
  }

  @override
  void dispose() {
    _pedidosSub?.cancel();
    super.dispose();
  }

  Future<void> _verificarBienvenidaInicial() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Usuarios_Perfil')
              .doc(user.uid)
              .get();
      final data = doc.data() ?? {};
      if (data['tutorialVisto'] != true && mounted) {
        await FirebaseFirestore.instance
            .collection('Usuarios_Perfil')
            .doc(user.uid)
            .set({'tutorialVisto': true}, SetOptions(merge: true));
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) mostrarMiniTutorialTese(context);
        });
      }
    } catch (_) {}
  }

  void _iniciarVigilanteDePedidos() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _pedidosSub = FirebaseFirestore.instance
        .collection('Pedidos')
        .where('idAlumno', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            final data = change.doc.data() as Map<String, dynamic>? ?? {};
            int estado = data['estado'] ?? 0;
            String idPedido = data['idPedido'] ?? change.doc.id;
            String local = data['local'] ?? 'Cafetería Central';

            if (estado < 2) {
              ServicioNotificaciones.iniciarMonitoreoOrden(idPedido);
            }

            if (change.type == DocumentChangeType.modified) {
              if (estado == 1) {
                ServicioNotificaciones.mostrarNotificacion(
                  id: 1,
                  titulo: '🍳 ¡Tu pedido está en preparación!',
                  cuerpo: '$local ya comenzó a cocinar tu orden $idPedido.',
                );
                _lanzarAlertaCuac(
                  titulo: '🍳 ¡Están cocinando tu orden!',
                  mensaje:
                      'Tu pedido $idPedido ya se está preparando en $local.',
                  codigoPedido: idPedido,
                  esListo: false,
                );
              } else if (estado == 2) {
                ServicioNotificaciones.cancelarMonitoreo();
                ServicioNotificaciones.mostrarNotificacion(
                  id: 2,
                  titulo: '🦆 ¡CUAC! Tu comida está lista',
                  cuerpo:
                      'Pasa a recoger tu orden $idPedido a la ventanilla de $local.',
                );
                _lanzarAlertaCuac(
                  titulo: '🦆 ¡CUAC! ¡Tu comida está lista!',
                  mensaje:
                      'Pasa a recoger tu orden $idPedido a la ventanilla de $local.',
                  codigoPedido: idPedido,
                  esListo: true,
                );
              } else if (estado >= 3) {
                ServicioNotificaciones.cancelarMonitoreo();
              }
            }
          }
        });
  }

  void _lanzarAlertaCuac({
    required String titulo,
    required String mensaje,
    required String codigoPedido,
    required bool esListo,
  }) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    try {
      reproductorGlobal.play(AssetSource('cuac.mp3'), volume: 1.0);
    } catch (_) {
      try {
        reproductorGlobal.play(AssetSource('exito.mp3'), volume: 1.0);
      } catch (_) {}
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 160,
          left: 16,
          right: 16,
        ),
        backgroundColor: esListo ? colorExito : colorVerdeTese,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 5),
        content: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SalaEsperaScreen(codigoPedido: codigoPedido),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  esListo ? '🦆' : '🍳',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      mensaje,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 11.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _actualizarCarrito(Platillo p) {
    if (carritoGlobal.isNotEmpty && carritoGlobal.first.local != p.local) {
      final String localActual = carritoGlobal.first.local;
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.storefront,
                    color: colorAmarilloTese,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¿Cambiar de Kiosko?',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                'En tu carrito tienes alimentos de "$localActual".\n\nPara que tu orden se cocine sin confusiones, cada pedido es por kiosko. ¿Quieres vaciar tu carrito actual y pedir "${p.nombre}" en ${p.local}?',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: colorTextoOscuro,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Conservar actual',
                    style: GoogleFonts.poppins(
                      color: colorTextoGris,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorVerdeTese,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      carritoGlobal
                        ..clear()
                        ..add(p);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '¡Listo! Iniciaste un nuevo carrito en ${p.local} 😋',
                        ),
                        backgroundColor: colorExito,
                      ),
                    );
                  },
                  child: Text(
                    'Sí, cambiar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      );
      return;
    }
    setState(() => carritoGlobal.add(p));
  }

  void _limpiarCarrito() => setState(() => carritoGlobal.clear());

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      CatalogoEstudianteScreen(
        carrito: carritoGlobal,
        onAgregar: _actualizarCarrito,
        onIrAPedidos: () => setState(() => _indiceActual = 1),
        onIrAPerfil: () => setState(() => _indiceActual = 2),
      ),
      const MisPedidosScreen(),
      const PerfilEstudianteScreen(),
    ];

    final double totalCarrito = carritoGlobal.fold(
      0,
      (sum, item) => sum + item.precio,
    );

    return Scaffold(
      backgroundColor: colorFondoCrema,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
        child: KeyedSubtree(
          key: ValueKey<int>(_indiceActual),
          child: pantallas[_indiceActual],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _indiceActual,
        height: 58,
        backgroundColor: Colors.transparent,
        color: colorVerdeTese,
        buttonBackgroundColor: colorAmarilloTese,
        animationDuration: const Duration(milliseconds: 400),
        animationCurve: Curves.easeOutBack,
        items: [
          Icon(
            Icons.fastfood,
            size: 26,
            color: _indiceActual == 0 ? colorVerdeOscuro : Colors.white,
          ),
          Icon(
            Icons.receipt_long,
            size: 26,
            color: _indiceActual == 1 ? colorVerdeOscuro : Colors.white,
          ),
          Icon(
            Icons.person,
            size: 26,
            color: _indiceActual == 2 ? colorVerdeOscuro : Colors.white,
          ),
        ],
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _indiceActual = index);
        },
      ),
      floatingActionButton:
          (_indiceActual == 0 && carritoGlobal.isNotEmpty)
              ? ZoomIn(
                child: FloatingActionButton.extended(
                  backgroundColor: colorAmarilloTese,
                  elevation: 8,
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CarritoScreen(
                              carrito: carritoGlobal,
                              onVaciar: _limpiarCarrito,
                            ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  icon: Badge(
                    label: Text(
                      carritoGlobal.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: colorExito,
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: colorVerdeOscuro,
                    ),
                  ),
                  label: Text(
                    'Ver Pedido • \$${totalCarrito.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: colorVerdeOscuro,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
              : null,
    );
  }
}

class MisPedidosScreen extends StatelessWidget {
  const MisPedidosScreen({super.key});

  void _ocultarPedidoDeHistorial(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Quitar del historial?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Se limpiará de esta vista, pero conservarás intactos los puntos 🪙 y tu rango ganados con esta compra.',
              style: GoogleFonts.poppins(fontSize: 13.5, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerdeTese,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  FirebaseFirestore.instance
                      .collection('Pedidos')
                      .doc(docId)
                      .update({'ocultoParaAlumno': true});
                },
                child: const Text(
                  'Limpiar de la lista',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? 'anonimo';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Pedidos',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorVerdeTese.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'En tiempo real',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorVerdeTese,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Pedidos')
                      .where('idAlumno', isEqualTo: uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: colorVerdeTese),
                  );
                }

                final todosDocs = snapshot.data?.docs ?? [];
                final historial =
                    todosDocs
                        .where(
                          (d) =>
                              (d.data()
                                  as Map<
                                    String,
                                    dynamic
                                  >)['ocultoParaAlumno'] !=
                              true,
                        )
                        .toList();

                if (historial.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/esperandoPedido.png',
                            height: 150,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No tienes pedidos en lista',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorTextoOscuro,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Explora el menú, personaliza tu antojo y recógelo en ventanilla sin hacer fila.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: colorTextoGris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                historial.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final Timestamp? tA = aData['horaLlegada'] as Timestamp?;
                  final Timestamp? tB = bData['horaLlegada'] as Timestamp?;
                  if (tA == null) return -1;
                  if (tB == null) return 1;
                  return tB.compareTo(tA);
                });

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final pedido = historial[index];
                    final data = pedido.data() as Map<String, dynamic>;

                    int estadoReal = data['estado'] ?? 0;
                    String idPedido = data['idPedido'] ?? '#TESE-0000';
                    String local = data['local'] ?? 'Cafetería Central';
                    String detalle = data['detalle'] ?? '';
                    String metodoPago = data['metodoPago'] ?? 'Efectivo';
                    double total = (data['total'] ?? 0).toDouble();
                    int puntos = data['puntosGanados'] ?? 10;
                    bool yaCalificado = data['calificado'] ?? false;

                    Color colorEstado = Colors.grey[400]!;
                    String textoEstado = 'Recibido';
                    IconData iconoEstado = Icons.access_time;

                    if (estadoReal == 1) {
                      colorEstado = colorAmarilloTese;
                      textoEstado = 'Preparando';
                      iconoEstado = Icons.soup_kitchen;
                    } else if (estadoReal == 2) {
                      colorEstado = colorExito;
                      textoEstado = '¡Listo!';
                      iconoEstado = Icons.check_circle;
                    } else if (estadoReal >= 3) {
                      colorEstado = colorTextoGris;
                      textoEstado = 'Entregado';
                      iconoEstado = Icons.task_alt;
                    }

                    return FadeInUp(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: colorVerdeTese.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: colorEstado.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SalaEsperaScreen(
                                        codigoPedido: idPedido,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        idPedido,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: colorVerdeTese,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorEstado.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  iconoEstado,
                                                  size: 14,
                                                  color: colorEstado,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  textoEstado,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: colorEstado,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (estadoReal >= 3) ...[
                                            const SizedBox(width: 4),
                                            IconButton(
                                              tooltip: 'Limpiar de la vista',
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                                size: 20,
                                              ),
                                              onPressed:
                                                  () =>
                                                      _ocultarPedidoDeHistorial(
                                                        context,
                                                        pedido.id,
                                                      ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.redAccent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Recoger en: $local',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: colorTextoOscuro,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorAmarilloTese.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '🪙 +$puntos pts',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: colorVerdeOscuro,
                                          ),
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
                                    child: Text(
                                      detalle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        color: colorTextoOscuro,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Pago con $metodoPago',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          color: colorTextoGris,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '\$${total.toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: colorVerdeTese,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((estadoReal == 2 || estadoReal == 3) &&
                                      !yaCalificado) ...[
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: colorAmarilloTese,
                                          side: const BorderSide(
                                            color: colorAmarilloTese,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.star, size: 16),
                                        label: Text(
                                          'Calificar comida',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        onPressed:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => PantallaResena(
                                                      codigoPedido: idPedido,
                                                    ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                  const Divider(height: 20),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.touch_app,
                                          size: 14,
                                          color: colorVerdeTese.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Toca para ver el seguimiento en vivo y ticket',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: colorVerdeTese,
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogoEstudianteScreen extends StatefulWidget {
  final List<Platillo> carrito;
  final Function(Platillo) onAgregar;
  final VoidCallback? onIrAPedidos;
  final VoidCallback? onIrAPerfil;

  const CatalogoEstudianteScreen({
    super.key,
    required this.carrito,
    required this.onAgregar,
    this.onIrAPedidos,
    this.onIrAPerfil,
  });

  @override
  State<CatalogoEstudianteScreen> createState() =>
      _CatalogoEstudianteScreenState();
}

class _CatalogoEstudianteScreenState extends State<CatalogoEstudianteScreen> {
  final List<String> _categorias = const [
    'Todos',
    'Desayunos',
    'Comida',
    'Bebidas',
    'Postres',
  ];
  final List<String> _locales = const [
    'Todos',
    'Cafetería Central',
    'Kiosko Sistemas',
    'Kiosko Biblioteca',
  ];
  String _categoriaSeleccionada = 'Todos';
  String _localSeleccionado = 'Todos';
  final TextEditingController _busquedaCtrl = TextEditingController();
  String _terminoBusqueda = '';

  String _saludoSegunHora() {
    final hora = DateTime.now().hour;
    if (hora < 12) return '¡Buenos días';
    if (hora < 19) return '¡Buenas tardes';
    return '¡Buenas noches';
  }

  List<Platillo> _filtrarLista(List<Platillo> menuDisponibles) {
    return menuDisponibles.where((p) {
      final coincideCategoria =
          _categoriaSeleccionada == 'Todos' ||
          p.categoria == _categoriaSeleccionada;
      final coincideLocal =
          _localSeleccionado == 'Todos' || p.local == _localSeleccionado;
      final coincideBusqueda =
          _terminoBusqueda.isEmpty ||
          p.nombre.toLowerCase().contains(_terminoBusqueda.toLowerCase());
      return coincideCategoria && coincideLocal && coincideBusqueda;
    }).toList();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _mostrarAlertaExito(String nombre) {
    HapticFeedback.lightImpact();
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: '¡Añadido!',
        message: 'Has agregado $nombre a tu carrito 😋',
        contentType: ContentType.success,
        color: colorExito,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _abrirDetalle(Platillo platillo) async {
    HapticFeedback.selectionClick();
    final agregado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => PantallaDetallePlatillo(
              platillo: platillo,
              onAgregar: widget.onAgregar,
            ),
      ),
    );
    if (agregado == true && mounted) {
      _mostrarAlertaExito(platillo.nombre);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? 'anonimo';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [colorVerdeTese, colorFondoCrema],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.38],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: colorVerdeTese,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeTese.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Usuarios')
                                .doc(uid)
                                .snapshots(),
                        builder: (context, userSnap) {
                          final uData =
                              userSnap.data?.data() as Map<String, dynamic>? ??
                              {};
                          final String nombreCompleto =
                              uData['nombre_completo'] ??
                              (user?.displayName ?? 'Estudiante');
                          final String primerNombre =
                              nombreCompleto.split(' ').first;

                          return Row(
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('Usuarios_Perfil')
                                        .doc(uid)
                                        .snapshots(),
                                builder: (context, pSnap) {
                                  final pData =
                                      pSnap.data?.data()
                                          as Map<String, dynamic>? ??
                                      {};
                                  final String patoId =
                                      pData['patoEquipadoId'] ?? 'estudiante';
                                  final PatoSkin skin = catalogoPatos
                                      .firstWhere(
                                        (s) => s.id == patoId,
                                        orElse: () => catalogoPatos[1],
                                      );
                                  return GestureDetector(
                                    onTap: widget.onIrAPerfil,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorAmarilloTese,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: colorVerdeOscuro,
                                        child: ClipOval(
                                          child: PatoVista(
                                            skin: skin,
                                            tamano: 38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_saludoSegunHora()}, $primerNombre! 👋',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '¿Dónde comeremos hoy sin hacer fila?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  mostrarMiniTutorialTese(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.help_outline_rounded,
                                        color: colorAmarilloTese,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Guía',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 86,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _locales.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final local = _locales[index];
                          final seleccionada = local == _localSeleccionado;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _localSeleccionado = local);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 95,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    seleccionada
                                        ? colorAmarilloTese
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow:
                                    seleccionada
                                        ? [
                                          BoxShadow(
                                            color: colorAmarilloTese.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    local == 'Todos'
                                        ? Icons.map
                                        : Icons.storefront,
                                    color:
                                        seleccionada
                                            ? colorVerdeOscuro
                                            : colorVerdeTese,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    local,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          seleccionada
                                              ? colorVerdeOscuro
                                              : colorTextoOscuro,
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
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Pedidos')
                        .where('idAlumno', isEqualTo: uid)
                        .snapshots(),
                builder: (context, pedSnap) {
                  if (!pedSnap.hasData) return const SizedBox.shrink();
                  final activos =
                      pedSnap.data!.docs
                          .where(
                            (d) =>
                                (((d.data() as Map)['estado'] ?? 0) as int) < 3,
                          )
                          .toList();
                  if (activos.isEmpty) return const SizedBox.shrink();

                  final docActivo = activos.first;
                  final data = docActivo.data() as Map<String, dynamic>;
                  final int estado = data['estado'] ?? 0;
                  final String codigo = data['idPedido'] ?? docActivo.id;
                  final String local = data['local'] ?? 'Kiosko';

                  final String textoBanner =
                      estado == 0
                          ? '⏳ Tu orden $codigo fue enviada a $local'
                          : (estado == 1
                              ? '🍳 ¡Están cocinando tu orden $codigo en $local!'
                              : '🦆 ¡CUAC! Tu orden $codigo está LISTA en $local');
                  final Color colorBanner =
                      estado == 2 ? colorExito : colorAmarilloTese;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => SalaEsperaScreen(codigoPedido: codigo),
                            ),
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorBanner,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorBanner.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                textoBanner,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      estado == 2
                                          ? Colors.white
                                          : colorVerdeOscuro,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color:
                                  estado == 2 ? Colors.white : colorVerdeOscuro,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _busquedaCtrl,
                  onChanged:
                      (valor) => setState(() => _terminoBusqueda = valor),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorTextoOscuro,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Busca chilaquiles, tortas, café...',
                    hintStyle: GoogleFonts.poppins(
                      color: colorTextoGris,
                      fontSize: 13.5,
                    ),
                    prefixIcon: const Icon(Icons.search, color: colorVerdeTese),
                    suffixIcon:
                        _terminoBusqueda.isEmpty
                            ? null
                            : IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: colorTextoGris,
                                size: 18,
                              ),
                              onPressed: () {
                                _busquedaCtrl.clear();
                                setState(() => _terminoBusqueda = '');
                              },
                            ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categorias.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];
                    final seleccionada = categoria == _categoriaSeleccionada;
                    final acento = acentoDeCategoria(categoria);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _categoriaSeleccionada = categoria);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: seleccionada ? acento : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                seleccionada
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          categoria,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                seleccionada
                                    ? colorTextoSobreAcento(acento)
                                    : colorTextoGris,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Menu_Platillos')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: colorVerdeTese),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error al cargar el menú',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 52,
                              color: colorTextoGris.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'El menú está vacío por ahora',
                              style: GoogleFonts.poppins(
                                color: colorTextoGris,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    List<Platillo> menuDisponibles =
                        snapshot.data!.docs
                            .map((doc) => Platillo.fromFirestore(doc))
                            .toList();
                    List<Platillo> platillosFiltrados = _filtrarLista(
                      menuDisponibles,
                    );

                    if (platillosFiltrados.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 52,
                              color: colorTextoGris.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No encontramos platillos con ese filtro',
                              style: GoogleFonts.poppins(
                                color: colorTextoGris,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _busquedaCtrl.clear();
                                setState(() {
                                  _terminoBusqueda = '';
                                  _categoriaSeleccionada = 'Todos';
                                  _localSeleccionado = 'Todos';
                                });
                              },
                              child: Text(
                                'Ver todo el menú',
                                style: GoogleFonts.poppins(
                                  color: colorVerdeTese,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 95),
                      itemCount: platillosFiltrados.length,
                      itemBuilder: (context, index) {
                        final platillo = platillosFiltrados[index];
                        final acento = acentoDeCategoria(platillo.categoria);
                        final bool agotado = platillo.existencias <= 0;
                        final bool pocasPiezas =
                            platillo.existencias > 0 &&
                            platillo.existencias <= 5;

                        return FadeInUp(
                          delay: Duration(milliseconds: 50 * index),
                          child: GestureDetector(
                            onTap: () => _abrirDetalle(platillo),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorVerdeTese.withValues(
                                      alpha: 0.07,
                                    ),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 62,
                                        height: 62,
                                        decoration: BoxDecoration(
                                          color:
                                              agotado
                                                  ? Colors.grey.withValues(
                                                    alpha: 0.15,
                                                  )
                                                  : acento.withValues(
                                                    alpha: 0.16,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child:
                                              platillo.fotos.isNotEmpty
                                                  ? Image.memory(
                                                    base64Decode(
                                                      platillo.fotos.first,
                                                    ),
                                                    width: 62,
                                                    height: 62,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) => Center(
                                                          child: Icon(
                                                            platillo.icono,
                                                            color:
                                                                colorTextoOscuro,
                                                            size: 28,
                                                          ),
                                                        ),
                                                  )
                                                  : Center(
                                                    child: Icon(
                                                      platillo.icono,
                                                      color: colorTextoOscuro,
                                                      size: 28,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      if (platillo.popular && !agotado)
                                        Positioned(
                                          top: -6,
                                          left: -6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorAmarilloTese,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Text(
                                              '🔥',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                platillo.nombre,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15.5,
                                                  color:
                                                      agotado
                                                          ? colorTextoGris
                                                          : colorTextoOscuro,
                                                  decoration:
                                                      agotado
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null,
                                                ),
                                              ),
                                            ),
                                            if (agotado) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Agotado',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ),
                                            ] else if (pocasPiezas) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Quedan ${platillo.existencias}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepOrange,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          platillo.local,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: colorTextoGris,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: acento.withValues(
                                                  alpha: 0.16,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                '\$${platillo.precio.toInt()}',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  color: colorTextoOscuro,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '🪙 +${platillo.puntos} pts',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: colorVerdeTese,
                                              ),
                                            ),
                                            if (platillo.calificacion > 0)
                                              Text(
                                                '⭐ ${platillo.calificacion.toStringAsFixed(1)}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorTextoOscuro,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      agotado ? Icons.block : Icons.add_circle,
                                      color:
                                          agotado
                                              ? Colors.grey[400]
                                              : colorAmarilloTese,
                                      size: 36,
                                    ),
                                    onPressed:
                                        agotado
                                            ? () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Este platillo se encuentra agotado por el momento. 🚫',
                                                  ),
                                                ),
                                              );
                                            }
                                            : () {
                                              widget.onAgregar(platillo);
                                              _mostrarAlertaExito(
                                                platillo.nombre,
                                              );
                                            },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
}
