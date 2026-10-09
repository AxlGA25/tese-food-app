import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_menu.dart';

class PantallaDetallePlatillo extends StatefulWidget {
  final Platillo platillo;
  final void Function(Platillo) onAgregar;
  const PantallaDetallePlatillo({
    super.key,
    required this.platillo,
    required this.onAgregar,
  });

  @override
  State<PantallaDetallePlatillo> createState() =>
      _PantallaDetallePlatilloState();
}

class _PantallaDetallePlatilloState extends State<PantallaDetallePlatillo> {
  int cantidad = 1;
  int _fotoActualIndex = 0;
  // 0 = Normal (Verde), 1 = Sin (Rojo), 2 = Extra (Amarillo)
  Map<String, int> estadoIngredientes = {};

  @override
  void initState() {
    super.initState();
    for (var ing in widget.platillo.ingredientes) {
      estadoIngredientes[ing] = 0;
    }
  }

  Widget _botonCircular({
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icono, color: colorTextoOscuro, size: 20),
      ),
    );
  }

  Widget _chipInfo(IconData icono, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: colorTextoOscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonCantidad(IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorFondoCrema,
          shape: BoxShape.circle,
          border: Border.all(color: colorTextoGris.withValues(alpha: 0.3)),
        ),
        child: Icon(icono, size: 18, color: colorTextoOscuro),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platillo = widget.platillo;
    final acento = acentoDeCategoria(platillo.categoria);
    final total = platillo.precio * cantidad;
    final bool tieneFotos = platillo.fotos.isNotEmpty;

    return Scaffold(
      backgroundColor: colorFondoCrema,
      body: Column(
        children: [
          // ==========================================
          // 📸 HEADER CON FOTOS DESLIZABLES O ÍCONO
          // ==========================================
          Stack(
            children: [
              Container(
                height: 260,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  child:
                      tieneFotos
                          ? PageView.builder(
                            itemCount: platillo.fotos.length,
                            onPageChanged:
                                (i) => setState(() => _fotoActualIndex = i),
                            itemBuilder: (context, index) {
                              return Image.memory(
                                base64Decode(platillo.fotos[index]),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 260,
                              );
                            },
                          )
                          : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  acento,
                                  acento.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                            child: Center(
                              child: ZoomIn(
                                child: Container(
                                  padding: const EdgeInsets.all(26),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    platillo.icono,
                                    size: 70,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                ),
              ),

              // INDICADOR DE FOTOS (1/3, 2/3) SI TIENE MÁS DE UNA
              if (tieneFotos && platillo.fotos.length > 1)
                Positioned(
                  bottom: 16,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_fotoActualIndex + 1} / ${platillo.fotos.length}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // BOTONES SUPERIORES (REGRESAR Y POPULAR)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _botonCircular(
                        icono: Icons.arrow_back,
                        onTap: () => Navigator.pop(context, false),
                      ),
                      if (platillo.popular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            '🔥 Popular',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorTextoOscuro,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ==========================================
          // DETALLE Y PERSONALIZACIÓN DE INGREDIENTES
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          platillo.nombre,
                          style: GoogleFonts.poppins(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: colorTextoOscuro,
                          ),
                        ),
                      ),
                      Text(
                        '\$${platillo.precio.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: acento,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        size: 15,
                        color: colorTextoGris,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        platillo.local,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: colorTextoGris,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _chipInfo(
                        Icons.star_rounded,
                        platillo.calificacion <= 0
                            ? 'Nuevo ✨'
                            : '${platillo.calificacion.toStringAsFixed(1)} ★',
                        colorAmarilloTese,
                      ),
                      _chipInfo(
                        Icons.schedule,
                        platillo.tiempoPrep,
                        colorVerdeTese,
                      ),
                      _chipInfo(Icons.local_offer, platillo.categoria, acento),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Descripción',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    platillo.descripcion.isEmpty
                        ? 'Delicioso, recién preparado para ti.'
                        : platillo.descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: colorTextoGris,
                      height: 1.5,
                    ),
                  ),

                  // INGREDIENTES PERSONALIZABLES
                  if (platillo.ingredientes.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Personaliza tu platillo',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorTextoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca para cambiar: Normal ➔ Sin ➔ Extra',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colorTextoGris,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          platillo.ingredientes.map((ing) {
                            int estado = estadoIngredientes[ing] ?? 0;
                            Color color =
                                estado == 0
                                    ? colorExito
                                    : (estado == 1
                                        ? Colors.redAccent
                                        : colorAmarilloTese);
                            IconData icono =
                                estado == 0
                                    ? Icons.check
                                    : (estado == 1 ? Icons.close : Icons.add);
                            String prefijo =
                                estado == 0
                                    ? ''
                                    : (estado == 1 ? 'Sin ' : 'Extra ');
                            bool tachado = estado == 1;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  estadoIngredientes[ing] = (estado + 1) % 3;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icono, size: 14, color: color),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$prefijo$ing',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        decoration:
                                            tachado
                                                ? TextDecoration.lineThrough
                                                : null,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],

                  const SizedBox(height: 22),
                  const Divider(),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cantidad',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorTextoOscuro,
                        ),
                      ),
                      Row(
                        children: [
                          _botonCantidad(Icons.remove, () {
                            if (cantidad > 1) {
                              setState(() => cantidad--);
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              '$cantidad',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorTextoOscuro,
                              ),
                            ),
                          ),
                          _botonCantidad(
                            Icons.add,
                            () => setState(() => cantidad++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // BOTÓN AGREGAR AL CARRITO
          Container(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acento,
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    List<String> personalizacionFinal = [];
                    estadoIngredientes.forEach((ing, estado) {
                      if (estado == 1) personalizacionFinal.add('Sin $ing');
                      if (estado == 2) personalizacionFinal.add('Extra $ing');
                    });

                    final platilloPersonalizado = widget.platillo.copyWith(
                      personalizacion: personalizacionFinal,
                    );

                    for (int i = 0; i < cantidad; i++) {
                      widget.onAgregar(platilloPersonalizado);
                    }
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Agregar • \$${total.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: colorTextoSobreAcento(acento),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
