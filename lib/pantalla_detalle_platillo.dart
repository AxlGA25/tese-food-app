import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colores.dart';
import 'modelos.dart';
import 'catalogo_patos.dart';
import 'pantalla_menu.dart';

class PantallaDetallePlatillo extends StatefulWidget {
  final Platillo platillo;
  final int? stockDisponible;
  final ValueChanged<Platillo>? onAgregar;

  const PantallaDetallePlatillo({
    super.key,
    required this.platillo,
    this.stockDisponible,
    this.onAgregar,
  });

  @override
  State<PantallaDetallePlatillo> createState() =>
      _PantallaDetallePlatilloState();
}

class _PantallaDetallePlatilloState extends State<PantallaDetallePlatillo>
    with SingleTickerProviderStateMixin {
  int _cantidad = 1;
  int _fotoActual = 0;
  final PageController _pageFotosCtrl = PageController();

  // 0 = Normal (Con), 1 = Sin ingrediente, 2 = Extra ingrediente
  late Map<String, int> _estadoIngredientes;
  final TextEditingController _notaEspecialCtrl = TextEditingController();
  late final AnimationController _relojPato;

  int get _maxStock {
    final disp = widget.stockDisponible ?? widget.platillo.existencias;
    return disp > 0 ? disp : 0;
  }

  @override
  void initState() {
    super.initState();
    _estadoIngredientes = {
      for (final ing in widget.platillo.ingredientes) ing: 0,
    };
    _relojPato = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pageFotosCtrl.dispose();
    _notaEspecialCtrl.dispose();
    _relojPato.dispose();
    super.dispose();
  }

  String _emojiIngrediente(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('queso')) return '🧀';
    if (n.contains('crema')) return '🥛';
    if (n.contains('salsa') || n.contains('chile') || n.contains('picante')) {
      return '🌶️';
    }
    if (n.contains('cebolla')) return '🧅';
    if (n.contains('aguacate') || n.contains('guacamole')) return '🥑';
    if (n.contains('lechuga') || n.contains('cilantro')) return '🥬';
    if (n.contains('jitomate') || n.contains('tomate')) return '🍅';
    if (n.contains('frijol')) return '🫘';
    if (n.contains('pollo') || n.contains('milanesa') || n.contains('carne')) {
      return '🍗';
    }
    if (n.contains('jamón') || n.contains('tocino')) return '🥓';
    if (n.contains('huevo')) return '🍳';
    if (n.contains('pan') || n.contains('bolillo') || n.contains('tortilla')) {
      return '🥖';
    }
    if (n.contains('hielo')) return '🧊';
    if (n.contains('azúcar') || n.contains('chocolate') || n.contains('miel')) {
      return '🍯';
    }
    return '🥗';
  }

  List<String> _construirListaPersonalizacion() {
    final List<String> lista = [];
    _estadoIngredientes.forEach((ing, estado) {
      if (estado == 1) {
        lista.add('Sin $ing');
      } else if (estado == 2) {
        lista.add('Extra $ing');
      }
    });
    final nota = _notaEspecialCtrl.text.trim();
    if (nota.isNotEmpty) {
      lista.add('Nota: $nota');
    }
    if (lista.isEmpty) {
      lista.add('Receta clásica (Con todo)');
    }
    return lista;
  }

  String _resumenAmigableChef() {
    final cambios = <String>[];
    _estadoIngredientes.forEach((ing, estado) {
      if (estado == 1) cambios.add('sin $ing');
      if (estado == 2) cambios.add('extra $ing');
    });
    if (_notaEspecialCtrl.text.trim().isNotEmpty) {
      cambios.add('"${_notaEspecialCtrl.text.trim()}"');
    }
    if (cambios.isEmpty) {
      return '¡Hola! Prepararé tu ${widget.platillo.nombre} al momento con todos sus ingredientes clásicos 😋';
    }
    return '¡Anotado en comanda! Lo prepararé: ${cambios.join(' • ')} 👨‍🍳✨';
  }

  void _salirAlMenu() {
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
  }

  void _confirmarYAgregar() {
    if (_maxStock <= 0) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    final Platillo platilloPersonalizado = widget.platillo.copyWith(
      personalizacion: _construirListaPersonalizacion(),
    );

    if (widget.onAgregar != null) {
      for (int i = 0; i < _cantidad; i++) {
        widget.onAgregar!(platilloPersonalizado);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🦆🛒 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  '¡Listo! Se ${_cantidad == 1 ? 'agregó 1' : 'agregaron $_cantidad'} ${widget.platillo.nombre} a tu pedido.',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: colorVerdeTese,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(
      context,
    ).pop({'platillo': platilloPersonalizado, 'cantidad': _cantidad});
  }

  // ✍️ MODAL PARA PUBLICAR OPINIÓN (CON OPCIÓN PÚBLICA O ANÓNIMA)
  void _mostrarModalEscribirOpinion() {
    int estrellasElegidas = 5;
    bool esAnonimo = false;
    bool publicando = false;
    final TextEditingController opinionCtrl = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    final String nombreReal = user?.displayName ?? 'Estudiante TESE';

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
                  top: 18,
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 22,
                ),
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
                    Text(
                      'Calificar ${widget.platillo.nombre}',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: colorVerdeTese,
                      ),
                    ),
                    Text(
                      'Elige si deseas publicar tu opinión con tu nombre o de forma anónima:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colorTextoGris,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Estrellas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          iconSize: 36,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setStateModal(() => estrellasElegidas = index + 1);
                          },
                          icon: Icon(
                            index < estrellasElegidas
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: colorAmarilloTese,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    // Selector de privacidad: Público vs Anónimo
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorFondoCrema,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setStateModal(() => esAnonimo = false);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      !esAnonimo
                                          ? colorVerdeTese
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      size: 16,
                                      color:
                                          !esAnonimo
                                              ? Colors.white
                                              : colorTextoGris,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        'Público ($nombreReal)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              !esAnonimo
                                                  ? Colors.white
                                                  : colorTextoGris,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setStateModal(() => esAnonimo = true);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      esAnonimo
                                          ? const Color(0xFF475569)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.visibility_off_rounded,
                                      size: 16,
                                      color:
                                          esAnonimo
                                              ? Colors.white
                                              : colorTextoGris,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Anónimo 🕵️‍♂️',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            esAnonimo
                                                ? Colors.white
                                                : colorTextoGris,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: opinionCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Escribe qué te pareció este platillo...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12.5,
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
                            publicando
                                ? null
                                : () async {
                                  setStateModal(() => publicando = true);
                                  await FirebaseFirestore.instance
                                      .collection('Resenas')
                                      .add({
                                        'platilloId': widget.platillo.id,
                                        'platilloNombre':
                                            widget.platillo.nombre,
                                        'local': widget.platillo.local,
                                        'alumno':
                                            esAnonimo
                                                ? 'Estudiante Anónimo'
                                                : nombreReal,
                                        'esAnonimo': esAnonimo,
                                        'estrellas': estrellasElegidas,
                                        'comentario':
                                            opinionCtrl.text.trim().isEmpty
                                                ? '¡Muy rico y recomendado!'
                                                : opinionCtrl.text.trim(),
                                        'fecha': FieldValue.serverTimestamp(),
                                      });
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        esAnonimo
                                            ? '¡Opinión publicada de forma anónima! 🕵️‍♂️✨'
                                            : '¡Tu opinión pública fue publicada con éxito! ⭐',
                                      ),
                                      backgroundColor: colorExito,
                                    ),
                                  );
                                },
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          esAnonimo
                              ? 'Publicar como Anónimo'
                              : 'Publicar mi Opinión',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Color _fondoPastelPorCategoria(String cat) {
    switch (cat) {
      case 'Desayunos':
        return const Color(0xFFFFF6D6);
      case 'Comida':
        return const Color(0xFFE6F6EC);
      case 'Bebidas':
        return const Color(0xFFE3F4FD);
      case 'Postres':
        return const Color(0xFFFDE8F1);
      default:
        return const Color(0xFFE6F6EC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.platillo;
    final Color colorAcento = acentoDeCategoria(p.categoria);
    final Color colorTextoChip = colorTextoSobreAcento(colorAcento);
    final Color fondoPastel = _fondoPastelPorCategoria(p.categoria);
    final bool hayStock = _maxStock > 0;
    final double subtotal = p.precio * _cantidad;
    final int puntosTotales = p.puntos * _cantidad;

    final PatoSkin skinChef = catalogoPatos.firstWhere(
      (s) => s.id == 'chef',
      orElse: () => catalogoPatos.first,
    );

    return Scaffold(
      backgroundColor: colorFondoCrema,
      body: Column(
        children: [
          // 1. BARRA SUPERIOR CON BOTÓN "← Menú"
          Container(
            color: fondoPastel,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: _salirAlMenu,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back_rounded,
                              color: colorVerdeTese,
                              size: 19,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Menú',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: colorVerdeTese,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: 15,
                              color: colorAcento,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                p.local,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: colorTextoOscuro,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF3C4), Color(0xFFFFE082)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorAmarilloTese,
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '+$puntosTotales pts',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: colorVerdeOscuro,
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

          // 2. CONTENIDO DESLIZABLE
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABECERA VISUAL PASTEL CON FOTO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
                    decoration: BoxDecoration(
                      color: fondoPastel,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(34),
                      ),
                    ),
                    child: Column(
                      children: [
                        ZoomIn(
                          duration: const Duration(milliseconds: 280),
                          child: Container(
                            height: 205,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: colorAcento.withValues(alpha: 0.16),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (p.fotos.isNotEmpty)
                                    PageView.builder(
                                      controller: _pageFotosCtrl,
                                      itemCount: p.fotos.length,
                                      onPageChanged:
                                          (i) =>
                                              setState(() => _fotoActual = i),
                                      itemBuilder: (_, idx) {
                                        return Image.memory(
                                          base64Decode(p.fotos[idx]),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) =>
                                                  _ilustracionPlatillo(
                                                    colorAcento,
                                                    p.icono,
                                                  ),
                                        );
                                      },
                                    )
                                  else
                                    _ilustracionPlatillo(colorAcento, p.icono),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorAcento,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        p.categoria,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: colorTextoChip,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (p.fotos.length > 1)
                                    Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          p.fotos.length,
                                          (i) => AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            width: _fotoActual == i ? 20 : 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color:
                                                  _fotoActual == i
                                                      ? Colors.white
                                                      : Colors.white60,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _ChipDatoPastel(
                              icono: Icons.schedule_rounded,
                              texto: p.tiempoPrep,
                              colorIcono: colorVerdeTese,
                            ),
                            _ChipDatoPastel(
                              icono: Icons.star_rounded,
                              texto:
                                  '${p.calificacion.toStringAsFixed(1)} (${p.numCalificaciones} opiniones)',
                              colorIcono: const Color(0xFFF59E0B),
                            ),
                            _ChipDatoPastel(
                              icono:
                                  hayStock
                                      ? Icons.check_circle_rounded
                                      : Icons.error_outline_rounded,
                              texto:
                                  hayStock
                                      ? '$_maxStock disponibles'
                                      : 'Agotado hoy',
                              colorIcono:
                                  hayStock ? colorExito : Colors.redAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 3. NOMBRE, PRECIO Y DESCRIPCIÓN
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  p.nombre,
                                  style: GoogleFonts.poppins(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    color: colorTextoOscuro,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorVerdeTese.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '\$${p.precio.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: colorVerdeTese,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.descripcion,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: colorTextoGris,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. GLOBO DE DIÁLOGO EN VIVO DEL "MASTER CHEF PATITO"
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBF0), Color(0xFFFFF3D1)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorAmarilloTese.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorAmarilloTese,
                                width: 2,
                              ),
                            ),
                            child: PatoVista(
                              skin: skinChef,
                              reloj: _relojPato,
                              tamano: 52,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Master Chef Patito dice:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _resumenAmigableChef(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorTextoOscuro,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. INGREDIENTES SIN OVERFLOW + CAMPO DE NOTA OPCIONAL
                  if (p.ingredientes.isNotEmpty)
                    FadeInUp(
                      duration: const Duration(milliseconds: 240),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fila corregida con Expanded para evitar el RIGHT OVERFLOW de 5.1 px
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant_rounded,
                                      color: colorVerdeTese,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '¿Cómo lo preparamos?',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.5,
                                        color: colorTextoOscuro,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        for (final k
                                            in _estadoIngredientes.keys) {
                                          _estadoIngredientes[k] = 0;
                                        }
                                        _notaEspecialCtrl.clear();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.restart_alt_rounded,
                                            size: 15,
                                            color: colorVerdeTese,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Restaurar',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: colorVerdeTese,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Elige si deseas quitar algún ingrediente o pedir porción extra:',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: colorTextoGris,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...p.ingredientes.map((ing) {
                                final int est = _estadoIngredientes[ing] ?? 0;
                                final String emoji = _emojiIngrediente(ing);

                                Color fondoFila = colorFondoCrema;
                                Color bordeFila = Colors.transparent;
                                if (est == 1) {
                                  fondoFila = const Color(0xFFFFF0F0);
                                  bordeFila = Colors.redAccent.withValues(
                                    alpha: 0.35,
                                  );
                                } else if (est == 2) {
                                  fondoFila = const Color(0xFFFFF8E1);
                                  bordeFila = const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.45);
                                }

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fondoFila,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: bordeFila,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            emoji,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              ing,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13.5,
                                                color: colorTextoOscuro,
                                                decoration:
                                                    est == 1
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            est == 0
                                                ? 'Incluido'
                                                : (est == 1
                                                    ? 'Quitado'
                                                    : '¡Porción Extra!'),
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  est == 0
                                                      ? colorVerdeTese
                                                      : (est == 1
                                                          ? Colors.redAccent
                                                          : const Color(
                                                            0xFFD97706,
                                                          )),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _PildoraEstadoIngrediente(
                                              etiqueta: '🚫 Sin',
                                              seleccionado: est == 1,
                                              colorFondoActivo:
                                                  Colors.redAccent,
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                setState(
                                                  () =>
                                                      _estadoIngredientes[ing] =
                                                          1,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _PildoraEstadoIngrediente(
                                              etiqueta: '✅ Normal',
                                              seleccionado: est == 0,
                                              colorFondoActivo: colorVerdeTese,
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                setState(
                                                  () =>
                                                      _estadoIngredientes[ing] =
                                                          0,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _PildoraEstadoIngrediente(
                                              etiqueta: '✨ Extra',
                                              seleccionado: est == 2,
                                              colorFondoActivo: const Color(
                                                0xFFF59E0B,
                                              ),
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                setState(
                                                  () =>
                                                      _estadoIngredientes[ing] =
                                                          2,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _notaEspecialCtrl,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText:
                                      'Nota opcional para cocina (ej. Salsa aparte)...',
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: colorTextoGris,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.edit_note_rounded,
                                    color: colorVerdeTese,
                                  ),
                                  filled: true,
                                  fillColor: colorFondoCrema,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 6. OPINIONES DE ESTUDIANTES (CON MODALIDAD ANÓNIMA O PÚBLICA)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Opiniones de estudiantes ⭐',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: colorTextoOscuro,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8F5E9),
                            foregroundColor: colorVerdeTese,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: colorVerdeTese.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          onPressed: _mostrarModalEscribirOpinion,
                          icon: const Icon(
                            Icons.rate_review_outlined,
                            size: 15,
                          ),
                          label: Text(
                            'Dejar opinión',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('Resenas')
                            .where('platilloNombre', isEqualTo: p.nombre)
                            .snapshots(),
                    builder: (context, snap) {
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '🕵️‍♂️',
                                  style: TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Aún no hay opiniones. ¡Sé el primero en opinar con tu nombre o de forma anónima!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: colorTextoGris,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: docs.length > 5 ? 5 : docs.length,
                        itemBuilder: (_, i) {
                          final r = docs[i].data() as Map<String, dynamic>;
                          final int est = (r['estrellas'] ?? 5) as int;
                          final String autorRaw =
                              (r['alumno'] ?? 'Estudiante TESE').toString();
                          final bool esAnon =
                              r['esAnonimo'] == true ||
                              autorRaw.toLowerCase().contains('anónimo') ||
                              autorRaw.toLowerCase().contains('anonimo');
                          final String nombreMostrar =
                              esAnon ? 'Estudiante Anónimo' : autorRaw;

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
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          esAnon
                                              ? const Color(0xFFF1F5F9)
                                              : const Color(0xFFE8F5E9),
                                      child: Icon(
                                        esAnon
                                            ? Icons.visibility_off_rounded
                                            : Icons.person_rounded,
                                        size: 15,
                                        color:
                                            esAnon
                                                ? const Color(0xFF475569)
                                                : colorVerdeTese,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              nombreMostrar,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.5,
                                                color: colorTextoOscuro,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  esAnon
                                                      ? const Color(0xFFF1F5F9)
                                                      : const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              esAnon ? 'Anónimo' : 'Público',
                                              style: GoogleFonts.poppins(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    esAnon
                                                        ? const Color(
                                                          0xFF475569,
                                                        )
                                                        : colorVerdeTese,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (idx) => Icon(
                                          idx < est
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          color: colorAmarilloTese,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  (r['comentario'] ?? '').toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 7. BARRA INFERIOR FIJA PARA ELEGIR CANTIDAD Y AGREGAR
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorFondoCrema,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed:
                              _cantidad > 1
                                  ? () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _cantidad--);
                                  }
                                  : null,
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            size: 22,
                          ),
                          color: colorVerdeTese,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$_cantidad',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: colorTextoOscuro,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed:
                              _cantidad < _maxStock
                                  ? () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _cantidad++);
                                  }
                                  : null,
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 22,
                          ),
                          color: colorVerdeTese,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hayStock ? colorVerdeTese : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          elevation: hayStock ? 3 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: hayStock ? _confirmarYAgregar : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag_rounded,
                              color: colorAmarilloTese,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                hayStock
                                    ? 'Agregar • \$${subtotal.toStringAsFixed(0)}'
                                    : 'Platillo Agotado',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ilustracionPlatillo(Color acento, IconData icono) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [acento.withValues(alpha: 0.18), Colors.white],
          radius: 0.9,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: acento.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, size: 74, color: acento),
        ),
      ),
    );
  }
}

class _ChipDatoPastel extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color colorIcono;

  const _ChipDatoPastel({
    required this.icono,
    required this.texto,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: colorIcono),
          const SizedBox(width: 5),
          Text(
            texto,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: colorTextoOscuro,
            ),
          ),
        ],
      ),
    );
  }
}

class _PildoraEstadoIngrediente extends StatelessWidget {
  final String etiqueta;
  final bool seleccionado;
  final Color colorFondoActivo;
  final VoidCallback onTap;

  const _PildoraEstadoIngrediente({
    required this.etiqueta,
    required this.seleccionado,
    required this.colorFondoActivo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: seleccionado ? colorFondoActivo : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? colorFondoActivo : Colors.grey.shade300,
            width: seleccionado ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            etiqueta,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: seleccionado ? Colors.white : colorTextoGris,
            ),
          ),
        ),
      ),
    );
  }
}
