import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_perfil.dart';
import 'pantalla_pedido.dart';
import 'pantalla_detalle_platillo.dart';

// Un color de acento por categoría: lo usan tanto el catálogo como la
// pantalla de detalle, para que combinen.
const Map<String, Color> colorPorCategoria = {
  'Todos': colorVerdeTese,
  'Desayunos': colorAmarilloTese,
  'Comida': colorVerdeTese,
  'Bebidas': colorSalvia,
  'Postres': colorRosa,
};

Color acentoDeCategoria(String categoria) =>
    colorPorCategoria[categoria] ?? colorVerdeTese;

// Solo el acento verde oscuro es lo bastante oscuro para texto blanco;
// el resto (amarillo, salvia, rosa) son claros y piden texto oscuro.
Color colorTextoSobreAcento(Color fondo) =>
    fondo == colorVerdeTese ? Colors.white : colorVerdeOscuro;

// Cascarón con el nav bar curvo: aquí vive el carrito global que comparten
// el catálogo y la pantalla de pedido.
class NavegacionEstudiante extends StatefulWidget {
  const NavegacionEstudiante({super.key});

  @override
  State<NavegacionEstudiante> createState() => _NavegacionEstudianteState();
}

class _NavegacionEstudianteState extends State<NavegacionEstudiante> {
  int _indiceActual = 0;
  List<Platillo> carritoGlobal = [];

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
      const PerfilEstudianteScreen(),
    ];

    return Scaffold(
      backgroundColor: colorFondoCrema,
      extendBody: true,
      body: pantallas[_indiceActual],
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
            Icons.person,
            size: 26,
            color: _indiceActual == 1 ? colorVerdeOscuro : Colors.white,
          ),
        ],
        onTap: (index) {
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
                onPressed: () {
                  if (carritoGlobal.isEmpty) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CarritoScreen(
                            carrito: carritoGlobal,
                            onVaciar: _limpiarCarrito,
                          ),
                    ),
                  ).then((_) => setState(() {}));
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
  final List<Platillo> menuDisponibles = [
    Platillo(
      id: '1',
      nombre: 'Chilaquiles Verdes',
      local: 'Cafetería Central',
      precio: 45.0,
      categoria: 'Desayunos',
      icono: Icons.breakfast_dining,
      descripcion:
          'Totopos bañados en salsa verde, con crema, queso fresco y '
          'cebolla. Se sirven bien calientes.',
      calificacion: 4.7,
      tiempoPrep: '10-15 min',
      popular: true,
    ),
    Platillo(
      id: '2',
      nombre: 'Hot Cakes con Miel',
      local: 'Cafetería Central',
      precio: 35.0,
      categoria: 'Desayunos',
      icono: Icons.bakery_dining,
      descripcion: 'Hot cakes esponjositos, con miel y mantequilla al gusto.',
      calificacion: 4.5,
      tiempoPrep: '8-10 min',
    ),
    Platillo(
      id: '3',
      nombre: 'Licuado de Fresa',
      local: 'Jugos TESE',
      precio: 30.0,
      categoria: 'Desayunos',
      icono: Icons.local_drink,
      descripcion: 'Licuado cremoso de fresa con leche, bien frío.',
      calificacion: 4.6,
      tiempoPrep: '5 min',
    ),
    Platillo(
      id: '4',
      nombre: 'Hamburguesa Clásica',
      local: 'Kiosko Sistemas',
      precio: 65.0,
      categoria: 'Comida',
      icono: Icons.lunch_dining,
      descripcion:
          'Carne a la plancha, queso, lechuga, jitomate y nuestra salsa '
          'especial, en pan recién tostado.',
      calificacion: 4.8,
      tiempoPrep: '12-15 min',
      popular: true,
    ),
    Platillo(
      id: '5',
      nombre: 'Orden de Tacos (4)',
      local: 'Cafetería Central',
      precio: 40.0,
      categoria: 'Comida',
      icono: Icons.dinner_dining,
      descripcion: 'Cuatro tacos al pastor con piña, cebolla y cilantro.',
      calificacion: 4.9,
      tiempoPrep: '10 min',
      popular: true,
    ),
    Platillo(
      id: '6',
      nombre: 'Torta de Milanesa',
      local: 'Kiosko Sistemas',
      precio: 55.0,
      categoria: 'Comida',
      icono: Icons.fastfood,
      descripcion:
          'Milanesa empanizada con aguacate, jitomate, frijoles y mayonesa.',
      calificacion: 4.6,
      tiempoPrep: '12 min',
    ),
    Platillo(
      id: '7',
      nombre: 'Arroz con Pollo',
      local: 'Cafetería Central',
      precio: 50.0,
      categoria: 'Comida',
      icono: Icons.rice_bowl,
      descripcion: 'Arroz guisado con pollo deshebrado y verduras salteadas.',
      calificacion: 4.4,
      tiempoPrep: '15 min',
    ),
    Platillo(
      id: '8',
      nombre: 'Jugo de Naranja',
      local: 'Jugos TESE',
      precio: 25.0,
      categoria: 'Bebidas',
      icono: Icons.emoji_food_beverage,
      descripcion: 'Jugo de naranja recién exprimido, bien frío.',
      calificacion: 4.5,
      tiempoPrep: '5 min',
    ),
    Platillo(
      id: '9',
      nombre: 'Café Americano',
      local: 'Cafetería Central',
      precio: 20.0,
      categoria: 'Bebidas',
      icono: Icons.coffee,
      descripcion: 'Café negro recién hecho, tamaño grande.',
      calificacion: 4.3,
      tiempoPrep: '3 min',
    ),
    Platillo(
      id: '10',
      nombre: 'Gelatina de Mosaico',
      local: 'Cafetería Central',
      precio: 15.0,
      categoria: 'Postres',
      icono: Icons.icecream,
      descripcion: 'Gelatina de varios sabores en cuadritos, con leche.',
      calificacion: 4.2,
      tiempoPrep: 'Listo',
    ),
    Platillo(
      id: '11',
      nombre: 'Pay de Queso',
      local: 'Kiosko Sistemas',
      precio: 30.0,
      categoria: 'Postres',
      icono: Icons.cake,
      descripcion: 'Rebanada de pay de queso cremoso con zarzamora.',
      calificacion: 4.7,
      tiempoPrep: 'Listo',
      popular: true,
    ),
  ];

  final List<String> _categorias = const [
    'Todos',
    'Desayunos',
    'Comida',
    'Bebidas',
    'Postres',
  ];
  String _categoriaSeleccionada = 'Todos';

  final TextEditingController _busquedaCtrl = TextEditingController();
  String _terminoBusqueda = '';

  int _promoIndex = 0;
  final List<String> promociones = [
    '¡2x1 en Chilaquiles hoy!',
    'Combo Godín a solo \$50',
    'Postre gratis en compras > \$100',
  ];

  List<Platillo> get _platillosFiltrados {
    return menuDisponibles.where((p) {
      final coincideCategoria =
          _categoriaSeleccionada == 'Todos' ||
          p.categoria == _categoriaSeleccionada;
      final coincideBusqueda =
          _terminoBusqueda.isEmpty ||
          p.nombre.toLowerCase().contains(_terminoBusqueda.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _mostrarAlertaExito(String nombre) {
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
    final platillosFiltrados = _platillosFiltrados;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorVerdeTese, colorFondoCrema],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  '¿Qué comeremos hoy?',
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
                  'Ordena y recógelo directo en el receso',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
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
                      onTap:
                          () => setState(
                            () => _categoriaSeleccionada = categoria,
                          ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: seleccionada ? acento : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow:
                              seleccionada
                                  ? []
                                  : [
                                    BoxShadow(
                                      color: colorVerdeTese.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
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
              CarouselSlider(
                options: CarouselOptions(
                  height: 130.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  onPageChanged:
                      (index, reason) => setState(() => _promoIndex = index),
                ),
                items:
                    promociones.asMap().entries.map((entry) {
                      final index = entry.key;
                      final texto = entry.value;
                      const gradientes = [
                        [colorAmarilloTese, Color(0xFFF07B1D)],
                        [colorRosa, Color(0xFFE88F82)],
                        [colorSalvia, colorVerdeTese],
                      ];
                      const textosClaros = [true, false, true];
                      final gradiente = gradientes[index % gradientes.length];
                      final colorTexto =
                          textosClaros[index % textosClaros.length]
                              ? Colors.white
                              : colorVerdeOscuro;
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradiente,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: colorTexto,
                                  size: 46,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      texto,
                                      style: GoogleFonts.poppins(
                                        fontSize: 17.0,
                                        color: colorTexto,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 8),
              Center(
                child: AnimatedSmoothIndicator(
                  activeIndex: _promoIndex,
                  count: promociones.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    activeDotColor: colorVerdeTese,
                    dotColor: colorVerdeTese.withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    platillosFiltrados.isEmpty
                        ? Center(
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
                                'No encontramos nada con eso',
                                style: GoogleFonts.poppins(
                                  color: colorTextoGris,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          itemCount: platillosFiltrados.length,
                          itemBuilder: (context, index) {
                            final platillo = platillosFiltrados[index];
                            final acento = acentoDeCategoria(
                              platillo.categoria,
                            );
                            return FadeInUp(
                              delay: Duration(milliseconds: 70 * index),
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
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: acento.withValues(
                                                alpha: 0.16,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              platillo.icono,
                                              color: colorTextoOscuro,
                                              size: 28,
                                            ),
                                          ),
                                          if (platillo.popular)
                                            Positioned(
                                              top: -6,
                                              left: -6,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: const Text(
                                                  '🔥',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
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
                                            Text(
                                              platillo.nombre,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.5,
                                                color: colorTextoOscuro,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              platillo.local,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.5,
                                                color: colorTextoGris,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: colorAmarilloTese,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  platillo.calificacion
                                                      .toStringAsFixed(1),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: colorTextoOscuro,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
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
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: colorAmarilloTese,
                                          size: 36,
                                        ),
                                        onPressed: () {
                                          widget.onAgregar(platillo);
                                          _mostrarAlertaExito(platillo.nombre);
                                        },
                                      ),
                                    ],
                                  ),
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
}
