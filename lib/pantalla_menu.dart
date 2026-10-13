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
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_perfil.dart';
import 'pantalla_pedido.dart';
import 'pantalla_detalle_platillo.dart';
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
  }

  @override
  void dispose() {
    _pedidosSub?.cancel();
    super.dispose();
  }

  void _iniciarVigilanteDePedidos() {
    _pedidosSub = FirebaseFirestore.instance
        .collection('Pedidos')
        .where('alumno', isEqualTo: 'Axel Guerrero')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              final data = change.doc.data() as Map<String, dynamic>? ?? {};
              int estado = data['estado'] ?? 0;
              String idPedido = data['idPedido'] ?? change.doc.id;
              String local = data['local'] ?? 'Cafetería Central';

              if (estado == 1) {
                ServicioNotificaciones.mostrarNotificacion(
                  id: 1,
                  titulo: '🍳 ¡Tu pedido está en preparación!',
                  cuerpo:
                      'Kiosko Sistemas ya comenzó a cocinar tu orden $idPedido.',
                );

                _lanzarAlertaCuac(
                  titulo: '🍳 ¡Están cocinando tu orden!',
                  mensaje:
                      'Tu pedido $idPedido ya se está preparando en $local.',
                  codigoPedido: idPedido,
                  esListo: false,
                );
              } else if (estado == 2) {
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
    setState(() {
      carritoGlobal.add(p);
    });
  }

  void _limpiarCarrito() {
    setState(() {
      carritoGlobal.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      CatalogoEstudianteScreen(
        carrito: carritoGlobal,
        onAgregar: _actualizarCarrito,
      ),
      const MisPedidosScreen(),
      const PerfilEstudianteScreen(),
    ];

    return Scaffold(
      backgroundColor: colorFondoCrema,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
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
          setState(() {
            _indiceActual = index;
          });
        },
      ),
      floatingActionButton:
          _indiceActual == 0
              ? FloatingActionButton.extended(
                backgroundColor: colorAmarilloTese,
                elevation: 6,
                onPressed: () async {
                  if (carritoGlobal.isEmpty) {
                    return;
                  }
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
                },
                icon: Badge(
                  isLabelVisible: carritoGlobal.isNotEmpty,
                  label: Text(
                    carritoGlobal.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: colorExito,
                  child: const Icon(Icons.shopping_cart, color: Colors.white),
                ),
                label: Text(
                  'Ver Pedido',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
    );
  }
}

// ==========================================================
// MIS PEDIDOS
// ==========================================================
class MisPedidosScreen extends StatelessWidget {
  const MisPedidosScreen({super.key});

  void _eliminarPedido(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Eliminar pedido?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Este pedido se quitará de tu historial permanentemente.',
              style: GoogleFonts.poppins(fontSize: 13.5, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  FirebaseFirestore.instance
                      .collection('Pedidos')
                      .doc(docId)
                      .delete();
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      .where('alumno', isEqualTo: 'Axel Guerrero')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: colorVerdeTese),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/esperandoPedido.png', height: 150),
                        const SizedBox(height: 20),
                        Text(
                          'No tienes pedidos activos',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorTextoGris,
                          ),
                        ),
                        Text(
                          'Tus órdenes aparecerán aquí en cuanto pidas.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: colorTextoGris,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final historial = List<DocumentSnapshot>.from(
                  snapshot.data!.docs,
                );
                historial.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final Timestamp? tA = aData['horaLlegada'] as Timestamp?;
                  final Timestamp? tB = bData['horaLlegada'] as Timestamp?;
                  if (tA == null) {
                    return -1;
                  }
                  if (tB == null) {
                    return 1;
                  }
                  return tB.compareTo(tA);
                });

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                                size: 20,
                                              ),
                                              onPressed:
                                                  () => _eliminarPedido(
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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => PantallaResena(
                                                    codigoPedido: idPedido,
                                                  ),
                                            ),
                                          );
                                        },
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

// ==========================================================
// CATÁLOGO DE ESTUDIANTES: BLOQUEO DE PLATILLOS AGOTADOS
// ==========================================================
class CatalogoEstudianteScreen extends StatefulWidget {
  final List<Platillo> carrito;
  final Function(Platillo) onAgregar;
  const CatalogoEstudianteScreen({
    super.key,
    required this.carrito,
    required this.onAgregar,
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
    if (agregado == true) {
      _mostrarAlertaExito(platillo.nombre);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [colorVerdeTese, colorFondoCrema],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 20),
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Text(
                        '¿Dónde comeremos hoy?',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Text(
                        'Selecciona tu kiosco favorito',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 90,
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
                                    size: 28,
                                  ),
                                  const SizedBox(height: 6),
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
              const SizedBox(height: 16),
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
                    hintText: 'Busca tu antojo...',
                    hintStyle: GoogleFonts.poppins(
                      color: colorTextoGris,
                      fontSize: 14,
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
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
              const SizedBox(height: 14),
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
                              Icons.search_off,
                              size: 52,
                              color: colorTextoGris.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'El menú está vacío',
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
                              'No encontramos nada aquí',
                              style: GoogleFonts.poppins(
                                color: colorTextoGris,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      itemCount: platillosFiltrados.length,
                      itemBuilder: (context, index) {
                        final platillo = platillosFiltrados[index];
                        final acento = acentoDeCategoria(platillo.categoria);
                        final bool agotado =
                            platillo.existencias <= 0; // 🚫 DETECCIÓN DE STOCK

                        return FadeInUp(
                          delay: Duration(milliseconds: 60 * index),
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
                                        width: 58,
                                        height: 58,
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
                                                    width: 58,
                                                    height: 58,
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
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          platillo.local,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.5,
                                            color: colorTextoGris,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            if (platillo.calificacion > 0) ...[
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 15,
                                                color: colorAmarilloTese,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${platillo.calificacion.toStringAsFixed(1)} ★',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorTextoOscuro,
                                                ),
                                              ),
                                            ] else ...[
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorExito.withValues(
                                                    alpha: 0.12,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Nuevo ✨',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: colorExito,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.schedule,
                                              size: 12,
                                              color: colorTextoGris,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              platillo.tiempoPrep,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                color: colorTextoGris,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 3,
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
                                            const SizedBox(width: 8),
                                            Text(
                                              '🪙 +${platillo.puntos} pts',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: colorAmarilloTese,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // BOTÓN DE AGREGAR (DESHABILITADO SI ESTÁ AGOTADO)
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
