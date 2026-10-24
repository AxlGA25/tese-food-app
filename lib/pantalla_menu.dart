import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_detalle_platillo.dart';
import 'pantalla_pedido.dart';
import 'pantalla_perfil.dart';
import 'pantalla_gachapon.dart';
import 'pantalla_login.dart';
import 'servicio_notificaciones.dart';

// ==========================================================
// FUNCIONES DE COLOR POR CATEGORÍA (COMPARTIDAS CON DETALLE)
// ==========================================================
Color acentoDeCategoria(String categoria) {
  switch (categoria) {
    case 'Desayunos':
      return const Color(0xFFF59E0B);
    case 'Comida':
      return colorVerdeTese;
    case 'Bebidas':
      return const Color(0xFF0284C7);
    case 'Postres':
      return const Color(0xFFEC4899);
    default:
      return colorVerdeTese;
  }
}

Color fondoPastelDeCategoria(String categoria) {
  switch (categoria) {
    case 'Desayunos':
      return const Color(0xFFFFF6D6);
    case 'Comida':
      return const Color(0xFFE6F6EC);
    case 'Bebidas':
      return const Color(0xFFE0F2FE);
    case 'Postres':
      return const Color(0xFFFCE7F3);
    default:
      return const Color(0xFFE8F5E9);
  }
}

Color colorTextoSobreAcento(dynamic entrada) {
  if (entrada is Color) {
    return entrada.computeLuminance() > 0.55 ? colorVerdeOscuro : Colors.white;
  }
  if (entrada == 'Desayunos') return colorVerdeOscuro;
  return Colors.white;
}

// ==========================================================
// GUÍA RÁPIDA INTERACTIVA PARA ESTUDIANTES (ONBOARDING)
// ==========================================================
void mostrarMiniTutorialTese(BuildContext context, String primerNombre) {
  int paginaActual = 0;
  final PageController pageCtrl = PageController();

  final List<Map<String, dynamic>> pasos = [
    {
      'badge': 'PASO 1 DE 4 • BIENVENIDA',
      'titulo': '¡Hola, $primerNombre! 🦆✨',
      'descripcion':
          'Con TESE Hambreados puedes pedir tus alimentos desde el salón o laboratorio y pasar directo a ventanilla sin hacer fila en el receso.',
      'skinId': 'estudiante',
      'color': colorVerdeTese,
    },
    {
      'badge': 'PASO 2 DE 4 • PERSONALIZA',
      'titulo': 'Elige tu Kiosko y Platillo 🍔',
      'descripcion':
          'Toca las tarjetas con el icono de tu sucursal favorita (Sistemas, Biblioteca o Cafetería Central), personaliza ingredientes y revisa el stock.',
      'skinId': 'chef',
      'color': const Color(0xFFFF8F00),
    },
    {
      'badge': 'PASO 3 DE 4 • ALERTA ¡CUAC!',
      'titulo': 'Seguimiento por Etapas 🔔',
      'descripcion':
          'Mira en vivo cómo avanza tu orden. Cuando esté lista para recoger, tu celular vibrará y sonará un ¡CUAC! Muestra tu código #TESE en ventanilla.',
      'skinId': 'rockstar_rosa',
      'color': const Color(0xFF00B4D8),
    },
    {
      'badge': 'PASO 4 DE 4 • MULTIVERSO GACHAPÓN',
      'titulo': 'Equipa tus Patitos en el Menú 🪙🎰',
      'descripcion':
          'Cada pedido entregado suma puntos para abrir cápsulas en el Gachapón. ¡Toca tu patito arriba a la izquierda en el menú para cambiar de compañero cuando quieras!',
      'skinId': 'oro',
      'color': const Color(0xFF8E24AA),
    },
  ];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (ctx) => StatefulBuilder(
          builder: (contextModal, setStateModal) {
            final paso = pasos[paginaActual];
            final Color colorTema = paso['color'] as Color;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: colorTema.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
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
                            color: colorTema.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            paso['badge'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colorTema,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Saltar',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorTextoGris,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 295,
                      child: PageView.builder(
                        controller: pageCtrl,
                        itemCount: pasos.length,
                        onPageChanged: (idx) {
                          HapticFeedback.selectionClick();
                          setStateModal(() => paginaActual = idx);
                        },
                        itemBuilder: (_, index) {
                          final item = pasos[index];
                          final PatoSkin skin = catalogoPatos.firstWhere(
                            (p) => p.id == item['skinId'],
                            orElse: () => catalogoPatos[1],
                          );
                          final Color cItem = item['color'] as Color;

                          return SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8),
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cItem.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: cItem.withValues(alpha: 0.35),
                                      width: 2,
                                    ),
                                  ),
                                  child: PatoVista(skin: skin, tamano: 94),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  item['titulo'] as String,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    item['descripcion'] as String,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: colorTextoGris,
                                      height: 1.42,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pasos.length, (i) {
                        final bool activo = i == paginaActual;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: activo ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: activo ? colorTema : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorTema,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          if (paginaActual < pasos.length - 1) {
                            pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          } else {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(ctx);
                          }
                        },
                        icon: Icon(
                          paginaActual < pasos.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.check_circle_outline,
                          size: 18,
                        ),
                        label: Text(
                          paginaActual < pasos.length - 1
                              ? 'Siguiente'
                              : '¡Empezar a pedir! 🍔',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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

// ==========================================================
// CONTENEDOR PRINCIPAL DEL ESTUDIANTE + MONITOREO DE RED
// ==========================================================
class NavegacionEstudiante extends StatefulWidget {
  const NavegacionEstudiante({super.key});

  @override
  State<NavegacionEstudiante> createState() => _NavegacionEstudianteState();
}

class _NavegacionEstudianteState extends State<NavegacionEstudiante> {
  int _indiceActual = 0;
  final List<Platillo> _carritoGlobal = [];

  final AudioPlayer _audioNotif = AudioPlayer();
  StreamSubscription<QuerySnapshot>? _subPedidos;
  Timer? _timerConexion;
  bool _conectadoAInternet = true;

  final Map<String, int> _ultimosEstadosConocidos = {};
  bool _primeraCargaLista = false;

  @override
  void initState() {
    super.initState();
    _iniciarMonitoreoInternet();
    _iniciarVigilanteDePedidos();
  }

  void _iniciarMonitoreoInternet() {
    _checarRedAhora();
    _timerConexion = Timer.periodic(const Duration(seconds: 6), (_) {
      _checarRedAhora();
    });
  }

  Future<void> _checarRedAhora() async {
    final ok = await verificarConexionInternet();
    if (mounted && ok != _conectadoAInternet) {
      setState(() => _conectadoAInternet = ok);
    }
  }

  void _iniciarVigilanteDePedidos() {
    ServicioNotificaciones.inicializar();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subPedidos = FirebaseFirestore.instance
        .collection('Pedidos')
        .where('idAlumno', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) async {
          // En la primera carga solo registramos el estado actual de cada pedido
          if (!_primeraCargaLista) {
            for (var doc in snapshot.docs) {
              final data = doc.data();
              _ultimosEstadosConocidos[doc.id] = (data['estado'] ?? 0) as int;
            }
            _primeraCargaLista = true;
            return;
          }

          for (var doc in snapshot.docs) {
            // Si el cambio aún no viene confirmado del servidor y estamos sin red, esperamos
            if (!_conectadoAInternet && doc.metadata.hasPendingWrites) continue;

            final data = doc.data();
            final int nuevoEstado = (data['estado'] ?? 0) as int;
            final String codigo = (data['idPedido'] ?? '#TESE').toString();
            final String local = (data['local'] ?? 'Cafetería').toString();

            // Si es un pedido recién creado en esta sesión, su estado base es 0
            final int estadoAnterior = _ultimosEstadosConocidos[doc.id] ?? 0;
            _ultimosEstadosConocidos[doc.id] = nuevoEstado;

            if (estadoAnterior != nuevoEstado) {
              if (nuevoEstado == 1) {
                await ServicioNotificaciones.mostrarNotificacionOrden(
                  id: doc.id.hashCode,
                  titulo: '🍳 Tu orden $codigo entró a cocina',
                  cuerpo: '$local ya está preparando tus alimentos.',
                  enCurso: true,
                  esPedidoListo: false,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🍳 ¡Tu orden $codigo ya se está cocinando en $local!',
                      ),
                      backgroundColor: Colors.orange.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else if (nuevoEstado == 2) {
                await ServicioNotificaciones.mostrarNotificacionOrden(
                  id: doc.id.hashCode,
                  titulo: '🦆 ¡CUAC! ¡Tu pedido $codigo está LISTO!',
                  cuerpo:
                      'Pasa a la ventanilla de $local a recoger tus alimentos.',
                  enCurso: false,
                  esPedidoListo: true,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🦆🔔 ¡CUAC! ¡Tu orden $codigo está LISTA en $local!',
                      ),
                      backgroundColor: colorExito,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } else if (nuevoEstado == 3) {
                await ServicioNotificaciones.mostrarNotificacionOrden(
                  id: doc.id.hashCode,
                  titulo: 'Pedido $codigo entregado',
                  cuerpo:
                      '¡Buen provecho! Tus puntos ya están en tu credencial TESE.',
                  enCurso: false,
                  esPedidoListo: false,
                );
              } else if (nuevoEstado == 4) {
                final String motivo =
                    (data['motivoCancelacion'] ?? 'Revisa tu historial')
                        .toString();
                await ServicioNotificaciones.mostrarNotificacionOrden(
                  id: doc.id.hashCode,
                  titulo: 'Tu pedido $codigo fue cancelado',
                  cuerpo: '$local: $motivo',
                  enCurso: false,
                  esPedidoListo: false,
                );
              }
            }
          }
        });
  }

  @override
  void dispose() {
    _subPedidos?.cancel();
    _timerConexion?.cancel();
    _audioNotif.dispose();
    super.dispose();
  }

  bool _intentarAgregarAlCarrito(Platillo platillo, int cantidad) {
    if (_carritoGlobal.isNotEmpty) {
      final String sucursalActual = _carritoGlobal.first.local;
      if (platillo.local != sucursalActual) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Tu carrito ya tiene productos de "$sucursalActual". Termina o vacía ese pedido antes de pedir en "${platillo.local}".',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            backgroundColor: Colors.orange.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    }

    final int yaEnCarrito =
        _carritoGlobal.where((p) => p.id == platillo.id).length;
    if (yaEnCarrito + cantidad > platillo.existencias) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo quedan ${platillo.existencias} disponibles de ${platillo.nombre}.',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    setState(() {
      for (int i = 0; i < cantidad; i++) {
        _carritoGlobal.add(platillo);
      }
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      extendBody: true,
      body: Column(
        children: [
          if (!_conectadoAInternet)
            SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                color: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No tienes conexión a Internet. Conéctate a una red.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _checarRedAhora,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Reintentar',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _indiceActual,
              children: [
                MenuEstudianteScreen(
                  carrito: _carritoGlobal,
                  onAgregarPlatillo: _intentarAgregarAlCarrito,
                  onActualizarUI: () => setState(() {}),
                ),
                MisPedidosEstudianteScreen(
                  carritoGlobal: _carritoGlobal,
                  onIrAlCarrito: () {
                    setState(() => _indiceActual = 0);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarritoScreen(carrito: _carritoGlobal),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
                const PerfilEstudianteScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _indiceActual,
        height: 60,
        backgroundColor: Colors.transparent,
        color: colorVerdeTese,
        buttonBackgroundColor: colorAmarilloTese,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (idx) {
          HapticFeedback.selectionClick();
          setState(() => _indiceActual = idx);
        },
        items: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 26,
            color: _indiceActual == 0 ? colorVerdeOscuro : Colors.white,
          ),
          Icon(
            Icons.receipt_long_rounded,
            size: 26,
            color: _indiceActual == 1 ? colorVerdeOscuro : Colors.white,
          ),
          Icon(
            Icons.person_rounded,
            size: 26,
            color: _indiceActual == 2 ? colorVerdeOscuro : Colors.white,
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// 1. CATÁLOGO CON PATITO GACHAPÓN INTERACTIVO Y TONOS PASTELES
// ==========================================================
class MenuEstudianteScreen extends StatefulWidget {
  final List<Platillo> carrito;
  final bool Function(Platillo platillo, int cantidad) onAgregarPlatillo;
  final VoidCallback onActualizarUI;

  const MenuEstudianteScreen({
    super.key,
    required this.carrito,
    required this.onAgregarPlatillo,
    required this.onActualizarUI,
  });

  @override
  State<MenuEstudianteScreen> createState() => _MenuEstudianteScreenState();
}

class _MenuEstudianteScreenState extends State<MenuEstudianteScreen>
    with SingleTickerProviderStateMixin {
  String localSeleccionado = 'Todos';
  String categoriaSeleccionada = 'Todos';
  String textoBusqueda = '';
  final TextEditingController _searchCtrl = TextEditingController();
  late final AnimationController _relojPatoMenu;

  // Tarjetas de sucursales con su propio icono/loguito y paleta pastel
  final List<Map<String, dynamic>> _infoLocales = [
    {
      'nombre': 'Todos',
      'corto': 'Todos',
      'sub': 'Campus TESE',
      'icono': Icons.grid_view_rounded,
      'color': colorVerdeTese,
      'fondo': const Color(0xFFE6F6EC),
    },
    {
      'nombre': 'Cafetería Central',
      'corto': 'Cafetería Central',
      'sub': 'Comedor Principal',
      'icono': Icons.restaurant_rounded,
      'color': const Color(0xFFE07A5F),
      'fondo': const Color(0xFFFFEFEA),
    },
    {
      'nombre': 'Kiosko Sistemas',
      'corto': 'Kiosko Sistemas',
      'sub': 'Edificio Sistemas',
      'icono': Icons.computer_rounded,
      'color': const Color(0xFF0284C7),
      'fondo': const Color(0xFFE0F2FE),
    },
    {
      'nombre': 'Kiosko Biblioteca',
      'corto': 'Kiosko Biblioteca',
      'sub': 'Explanada Biblio',
      'icono': Icons.menu_book_rounded,
      'color': const Color(0xFF8E24AA),
      'fondo': const Color(0xFFF3E8FF),
    },
  ];

  // Categorías con emojis y colores pasteles propios
  final List<Map<String, dynamic>> _infoCategorias = [
    {
      'nombre': 'Todos',
      'emoji': '🍽️',
      'fondo': const Color(0xFFE6F6EC),
      'borde': colorVerdeTese,
    },
    {
      'nombre': 'Desayunos',
      'emoji': '🥞',
      'fondo': const Color(0xFFFFF6D6),
      'borde': const Color(0xFFF59E0B),
    },
    {
      'nombre': 'Comida',
      'emoji': '🍔',
      'fondo': const Color(0xFFFFEFEA),
      'borde': const Color(0xFFE07A5F),
    },
    {
      'nombre': 'Bebidas',
      'emoji': '🧋',
      'fondo': const Color(0xFFE0F2FE),
      'borde': const Color(0xFF0284C7),
    },
    {
      'nombre': 'Postres',
      'emoji': '🍩',
      'fondo': const Color(0xFFFCE7F3),
      'borde': const Color(0xFFEC4899),
    },
  ];

  @override
  void initState() {
    super.initState();
    _relojPatoMenu = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _relojPatoMenu.dispose();
    super.dispose();
  }

  String _saludoSegunHora(String nombre) {
    final hora = DateTime.now().hour;
    if (hora < 12) return '¡Buenos días, $nombre! ☀️';
    if (hora < 19) return '¡Qué rico receso, $nombre! 🍔';
    return '¡Buenas noches, $nombre! 🌙';
  }

  // 🦆 SELECTOR RÁPIDO DE PATITO DEL GACHAPÓN DESDE EL MENÚ PRINCIPAL
  void _abrirSelectorRapidoPatitoMenu(
    String uid,
    String patoActualId,
    Map<String, int> coleccion,
  ) {
    HapticFeedback.mediumImpact();
    final desbloqueados =
        catalogoPatos
            .where((p) => (coleccion[p.id] ?? 0) > 0 || p.id == 'estudiante')
            .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF6D6),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🦆', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu Compañero de Receso',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: colorTextoOscuro,
                              ),
                            ),
                            Text(
                              'Elige qué patito de tu colección Gachapón te acompaña en el menú:',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: colorTextoGris,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.42,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.84,
                          ),
                      itemCount: desbloqueados.length,
                      itemBuilder: (_, i) {
                        final pato = desbloqueados[i];
                        final bool equipado = pato.id == patoActualId;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            FirebaseFirestore.instance
                                .collection('Usuarios_Perfil')
                                .doc(uid)
                                .set({
                                  'patoEquipadoId': pato.id,
                                }, SetOptions(merge: true));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '¡${pato.nombre} ahora te acompaña en el menú! 🦆✨',
                                ),
                                backgroundColor: colorVerdeTese,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  equipado
                                      ? const Color(0xFFE6F6EC)
                                      : colorFondoCrema,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    equipado
                                        ? pato.rareza.color
                                        : Colors.grey.shade200,
                                width: equipado ? 2.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 66,
                                  height: 66,
                                  child: PatoVista(
                                    skin: pato,
                                    reloj: _relojPatoMenu,
                                    tamano: 66,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pato.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                                Text(
                                  equipado
                                      ? 'En el menú ✓'
                                      : pato.rareza.nombre,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        equipado
                                            ? colorExito
                                            : pato.rareza.color,
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? 'anonimo';
    final String primerNombre =
        (user?.displayName ?? 'Estudiante').split(' ').first;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Usuarios_Perfil')
              .doc(uid)
              .snapshots(),
      builder: (context, perfilSnap) {
        String patoEquipadoId = 'estudiante';
        Map<String, int> coleccionPatos = {'estudiante': 1};

        if (perfilSnap.hasData && perfilSnap.data!.exists) {
          final pData = perfilSnap.data!.data() as Map<String, dynamic>;
          patoEquipadoId = (pData['patoEquipadoId'] ?? 'estudiante').toString();
          if (pData['coleccionPatos'] != null) {
            coleccionPatos = Map<String, int>.from(pData['coleccionPatos']);
          }
        }

        final PatoSkin patoCompanero = catalogoPatos.firstWhere(
          (p) => p.id == patoEquipadoId,
          orElse: () => catalogoPatos[1],
        );

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('Locales_Seguridad')
                  .snapshots(),
          builder: (context, localesSnap) {
            final Map<String, bool> mapaLocalesAbiertos = {};
            if (localesSnap.hasData) {
              for (var d in localesSnap.data!.docs) {
                final data = d.data() as Map<String, dynamic>;
                final String nom = (data['nombre'] ?? '').toString();
                if (nom.isNotEmpty) {
                  mapaLocalesAbiertos[nom] = data['abierto'] ?? true;
                }
              }
            }

            return Scaffold(
              backgroundColor: colorFondoCrema,
              body: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CABECERA CON TU PATITO DEL GACHAPÓN ANIMADO EN VIVO
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: Row(
                        children: [
                          // Avatar interactivo del Patito Gachapón equipado
                          GestureDetector(
                            onTap:
                                () => _abrirSelectorRapidoPatitoMenu(
                                  uid,
                                  patoEquipadoId,
                                  coleccionPatos,
                                ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        patoCompanero.rareza.color.withValues(
                                          alpha: 0.22,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: patoCompanero.rareza.color,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: patoCompanero.rareza.color
                                            .withValues(alpha: 0.28),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: PatoVista(
                                    skin: patoCompanero,
                                    reloj: _relojPatoMenu,
                                    tamano: 48,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: colorVerdeTese,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 11,
                                    color: colorAmarilloTese,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () => _abrirSelectorRapidoPatitoMenu(
                                    uid,
                                    patoEquipadoId,
                                    coleccionPatos,
                                  ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _saludoSegunHora(primerNombre),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: colorTextoOscuro,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17.5,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF6D6),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: colorAmarilloTese
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                          child: Text(
                                            '🦆 ${patoCompanero.nombre} (Toca para cambiar)',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFB45309),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap:
                                () => mostrarMiniTutorialTese(
                                  context,
                                  primerNombre,
                                ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F6EC),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorVerdeTese.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.help_outline_rounded,
                                    color: colorVerdeTese,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Guía',
                                    style: GoogleFonts.poppins(
                                      color: colorVerdeTese,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. GLOBITO PASTEL CON LA FRASE DE TU PATITO + BUSCADOR
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE6F6EC), Color(0xFFFFF6D6)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorVerdeTese.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              patoCompanero.universo.emoji,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '"${patoCompanero.frase}"',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: colorTextoOscuro,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. BUSCADOR PASTEL CON SOMBRA SUAVE
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorVerdeTese.withValues(alpha: 0.14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorVerdeTese.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged:
                              (v) => setState(() => textoBusqueda = v.trim()),
                          decoration: InputDecoration(
                            hintText:
                                'Buscar chilaquiles, torta, pambazo, frapé...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: colorTextoGris,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: colorVerdeTese,
                              size: 21,
                            ),
                            suffixIcon:
                                textoBusqueda.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => textoBusqueda = '');
                                      },
                                    )
                                    : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 11,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 4. TARJETAS DE CAFETERÍAS / KIOSKOS CON SU ICONO Y LOGUITO
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Elige tu Cafetería o Kiosko 🏪',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: colorTextoOscuro,
                            ),
                          ),
                          Text(
                            localSeleccionado == 'Todos'
                                ? 'Mostrando todo el campus'
                                : localSeleccionado,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorVerdeTese,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _infoLocales.length,
                        itemBuilder: (context, i) {
                          final loc = _infoLocales[i];
                          final String nombreLoc = loc['nombre'] as String;
                          final bool seleccionado =
                              localSeleccionado == nombreLoc;
                          final bool abierto =
                              mapaLocalesAbiertos[nombreLoc] ?? true;
                          final Color colorTema = loc['color'] as Color;
                          final Color fondoPastel = loc['fondo'] as Color;

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => localSeleccionado = nombreLoc);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 154,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    seleccionado ? fondoPastel : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color:
                                      seleccionado
                                          ? colorTema
                                          : Colors.grey.shade200,
                                  width: seleccionado ? 2.0 : 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        seleccionado
                                            ? colorTema.withValues(alpha: 0.16)
                                            : Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color:
                                          seleccionado
                                              ? colorTema
                                              : fondoPastel,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      loc['icono'] as IconData,
                                      color:
                                          seleccionado
                                              ? Colors.white
                                              : colorTema,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          loc['corto'] as String,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: colorTextoOscuro,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            if (nombreLoc != 'Todos') ...[
                                              Container(
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      abierto
                                                          ? colorExito
                                                          : Colors.redAccent,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Expanded(
                                              child: Text(
                                                nombreLoc == 'Todos'
                                                    ? (loc['sub'] as String)
                                                    : (abierto
                                                        ? 'Abierto'
                                                        : 'Cerrado'),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      nombreLoc == 'Todos'
                                                          ? colorTextoGris
                                                          : (abierto
                                                              ? colorExito
                                                              : Colors
                                                                  .redAccent),
                                                ),
                                              ),
                                            ),
                                          ],
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

                    // 5. PÍLDORAS DE CATEGORÍAS CON COLORES PASTELES PROPIOS
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        itemCount: _infoCategorias.length,
                        itemBuilder: (context, i) {
                          final cat = _infoCategorias[i];
                          final String nombreCat = cat['nombre'] as String;
                          final bool sel = categoriaSeleccionada == nombreCat;
                          final Color fondoCat = cat['fondo'] as Color;
                          final Color bordeCat = cat['borde'] as Color;

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => categoriaSeleccionada = nombreCat);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: sel ? fondoCat : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sel ? bordeCat : Colors.grey.shade200,
                                  width: sel ? 1.8 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cat['emoji'] as String,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    nombreCat,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight:
                                          sel
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                      color:
                                          sel
                                              ? colorTextoOscuro
                                              : colorTextoGris,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 4),

                    // 6. LISTA DE PLATILLOS CON DETALLES PASTELES Y ANIMACIONES
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Menu_Platillos')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: colorVerdeTese,
                              ),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];
                          final List<Platillo> platillos =
                              docs
                                  .map(
                                    (d) => Platillo.fromMap(
                                      d.data() as Map<String, dynamic>,
                                      d.id,
                                    ),
                                  )
                                  .where((p) {
                                    final bool pasaLocal =
                                        localSeleccionado == 'Todos' ||
                                        p.local == localSeleccionado;
                                    final bool pasaCat =
                                        categoriaSeleccionada == 'Todos' ||
                                        p.categoria == categoriaSeleccionada;
                                    final bool pasaTexto =
                                        textoBusqueda.isEmpty ||
                                        p.nombre.toLowerCase().contains(
                                          textoBusqueda.toLowerCase(),
                                        ) ||
                                        p.local.toLowerCase().contains(
                                          textoBusqueda.toLowerCase(),
                                        );
                                    return pasaLocal && pasaCat && pasaTexto;
                                  })
                                  .toList();

                          if (platillos.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF6D6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lunch_dining_rounded,
                                      size: 48,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No encontramos platillos con ese filtro 🍽️',
                                    style: GoogleFonts.poppins(
                                      color: colorTextoOscuro,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 115),
                            itemCount: platillos.length,
                            itemBuilder: (context, index) {
                              final platillo = platillos[index];
                              final bool localAbierto =
                                  mapaLocalesAbiertos[platillo.local] ?? true;
                              final bool disponible =
                                  platillo.existencias > 0 && localAbierto;
                              final Color colorCat = acentoDeCategoria(
                                platillo.categoria,
                              );
                              final Color pastelCat = fondoPastelDeCategoria(
                                platillo.categoria,
                              );

                              final int enMiCarrito =
                                  widget.carrito
                                      .where((c) => c.id == platillo.id)
                                      .length;

                              return FadeInUp(
                                duration: const Duration(milliseconds: 240),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color:
                                          enMiCarrito > 0
                                              ? colorAmarilloTese
                                              : colorCat.withValues(
                                                alpha: 0.18,
                                              ),
                                      width: enMiCarrito > 0 ? 2.0 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorCat.withValues(alpha: 0.06),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(22),
                                    onTap:
                                        !localAbierto
                                            ? () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '🔒 ${platillo.local} se encuentra cerrado en este momento.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                              );
                                            }
                                            : () async {
                                              final stockRestante = (platillo
                                                          .existencias -
                                                      enMiCarrito)
                                                  .clamp(
                                                    0,
                                                    platillo.existencias,
                                                  );
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        _,
                                                      ) => PantallaDetallePlatillo(
                                                        platillo: platillo,
                                                        stockDisponible:
                                                            stockRestante,
                                                        onAgregar: (pMod) {
                                                          widget
                                                              .onAgregarPlatillo(
                                                                pMod,
                                                                1,
                                                              );
                                                        },
                                                      ),
                                                ),
                                              );
                                              widget.onActualizarUI();
                                            },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          // Imagen del platillo con badge de Popular o En Carrito
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: pastelCat,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child:
                                                      platillo.fotos.isNotEmpty
                                                          ? Image.memory(
                                                            base64Decode(
                                                              platillo
                                                                  .fotos
                                                                  .first,
                                                            ),
                                                            width: 78,
                                                            height: 78,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (
                                                                  _,
                                                                  __,
                                                                  ___,
                                                                ) => _imgDefault(
                                                                  platillo
                                                                      .categoria,
                                                                ),
                                                          )
                                                          : _imgDefault(
                                                            platillo.categoria,
                                                          ),
                                                ),
                                              ),
                                              if (platillo.popular)
                                                Positioned(
                                                  top: -4,
                                                  left: -4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFFF3C4,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            colorAmarilloTese,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '🔥 Top',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: const Color(
                                                              0xFFB45309,
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              if (enMiCarrito > 0)
                                                Positioned(
                                                  bottom: -4,
                                                  right: -4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 7,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: colorVerdeTese,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'x$enMiCarrito',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 9.5,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  platillo.nombre,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14.5,
                                                    color: colorTextoOscuro,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.storefront_rounded,
                                                      size: 13,
                                                      color: colorCat,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        '${platillo.local} • ${platillo.tiempo}',
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 11,
                                                              color:
                                                                  colorTextoGris,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Wrap(
                                                  spacing: 6,
                                                  runSpacing: 4,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            !localAbierto
                                                                ? Colors
                                                                    .red
                                                                    .shade50
                                                                : (platillo.existencias >
                                                                        0
                                                                    ? const Color(
                                                                      0xFFE6F6EC,
                                                                    )
                                                                    : Colors
                                                                        .red
                                                                        .shade50),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        !localAbierto
                                                            ? 'Cerrado 🔒'
                                                            : (platillo.existencias >
                                                                    0
                                                                ? '${platillo.existencias} disp.'
                                                                : 'Agotado'),
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  disponible
                                                                      ? colorExito
                                                                      : Colors
                                                                          .red,
                                                            ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFFFF6D6,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '+${platillo.puntos} pts 🪙',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  const Color(
                                                                    0xFFB45309,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 9,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: pastelCat,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '\$${platillo.precio.toStringAsFixed(0)}',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15.5,
                                                    color: colorTextoOscuro,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                onTap:
                                                    !disponible
                                                        ? null
                                                        : () {
                                                          HapticFeedback.lightImpact();
                                                          final ok = widget
                                                              .onAgregarPlatillo(
                                                                platillo,
                                                                1,
                                                              );
                                                          if (ok) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Agregaste ${platillo.nombre} al carrito 🛒',
                                                                ),
                                                                duration:
                                                                    const Duration(
                                                                      seconds:
                                                                          1,
                                                                    ),
                                                                backgroundColor:
                                                                    colorVerdeTese,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                child: Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        disponible
                                                            ? colorAmarilloTese
                                                            : Colors
                                                                .grey
                                                                .shade200,
                                                    shape: BoxShape.circle,
                                                    boxShadow:
                                                        disponible
                                                            ? [
                                                              BoxShadow(
                                                                color: colorAmarilloTese
                                                                    .withValues(
                                                                      alpha:
                                                                          0.35,
                                                                    ),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      3,
                                                                    ),
                                                              ),
                                                            ]
                                                            : null,
                                                  ),
                                                  child: Icon(
                                                    Icons.add_rounded,
                                                    color:
                                                        disponible
                                                            ? colorVerdeOscuro
                                                            : Colors.grey,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
              ),
              floatingActionButton:
                  widget.carrito.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(bottom: 58.0),
                        child: ElasticIn(
                          child: FloatingActionButton.extended(
                            backgroundColor: colorVerdeTese,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CarritoScreen(
                                        carrito: widget.carrito,
                                      ),
                                ),
                              ).then((_) => widget.onActualizarUI());
                            },
                            icon: const Icon(
                              Icons.shopping_bag_rounded,
                              color: colorAmarilloTese,
                            ),
                            label: Text(
                              'Ver Carrito (${widget.carrito.length})',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      : null,
            );
          },
        );
      },
    );
  }

  Widget _imgDefault(String categoria) {
    final Color c = acentoDeCategoria(categoria);
    final Color f = fondoPastelDeCategoria(categoria);
    return Container(
      width: 78,
      height: 78,
      color: f,
      child: Icon(Icons.fastfood_rounded, color: c, size: 34),
    );
  }
}

// ==========================================================
// 2. MIS PEDIDOS CON ETAPAS VISUALES Y TONOS PASTELES
// ==========================================================
class MisPedidosEstudianteScreen extends StatelessWidget {
  final List<Platillo> carritoGlobal;
  final VoidCallback onIrAlCarrito;

  const MisPedidosEstudianteScreen({
    super.key,
    required this.carritoGlobal,
    required this.onIrAlCarrito,
  });

  Future<void> _repetirPedidoAnterior(
    BuildContext context,
    Map<String, dynamic> pedidoData,
  ) async {
    final List<dynamic> ids = pedidoData['platillosIds'] ?? [];
    if (ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este pedido no tiene platillos recargables.'),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    int agregados = 0;

    for (var idPlat in ids) {
      final doc =
          await FirebaseFirestore.instance
              .collection('Menu_Platillos')
              .doc(idPlat.toString())
              .get();
      if (doc.exists) {
        final p = Platillo.fromMap(doc.data()!, doc.id);
        if (p.existencias > 0) {
          if (carritoGlobal.isEmpty || carritoGlobal.first.local == p.local) {
            carritoGlobal.add(p);
            agregados++;
          }
        }
      }
    }

    if (!context.mounted) return;
    if (agregados > 0) {
      onIrAlCarrito();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Los platillos de esa orden están agotados o tienes otro local en el carrito.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _limpiarHistorialVisual(String uid) async {
    final snap =
        await FirebaseFirestore.instance
            .collection('Pedidos')
            .where('idAlumno', isEqualTo: uid)
            .get();
    for (var doc in snap.docs) {
      final d = doc.data();
      final int est = d['estado'] ?? 0;
      if (est >= 3) {
        await doc.reference.update({'ocultoParaAlumno': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonimo';

    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Mis Pedidos y Etapas',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _limpiarHistorialVisual(uid),
            icon: const Icon(
              Icons.cleaning_services_outlined,
              color: colorVerdeTese,
              size: 16,
            ),
            label: Text(
              'Limpiar pasados',
              style: GoogleFonts.poppins(
                color: colorVerdeTese,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          final docs =
              (snapshot.data?.docs ?? []).where((d) {
                final data = d.data() as Map<String, dynamic>;
                return data['ocultoParaAlumno'] != true;
              }).toList();

          docs.sort((a, b) {
            final da = a.data() as Map<String, dynamic>;
            final db = b.data() as Map<String, dynamic>;
            final ta = da['horaLlegada'] as Timestamp?;
            final tb = db['horaLlegada'] as Timestamp?;
            if (ta == null || tb == null) return 0;
            return tb.compareTo(ta);
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F6EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 54,
                      color: colorVerdeTese,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aún no tienes pedidos en curso',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colorTextoOscuro,
                    ),
                  ),
                  Text(
                    'Cuando pidas algo, aquí verás las etapas en vivo 🦆',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colorTextoGris,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final p = doc.data() as Map<String, dynamic>;
              final int estado = p['estado'] ?? 0;
              final String codigo = p['idPedido'] ?? '#TESE';
              final String local = p['local'] ?? 'Cafetería';
              final String detalle = p['detalle'] ?? '';
              final double total = (p['total'] ?? 0.0).toDouble();

              String etiquetaEstado = '1. Recibido';
              Color colorEstado = const Color(0xFFF59E0B);
              Color fondoTarjeta = Colors.white;

              if (estado == 1) {
                etiquetaEstado = '2. Cocinando 🍳';
                colorEstado = const Color(0xFFEA580C);
              } else if (estado == 2) {
                etiquetaEstado = '3. ¡LISTO EN VENTANILLA! 🔔';
                colorEstado = colorExito;
                fondoTarjeta = const Color(0xFFF0FDF4);
              } else if (estado == 3) {
                etiquetaEstado = '4. Entregado ✓';
                colorEstado = colorVerdeTese;
              } else if (estado == 4) {
                etiquetaEstado = 'Cancelado 🥺';
                colorEstado = Colors.redAccent;
                fondoTarjeta = const Color(0xFFFFF5F5);
              }

              return FadeInUp(
                duration: const Duration(milliseconds: 220),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: fondoTarjeta,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorEstado.withValues(alpha: 0.4),
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorEstado.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => SalaEsperaPedidoScreen(
                                pedidoDocId: doc.id,
                                codigoInicial: codigo,
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$codigo • $local',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
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
                                  color: colorEstado.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  etiquetaEstado,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: colorEstado,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (estado <= 3) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: List.generate(4, (paso) {
                                final bool alcanzado = estado >= paso;
                                return Expanded(
                                  child: Container(
                                    height: 5,
                                    margin: EdgeInsets.only(
                                      right: paso < 3 ? 5 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          alcanzado
                                              ? colorEstado
                                              : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                          const Divider(height: 18),
                          Text(
                            detalle,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorTextoOscuro,
                            ),
                          ),
                          if (estado == 4 &&
                              p['motivoCancelacion'] != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Motivo: ${p['motivoCancelacion']}',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: \$${total.toStringAsFixed(0)} MXN',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                  color: colorVerdeTese,
                                ),
                              ),
                              if (estado == 3 || estado == 4)
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorVerdeTese,
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: colorVerdeTese,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                      () => _repetirPedidoAnterior(context, p),
                                  icon: const Icon(
                                    Icons.replay_rounded,
                                    size: 15,
                                  ),
                                  label: Text(
                                    'Volver a pedir',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F6EC),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Ver etapas en vivo ➔',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: colorVerdeTese,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
